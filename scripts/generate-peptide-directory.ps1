$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot "data\peptides.json"
$directoryPath = Join-Path $repoRoot "peptide-directory\index.html"
$peptidesRoot = Join-Path $repoRoot "peptides"

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

function Get-CategoryMeta($key) {
  switch ($key) {
    "glp-metabolic" { return @{ title = "GLP and metabolic research compounds"; blurb = "This section groups compound pages that are usually discussed in metabolic, incretin, and appetite-related research coverage without turning the page into a promotional landing page." } }
    "growth-secretagogue" { return @{ title = "Growth hormone secretagogue research compounds"; blurb = "These entries are commonly organized around endocrine signaling, secretagogue language, and broader growth-hormone research context." } }
    "repair-tissue" { return @{ title = "Repair and tissue research compounds"; blurb = "These pages focus on how repair-oriented compounds are described in educational references and how supplier documentation can be evaluated more carefully." } }
    "cognitive-neuropeptide" { return @{ title = "Cognitive and neuropeptide research compounds"; blurb = "These references stay focused on neuropeptide, cognition, and signaling language rather than overstated performance or wellness claims." } }
    "longevity-cellular" { return @{ title = "Longevity and cellular research compounds"; blurb = "This group collects entries that usually appear in cellular, mitochondrial, or longevity-oriented research discussions." } }
    "cosmetic-pigmentation" { return @{ title = "Cosmetic and pigmentation research compounds"; blurb = "These pages look at appearance-oriented or pigmentation-related catalog language in a research and documentation context." } }
    "immune-regulatory" { return @{ title = "Immune and regulatory research compounds"; blurb = "These entries are organized around regulatory signaling, thymic peptides, and other immune-focused research references." } }
    "blends-protocols" { return @{ title = "Blends and named protocols"; blurb = "These pages cover branded combinations, named protocols, or shorthand listings that need extra context to stay understandable." } }
    default { return @{ title = "Research compounds"; blurb = "Educational compound references grouped into one place." } }
  }
}

