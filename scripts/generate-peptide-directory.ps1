$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot "data\peptides.json"
$directoryPath = Join-Path $repoRoot "peptide-directory\index.html"
$peptidesRoot = Join-Path $repoRoot "peptides"
$stylesVersion = "20260518a"

function Get-SiteUrl {
  $cnamePath = Join-Path $repoRoot "CNAME"
  if (Test-Path $cnamePath) {
    $cname = (Get-Content $cnamePath -Raw).Trim()
    if ($cname) {
      return "https://$cname"
    }
  }

  return "https://peptidesuppliers.org"
}

function HtmlEncode([string]$value) {
  return [System.Net.WebUtility]::HtmlEncode($value)
}

function JsonText([object]$value) {
  return $value | ConvertTo-Json -Depth 8 -Compress
}

function Get-DiscountCode([string]$supplier) {
  switch ($supplier) {
    "Iron Peptides" { return "IRONMAN" }
    "Pinnacle Peptide Labs" { return "PPL15" }
    "Peptides Kingdom" { return "KING15" }
    "Ascension Peptides" { return "PEPTIDE10" }
    "Amino Club" { return "AMINOSAVE" }
    default { return $null }
  }
}

function Get-DiscountPercent([string]$supplier) {
  switch ($supplier) {
    "Iron Peptides" { return "10%" }
    "Pinnacle Peptide Labs" { return "15%" }
    "Peptides Kingdom" { return "15%" }
    "Ascension Peptides" { return "20%" }
    "Amino Club" { return "20%" }
    default { return $null }
  }
}

function Get-Bool([string]$value) {
  if (-not $value) { return $false }
  return $value.Trim().ToLower() -eq "true"
}

function Get-CardSummary([string]$text) {
  if ([string]::IsNullOrWhiteSpace($text)) { return "" }
  $clean = $text.Trim()
  if ($clean.Length -le 140) { return $clean }

  $sentenceMatch = [regex]::Match($clean, '^.{1,140}?(?:\.)')
  if ($sentenceMatch.Success -and $sentenceMatch.Value.Length -ge 70) {
    return $sentenceMatch.Value.Trim()
  }

  $truncated = $clean.Substring(0, 137).TrimEnd()
  $lastSpace = $truncated.LastIndexOf(' ')
  if ($lastSpace -gt 80) {
    $truncated = $truncated.Substring(0, $lastSpace).TrimEnd()
  }

  return ($truncated + "...")
}

function Get-WhatItIs($peptide) {
  if (-not [string]::IsNullOrWhiteSpace($peptide.what_it_is)) {
    return [string]$peptide.what_it_is
  }
  return [string]$peptide.short_educational_description
}

function Get-ResearchOverview($peptide, [string]$fallback) {
  if (-not [string]::IsNullOrWhiteSpace($peptide.concise_research_overview)) {
    return [string]$peptide.concise_research_overview
  }
  return $fallback
}

function Get-CategoryMeta($key) {
  switch ($key) {
    "glp-metabolic" { return @{ title = "GLP and metabolic research compounds"; blurb = "Research compounds commonly referenced in metabolic and incretin science." } }
    "growth-secretagogue" { return @{ title = "Growth hormone secretagogue research compounds"; blurb = "Compounds commonly filed under growth hormone signaling and secretagogue research." } }
    "repair-tissue" { return @{ title = "Repair and tissue research compounds"; blurb = "Pages centered on repair, recovery, and tissue-focused research compounds." } }
    "cognitive-neuropeptide" { return @{ title = "Cognitive and neuropeptide research compounds"; blurb = "Neuropeptide and cognition-focused compounds that appear across signaling and neurobiology coverage." } }
    "longevity-cellular" { return @{ title = "Longevity and cellular research compounds"; blurb = "Compounds commonly referenced in cellular, mitochondrial, and longevity research." } }
    "cosmetic-pigmentation" { return @{ title = "Cosmetic and pigmentation research compounds"; blurb = "Compounds tied to pigmentation, appearance-focused, and melanocortin-related research." } }
    "immune-regulatory" { return @{ title = "Immune and regulatory research compounds"; blurb = "Compounds associated with immune signaling, regulatory pathways, and thymic peptide research." } }
    "blends-protocols" { return @{ title = "Blends and named protocols"; blurb = "Named blends, shorthand listings, and multi-compound pages that need added context." } }
    default { return @{ title = "Research compounds"; blurb = "Compound pages gathered in one place." } }
  }
}

