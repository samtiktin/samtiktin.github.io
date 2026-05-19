$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot "data\locations.csv"
$locationsRoot = Join-Path $repoRoot "locations"
$sitemapPath = Join-Path $repoRoot "sitemap.xml"

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

function Get-Bool([object]$value) {
  if ($null -eq $value) { return $false }
  return $value.ToString().Trim().ToLower() -eq "true"
}

function Clean([object]$value) {
  if ($null -eq $value) { return "" }
  return $value.ToString().Trim()
}

function Escape-RegexLiteral([string]$value) {
  return [regex]::Escape($value)
}

function Get-HeroIntro($row) {
  $city = Clean $row.city
  $region = Clean $row.region
  $anchor = Clean $row.local_research_anchor
  return "$anchor is one of the clearest local research anchors for $city, which makes it a useful starting point for reading supplier documentation and broader industry coverage in $region."
}

function Get-OverviewCopy($row) {
  $city = Clean $row.city
  $state = Clean $row.state
  return "This guide brings together local context, nearby city links, and documentation signals so $city readers can compare supplier transparency in a more grounded $state context."
}

function Get-ResearchContextCopy($row) {
  $city = Clean $row.city
  $region = Clean $row.region
  $anchor = Clean $row.local_research_anchor
  return "$anchor provides the local anchor here, while the broader $region context helps with comparing documentation standards, research-use labeling, and transparency language across supplier pages."
}

function Get-SupplierCopy($row) {
  $city = Clean $row.city
  $focus = Clean $row.documentation_focus
  return "For $city readers, a close comparison usually starts with $focus, then moves into COA access, batch details, research-use labeling, and overall policy clarity."
}

function Get-LogisticsCopy($row) {
  $city = Clean $row.city
  return "Clear dispatch language, carrier visibility, and straightforward handling notes are useful trust signals for $city readers."
}

function Get-FaqOneAnswer($row) {
  $anchor = Clean $row.local_research_anchor
  $city = Clean $row.city
  return "It connects $anchor with supplier transparency, documentation quality, and nearby city reading paths in a way that is more useful for $city readers."
}

function Get-FaqTwoAnswer($row) {
  $focus = Clean $row.documentation_focus
  return "Start with $focus. Then review COA access, batch identifiers, lab report dates, research-use labeling, and overall policy consistency."
}

function Get-RelatedRows($row, $lookup) {
  $rows = @()
  foreach ($key in @("related_slug_1", "related_slug_2", "related_slug_3")) {
    $slug = Clean $row.$key
    if ($slug -and $lookup.ContainsKey($slug)) {
      $rows += $lookup[$slug]
    }
  }
  return $rows
}

function Get-IsIndexable($row, $lookup) {
  $required = @(
    Clean $row.index,
    Clean $row.local_intro,
    Clean $row.local_research_anchor,
    Clean $row.regional_research_context,
    Clean $row.supplier_transparency_paragraph,
    Clean $row.documentation_checklist
  )

  if (-not (Get-Bool $row.index)) { return $false }
  if (($required | Where-Object { [string]::IsNullOrWhiteSpace($_) }).Count -gt 0) { return $false }
  if ((Get-RelatedRows $row $lookup).Count -lt 3) { return $false }
  return $true
}

function Get-PageTitle($row) {
  $base = Clean $row.seo_title
  if (-not $base) {
    $base = "$(Clean $row.city) Research Peptide Supplier Transparency Guide"
  }

  if ($base -like "*PeptideSuppliers.org*") {
    return $base
  }

  return "$base | PeptideSuppliers.org"
}

function Get-MetaDescription($row) {
  $meta = Clean $row.meta_description
  if ($meta) { return $meta }
  return "$(Clean $row.city), $(Clean $row.state_code) educational guide to research peptide supplier transparency, laboratory documentation, and related city reading."
}

function Get-CanonicalUrl($row, $siteUrl) {
  $canonical = Clean $row.canonical_url
  if ($canonical) { return $canonical }
  return "$siteUrl/locations/$(Clean $row.slug)/"
}

function Get-RobotsValue($row, $lookup) {
  if (Get-IsIndexable $row $lookup) { return "index,follow" }
  return "noindex,follow"
}

