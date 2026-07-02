(function () {
  var suppliers = window.SUPPLIER_DIRECTORY || [];
  var form = document.getElementById("supplier-filters");
  var results = document.getElementById("supplier-results");
  var summary = document.getElementById("results-summary");
  var searchInput = document.getElementById("search-input");
  var comparePanel = document.getElementById("compare-panel");
  var compareSummary = document.getElementById("compare-summary");
  var compareChips = document.getElementById("compare-chips");
  var compareHeadRow = document.getElementById("compare-head-row");
  var compareBody = document.getElementById("compare-body");
  var clearCompareButton = document.getElementById("clear-compare");
  var compareLimit = 3;

  function getQueryFilters() {
    var params = new URLSearchParams(window.location.search);
    return {
      q: (params.get("q") || "").trim(),
      price: params.get("price") || "",
      coa: params.get("coa") || "",
      location: params.get("location") || "",
      shipping: params.get("shipping") || "",
      fit: params.get("fit") || "",
      compare: (params.get("compare") || "").split(",").map(function (value) {
        return value.trim();
      }).filter(Boolean)
    };
  }

  var compareSlugs = getQueryFilters().compare.filter(function (slug, index, values) {
    return values.indexOf(slug) === index;
  }).slice(0, compareLimit);

  function applyQueryToForm() {
    var filters = getQueryFilters();
    Object.keys(filters).forEach(function (key) {
      if (key !== "compare" && form.elements[key]) {
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

    var actions = supplier.reviewUrl
      ? '<a class="button button-ghost" href="' + supplier.reviewUrl + '">Read review</a>'
      : '<span class="finder-note">Directory listing</span>';

    var isSelected = compareSlugs.indexOf(supplier.slug) !== -1;
    var compareLabel = isSelected ? "Remove from compare" : "Compare supplier";
    var compareClass = isSelected ? "button button-secondary compare-toggle is-selected" : "button button-ghost compare-toggle";

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
        '<button class="' + compareClass + '" type="button" data-compare-slug="' + supplier.slug + '">' + compareLabel + '</button>' +
        actions +
        '<a class="button button-primary" href="' + supplier.supplierUrl + '" target="_blank" rel="noopener noreferrer">Visit supplier</a>' +
      '</div>';

    return card;
  }

  function getSupplierBySlug(slug) {
    return suppliers.find(function (supplier) {
      return supplier.slug === slug;
    });
  }

  function renderCompare() {
    var selectedSuppliers = compareSlugs.map(getSupplierBySlug).filter(Boolean);
    comparePanel.hidden = !selectedSuppliers.length;

    if (!selectedSuppliers.length) {
      compareChips.innerHTML = "";
      compareHeadRow.innerHTML = "<th>Category</th>";
      compareBody.innerHTML = "";
      return;
    }

    compareSummary.textContent = selectedSuppliers.length + " supplier" + (selectedSuppliers.length === 1 ? "" : "s") + " in comparison. Add up to " + compareLimit + " to compare key buying signals side by side.";

    compareChips.innerHTML = selectedSuppliers.map(function (supplier) {
      return '<button class="compare-chip" type="button" data-remove-compare="' + supplier.slug + '">' + supplier.name + ' <span aria-hidden="true">&times;</span></button>';
    }).join("");

    compareHeadRow.innerHTML = "<th>Category</th>" + selectedSuppliers.map(function (supplier) {
      return "<th>" + supplier.name + "</th>";
    }).join("");

    var rows = [
      ["Best for", "bestFor"],
      ["Price tier", "priceLabel"],
      ["Testing visibility", "coaLabel"],
      ["Shipping", "shippingLabel"],
      ["Location", "locationLabel"],
      ["Ships beyond US", function (supplier) {
        if (supplier.shipsOutsideUS === true) return "Yes";
        if (supplier.shipsOutsideUS === false) return "No";
        return "Not clearly stated";
      }],
      ["Common compounds", function (supplier) {
        return (supplier.compounds || []).join(", ");
      }],
      ["Discount code", function (supplier) {
        return supplier.discountCode || "None listed";
      }],
      ["Review page", function (supplier) {
        return supplier.reviewUrl
          ? '<a href="' + supplier.reviewUrl + '">Read review</a>'
          : "No review page";
      }],
      ["Visit supplier", function (supplier) {
        return '<a href="' + supplier.supplierUrl + '" target="_blank" rel="noopener noreferrer">Visit supplier</a>';
      }]
    ];

    compareBody.innerHTML = rows.map(function (row) {
      var label = row[0];
      var getter = row[1];
      var cells = selectedSuppliers.map(function (supplier) {
        var value = typeof getter === "function" ? getter(supplier) : supplier[getter];
        return "<td>" + value + "</td>";
      }).join("");
      return "<tr><th>" + label + "</th>" + cells + "</tr>";
    }).join("");
  }

  function syncUrl(filters) {
    var params = new URLSearchParams();
    Object.keys(filters).forEach(function (key) {
      if (filters[key]) {
        params.set(key, filters[key]);
      }
    });
    if (compareSlugs.length) {
      params.set("compare", compareSlugs.join(","));
    }
    var nextUrl = window.location.pathname + (params.toString() ? "?" + params.toString() : "");
    window.history.replaceState({}, "", nextUrl);
  }

  function toggleCompare(slug) {
    var index = compareSlugs.indexOf(slug);
    if (index !== -1) {
      compareSlugs.splice(index, 1);
      return;
    }
    if (compareSlugs.length >= compareLimit) {
      window.alert("You can compare up to " + compareLimit + " suppliers at a time.");
      return;
    }
    compareSlugs.push(slug);
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
      renderCompare();
      syncUrl(filters);
      return;
    }

    filtered.forEach(function (supplier) {
      results.appendChild(makeCard(supplier));
    });

    renderCompare();
    syncUrl(filters);
  }

  applyQueryToForm();
  render();

  form.addEventListener("input", render);
  form.addEventListener("change", render);
  form.addEventListener("reset", function () {
    window.setTimeout(render, 0);
  });

  results.addEventListener("click", function (event) {
    var button = event.target.closest("[data-compare-slug]");
    if (!button) {
      return;
    }
    toggleCompare(button.getAttribute("data-compare-slug"));
    render();
  });

  compareChips.addEventListener("click", function (event) {
    var button = event.target.closest("[data-remove-compare]");
    if (!button) {
      return;
    }
    compareSlugs = compareSlugs.filter(function (slug) {
      return slug !== button.getAttribute("data-remove-compare");
    });
    render();
  });

  if (clearCompareButton) {
    clearCompareButton.addEventListener("click", function () {
      compareSlugs = [];
      render();
    });
  }

  if (searchInput && !searchInput.value) {
    searchInput.focus();
  }
})();
