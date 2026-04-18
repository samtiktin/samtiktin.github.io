(function () {
  window.VERIFY_API_ENDPOINT = "https://samtiktin-github-io.vercel.app/api/verify";

  var form = document.getElementById("verify-form");
  var statusBox = document.getElementById("scan-status");
  var results = document.getElementById("verify-results");

  function setStatus(message, isError) {
    statusBox.hidden = false;
    statusBox.className = isError ? "status-box error" : "status-box";
    statusBox.textContent = message;
  }

  function renderList(targetId, items) {
    var target = document.getElementById(targetId);
    target.innerHTML = "";
    (items || []).forEach(function (item) {
      var li = document.createElement("li");
      li.textContent = item;
      target.appendChild(li);
    });
  }

  function renderResult(payload) {
    document.getElementById("result-label").textContent = payload.label || "Mixed signals";
    document.getElementById("result-score").textContent = (payload.score || 0) + "/100";
    document.getElementById("result-pill").textContent = payload.band || "Trust signal scan";
    document.getElementById("result-summary").textContent = payload.summary || "";
    renderList("result-found", payload.found || []);
    renderList("result-missing", payload.missing || []);
    renderList("result-notes", payload.notes || []);
    results.hidden = false;
  }

  function buildFallback(url) {
    return {
      label: "Backend not connected",
      band: "Setup needed",
      score: 0,
      summary: "The frontend page is live, but the live scanner API has not been connected yet for " + url + ". Deploy the backend starter and connect the API endpoint to enable real scans.",
      found: [
        "Frontend verify page is ready on the site",
        "Result layout and rubric are already wired",
        "Backend starter files can be deployed from GitHub to Vercel"
      ],
      missing: [
        "No live scan endpoint is configured yet",
        "OpenAI API key still needs to be added in the backend host",
        "Cross-site fetch and analysis must run outside GitHub Pages"
      ],
      notes: [
        "Use the starter backend in /verifier-backend",
        "Once deployed, point this page at your backend URL",
        "Then the scanner can evaluate visible trust signals automatically"
      ]
    };
  }

  async function runScan(url, notes) {
    var endpoint = window.VERIFY_API_ENDPOINT || "/api/verify";
    var response = await fetch(endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        url: url,
        notes: notes || ""
      })
    });

    if (!response.ok) {
      throw new Error("Scan request failed");
    }

    return response.json();
  }

  form.addEventListener("submit", async function (event) {
    event.preventDefault();

    var url = document.getElementById("supplier-url").value.trim();
    var notes = document.getElementById("scan-notes").value.trim();

    setStatus("Running trust signal scan...", false);
    results.hidden = true;

    try {
      var payload = await runScan(url, notes);
      renderResult(payload);
      setStatus("Scan complete.", false);
    } catch (error) {
      renderResult(buildFallback(url));
      setStatus("The live scanner API is not connected yet, so the page is showing the setup fallback. Deploy the backend starter next.", true);
    }
  });
})();