function Get-ChecklistMarkup($value) {
  $items = @()
  foreach ($part in ($value -split ';')) {
    $cleaned = Clean $part
    if ($cleaned) {
      $items += "<li>$([string](HtmlEncode($cleaned)))</li>"
    }
  }

  return ($items -join "`n              ")
}

function Get-RelatedLinksMarkup($row, $lookup) {
  $links = foreach ($related in (Get-RelatedRows $row $lookup)) {
    "<a class=`"pill`" href=`"/locations/$($related.slug)/`">$([string](HtmlEncode("$(Clean $related.city), $(Clean $related.state_code)")))</a>"
  }
  return ($links -join "`n              ")
}

function Get-RelatedCardsMarkup($row, $lookup) {
  $cards = foreach ($related in (Get-RelatedRows $row $lookup)) {
@"
          <article class="card reveal">
            <div class="kicker">Related city guide</div>
            <h3>$([string](HtmlEncode("$(Clean $related.city), $(Clean $related.state_code)")))</h3>
            <p>$([string](HtmlEncode((Get-MetaDescription $related))))</p>
            <div class="button-row">
              <a class="button button-primary" href="/locations/$($related.slug)/">Open city guide</a>
            </div>
          </article>
"@
  }

  return ($cards -join "`n")
}

function Get-FaqData($row) {
  return @(
    @{
      "@type" = "Question"
      "name" = Clean $row.faq_1_question
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = Get-FaqOneAnswer $row
      }
    },
    @{
      "@type" = "Question"
      "name" = Clean $row.faq_2_question
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = Get-FaqTwoAnswer $row
      }
    },
    @{
      "@type" = "Question"
      "name" = Clean $row.faq_3_question
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = Clean $row.faq_3_answer
      }
    }
  )
}

function Get-BreadcrumbData($siteUrl, $row) {
  return @(
    @{ "@type" = "ListItem"; "position" = 1; "name" = "Home"; "item" = "$siteUrl/" },
    @{ "@type" = "ListItem"; "position" = 2; "name" = "Locations"; "item" = "$siteUrl/locations/" },
    @{ "@type" = "ListItem"; "position" = 3; "name" = "$(Clean $row.city), $(Clean $row.state_code)"; "item" = "$(Get-CanonicalUrl $row $siteUrl)" }
  )
}

