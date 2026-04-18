import OpenAI from "openai";

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const cache = globalThis.__supplierScanCache || new Map();
const rateLimits = globalThis.__supplierRateLimits || new Map();
globalThis.__supplierScanCache = cache;
globalThis.__supplierRateLimits = rateLimits;

const CACHE_TTL_MS = 24 * 60 * 60 * 1000;
const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000;
const RATE_LIMIT_MAX = 10;

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

function normalizeUrl(url) {
  const parsed = new URL(url);
  parsed.hash = "";
  return parsed.toString();
}

function getCacheKey(url) {
  const parsed = new URL(url);
  return parsed.hostname.replace(/^www\./, "");
}

function getClientIp(req) {
  const forwarded = req.headers["x-forwarded-for"];
  if (typeof forwarded === "string" && forwarded.length > 0) {
    return forwarded.split(",")[0].trim();
  }
  return "unknown";
}

function checkRateLimit(ip) {
  const now = Date.now();
  const existing = rateLimits.get(ip);

  if (!existing || now > existing.resetAt) {
    rateLimits.set(ip, { count: 1, resetAt: now + RATE_LIMIT_WINDOW_MS });
    return { allowed: true, remaining: RATE_LIMIT_MAX - 1 };
  }

  if (existing.count >= RATE_LIMIT_MAX) {
    return { allowed: false, retryAfterMs: existing.resetAt - now };
  }

  existing.count += 1;
  rateLimits.set(ip, existing);
  return { allowed: true, remaining: RATE_LIMIT_MAX - existing.count };
}

function getCachedResult(key) {
  const entry = cache.get(key);
  if (!entry) {
    return null;
  }

  if (Date.now() > entry.expiresAt) {
    cache.delete(key);
    return null;
  }

  return entry.payload;
}

function setCachedResult(key, payload) {
  cache.set(key, {
    payload,
    expiresAt: Date.now() + CACHE_TTL_MS
  });
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
    const normalizedUrl = normalizeUrl(url);
    const cacheKey = getCacheKey(normalizedUrl);
    const cached = getCachedResult(cacheKey);
    if (cached) {
      return res.status(200).json({
        ...cached,
        cache: "hit"
      });
    }

    const ip = getClientIp(req);
    const rateLimit = checkRateLimit(ip);
    if (!rateLimit.allowed) {
      return res.status(429).json({
        error: "Rate limit exceeded",
        details: "Too many scans from this IP. Please try again later."
      });
    }

    const response = await fetch(normalizedUrl, {
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

    const payload = {
      ...parsed,
      cache: "miss"
    };
    setCachedResult(cacheKey, payload);

    return res.status(200).json(payload);
  } catch (error) {
    return res.status(500).json({
      error: "Scan failed",
      details: error.message || "Unknown server error"
    });
  }
}