function Get-CategoryPrompt($key) {
  switch ($key) {
    "glp-metabolic" { return "Clear naming matters here. The strongest pages show the compound family plainly and keep documentation easy to find." }
    "growth-secretagogue" { return "These pages should separate signaling terminology from sales language and keep testing notes easy to verify." }
    "repair-tissue" { return "The strongest pages explain the compound plainly and make documentation easier to review than the surrounding marketing." }
    "cognitive-neuropeptide" { return "These pages work best when the wording stays precise and the category fit is easy to follow." }
    "longevity-cellular" { return "These compounds need careful labeling, clear context, and documentation that is easier to verify than the headline copy." }
    "cosmetic-pigmentation" { return "Clear category labels and readable documentation matter more than dramatic appearance language." }
    "immune-regulatory" { return "These pages should make labeling, testing notes, and category fit easy to follow." }
    "blends-protocols" { return "Named blends and shorthand labels should be spelled out clearly, with supporting notes close at hand." }
    default { return "The strongest pages stay specific, readable, and easy to compare with related compounds." }
  }
}

function Get-PeptideIndexable($peptide) {
  $hasFlag = Get-Bool $peptide.index
  $hasDescription = -not [string]::IsNullOrWhiteSpace($peptide.short_educational_description) -and $peptide.short_educational_description.Length -ge 80
  $hasDocs = -not [string]::IsNullOrWhiteSpace($peptide.documentation_focus)
  $hasTransparency = -not [string]::IsNullOrWhiteSpace($peptide.supplier_transparency_notes)
  return $hasFlag -and $hasDescription -and $hasDocs -and $hasTransparency
}

function Get-RelatedPeptides($peptide, $lookup) {
  $rows = @()
  foreach ($slug in $peptide.related_peptides) {
    if ($lookup.ContainsKey($slug)) {
      $rows += $lookup[$slug]
    }
  }
  return $rows
}

function Build-FaqData($peptide, $categoryTitle) {
  return @(
    @{
      "@type" = "Question"
      "name" = "How is $($peptide.name) usually described in research listings?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = (Get-WhatItIs $peptide)
      }
    },
    @{
      "@type" = "Question"
      "name" = "What should stand out on this $($peptide.name) page?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = "$($peptide.documentation_focus) $($peptide.supplier_transparency_notes)"
      }
    },
    @{
      "@type" = "Question"
      "name" = "What else is worth checking before opening a listing?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = "Check whether the compound name is clear, the documentation notes are readable, and the related pages line up with the label on the listing."
      }
    }
  )
}

function Build-BreadcrumbData($siteUrl, $peptide) {
  return @(
    @{ "@type" = "ListItem"; "position" = 1; "name" = "Home"; "item" = "$siteUrl/" },
    @{ "@type" = "ListItem"; "position" = 2; "name" = "Peptide Directory"; "item" = "$siteUrl/peptide-directory/" },
    @{ "@type" = "ListItem"; "position" = 3; "name" = $peptide.name; "item" = "$siteUrl/peptides/$($peptide.slug)/" }
  )
}

