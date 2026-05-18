$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot "data\locations.csv"
$locationsRoot = Join-Path $repoRoot "locations"
$sitemapPath = Join-Path $repoRoot "sitemap.xml"
$peptidesDataPath = Join-Path $repoRoot "data\peptides.json"

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

function Get-StableNumber([string]$value) {
  $sum = 0
  foreach ($char in $value.ToCharArray()) {
    $sum += [int][char]$char
  }
  return $sum
}

function Get-Bool([string]$value) {
  if (-not $value) { return $false }
  return $value.Trim().ToLower() -eq "true"
}

function Get-RelatedRows($row, $lookup) {
  $related = @()
  foreach ($key in @("related_1", "related_2", "related_3")) {
    $slug = $row.$key
    if ($slug -and $lookup.ContainsKey($slug)) {
      $related += $lookup[$slug]
    }
  }
  return $related
}

# A city page should only be indexable when it has enough unique local context.
# To make a city page indexable, keep index=true in data/locations.csv and make sure:
# 1. local_research_anchor is filled in
# 2. regional_biotech_context is filled in
# 3. the page has at least 3 valid related city links
function Get-IsIndexable($row, $lookup) {
  $hasIndexFlag = Get-Bool $row.index
  $hasLocalAnchor = -not [string]::IsNullOrWhiteSpace($row.local_research_anchor)
  $hasRegionalContext = -not [string]::IsNullOrWhiteSpace($row.regional_biotech_context)
  $hasReaderFocus = -not [string]::IsNullOrWhiteSpace($row.local_reader_focus)
  $relatedCount = (Get-RelatedRows $row $lookup).Count
  return $hasIndexFlag -and $hasLocalAnchor -and $hasRegionalContext -and $hasReaderFocus -and $relatedCount -ge 3
}

function Build-PageTitle($row) {
  return "$($row.city), $($row.state_code) Research Peptide Supplier Transparency Guide | PeptideSuppliers.org"
}

function Build-MetaDescription($row) {
  if (-not [string]::IsNullOrWhiteSpace($row.meta_description)) {
    return $row.meta_description
  }

  return "$($row.city), $($row.state_code) research peptide supplier transparency guide covering local research context, laboratory documentation, and related city references."
}

function Build-Robots($isIndexable) {
  if ($isIndexable) { return "index,follow" }
  return "noindex,follow"
}

function Build-RelatedLinkMarkup($row, $lookup) {
  $links = foreach ($related in (Get-RelatedRows $row $lookup)) {
    "<a class=`"pill`" href=`"/locations/$($related.slug)/`">$([string](HtmlEncode("$($related.city), $($related.state_code)")))</a>"
  }

  return ($links -join "`n              ")
}

function Build-RelatedCityNames($row, $lookup) {
  $names = foreach ($related in (Get-RelatedRows $row $lookup)) {
    "$($related.city), $($related.state_code)"
  }

  if (-not $names) {
    return "Related city links will appear here when nearby guide data is added."
  }

  return ($names -join ", ")
}

function Build-FaqData($row) {
  return @(
    @{
      "@type" = "Question"
      "name" = "How should this $($row.city) guide be used?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = "This page is meant to be a local educational reference that connects regional research context, supplier transparency habits, and related city reading paths."
      }
    },
    @{
      "@type" = "Question"
      "name" = "What should stand out on supplier pages linked to this topic?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = "The guide focuses on COA availability, batch testing references, research-use labeling, third-party testing language, and how clearly supplier pages explain fulfillment and documentation details."
      }
    },
    @{
      "@type" = "Question"
      "name" = "Where do the featured peptide research links lead?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = "The featured peptide section points to internal research reference pages on PeptideSuppliers.org and recent PubMed searches so readers can continue with educational reading."
      }
    },
    @{
      "@type" = "Question"
      "name" = "Does this guide recommend peptides or human use?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = "No. This page is for educational and informational purposes only. PeptideSuppliers.org does not sell peptides, provide medical advice, or recommend human use."
      }
    }
  )
}

function Build-BreadcrumbData($siteUrl, $row) {
  return @(
    @{ "@type" = "ListItem"; "position" = 1; "name" = "Home"; "item" = "$siteUrl/" },
    @{ "@type" = "ListItem"; "position" = 2; "name" = "Locations"; "item" = "$siteUrl/locations/" },
    @{ "@type" = "ListItem"; "position" = 3; "name" = "$($row.city), $($row.state_code)"; "item" = "$siteUrl/locations/$($row.slug)/" }
  )
}

