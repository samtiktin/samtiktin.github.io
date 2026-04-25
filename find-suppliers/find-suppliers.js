(function () {
  var suppliers = window.SUPPLIER_DIRECTORY || [];
  var form = document.getElementById("supplier-filters");
  var results = document.getElementById("supplier-results");
  var summary = document.getElementById("results-summary");
  var searchInput = document.getElementById("search-input");

  function getQueryFilters() {
    var params = new URLSearchParams(window.location.search);
    return {
      q: (params.get("q") || "").trim(),
      price: params.get("price") || "",
      coa: params.get("coa") || "",
      location: params.get("location") || "",
      shipping: params.get("shipping") || "",
      fit: params.get("fit") || ""
    };
  }

  function applyQueryToForm() {
    var filters = getQueryFilters();
    Object.keys(filters).forEach(function (key) {
      if (form.elements[key]) {
        form.elements[key].value = filters[key];
      }
    });
  }

  function matchesFilter(supplier, filters) {
    var haystack = [
      supplier.name,
      supplier.bestFor,
      supplier.locationLabel,
      supplier.shippingLabel,
      supplier.notes
    ].concat(supplier.compounds || []).join(" ").toLowerCase();

    if (filters.q && haystack.indexOf(filters.q.toLowerCase()) === -1) {
      return false;
    }
    if (filters.price && supplier.priceTier !== filters.price) {
      return false;
    }
    if (filters.coa && !(supplier.coaLevel === filters.coa || (filters.coa === "visible" && supplier.coaLevel === "strong"))) {
      return false;
    }
    if (filters.location && supplier.location !== filters.location) {
      return false;
    }
    if (filters.shipping === "fast" && supplier.shippingLabel.toLowerCase().indexOf("fast") === -1 && supplier.shippingLabel.indexOf("48 hours") === -1 && supplier.shippingLabel.indexOf("0-2") === -1 && supplier.shippingLabel.indexOf("1-3") === -1) {
      return false;
    }
    if (filters.shipping === "outside-us" && supplier.shipsOutsideUS !== true) {
      return false;
    }
    if (filters.fit && supplier.bestFor !== filters.fit) {
      return false;
    }
    return true;
  }

  function makeCard(supplier) {
    var card = document.createElement("article");
    card.className = "finder-card";

    var chips = [
      supplier.priceLabel,
      supplier.coaLabel,
      supplier.locationLabel
    ];

    if (supplier.discountCode) {
      chips.push("Code: " + supplier.discountCode);
    }

    if (supplier.affiliateReady) {
      chips.push(supplier.affiliateLabel);
    }

    var actions = supplier.reviewUrl
      ? '<a class="button button-ghost" href="' + supplier.reviewUrl + '">Read review</a>'
      : '<span class="finder-note">Directory listing</span>';

    card.innerHTML =
      '<div class="kicker">Supplier match</div>' +
      '<h3>' + supplier.name + '</h3>' +
      '<p>' + supplier.notes + '</p>' +
      '<div class="pill-row">' + chips.map(function (chip) {
        return '<span class="pill">' + chip + '</span>';
      }).join("") + "</div>" +
      '<div class="finder-meta">' +
        '<div><strong>Best for</strong><span>' + supplier.bestFor + '</span></div>' +
        '<div><strong>Shipping</strong><span>' + supplier.shippingLabel + '</span></div>' +
      '</div>' +
      '<div class="finder-compounds"><strong>Common compounds:</strong> ' + supplier.compounds.join(", ") + '</div>' +
      '<div class="button-row">' +
        actions +
        '<a class="button button-primary" href="' + supplier.supplierUrl + '" target="_blank" rel="noopener noreferrer">Visit supplier</a>' +
      '</div>';

    return card;
  }

  function render() {
    var filters = {
      q: (form.elements.q.value || "").trim(),
      price: form.elements.price.value || "",
      coa: form.elements.coa.value || "",
      location: form.elements.location.value || "",
      shipping: form.elements.shipping.value || "",
      fit: form.elements.fit.value || ""
    };

    var filtered = suppliers.filter(function (supplier) {
      return matchesFilter(supplier, filters);
    });

    results.innerHTML = "";
    summary.textContent = filtered.length + " supplier" + (filtered.length === 1 ? "" : "s") + " matched the current filters.";

    if (!filtered.length) {
      var empty = document.createElement("article");
      empty.className = "card";
      empty.innerHTML = "<h3>No exact matches yet</h3><p>Try widening the price or location filters, or search by a compound like BPC-157, GHK-Cu, or TB-500.</p>";
      results.appendChild(empty);
      return;
    }

    filtered.forEach(function (supplier) {
      results.appendChild(makeCard(supplier));
    });

    var params = new URLSearchParams();
    Object.keys(filters).forEach(function (key) {
      if (filters[key]) {
        params.set(key, filters[key]);
      }
    });
    var nextUrl = window.location.pathname + (params.toString() ? "?" + params.toString() : "");
    window.history.replaceState({}, "", nextUrl);
  }

  applyQueryToForm();
  render();

  form.addEventListener("input", render);
  form.addEventListener("change", render);
  form.addEventListener("reset", function () {
    window.setTimeout(render, 0);
  });

  if (searchInput && !searchInput.value) {
    searchInput.focus();
  }
})();