function New-DirectoryPage($peptides, $lookup, $siteUrl) {
  $categoryOrder = @(
    "glp-metabolic",
    "growth-secretagogue",
    "repair-tissue",
    "cognitive-neuropeptide",
    "longevity-cellular",
    "cosmetic-pigmentation",
    "immune-regulatory",
    "blends-protocols"
  )

  $navLinks = foreach ($category in $categoryOrder) {
    $meta = Get-CategoryMeta $category
    $anchor = ($category -replace '[^a-z0-9]+', '-')
    "<a href=`"#$anchor`">$([string](HtmlEncode($meta.title)))</a>"
  }

  $sections = foreach ($category in $categoryOrder) {
    $meta = Get-CategoryMeta $category
    $anchor = ($category -replace '[^a-z0-9]+', '-')
    $cards = foreach ($peptide in ($peptides | Where-Object { $_.category -eq $category })) {
      $relatedRows = Get-RelatedPeptides $peptide $lookup
      $whatItIs = Get-WhatItIs $peptide
      $cardSummary = Get-CardSummary $whatItIs
      $relatedLinks = foreach ($related in $relatedRows) {
        "<a class=`"pill`" href=`"/peptides/$($related.slug)/`">$([string](HtmlEncode($related.name)))</a>"
      }
      $supplierButtons = foreach ($supplier in @($peptide.suppliers)) {
        if (-not $supplier) { continue }
        $percent = Get-DiscountPercent $supplier.name
        $code = Get-DiscountCode $supplier.name
        $discountLabel = if ($percent -and $code) { "$percent code: $code" } elseif ($percent) { "$percent discount available" } else { $null }
@"
              <div class="directory-supplier-link">
                <a class="button button-secondary" href="$([string](HtmlEncode($supplier.link)))" target="_blank" rel="sponsored nofollow noopener noreferrer">View supplier listing</a>
                $(if ($discountLabel) { "<span class=`"discount-note`">$([string](HtmlEncode($discountLabel)))</span>" })
              </div>
"@
      }

@"
          <article class="card reveal directory-card" data-name="$([string](HtmlEncode($peptide.name.ToLower())))" data-category="$([string](HtmlEncode($meta.title.ToLower())))" data-description="$([string](HtmlEncode($whatItIs.ToLower())))">
            <div class="review-media">
              <img class="directory-image" src="$([string](HtmlEncode($peptide.image)))" alt="$([string](HtmlEncode($peptide.name))) reference image" loading="lazy">
            </div>
          <div class="kicker">Peptide page</div>
            <h3>$([string](HtmlEncode($peptide.name)))</h3>
            <p>$([string](HtmlEncode($cardSummary)))</p>
            <p class="directory-category-label">$([string](HtmlEncode($meta.title)))</p>
            <div class="pill-row">
$($relatedLinks -join "`n")
            </div>
            <div class="button-row">
$(if ($supplierButtons) { ($supplierButtons -join "`n") })
              <a class="button button-primary" href="/peptides/$($peptide.slug)/">Learn more</a>
            </div>
          </article>
"@
    }

@"
    <section id="$anchor">
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>$([string](HtmlEncode($meta.title)))</h2>
            <p>$([string](HtmlEncode($meta.blurb)))</p>
          </div>
        </div>
        <div class="supplier-grid directory-grid">
$($cards -join "`n")
        </div>
      </div>
    </section>
"@
  }

  return @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Peptide Directory | PeptideSuppliers.org</title>
  <meta name="description" content="Browse a searchable peptide directory with compound pages, documentation notes, related compounds, and linked supplier listings.">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="$siteUrl/peptide-directory/">
  <meta property="og:type" content="website">
  <meta property="og:title" content="Peptide Directory | PeptideSuppliers.org">
  <meta property="og:description" content="Peptide pages grouped by category, documentation notes, and related compounds.">
  <meta property="og:url" content="$siteUrl/peptide-directory/">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="$siteUrl/og-image.svg">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="Peptide Directory | PeptideSuppliers.org">
  <meta name="twitter:description" content="Peptide pages grouped by category, documentation notes, and related compounds.">
  <meta name="twitter:image" content="$siteUrl/og-image.svg">
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <link rel="stylesheet" href="/styles.css?v=$stylesVersion">
</head>
<body>
  <header class="topbar">
    <div class="shell topbar-inner">
      <a class="brand" href="/">
        <span class="brand-mark">PS</span>
        <span class="brand-copy">
          <strong>PeptideSuppliers.org</strong>
          <span>Research supplier discovery and education</span>
        </span>
      </a>
      <nav class="nav" aria-label="Primary">
        <a href="/">Home</a>
        <a href="/about/">About</a>
        <a href="/faq/">FAQ</a>
        <a href="/education/">Education</a>
        <a href="/suppliers/">Suppliers</a>
        <a href="/reviews/">Reviews</a>
        <a class="active" href="/peptide-directory/">Directory</a>
        <a href="/verify/">Verify</a>
        <a href="/contact/">Contact</a>
      </nav>
    </div>
  </header>

  <main>
    <section class="page-hero">
      <div class="shell">
        <div class="page-hero-card">
          <div class="page-hero-grid">
            <div class="page-hero-copy reveal">
              <div class="eyebrow">Peptide directory</div>
              <h1 class="page-title">Peptide Directory</h1>
              <p>
                Browse compound pages, compare related entries, and open linked supplier listings from one directory.
              </p>
              <div class="button-row">
                <a class="button button-primary" href="#directory-search">Search the directory</a>
                <a class="button button-ghost" href="/education/">Open education hub</a>
              </div>
            </div>
            <div class="hero-art reveal delay-1">
              <img src="/assets/directory-compounds.svg" alt="Editorial illustration representing grouped peptide categories">
            </div>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="notice reveal">
          <div class="kicker">Educational disclaimer</div>
          <h3>Informational reference only</h3>
          <p>This page is for educational and informational purposes only. PeptideSuppliers.org does not sell peptides, provide medical advice, or recommend human use.</p>
        </div>
      </div>
    </section>

    <section id="directory-search">
      <div class="shell">
        <div class="jump-nav sticky-directory-nav reveal">
          <strong>Jump to a category</strong>
          <div class="jump-links">
$($navLinks -join "`n            ")
          </div>
          <div class="directory-search">
            <label class="sr-only" for="peptide-directory-search">Search the peptide directory</label>
            <input id="peptide-directory-search" type="search" placeholder="Search compounds, categories, or related names">
          </div>
        </div>
      </div>
    </section>

$($sections -join "`n")
  </main>

  <footer class="footer">
    <div class="shell footer-row">
      <span>&copy; 2026 PeptideSuppliers.org</span>
      <div class="footer-links">
        <a href="/peptide-directory/">Peptide Directory</a>
        <a href="/education/">Education</a>
        <a href="/privacy/">Privacy</a>
      </div>
    </div>
  </footer>

  <script>
    (function () {
      const input = document.getElementById('peptide-directory-search');
      if (!input) return;
      const sections = Array.from(document.querySelectorAll('.directory-grid'));
      const cards = Array.from(document.querySelectorAll('.directory-card'));

      function applyFilter() {
        const value = input.value.trim().toLowerCase();
        cards.forEach((card) => {
          const haystack = [
            card.dataset.name || '',
            card.dataset.category || '',
            card.dataset.description || '',
            card.textContent || ''
          ].join(' ').toLowerCase();
          const match = !value || haystack.includes(value);
          card.style.display = match ? '' : 'none';
        });

        sections.forEach((grid) => {
          const visibleCards = Array.from(grid.children).some((card) => card.style.display !== 'none');
          const section = grid.closest('section');
          if (section) {
            section.style.display = visibleCards ? '' : 'none';
          }
        });
      }

      input.addEventListener('input', applyFilter);
    }());
  </script>
</body>
</html>
"@
}

function New-PeptidePage($peptide, $lookup, $siteUrl) {
  $categoryMeta = Get-CategoryMeta $peptide.category
  $categoryPrompt = Get-CategoryPrompt $peptide.category
  $whatItIs = Get-WhatItIs $peptide
  $researchOverview = Get-ResearchOverview $peptide $categoryPrompt
  $relatedRows = Get-RelatedPeptides $peptide $lookup
  $isIndexable = Get-PeptideIndexable $peptide
  $robots = if ($isIndexable) { "index,follow" } else { "noindex,follow" }
  $canonical = "$siteUrl/peptides/$($peptide.slug)/"
  $title = "$($peptide.name) Peptide Guide & Supplier Listing Notes | PeptideSuppliers.org"
  $metaDescription = "$($peptide.name) page covering documentation notes, related compounds, and linked supplier listings."
  $faqJson = JsonText (Build-FaqData $peptide $categoryMeta.title)
  $breadcrumbJson = JsonText (Build-BreadcrumbData $siteUrl $peptide)
  $heroSupplierLinks = foreach ($supplier in @($peptide.suppliers)) {
    if (-not $supplier) { continue }
    $percent = Get-DiscountPercent $supplier.name
    $code = Get-DiscountCode $supplier.name
    $discountLabel = if ($percent -and $code) { "$percent off with code $code" } elseif ($percent) { "$percent discount available" } else { $null }
@"
              <div class="peptide-quick-link">
                <a class="button button-secondary" href="$([string](HtmlEncode($supplier.link)))" target="_blank" rel="sponsored nofollow noopener noreferrer">View supplier listing</a>
                $(if ($discountLabel) { "<span class=`"discount-note`">$([string](HtmlEncode($discountLabel)))</span>" })
              </div>
"@
  }

  $relatedLinks = foreach ($related in $relatedRows) {
@"
          <a class="pill" href="/peptides/$($related.slug)/">$([string](HtmlEncode($related.name)))</a>
"@
  }

  $supplierCards = foreach ($supplier in @($peptide.suppliers)) {
    if (-not $supplier) { continue }
    $percent = Get-DiscountPercent $supplier.name
    $code = Get-DiscountCode $supplier.name
    $discountLabel = if ($percent -and $code) { "$percent off with code $code" } elseif ($percent) { "$percent discount available" } else { $null }
@"
          <article class="peptide-supplier-card reveal">
            <div class="kicker">Supplier listing</div>
            <h3>$([string](HtmlEncode($supplier.name)))</h3>
            <p>This listing is useful for checking naming, documentation access, and overall page clarity.</p>
            <div class="button-row">
              <a class="button button-primary" href="$([string](HtmlEncode($supplier.link)))" target="_blank" rel="sponsored nofollow noopener noreferrer">View supplier listing</a>
            </div>
            $(if ($discountLabel) { "<span class=`"discount-note`">$([string](HtmlEncode($discountLabel)))</span>" })
          </article>
"@
  }

  $checklistItems = @(
    $peptide.documentation_focus,
    $peptide.supplier_transparency_notes,
    "Look for research-use labeling that stays consistent across the listing, FAQ, and policy copy.",
    "Prefer references that make laboratory documentation easy to locate without generic promotional filler."
  ) | ForEach-Object {
    "<li>$([string](HtmlEncode($_)))</li>"
  }

  $folder = Join-Path $peptidesRoot $peptide.slug
  New-Item -ItemType Directory -Force -Path $folder | Out-Null

  $page = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$([string](HtmlEncode($title)))</title>
  <meta name="description" content="$([string](HtmlEncode($metaDescription)))">
  <meta name="robots" content="$robots">
  <link rel="canonical" href="$canonical">
  <meta property="og:type" content="article">
  <meta property="og:title" content="$([string](HtmlEncode($title)))">
  <meta property="og:description" content="$([string](HtmlEncode($metaDescription)))">
  <meta property="og:url" content="$canonical">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="$([string](HtmlEncode($peptide.image)))">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="$([string](HtmlEncode($title)))">
  <meta name="twitter:description" content="$([string](HtmlEncode($metaDescription)))">
  <meta name="twitter:image" content="$([string](HtmlEncode($peptide.image)))">
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <link rel="stylesheet" href="/styles.css?v=$stylesVersion">
  <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      "mainEntity": $faqJson
    }
  </script>
  <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": $breadcrumbJson
    }
  </script>
</head>
<body>
  <header class="topbar">
    <div class="shell topbar-inner">
      <a class="brand" href="/">
        <span class="brand-mark">PS</span>
        <span class="brand-copy">
          <strong>PeptideSuppliers.org</strong>
          <span>Research supplier discovery and education</span>
        </span>
      </a>
      <nav class="nav" aria-label="Primary">
        <a href="/">Home</a>
        <a href="/education/">Education</a>
        <a href="/suppliers/">Suppliers</a>
        <a class="active" href="/peptide-directory/">Directory</a>
        <a href="/contact/">Contact</a>
      </nav>
    </div>
  </header>

  <main>
    <section class="page-hero">
      <div class="shell">
        <nav class="breadcrumbs" aria-label="Breadcrumb">
          <a href="/">Home</a>
          <span>/</span>
          <a href="/peptide-directory/">Peptide Directory</a>
          <span>/</span>
          <span>$([string](HtmlEncode($peptide.name)))</span>
        </nav>
        <div class="page-hero-card">
          <div class="page-hero-grid peptide-detail-grid">
            <div class="hero-art reveal">
              <img class="peptide-hero-image" src="$([string](HtmlEncode($peptide.image)))" alt="$([string](HtmlEncode($peptide.name))) reference image">
              $(if ($heroSupplierLinks) { "<div class=`"peptide-quick-links`">`n$($heroSupplierLinks -join "`n")`n              </div>" })
            </div>
            <div class="page-hero-copy reveal delay-1">
              <div class="eyebrow">Peptide guide</div>
              <h1 class="page-title">$([string](HtmlEncode("$($peptide.name) Peptide Guide & Supplier Listing Notes")))</h1>
              <p>$([string](HtmlEncode($whatItIs)))</p>
              <p>$([string](HtmlEncode($researchOverview)))</p>
              <div class="peptide-meta">
                <span class="pill">$([string](HtmlEncode($categoryMeta.title)))</span>
                <span class="pill">Educational guide</span>
                <span class="pill">Supplier transparency</span>
              </div>
              <div class="button-row" style="margin-top:18px;">
                <a class="button button-primary" href="/peptide-directory/">Back to directory</a>
                <a class="button button-ghost" href="/how-to-compare-peptide-suppliers/">Compare supplier pages</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="notice reveal">
          <div class="kicker">Educational disclaimer</div>
          <h3>Informational reference only</h3>
          <p>$([string](HtmlEncode($peptide.research_use_disclaimer)))</p>
        </div>
      </div>
    </section>

    <section>
      <div class="shell lede-grid">
        <article class="story-card reveal">
          <div class="kicker">Educational overview</div>
          <h2>How this page frames $([string](HtmlEncode($peptide.name)))</h2>
          <p>$([string](HtmlEncode($whatItIs)))</p>
          <p>$([string](HtmlEncode($researchOverview)))</p>
        </article>
        <article class="card reveal delay-1">
          <div class="kicker">Research documentation checklist</div>
          <h3>What to evaluate on the page</h3>
          <ul class="checklist">
$($checklistItems -join "`n")
          </ul>
        </article>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>COA and batch-testing signals</h2>
            <p>These checks make it easier to judge how clearly a listing is documented.</p>
          </div>
        </div>
        <div class="cards">
          <article class="card reveal">
            <div class="kicker">COA availability</div>
            <h3>Documentation should be easy to locate</h3>
            <p>$([string](HtmlEncode($peptide.documentation_focus)))</p>
          </article>
          <article class="card reveal delay-1">
            <div class="kicker">Batch context</div>
            <h3>Look for batch-specific references</h3>
            <p>$([string](HtmlEncode($peptide.supplier_transparency_notes)))</p>
          </article>
          <article class="card reveal delay-2">
            <div class="kicker">Research-use wording</div>
            <h3>Keep the language consistent</h3>
            <p>Listings read more clearly when research-use labeling, laboratory references, and category wording all point in the same direction.</p>
          </article>
        </div>
      </div>
    </section>

    <section>
      <div class="shell science-grid">
        <article class="card reveal">
          <div class="kicker">Supplier transparency notes</div>
          <h2>What stands out on this page</h2>
          <p>$([string](HtmlEncode($peptide.supplier_transparency_notes)))</p>
          <p>$([string](HtmlEncode($peptide.documentation_focus)))</p>
        </article>
        <article class="card reveal delay-1">
          <div class="kicker">Research context</div>
          <h3>Where it fits in current research</h3>
          <p>$([string](HtmlEncode($(if ($peptide.research_areas) { $peptide.research_areas } else { $categoryMeta.blurb }))))</p>
          $(if ($peptide.evidence_stage) { "<p>$([string](HtmlEncode($peptide.evidence_stage)))</p>" })
        </article>
      </div>
    </section>

    $(if ($supplierCards) {
@"
    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Linked supplier pages</h2>
            <p>Use these pages to compare naming, documentation access, and overall page clarity.</p>
          </div>
        </div>
        <div class="cards">
$($supplierCards -join "`n")
        </div>
      </div>
    </section>
"@
    })

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Related peptides</h2>
            <p>Related pages help with side-by-side category comparisons.</p>
          </div>
        </div>
        <div class="card reveal">
          <div class="pill-row">
$($relatedLinks -join "`n")
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Frequently asked questions</h2>
            <p>Quick answers to the main questions that come up on this page.</p>
          </div>
        </div>
        <div class="faq-grid">
          <article class="card reveal">
            <h3>How is $([string](HtmlEncode($peptide.name))) usually described in research listings?</h3>
            <p>$([string](HtmlEncode($whatItIs)))</p>
          </article>
          <article class="card reveal delay-1">
            <h3>What documentation signals matter most?</h3>
            <p>$([string](HtmlEncode($peptide.documentation_focus)))</p>
          </article>
          <article class="card reveal delay-2">
            <h3>What else is worth checking before opening a listing?</h3>
            <p>Check whether the compound name is clear, the documentation notes are readable, and the related pages line up with the label on the listing.</p>
          </article>
        </div>
      </div>
    </section>
  </main>

  <footer class="footer">
    <div class="shell footer-row">
      <span>&copy; 2026 PeptideSuppliers.org</span>
      <div class="footer-links">
        <a href="/peptide-directory/">Peptide Directory</a>
        <a href="/education/">Education</a>
        <a href="/privacy/">Privacy</a>
      </div>
    </div>
  </footer>
</body>
</html>
"@

  Set-Content -Path (Join-Path $folder "index.html") -Value $page -Encoding UTF8
}

$siteUrl = Get-SiteUrl
$peptides = Get-Content $dataPath -Raw | ConvertFrom-Json
$lookup = @{}
foreach ($peptide in $peptides) {
  $lookup[$peptide.slug] = $peptide
}

if (Test-Path $peptidesRoot) {
  Get-ChildItem -Path $peptidesRoot -Directory | Remove-Item -Recurse -Force
} else {
  New-Item -ItemType Directory -Force -Path $peptidesRoot | Out-Null
}

foreach ($peptide in $peptides) {
  New-PeptidePage -peptide $peptide -lookup $lookup -siteUrl $siteUrl
}

$directoryHtml = New-DirectoryPage -peptides $peptides -lookup $lookup -siteUrl $siteUrl
Set-Content -Path $directoryPath -Value $directoryHtml -Encoding UTF8
