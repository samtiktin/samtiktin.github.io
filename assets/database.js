(function () {
  var grid = document.getElementById("db-grid");
  if (!grid) return;

  var cards = Array.prototype.slice.call(grid.querySelectorAll(".db-card"));
  var els = {
    q: document.getElementById("db-q"),
    compound: document.getElementById("db-compound"),
    price: document.getElementById("db-price"),
    coa: document.getElementById("db-coa"),
    ships: document.getElementById("db-ships"),
    country: document.getElementById("db-country"),
    ordered: document.getElementById("db-ordered"),
    code: document.getElementById("db-code"),
    sort: document.getElementById("db-sort")
  };
  var countEl = document.getElementById("db-count");
  var emptyEl = document.getElementById("db-empty");
  var total = cards.length;

  function readParams() {
    var p = new URLSearchParams(window.location.search);
    els.q.value = p.get("q") || "";
    ["compound", "price", "coa", "ships", "country", "sort"].forEach(function (k) {
      var v = p.get(k);
      if (v) els[k].value = v;
    });
    els.ordered.checked = p.get("ordered") === "1";
    els.code.checked = p.get("code") === "1";
  }

  function writeParams() {
    var p = new URLSearchParams();
    if (els.q.value.trim()) p.set("q", els.q.value.trim());
    ["compound", "price", "coa", "ships", "country"].forEach(function (k) {
      if (els[k].value) p.set(k, els[k].value);
    });
    if (els.ordered.checked) p.set("ordered", "1");
    if (els.code.checked) p.set("code", "1");
    if (els.sort.value && els.sort.value !== "rating") p.set("sort", els.sort.value);
    var qs = p.toString();
    history.replaceState(null, "", window.location.pathname + (qs ? "?" + qs : ""));
  }

  function matches(card) {
    var q = els.q.value.trim().toLowerCase();
    var d = card.dataset;
    if (q) {
      var words = q.split(/\s+/);
      for (var i = 0; i < words.length; i++) {
        if (d.text.indexOf(words[i]) === -1 && d.compounds.indexOf(words[i]) === -1) return false;
      }
    }
    if (els.compound.value && d.compounds.split("|").indexOf(els.compound.value) === -1) return false;
    if (els.price.value && d.price !== els.price.value) return false;
    if (els.coa.value && d.coa !== els.coa.value) return false;
    if (els.ships.value && d.ships !== els.ships.value) return false;
    if (els.country.value && d.country !== els.country.value) return false;
    if (els.ordered.checked && d.ordered !== "1") return false;
    if (els.code.checked && d.code !== "1") return false;
    return true;
  }

  function sorter(a, b) {
    var s = els.sort.value;
    if (s === "name") return a.dataset.name.localeCompare(b.dataset.name);
    if (s === "price") {
      return (Number(a.dataset.priceorder) - Number(b.dataset.priceorder)) || a.dataset.name.localeCompare(b.dataset.name);
    }
    return (Number(b.dataset.rating) - Number(a.dataset.rating)) || a.dataset.name.localeCompare(b.dataset.name);
  }

  function update() {
    var visible = 0;
    cards.sort(sorter).forEach(function (card) {
      var show = matches(card);
      card.hidden = !show;
      if (show) visible++;
      grid.appendChild(card);
    });
    countEl.textContent = visible === total
      ? "Showing all " + total + " suppliers"
      : "Showing " + visible + " of " + total + " suppliers";
    emptyEl.hidden = visible !== 0;
    writeParams();
  }

  Object.keys(els).forEach(function (k) {
    els[k].addEventListener(k === "q" ? "input" : "change", update);
  });

  document.getElementById("db-reset").addEventListener("click", function () {
    els.q.value = "";
    ["compound", "price", "coa", "ships", "country"].forEach(function (k) { els[k].value = ""; });
    els.ordered.checked = false;
    els.code.checked = false;
    els.sort.value = "rating";
    update();
  });

  readParams();
  update();
})();