function New-LocationPage($row, $lookup, $siteUrl) {
  $title = Get-PageTitle $row
  $description = Get-MetaDescription $row
  $canonical = Get-CanonicalUrl $row $siteUrl
  $robots = Get-RobotsValue $row $lookup
  $faqJson = JsonText (Get-FaqData $row)
  $breadcrumbJson = JsonText (Get-BreadcrumbData $siteUrl $row)
  $relatedNames = ((Get-RelatedRows $row $lookup) | ForEach-Object { "$(Clean $_.city), $(Clean $_.state_code)" }) -join ", "
  $relatedLinks = Get-RelatedLinksMarkup $row $lookup
  $relatedCards = Get-RelatedCardsMarkup $row $lookup
  $checklistMarkup = Get-ChecklistMarkup (Clean $row.documentation_checklist)
  $heroIntro = Get-HeroIntro $row
  $overviewCopy = Get-OverviewCopy $row
  $researchContextCopy = Get-ResearchContextCopy $row
  $supplierCopy = Get-SupplierCopy $row
  $logisticsCopy = Get-LogisticsCopy $row
  $focusLine = "A close read in $(Clean $row.city) usually starts with $(Clean $row.documentation_focus), then moves into COA access, batch details, and policy consistency."

  $page = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$([string](HtmlEncode($title)))</title>
  <meta name="description" content="$([string](HtmlEncode($description)))">
  <meta name="robots" content="$robots">
  <link rel="canonical" href="$canonical">
  <meta property="og:type" content="article">
  <meta property="og:title" content="$([string](HtmlEncode($title)))">
  <meta property="og:description" content="$([string](HtmlEncode($description)))">
  <meta property="og:url" content="$canonical">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="$siteUrl/og-image.svg">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="$([string](HtmlEncode($title)))">
  <meta name="twitter:description" content="$([string](HtmlEncode($description)))">
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
          <span>Research supplier discovery and education</span>
        </span>
      </a>
      <nav class="nav" aria-label="Primary">
        <a href="/">Home</a>
        <a href="/education/">Education</a>
        <a class="active" href="/locations/">Locations</a>
        <a href="/suppliers/">Suppliers</a>
        <a href="/peptide-directory/">Directory</a>
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
          <span>$([string](HtmlEncode("$(Clean $row.city), $(Clean $row.state_code)")))</span>
        </nav>
        <div class="page-hero-card">
          <div class="page-hero-grid">
            <div class="page-hero-copy reveal">
              <div class="eyebrow">$([string](HtmlEncode((Clean $row.region))))</div>
              <h1 class="page-title">$([string](HtmlEncode((Clean $row.h1))))</h1>
              <p>$([string](HtmlEncode($heroIntro)))</p>
              <div class="button-row">
                <a class="button button-primary" href="/peptide-directory/">Open peptide directory</a>
                <a class="button button-ghost" href="/suppliers/">Browse suppliers</a>
              </div>
            </div>
            <div class="hero-art reveal delay-1">
              <img src="/assets/education-guides.svg" alt="Editorial-style illustration for city-specific research and supplier transparency guides">
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
          <p>$([string](HtmlEncode((Clean $row.disclaimer))))</p>
        </div>
      </div>
    </section>

    <section>
      <div class="shell location-grid">
        <article class="story-card reveal">
          <div class="kicker">Local overview</div>
          <h2>$([string](HtmlEncode("What stands out in $(Clean $row.city)")))</h2>
          <p>$([string](HtmlEncode($overviewCopy)))</p>
          <p>$([string](HtmlEncode($focusLine)))</p>
        </article>
        <article class="card context-card reveal delay-1">
          <div class="kicker">Local context</div>
          <h3>Quick reference</h3>
          <table class="context-table">
            <tbody>
              <tr>
                <th>City</th>
                <td>$([string](HtmlEncode((Clean $row.city))))</td>
              </tr>
              <tr>
                <th>State</th>
                <td>$([string](HtmlEncode((Clean $row.state))))</td>
              </tr>
              <tr>
                <th>Region</th>
                <td>$([string](HtmlEncode((Clean $row.region))))</td>
              </tr>
              <tr>
                <th>Local research anchor</th>
                <td>$([string](HtmlEncode((Clean $row.local_research_anchor))))</td>
              </tr>
              <tr>
                <th>Nearby cities</th>
                <td>$([string](HtmlEncode($relatedNames)))</td>
              </tr>
              <tr>
                <th>Documentation focus</th>
                <td>$([string](HtmlEncode((Clean $row.documentation_focus))))</td>
              </tr>
            </tbody>
          </table>
        </article>
      </div>
    </section>

    <section>
      <div class="shell location-grid">
        <article class="story-card reveal">
          <div class="kicker">Local research and biotech context</div>
          <h2>$([string](HtmlEncode("Research context in $(Clean $row.city)")))</h2>
          <p>$([string](HtmlEncode($researchContextCopy)))</p>
        </article>
        <article class="card reveal delay-1">
          <div class="kicker">Supplier transparency</div>
          <h3>What to look for on supplier pages</h3>
          <p>$([string](HtmlEncode($supplierCopy)))</p>
          <p>$([string](HtmlEncode($logisticsCopy)))</p>
        </article>
      </div>
    </section>

    <section>
      <div class="shell location-grid">
        <article class="story-card reveal">
          <div class="kicker">Documentation signals to evaluate</div>
          <h2>Checklist for city-specific reading</h2>
          <ul class="checklist">
              $checklistMarkup
          </ul>
        </article>
        <article class="card reveal delay-1">
          <div class="kicker">Related city guides</div>
          <h3>Continue with nearby reading</h3>
          <div class="pill-row">
              $relatedLinks
          </div>
        </article>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Related city guides</h2>
            <p>These nearby guides can help with comparing regional documentation habits and supplier transparency language.</p>
          </div>
        </div>
        <div class="resource-grid">
$relatedCards
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Frequently asked questions</h2>
            <p>These quick answers keep the page readable and focused on educational research context.</p>
          </div>
        </div>
        <div class="faq-grid">
          <article class="card reveal">
            <h3>$([string](HtmlEncode((Clean $row.faq_1_question))))</h3>
            <p>$([string](HtmlEncode((Get-FaqOneAnswer $row))))</p>
          </article>
          <article class="card reveal delay-1">
            <h3>$([string](HtmlEncode((Clean $row.faq_2_question))))</h3>
            <p>$([string](HtmlEncode((Get-FaqTwoAnswer $row))))</p>
          </article>
          <article class="card reveal delay-2">
            <h3>$([string](HtmlEncode((Clean $row.faq_3_question))))</h3>
            <p>$([string](HtmlEncode((Clean $row.faq_3_answer))))</p>
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
        <a href="/peptide-directory/">Peptide Directory</a>
        <a href="/suppliers/">Suppliers</a>
      </div>
    </div>
  </footer>
</body>
</html>
"@

  $folder = Join-Path $locationsRoot (Clean $row.slug)
  New-Item -ItemType Directory -Force -Path $folder | Out-Null
  Set-Content -Path (Join-Path $folder "index.html") -Value $page -Encoding UTF8
}