function Get-CategoryPrompt($key) {
  switch ($key) {
    "glp-metabolic" { return "These pages are easiest to evaluate when the compound naming is clear, the listing stays research-focused, and the documentation language is easy to follow." }
    "growth-secretagogue" { return "For this category, the key reading task is usually separating signaling-class language from generic hype and making sure documentation cues are easy to verify." }
    "repair-tissue" { return "These pages are most useful when they focus on documentation signals, category context, and how clearly the compound is explained in a research setting." }
    "cognitive-neuropeptide" { return "Neuropeptide pages are easier to trust when the wording stays careful, the category fit is clear, and the documentation language is easy to follow." }
    "longevity-cellular" { return "This group benefits from careful language because the category can quickly become repetitive or overly speculative without enough educational context." }
    "cosmetic-pigmentation" { return "These entries work best when the page stays focused on catalog language, laboratory documentation, and category clarity rather than broad appearance claims." }
    "immune-regulatory" { return "Regulatory and thymic peptide pages are easier to compare when the reference focuses on labeling, documentation, and overall transparency." }
    "blends-protocols" { return "Named blends and shorthand listings need extra context so the compound name, documentation language, and category fit are easy to understand at a glance." }
    default { return "The main goal is to keep the page educational, specific, and easy to compare with related references." }
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
      "name" = "What is $($peptide.name) in this directory?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = "$($peptide.name) is presented here as an educational research reference inside the $categoryTitle category."
      }
    },
    @{
      "@type" = "Question"
      "name" = "What should stand out on $($peptide.name) reference pages?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = "$($peptide.documentation_focus) $($peptide.supplier_transparency_notes)"
      }
    },
    @{
      "@type" = "Question"
      "name" = "Does this page recommend human use?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = "No. This page is for educational and informational purposes only. PeptideSuppliers.org does not sell peptides, provide medical advice, or recommend human use."
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
      $cardSummary = Get-CardSummary $peptide.short_educational_description
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
          <article class="card reveal directory-card" data-name="$([string](HtmlEncode($peptide.name.ToLower())))" data-category="$([string](HtmlEncode($meta.title.ToLower())))" data-description="$([string](HtmlEncode($peptide.short_educational_description.ToLower())))">
            <div class="review-media">
              <img class="directory-image" src="$([string](HtmlEncode($peptide.image)))" alt="$([string](HtmlEncode($peptide.name))) reference image" loading="lazy">
            </div>
            <div class="kicker">Research reference</div>
            <h3>$([string](HtmlEncode($peptide.name)))</h3>
            <p>$([string](HtmlEncode($cardSummary)))</p>
            <p class="directory-category-label">$([string](HtmlEncode($meta.title)))</p>
            <div class="pill-row">
$($relatedLinks -join "`n")
            </div>
            <div class="button-row">
$(if ($supplierButtons) { ($supplierButtons -join "`n") })
              <a class="button button-primary" href="/peptides/$($peptide.slug)/">View research reference</a>
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
  <title>Peptide Directory Research Reference | PeptideSuppliers.org</title>
  <meta name="description" content="Browse a searchable peptide directory organized as educational research references with documentation focus, supplier transparency notes, and related compound links.">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="$siteUrl/peptide-directory/">
  <meta property="og:type" content="website">
  <meta property="og:title" content="Peptide Directory Research Reference | PeptideSuppliers.org">
  <meta property="og:description" content="Educational peptide reference pages grouped by category, documentation focus, and related research compounds.">
  <meta property="og:url" content="$siteUrl/peptide-directory/">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="$siteUrl/og-image.svg">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="Peptide Directory Research Reference | PeptideSuppliers.org">
  <meta name="twitter:description" content="Educational peptide reference pages grouped by category, documentation focus, and related research compounds.">
  <meta name="twitter:image" content="$siteUrl/og-image.svg">
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <link rel="stylesheet" href="/styles.css">
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
              <div class="eyebrow">Peptide reference</div>
              <h1 class="page-title">Peptide Directory</h1>
              <p>
                This directory is designed as an educational reference for research compounds, laboratory documentation cues, and related reading paths. It stays focused on category context and supplier transparency rather than commercial language.
              </p>
              <div class="button-row">
                <a class="button button-primary" href="#directory-search">Search the directory</a>
                <a class="button button-ghost" href="/education/">Open education hub</a>
              </div>
            </div>
            <div class="hero-art reveal delay-1">
              <img src="/assets/directory-compounds.svg" alt="Editorial illustration representing grouped peptide research references">
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
  $relatedRows = Get-RelatedPeptides $peptide $lookup
  $isIndexable = Get-PeptideIndexable $peptide
  $robots = if ($isIndexable) { "index,follow" } else { "noindex,follow" }
  $canonical = "$siteUrl/peptides/$($peptide.slug)/"
  $title = "$($peptide.name) Research Reference & Supplier Transparency Guide | PeptideSuppliers.org"
  $metaDescription = "$($peptide.name) research reference covering educational context, documentation focus, supplier transparency notes, and related compound links."
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
            <p>Use this supplier page as a reference point for listing language, laboratory documentation cues, and how clearly the compound is presented.</p>
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
  <link rel="stylesheet" href="/styles.css">
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
              <div class="eyebrow">Research reference</div>
              <h1 class="page-title">$([string](HtmlEncode("$($peptide.name) Research Reference & Supplier Transparency Guide")))</h1>
              <p>$([string](HtmlEncode($peptide.short_educational_description)))</p>
              <p>$([string](HtmlEncode($categoryPrompt)))</p>
              <div class="peptide-meta">
                <span class="pill">$([string](HtmlEncode($categoryMeta.title)))</span>
                <span class="pill">Educational reference</span>
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
          <p>$([string](HtmlEncode($peptide.short_educational_description)))</p>
          <p>$([string](HtmlEncode($categoryPrompt)))</p>
        </article>
        <article class="card reveal delay-1">
          <div class="kicker">Research documentation checklist</div>
          <h3>What to evaluate on a reference page</h3>
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
            <p>These signals help keep the page focused on laboratory documentation rather than promotional wording.</p>
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
          <h2>What makes this page easier to trust</h2>
          <p>$([string](HtmlEncode($peptide.supplier_transparency_notes)))</p>
          <p>$([string](HtmlEncode($peptide.documentation_focus)))</p>
        </article>
        <article class="card reveal delay-1">
          <div class="kicker">Category context</div>
          <h3>Where this page fits in the directory</h3>
          <p>$([string](HtmlEncode($categoryMeta.blurb)))</p>
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
            <p>These supplier pages can help with comparing listing language, laboratory documentation cues, and overall transparency.</p>
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
            <p>Nearby reference pages can help when comparing closely related compounds and broader category context.</p>
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
            <p>These FAQ entries keep the page educational, research-focused, and easier to understand at a glance.</p>
          </div>
        </div>
        <div class="faq-grid">
          <article class="card reveal">
            <h3>What is $([string](HtmlEncode($peptide.name))) in this directory?</h3>
            <p>$([string](HtmlEncode($peptide.short_educational_description)))</p>
          </article>
          <article class="card reveal delay-1">
            <h3>What documentation signals matter most?</h3>
            <p>$([string](HtmlEncode($peptide.documentation_focus)))</p>
          </article>
          <article class="card reveal delay-2">
            <h3>Is this page for educational reading only?</h3>
            <p>$([string](HtmlEncode($peptide.research_use_disclaimer)))</p>
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