function Build-WhyGuideCopy($row) {
  $sentences = @(
    "$($row.local_reader_focus)",
    "$($row.state_policy_note)"
  ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

  return ($sentences -join " ")
}

function Build-ChecklistItems($row) {
  return @(
    "Check whether COA availability is obvious from the listing rather than buried behind generic claims.",
    "Look for batch testing references that connect the product page to readable laboratory documentation.",
    "Review how consistently research-use labeling appears across listing, FAQ, and policy content.",
    "$($row.documentation_focus)",
    "$($row.transparency_note)"
  ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
}

function Build-SignalCards($row) {
  return @(
    @{ kicker = "Documentation"; title = "COA availability"; body = "A strong page makes certificates and supporting laboratory documentation easy to locate without vague detours."; delay = "" },
    @{ kicker = "Verification"; title = "Batch testing references"; body = "Batch language becomes more useful when the page connects it to a product-specific testing trail."; delay = " delay-1" },
    @{ kicker = "Labeling"; title = "Research-use wording"; body = "Educational pages should stay consistent about research-use labeling instead of mixing in promotional language."; delay = " delay-2" },
    @{ kicker = "Logistics"; title = "Shipping transparency"; body = "$($row.logistics_note)"; delay = " delay-3" },
    @{ kicker = "Context"; title = "Third-party testing mentions"; body = "$($row.regional_biotech_context)"; delay = "" }
  )
}

function Get-FeaturedPeptideSlugs($row) {
  $bundles = @(
    @("glp-1", "tirz", "retatrutide-glp-3"),
    @("cagrilintide", "tesofensine", "mazdutide"),
    @("sermorelin", "ipamorelin", "cjc-1295"),
    @("bpc-157", "tb-500", "ghk-cu"),
    @("semax", "selank", "cerebrolysin"),
    @("nad", "mots-c", "epitalon"),
    @("thymosin-alpha-1", "thymalin", "gonadorelin"),
    @("melanotan-ii", "pt-141", "kisspeptin-10"),
    @("ara-290", "kpv", "foxo4-dri")
  )

  $index = (Get-StableNumber "$($row.slug)$($row.state_code)") % $bundles.Count
  return $bundles[$index]
}

function Get-PubMedUrl([string]$query) {
  $encoded = [System.Uri]::EscapeDataString($query)
  return "https://pubmed.ncbi.nlm.nih.gov/?term=$encoded&sort=pubdate"
}

function New-LocationPage($row, $lookup, $siteUrl, $peptideLookup) {
  $isIndexable = Get-IsIndexable $row $lookup
  $title = Build-PageTitle $row
  $metaDescription = Build-MetaDescription $row
  $canonical = "$siteUrl/locations/$($row.slug)/"
  $robots = Build-Robots $isIndexable
  $faqJson = JsonText (Build-FaqData $row)
  $breadcrumbJson = JsonText (Build-BreadcrumbData $siteUrl $row)
  $relatedLinks = Build-RelatedLinkMarkup $row $lookup
  $relatedCityNames = Build-RelatedCityNames $row $lookup
  $whyGuideCopy = Build-WhyGuideCopy $row
  $checklistItems = (Build-ChecklistItems $row | ForEach-Object { "<li>$([string](HtmlEncode($_)))</li>" }) -join "`n              "
  $signalCards = foreach ($card in (Build-SignalCards $row)) {
@"
            <article class="score-box reveal$($card.delay)">
              <div class="kicker">$([string](HtmlEncode($card.kicker)))</div>
              <h3>$([string](HtmlEncode($card.title)))</h3>
              <p>$([string](HtmlEncode($card.body)))</p>
            </article>
"@
  }

  $featuredCards = foreach ($slug in (Get-FeaturedPeptideSlugs $row)) {
    if (-not $peptideLookup.ContainsKey($slug)) { continue }
    $peptide = $peptideLookup[$slug]
@"
          <article class="card reveal">
            <div class="kicker">Research topic</div>
            <h3>$([string](HtmlEncode($peptide.name)))</h3>
            <p>$([string](HtmlEncode($peptide.short_educational_description)))</p>
            <div class="button-row">
              <a class="button button-primary" href="/peptides/$($peptide.slug)/">Open research reference</a>
              <a class="button button-ghost" href="$(Get-PubMedUrl $peptide.name)" target="_blank" rel="noopener noreferrer">Recent studies</a>
            </div>
          </article>
"@
  }

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
  <meta property="og:image" content="$siteUrl/og-image.svg">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="$([string](HtmlEncode($title)))">
  <meta name="twitter:description" content="$([string](HtmlEncode($metaDescription)))">
  <meta name="twitter:image" content="$siteUrl/og-image.svg">
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
          <span>Research supplier discovery, transparency, and laboratory documentation</span>
        </span>
      </a>
      <nav class="nav" aria-label="Primary">
        <a href="/">Home</a>
        <a href="/education/">Education</a>
        <a class="active" href="/locations/">Locations</a>
        <a href="/how-to-compare-peptide-suppliers/">Compare Suppliers</a>
        <a href="/what-is-a-coa/">What is a COA?</a>
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
          <a href="/locations/">Locations</a>
          <span>/</span>
          <span>$([string](HtmlEncode("$($row.city), $($row.state_code)")))</span>
        </nav>
        <div class="page-hero-card">
          <div class="page-hero-grid">
            <div class="page-hero-copy reveal">
              <div class="eyebrow">Location guide</div>
              <h1 class="page-title">$([string](HtmlEncode("$($row.city) Research Peptide Supplier Transparency Guide")))</h1>
              <p>
                $([string](HtmlEncode($row.description_seed)))
              </p>
              <div class="pill-row">
                <span class="pill">$([string](HtmlEncode("$($row.city), $($row.state_code)")))</span>
                <span class="pill">$([string](HtmlEncode($row.region)))</span>
                <span class="pill">Educational reference</span>
              </div>
            </div>
            <div class="hero-art reveal delay-1">
              <img src="/assets/education-guides.svg" alt="Editorial-style illustration for location-based peptide supplier transparency guides">
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

    <section>
      <div class="shell location-grid">
        <article class="story-card reveal">
          <div class="kicker">Local overview</div>
          <h2>$([string](HtmlEncode("$($row.city), $($row.state_code)"))) research context</h2>
          <p>$([string](HtmlEncode($row.local_research_anchor)))</p>
          <p>$([string](HtmlEncode($row.regional_biotech_context)))</p>
        </article>
        <article class="card reveal delay-1">
          <div class="kicker">Reader context</div>
          <h3>How this guide helps $([string](HtmlEncode($row.city))) readers</h3>
          <p>$([string](HtmlEncode($whyGuideCopy)))</p>
        </article>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Local context table</h2>
            <p>These fields help the page stay grounded in local research reading habits instead of repeating the same national summary.</p>
          </div>
        </div>
        <div class="card reveal context-card">
          <table class="context-table">
            <tbody>
              <tr><th>City</th><td>$([string](HtmlEncode($row.city)))</td></tr>
              <tr><th>State</th><td>$([string](HtmlEncode($row.state_name)))</td></tr>
              <tr><th>Region</th><td>$([string](HtmlEncode($row.region)))</td></tr>
              <tr><th>Local research context</th><td>$([string](HtmlEncode($row.local_research_anchor)))</td></tr>
              <tr><th>Nearby cities</th><td>$([string](HtmlEncode($relatedCityNames)))</td></tr>
              <tr><th>Documentation focus</th><td>$([string](HtmlEncode($row.documentation_focus)))</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>

    <section>
      <div class="shell science-grid">
        <article class="card reveal">
          <div class="kicker">Regional biotech context</div>
          <h2>Local research and biotech context</h2>
          <p>$([string](HtmlEncode($row.news_angle)))</p>
          <p>$([string](HtmlEncode($row.nearby_research_hubs)))</p>
        </article>
        <article class="card reveal delay-1">
          <div class="kicker">Reader focus</div>
          <h3>What local readers usually compare first</h3>
          <p>$([string](HtmlEncode($row.local_reader_focus)))</p>
          <p>$([string](HtmlEncode($row.state_policy_note)))</p>
        </article>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Featured peptide research references</h2>
            <p>These are useful educational reference topics to explore alongside the local guide. Each one links back to the peptide directory and a recent PubMed search.</p>
          </div>
        </div>
        <div class="resource-grid">
$($featuredCards -join "`n")
        </div>
        <div class="button-row" style="margin-top:24px;">
          <a class="button button-primary" href="/peptide-directory/">Open peptide directory</a>
          <a class="button button-ghost" href="/how-to-compare-peptide-suppliers/">Compare supplier pages</a>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Supplier transparency checklist</h2>
            <p>This checklist keeps the page focused on laboratory documentation and page clarity rather than promotional claims.</p>
          </div>
        </div>
        <div class="card reveal">
          <ul class="checklist">
              $checklistItems
          </ul>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Documentation signals to evaluate</h2>
            <p>Each signal below is framed as an educational reading prompt for supplier pages that mention research compounds and laboratory documentation.</p>
          </div>
        </div>
        <div class="score-grid">
$($signalCards -join "`n")
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Related city guides</h2>
            <p>These nearby guides help put $([string](HtmlEncode($row.city))) into a broader regional context without repeating the same copy city after city.</p>
          </div>
        </div>
        <div class="card reveal">
          <div class="pill-row">
              $relatedLinks
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Frequently asked questions</h2>
            <p>These questions are tailored to the local guide format and keep the page educational rather than commercial.</p>
          </div>
        </div>
        <div class="faq-grid">
          <article class="card reveal">
            <h3>How should this guide be used?</h3>
            <p>$([string](HtmlEncode($row.local_reader_focus)))</p>
          </article>
          <article class="card reveal delay-1">
            <h3>What should stand out on a supplier page?</h3>
            <p>$([string](HtmlEncode($row.documentation_focus)))</p>
          </article>
          <article class="card reveal delay-2">
            <h3>Where do the featured peptide links go?</h3>
            <p>They point to internal research reference pages and recent PubMed searches so the page stays useful as an educational reading path.</p>
          </article>
          <article class="card reveal">
            <h3>Is this page for educational reading only?</h3>
            <p>This page is for educational and informational purposes only. PeptideSuppliers.org does not sell peptides, provide medical advice, or recommend human use.</p>
          </article>
        </div>
      </div>
    </section>
  </main>

  <footer class="footer">
    <div class="shell footer-row">
      <span>&copy; 2026 PeptideSuppliers.org</span>
      <div class="footer-links">
        <a href="/locations/">Locations</a>
        <a href="/education/">Education</a>
        <a href="/privacy/">Privacy</a>
      </div>
    </div>
  </footer>
</body>
</html>
"@

  $folder = Join-Path $locationsRoot $row.slug
  New-Item -ItemType Directory -Force -Path $folder | Out-Null
  Set-Content -Path (Join-Path $folder "index.html") -Value $page -Encoding UTF8
}

function New-LocationsHub($rows, $lookup, $siteUrl) {
  $groups = $rows | Sort-Object state_name, city | Group-Object state_name

  $jumpLinks = foreach ($group in $groups) {
    $stateSlug = ($group.Name.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
    "<a class=`"pill`" href=`"#state-$stateSlug`">$([string](HtmlEncode($group.Name)))</a>"
  }

  $sections = foreach ($group in $groups) {
    $stateSlug = ($group.Name.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
    $cards = foreach ($row in ($group.Group | Sort-Object city)) {
      $robotsLabel = if (Get-IsIndexable $row $lookup) { "Indexable guide" } else { "Reference draft" }
@"
            <article class="card reveal">
              <div class="kicker">City guide</div>
              <h3>$([string](HtmlEncode("$($row.city), $($row.state_code)")))</h3>
              <p>$([string](HtmlEncode((Build-MetaDescription $row))))</p>
              <div class="pill-row">
                <span class="pill">$([string](HtmlEncode($row.region)))</span>
                <span class="pill">$([string](HtmlEncode($robotsLabel)))</span>
              </div>
              <div class="button-row">
                <a class="button button-primary" href="/locations/$($row.slug)/">Open guide</a>
              </div>
            </article>
"@
    }

@"
        <section id="state-$stateSlug" class="location-section">
          <div class="section-head reveal">
            <div>
              <h2>$([string](HtmlEncode($group.Name)))</h2>
              <p>Grouped city guides for $([string](HtmlEncode($group.Name))) so the hub stays easier to scan as the library grows.</p>
            </div>
          </div>
          <div class="resource-grid">
$($cards -join "`n")
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
  <title>Location-Based Peptide Research Guides | PeptideSuppliers.org</title>
  <meta name="description" content="Browse city-by-city educational guides focused on peptide research context, supplier transparency, laboratory documentation, and related regional reading.">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="$siteUrl/locations/">
  <meta property="og:type" content="website">
  <meta property="og:title" content="Location-Based Peptide Research Guides | PeptideSuppliers.org">
  <meta property="og:description" content="State-grouped city guides focused on research context, laboratory documentation, and supplier transparency.">
  <meta property="og:url" content="$siteUrl/locations/">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="$siteUrl/og-image.svg">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="Location-Based Peptide Research Guides | PeptideSuppliers.org">
  <meta name="twitter:description" content="State-grouped city guides focused on research context, laboratory documentation, and supplier transparency.">
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
          <span>Research supplier discovery, transparency, and laboratory documentation</span>
        </span>
      </a>
      <nav class="nav" aria-label="Primary">
        <a href="/">Home</a>
        <a href="/education/">Education</a>
        <a class="active" href="/locations/">Locations</a>
        <a href="/how-to-compare-peptide-suppliers/">Compare Suppliers</a>
        <a href="/what-is-a-coa/">What is a COA?</a>
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
          <span>Locations</span>
        </nav>
        <div class="page-hero-card">
          <div class="page-hero-grid">
            <div class="page-hero-copy reveal">
              <div class="eyebrow">Locations hub</div>
              <h1 class="page-title">Research peptide supplier transparency guides by city</h1>
              <p>This hub groups city guides by state so the library stays useful as it grows. Each guide is meant to be an educational local reference centered on research context, supplier transparency, and laboratory documentation.</p>
              <div class="pill-row">
$($jumpLinks -join "`n                ")
              </div>
            </div>
            <div class="hero-art reveal delay-1">
              <img src="/assets/education-guides.svg" alt="Editorial-style illustration for state-grouped location guides">
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

$($sections -join "`n")
  </main>

  <footer class="footer">
    <div class="shell footer-row">
      <span>&copy; 2026 PeptideSuppliers.org</span>
      <div class="footer-links">
        <a href="/locations/">Locations</a>
        <a href="/education/">Education</a>
        <a href="/privacy/">Privacy</a>
      </div>
    </div>
  </footer>
</body>
</html>
"@
}

function Update-Sitemap($siteUrl) {
  $ignorePattern = '\\(?:\.git|api|verifier-backend|data|scripts)\\'
  $canonicals = New-Object System.Collections.Generic.List[string]

  Get-ChildItem -Path $repoRoot -Recurse -File -Filter *.html |
    Where-Object {
      $_.FullName -notmatch $ignorePattern -and
      ($_.Name -eq "index.html" -or $_.DirectoryName -eq $repoRoot)
    } |
    ForEach-Object {
      $raw = Get-Content $_.FullName -Raw
      $robotsMatch = [regex]::Match($raw, '<meta\s+name="robots"\s+content="([^"]+)"', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
      if ($robotsMatch.Success -and $robotsMatch.Groups[1].Value -match 'noindex') {
        return
      }

      $canonicalMatch = [regex]::Match($raw, '<link\s+rel="canonical"\s+href="([^"]+)"', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
      if ($canonicalMatch.Success) {
        [void]$canonicals.Add($canonicalMatch.Groups[1].Value)
      }
    }

  $uniqueUrls = $canonicals | Sort-Object -Unique
  $urlXml = ($uniqueUrls | ForEach-Object { "  <url>`n    <loc>$_</loc>`n  </url>" }) -join "`n"
  $sitemapXml = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n$urlXml`n</urlset>`n"
  Set-Content -Path $sitemapPath -Value $sitemapXml -Encoding UTF8
}

$siteUrl = Get-SiteUrl
$rows = Import-Csv $dataPath | Sort-Object city
$peptides = Get-Content $peptidesDataPath -Raw | ConvertFrom-Json
$lookup = @{}
$peptideLookup = @{}
foreach ($row in $rows) {
  $lookup[$row.slug] = $row
}
foreach ($peptide in $peptides) {
  $peptideLookup[$peptide.slug] = $peptide
}

foreach ($row in $rows) {
  New-LocationPage -row $row -lookup $lookup -siteUrl $siteUrl -peptideLookup $peptideLookup
}

$hubHtml = New-LocationsHub -rows $rows -lookup $lookup -siteUrl $siteUrl
Set-Content -Path (Join-Path $locationsRoot "index.html") -Value $hubHtml -Encoding UTF8

Update-Sitemap -siteUrl $siteUrl