function New-LocationsHub($rows, $lookup, $siteUrl) {
  $groups = $rows | Sort-Object state, city | Group-Object state

  $jumpLinks = foreach ($group in $groups) {
    $stateSlug = ($group.Name.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
    "<a class=`"pill`" href=`"#state-$stateSlug`">$([string](HtmlEncode($group.Name)))</a>"
  }

  $sections = foreach ($group in $groups) {
    $stateSlug = ($group.Name.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
    $cards = foreach ($row in ($group.Group | Sort-Object city)) {
@"
            <article class="card reveal">
              <div class="kicker">City guide</div>
              <h3>$([string](HtmlEncode("$(Clean $row.city), $(Clean $row.state_code)")))</h3>
              <p>$([string](HtmlEncode((Get-MetaDescription $row))))</p>
              <div class="pill-row">
                <span class="pill">$([string](HtmlEncode((Clean $row.region))))</span>
                <span class="pill">$([string](HtmlEncode((Clean $row.local_research_anchor))))</span>
              </div>
              <div class="button-row">
                <a class="button button-primary" href="/locations/$(Clean $row.slug)/">Open city guide</a>
              </div>
            </article>
"@
    }

@"
        <section id="state-$stateSlug" class="location-section">
          <div class="section-head reveal">
            <div>
              <h2>$([string](HtmlEncode($group.Name)))</h2>
              <p>City guides for $([string](HtmlEncode($group.Name))) with local context, documentation cues, and related reading paths.</p>
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
  <meta name="description" content="Browse city-by-city educational guides focused on research context, supplier transparency, laboratory documentation, and related regional reading.">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="$siteUrl/locations/">
  <meta property="og:type" content="website">
  <meta property="og:title" content="Location-Based Peptide Research Guides | PeptideSuppliers.org">
  <meta property="og:description" content="State-grouped city guides focused on local context, supplier transparency, and laboratory documentation.">
  <meta property="og:url" content="$siteUrl/locations/">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="$siteUrl/og-image.svg">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="Location-Based Peptide Research Guides | PeptideSuppliers.org">
  <meta name="twitter:description" content="State-grouped city guides focused on local context, supplier transparency, and laboratory documentation.">
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
        <a href="/education/">Education</a>
        <a class="active" href="/locations/">Locations</a>
        <a href="/suppliers/">Suppliers</a>
        <a href="/peptide-directory/">Directory</a>
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
              <p>This hub groups city guides by state and keeps the focus on local research context, supplier transparency, and laboratory documentation.</p>
              <div class="button-row">
                <a class="button button-primary" href="/peptide-directory/">Open peptide directory</a>
                <a class="button button-ghost" href="/suppliers/">Browse suppliers</a>
              </div>
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
        <a href="/peptide-directory/">Peptide Directory</a>
        <a href="/suppliers/">Suppliers</a>
      </div>
    </div>
  </footer>
</body>
</html>
"@
}

function Update-Sitemap($repoRoot, $sitemapPath) {
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
$rows = Import-Csv $dataPath | Sort-Object state, city
$lookup = @{}
foreach ($row in $rows) {
  $lookup[(Clean $row.slug)] = $row
}

foreach ($row in $rows) {
  New-LocationPage -row $row -lookup $lookup -siteUrl $siteUrl
}

$hubHtml = New-LocationsHub -rows $rows -lookup $lookup -siteUrl $siteUrl
Set-Content -Path (Join-Path $locationsRoot "index.html") -Value $hubHtml -Encoding UTF8

Update-Sitemap -repoRoot $repoRoot -sitemapPath $sitemapPath
