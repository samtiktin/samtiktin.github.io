import OpenAI from "openai";

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

function extractSignals(html) {
  const lower = html.toLowerCase();

  const checks = [
    { key: "coa", label: "COA or certificate mentions", pass: /coa|certificate of analysis/.test(lower) },
    { key: "thirdParty", label: "Third-party testing language", pass: /third-party|third party|lab-tested|lab tested/.test(lower) },
    { key: "ruo", label: "Research-use-only language", pass: /research use only|for research use only|ruo/.test(lower) },
    { key: "contact", label: "Contact information", pass: /contact|@|mailto:/.test(lower) },
    { key: "privacy", label: "Privacy page mention", pass: /privacy/.test(lower) },
    { key: "shipping", label: "Shipping or policy language", pass: /shipping|returns|refund/.test(lower) }
  ];

  return checks;
}

function stripHtml(html) {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 12000);
}

export default async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  if (req.method === "GET") {
    return res.status(200).json({
      ok: true,
      message: "Verifier API is live. Use POST to submit a supplier URL.",
      hasOpenAIKey: Boolean(process.env.OPENAI_API_KEY)
    });
  }

  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  const { url, notes = "" } = req.body || {};

  if (!url) {
    return res.status(400).json({ error: "URL is required" });
  }

  if (!process.env.OPENAI_API_KEY) {
    return res.status(500).json({
      error: "Missing OPENAI_API_KEY",
      details: "The Vercel project does not have a readable OPENAI_API_KEY environment variable in the current deployment."
    });
  }

  try {
    const response = await fetch(url, {
      headers: {
        "User-Agent": "PeptideSuppliersTrustScanner/1.0"
      }
    });

    const html = await response.text();
    const text = stripHtml(html);
    const signals = extractSignals(html);

    const prompt = [
      "You are analyzing a peptide supplier website for visible trust signals only.",
      "Do not claim the supplier is safe, legitimate, or verified.",
      "Return JSON with keys: label, band, score, summary, found, missing, notes.",
      "Score only visible site trust signals from 0-100.",
      "Bands should be one of: Strong, Mixed, Weak.",
      "Found, missing, and notes must each be arrays of short strings.",
      "",
      "Visible checks:",
      JSON.stringify(signals),
      "",
      "User notes:",
      notes,
      "",
      "Page text:",
      text
    ].join("\n");

    const completion = await client.responses.create({
      model: "gpt-5-mini",
      input: prompt
    });

    const raw = completion.output_text || "{}";
    let parsed;

    try {
      parsed = JSON.parse(raw);
    } catch {
      parsed = {
        label: "Mixed signals",
        band: "Mixed",
        score: 50,
        summary: "The page was scanned, but the AI response was not returned in the expected JSON format.",
        found: signals.filter((signal) => signal.pass).map((signal) => signal.label),
        missing: signals.filter((signal) => !signal.pass).map((signal) => signal.label),
        notes: ["Review the backend prompt or JSON parsing rules."]
      };
    }

    return res.status(200).json(parsed);
  } catch (error) {
    return res.status(500).json({
      error: "Scan failed",
      details: error.message || "Unknown server error"
    });
  }
}
