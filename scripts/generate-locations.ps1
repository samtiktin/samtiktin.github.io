$ErrorActionPreference = "Stop"

# Add more cities by adding rows to data/locations.csv.
# Each row should include a unique slug, city, state, local news angle,
# transparency note, logistics note, and three related city slugs.

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot "data\locations.csv"
$locationsRoot = Join-Path $repoRoot "locations"
$stylesPath = Join-Path $repoRoot "styles.css"
$educationPath = Join-Path $repoRoot "education\index.html"
$sitemapPath = Join-Path $repoRoot "sitemap.xml"

function Get-SiteUrl {
  $cnamePath = Join-Path $repoRoot "CNAME"
  if (Test-Path $cnamePath) {
    $cname = (Get-Content $cnamePath -Raw).Trim()
    if ($cname) {
      return "https://$cname"
    }
  }

  if (Test-Path $sitemapPath) {
    try {
      [xml]$sitemapXml = Get-Content $sitemapPath -Raw
      $firstLoc = $sitemapXml.urlset.url[0].loc
      if ($firstLoc) {
        $uri = [System.Uri]$firstLoc
        return $uri.GetLeftPart([System.UriPartial]::Authority)
      }
    } catch {
    }
  }

  return "https://peptidesuppliers.org"
}

function HtmlEncode([string]$value) {
  return [System.Net.WebUtility]::HtmlEncode($value)
}

function JsonEscape([string]$value) {
  return ($value | ConvertTo-Json -Compress).Trim('"')
}

function Build-Title($row) {
  return "$($row.city), $($row.state_code) Peptide Research News & Supplier Transparency Guide"
}

function Build-MetaDescription($row) {
  if ($row.PSObject.Properties.Name -contains "meta_description" -and $row.meta_description) {
    return $row.meta_description
  }
  return "$($row.city), $($row.state_code) peptide research news, laboratory documentation trends, and supplier transparency signals for local readers."
}

function Build-Robots([string]$indexFlag) {
  if ($indexFlag -eq "true") { return "index,follow" }
  return "noindex,follow"
}

function Build-RelatedLinks($row, $lookup) {
  $items = @()
  foreach ($key in @("related_1", "related_2", "related_3")) {
    $slug = $row.$key
    if ($slug -and $lookup.ContainsKey($slug)) {
      $related = $lookup[$slug]
      $items += "<a class=`"pill`" href=`"/locations/$slug/`">$([string](HtmlEncode("$($related.city), $($related.state_code)")))</a>"
    }
  }
  return ($items -join "`n            ")
}

function BuildHubCards($rows) {
  $groups = $rows | Sort-Object state_name, city | Group-Object state_name
  $sections = foreach ($group in $groups) {
    $stateRows = $group.Group | Sort-Object city
    $cards = foreach ($row in $stateRows) {
      $title = "$($row.city), $($row.state_code)"
      $description = Build-MetaDescription $row
@"
            <article class="card reveal">
              <div class="kicker">City guide</div>
              <h3>$([string](HtmlEncode($title)))</h3>
              <p>$([string](HtmlEncode($description)))</p>
              <div class="pill-row">
                <span class="pill">$([string](HtmlEncode($row.metro_label)))</span>
                <span class="pill">Research news</span>
                <span class="pill">Transparency signals</span>
              </div>
              <div class="button-row">
                <a class="button button-primary" href="/locations/$($row.slug)/">Open city guide</a>
              </div>
            </article>
"@
    }

@"
        <section id="state-$((($group.Name).ToLower() -replace '[^a-z0-9]+','-').Trim('-'))" class="location-section">
          <div class="section-head reveal">
            <div>
              <h2>$([string](HtmlEncode($group.Name)))</h2>
              <p>City guides for $([string](HtmlEncode($group.Name))) readers, grouped together so the hub stays easier to browse.</p>
            </div>
          </div>
          <div class="resource-grid">
$($cards -join "`n")
          </div>
        </section>
"@
  }
  return ($sections -join "`n")
}

function BuildHubIndex($rows) {
  $items = $rows |
    Sort-Object state_name, city |
    Group-Object state_name |
    ForEach-Object {
      $slug = ((($_.Name).ToLower() -replace '[^a-z0-9]+','-').Trim('-'))
      "<a class=`"pill`" href=`"#state-$slug`">$([string](HtmlEncode($_.Name)))</a>"
    }
  return ($items -join "`n            ")
}

function BuildFaqJson($city, $stateCode, $metroLabel) {
  $faq = @(
    @{
      "@type" = "Question"
      "name" = "What does this $city peptide research news page cover?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = "This page highlights peptide research news angles, supplier transparency signals, and laboratory documentation topics that may matter to readers in $city, $stateCode."
      }
    },
    @{
      "@type" = "Question"
      "name" = "Why focus on supplier transparency in ${city}?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = "Readers in ${metroLabel} often compare supplier pages by COA access, batch testing language, research-use labeling, shipping transparency, and third-party testing references rather than by promotional claims."
      }
    },
    @{
      "@type" = "Question"
      "name" = "Does this page recommend peptides or human use?"
      "acceptedAnswer" = @{
        "@type" = "Answer"
        "text" = "No. This page is educational and informational only. It does not sell peptides, provide medical advice, or recommend human use."
      }
    }
  )
  return ($faq | ConvertTo-Json -Depth 6 -Compress)
}

function BuildBreadcrumbJson($siteUrl, $city, $slug) {
  $items = @(
    @{ "@type" = "ListItem"; "position" = 1; "name" = "Home"; "item" = "$siteUrl/" },
    @{ "@type" = "ListItem"; "position" = 2; "name" = "Locations"; "item" = "$siteUrl/locations/" },
    @{ "@type" = "ListItem"; "position" = 3; "name" = "$city"; "item" = "$siteUrl/locations/$slug/" }
  )
  return ($items | ConvertTo-Json -Depth 5 -Compress)
}

function New-LocationPage($row, $lookup, $siteUrl) {
  $slug = $row.slug
  $city = $row.city
  $stateCode = $row.state_code
  $stateName = $row.state_name
  $metroLabel = $row.metro_label
  $title = Build-Title $row
  $metaDescription = Build-MetaDescription $row
  $canonical = "$siteUrl/locations/$slug/"
  $robots = Build-Robots $row.index
  $faqJson = BuildFaqJson $city $stateCode $row.metro_label
  $breadcrumbJson = BuildBreadcrumbJson $siteUrl $city $slug
  $relatedLinks = Build-RelatedLinks $row $lookup

  return @"
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
          <span>$([string](HtmlEncode($city)))</span>
        </nav>
        <div class="page-hero-card">
          <div class="page-hero-grid">
            <div class="page-hero-copy reveal">
              <div class="eyebrow">Location guide</div>
              <h1 class="page-title">$([string](HtmlEncode($title)))</h1>
              <p>
                $([string](HtmlEncode($city))), $([string](HtmlEncode($stateCode))) readers often look for peptide industry coverage that feels
                local, practical, and transparent. This page focuses on research news, laboratory
                documentation habits, and the supplier transparency cues that stand out in $([string](HtmlEncode($metroLabel))).
              </p>
              <div class="pill-row">
                <span class="pill">$([string](HtmlEncode($city))), $([string](HtmlEncode($stateCode)))</span>
                <span class="pill">Research news</span>
                <span class="pill">Supplier transparency</span>
              </div>
            </div>
            <div class="hero-art reveal delay-1">
              <img src="/assets/education-guides.svg" alt="Editorial-style illustration for local research news and supplier transparency guides">
            </div>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="notice reveal">
          <div class="kicker">Educational disclaimer</div>
          <h3>This page is for educational and informational purposes only.</h3>
          <p>This page is for educational and informational purposes only. PeptideSuppliers.org does not sell peptides, provide medical advice, or recommend human use.</p>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="location-grid">
          <article class="story-card reveal">
            <div class="kicker">Local overview</div>
            <h2>$([string](HtmlEncode($city))) research and transparency context</h2>
            <p>
              $([string](HtmlEncode($row.description_seed)))
            </p>
            <p>
              $([string](HtmlEncode($row.news_angle)))
            </p>
          </article>
          <article class="card reveal delay-1">
            <div class="kicker">What often matters locally</div>
            <h3>Why this city gets its own page</h3>
            <ul class="checklist">
              <li>$([string](HtmlEncode($row.transparency_note)))</li>
              <li>$([string](HtmlEncode($row.logistics_note)))</li>
              <li>Regional readers often compare how clearly supplier pages explain laboratory documentation, not just broad testing claims.</li>
            </ul>
          </article>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Peptide research news trends in $([string](HtmlEncode($city)))</h2>
            <p>
              These are the kinds of topics that usually make local coverage more useful than a generic city page.
            </p>
          </div>
        </div>
        <div class="resource-grid">
          <article class="card reveal">
            <div class="kicker">Industry news</div>
            <h3>Research reporting</h3>
            <p>$([string](HtmlEncode($row.news_angle)))</p>
          </article>
          <article class="card reveal delay-1">
            <div class="kicker">Documentation</div>
            <h3>Laboratory paperwork and COAs</h3>
            <p>$([string](HtmlEncode($row.transparency_note)))</p>
          </article>
          <article class="card reveal delay-2">
            <div class="kicker">Logistics</div>
            <h3>Shipping and fulfillment language</h3>
            <p>$([string](HtmlEncode($row.logistics_note)))</p>
          </article>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Supplier transparency signals to watch in $([string](HtmlEncode($city)))</h2>
            <p>
              This is the same research-first checklist used across the broader site, adapted to a local news and documentation angle.
            </p>
          </div>
        </div>
        <div class="score-grid">
          <article class="score-box reveal">
            <div class="kicker">Signal</div>
            <h3>COA availability</h3>
            <strong>1</strong>
            <p>Pages should make certificates of analysis easy to find and easy to read without forcing extra clicks.</p>
          </article>
          <article class="score-box reveal delay-1">
            <div class="kicker">Signal</div>
            <h3>Batch testing</h3>
            <strong>2</strong>
            <p>Testing language feels stronger when it connects to specific batches or product-level laboratory documentation.</p>
          </article>
          <article class="score-box reveal delay-2">
            <div class="kicker">Signal</div>
            <h3>Research-use labeling</h3>
            <strong>3</strong>
            <p>Research-focused wording should stay consistent across product, FAQ, and policy content rather than appearing as an afterthought.</p>
          </article>
          <article class="score-box reveal delay-3">
            <div class="kicker">Signal</div>
            <h3>Shipping transparency</h3>
            <strong>4</strong>
            <p>Clear dispatch windows, carrier notes, and handling language are more useful than vague speed claims.</p>
          </article>
          <article class="score-box reveal">
            <div class="kicker">Signal</div>
            <h3>Third-party testing</h3>
            <strong>5</strong>
            <p>Third-party testing references carry more weight when the underlying documents are readable and current.</p>
          </article>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="science-grid">
          <article class="card reveal">
            <div class="kicker">Helpful background</div>
            <h3>Keep the page tied to educational reading</h3>
            <p>
              These city guides work best as a local reading layer on top of the broader education section. They are meant to help readers follow research news and transparency trends, not to replace careful due diligence.
            </p>
            <div class="button-row">
              <a class="button button-primary" href="/what-is-a-coa/">What is a COA?</a>
              <a class="button button-ghost" href="/how-to-compare-peptide-suppliers/">Compare supplier pages</a>
            </div>
          </article>
          <article class="card reveal delay-1">
            <div class="kicker">Related city guides</div>
            <h3>Nearby or related pages</h3>
            <div class="pill-row">
              $relatedLinks
            </div>
            <div class="button-row">
              <a class="button button-secondary" href="/locations/">Browse all locations</a>
            </div>
          </article>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Frequently asked questions about $([string](HtmlEncode($city))) peptide research news</h2>
            <p>These questions are tailored to local readers and keep the page useful without turning it into a generic doorway page.</p>
          </div>
        </div>
        <div class="faq-grid">
          <article class="card reveal">
            <h3>What does this $([string](HtmlEncode($city))) page focus on?</h3>
            <p>
              It focuses on local peptide research news angles, laboratory documentation quality, and the supplier transparency cues that often matter most in $([string](HtmlEncode($city))), $([string](HtmlEncode($stateCode))).
            </p>
          </article>
          <article class="card reveal delay-1">
            <h3>Why mention shipping transparency on a local page?</h3>
            <p>
              Shipping language often affects how trustworthy a supplier page feels. In $([string](HtmlEncode($metroLabel))), clear handling notes and dispatch details can matter as much as the testing language itself.
            </p>
          </article>
          <article class="card reveal delay-2">
            <h3>Does this page recommend peptides or human use?</h3>
            <p>
              No. It is an educational page about supplier transparency, industry news, and laboratory documentation. It does not recommend human use or provide medical advice.
            </p>
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
}

function New-LocationsHub($rows, $siteUrl) {
  $cards = BuildHubCards $rows
  $hubIndex = BuildHubIndex $rows
  return @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Peptide Research News by City | PeptideSuppliers.org</title>
  <meta name="description" content="Browse peptide research news and supplier transparency guides by city, with local FAQ sections, laboratory documentation topics, and related reading.">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="$siteUrl/locations/">
  <meta property="og:type" content="website">
  <meta property="og:title" content="Peptide Research News by City | PeptideSuppliers.org">
  <meta property="og:description" content="City-by-city peptide research news and supplier transparency guides for educational reading.">
  <meta property="og:url" content="$siteUrl/locations/">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="$siteUrl/og-image.svg">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="Peptide Research News by City | PeptideSuppliers.org">
  <meta name="twitter:description" content="City-by-city peptide research news and supplier transparency guides for educational reading.">
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
              <h1 class="page-title">Peptide research news and supplier transparency by city</h1>
              <p>
                This hub collects city pages that focus on local research news angles, laboratory documentation, and supplier transparency patterns. The goal is to make each page genuinely useful to readers in that city, not to publish thin location placeholders.
              </p>
            </div>
            <div class="hero-art reveal delay-1">
              <img src="/assets/education-guides.svg" alt="Editorial-style illustration for city-based research news and transparency guides">
            </div>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="notice reveal">
          <div class="kicker">Educational disclaimer</div>
          <h3>This page is for educational and informational purposes only.</h3>
          <p>This page is for educational and informational purposes only. PeptideSuppliers.org does not sell peptides, provide medical advice, or recommend human use.</p>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="jump-nav reveal sticky-directory-nav">
          <strong>Browse by state</strong>
          <div class="jump-links">
            $hubIndex
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>City guides</h2>
            <p>Each page combines local news context, documentation signals, FAQ markup, and related city links so the content is more useful than a thin city template. Cities are grouped by state to keep the hub easier to scan.</p>
          </div>
        </div>
$cards
      </div>
    </section>
  </main>

  <footer class="footer">
    <div class="shell footer-row">
      <span>&copy; 2026 PeptideSuppliers.org</span>
      <div class="footer-links">
        <a href="/education/">Education</a>
        <a href="/how-to-compare-peptide-suppliers/">Compare Suppliers</a>
        <a href="/privacy/">Privacy</a>
      </div>
    </div>
  </footer>
</body>
</html>
"@
}

function Ensure-LocationStyles {
  $css = Get-Content $stylesPath -Raw
  if ($css -match "\.breadcrumbs \{") { return }

  $locationCss = @"

.breadcrumbs {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin: 0 0 18px;
  color: var(--muted);
  font-size: 0.92rem;
}

.breadcrumbs a {
  text-decoration: none;
}

.location-grid {
  display: grid;
  gap: 24px;
  grid-template-columns: 1.15fr 0.85fr;
}

.location-grid .story-card,
.location-grid .card,
.faq-grid .card {
  height: 100%;
}

.faq-grid {
  display: grid;
  gap: 24px;
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

@media (max-width: 940px) {
  .location-grid,
  .faq-grid {
    grid-template-columns: 1fr;
  }
}
"@

  Set-Content $stylesPath ($css.TrimEnd() + "`r`n" + $locationCss)
}

function Ensure-EducationLink {
  $html = Get-Content $educationPath -Raw
  if ($html -match "/locations/") { return }

  $insert = @"
        <article class="card reveal">
          <div class="kicker">Locations</div>
          <h3>Peptide research news by city</h3>
          <p>Browse city-based guides that combine local research coverage, supplier transparency cues, and laboratory documentation questions.</p>
          <div class="button-row">
            <a class="button button-primary" href="/locations/">Open locations hub</a>
          </div>
        </article>
"@

  $html = $html.Replace('        <article class="card reveal delay-2">
          <div class="kicker">Next step</div>', $insert + @'
        <article class="card reveal delay-2">
          <div class="kicker">Next step</div>
'@)
  Set-Content $educationPath $html
}

function Validate-LocationData($rows) {
  $errors = New-Object System.Collections.Generic.List[string]
  $slugSet = @{}
  foreach ($row in $rows) {
    if (-not $row.slug -or $row.slug -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
      $errors.Add("Invalid slug: $($row.slug)")
    }
    if ($slugSet.ContainsKey($row.slug)) {
      $errors.Add("Duplicate slug: $($row.slug)")
    } else {
      $slugSet[$row.slug] = $true
    }
    if (-not $row.city -or -not $row.state_name -or -not $row.state_code) {
      $errors.Add("Missing required city/state fields for slug: $($row.slug)")
    }
    foreach ($key in @("related_1","related_2","related_3")) {
      if (-not $row.$key) {
        $errors.Add("Missing $key for slug: $($row.slug)")
      }
    }
  }

  if ($errors.Count -gt 0) {
    throw ($errors -join "`n")
  }
}

function Update-Sitemap($rows, $siteUrl) {
  if (-not (Test-Path $sitemapPath)) { return }
  [xml]$xml = Get-Content $sitemapPath -Raw
  $namespace = $xml.DocumentElement.NamespaceURI
  $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
  $ns.AddNamespace("sm", $namespace)

  $existingLocs = @{}
  foreach ($node in $xml.SelectNodes("//sm:url/sm:loc", $ns)) {
    $existingLocs[$node.InnerText] = $true
  }

  $urlsToAdd = New-Object System.Collections.Generic.List[string]
  $urlsToAdd.Add("$siteUrl/locations/")
  foreach ($row in $rows) {
    if ($row.index -eq "true") {
      $urlsToAdd.Add("$siteUrl/locations/$($row.slug)/")
    }
  }

  foreach ($url in $urlsToAdd) {
    if (-not $existingLocs.ContainsKey($url)) {
      $urlNode = $xml.CreateElement("url", $namespace)
      $locNode = $xml.CreateElement("loc", $namespace)
      $locNode.InnerText = $url
      $urlNode.AppendChild($locNode) | Out-Null
      $xml.urlset.AppendChild($urlNode) | Out-Null
    }
  }

  $xml.Save($sitemapPath)
}

function Verify-Locations($siteUrl) {
  $files = Get-ChildItem $locationsRoot -Recurse -Filter index.html
  $titles = @{}
  $errors = New-Object System.Collections.Generic.List[string]
  $prohibited = @(
    "\bbuy now\b",
    "\bbuy\b",
    "\border\b",
    "\bshop\b",
    "\bfor sale\b",
    "\bweight loss\b",
    "\bhealing\b",
    "\banti-aging\b",
    "\bmuscle growth\b",
    "\bdisease treatment\b"
  )

  foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -notmatch '<title>.+?</title>') { $errors.Add("Missing title tag: $($file.FullName)") }
    if ($content -notmatch '<meta name="description" content=".+?">') { $errors.Add("Missing meta description: $($file.FullName)") }
    if ($content -notmatch '<link rel="canonical" href=".+?">') { $errors.Add("Missing canonical tag: $($file.FullName)") }

    $title = [regex]::Match($content, '<title>(.+?)</title>').Groups[1].Value
    if ($title) {
      if ($titles.ContainsKey($title)) { $errors.Add("Duplicate title tag: $title") }
      else { $titles[$title] = $true }
    }

    $relativePath = $file.FullName.Substring($repoRoot.Length).TrimStart('\')
    $urlPath = "/" + ($relativePath.Replace("\index.html", "\").Replace("\", "/"))
    $expectedCanonical = "$siteUrl" + $urlPath.TrimEnd("/")
    if ($urlPath -eq "/index.html") { $expectedCanonical = "$siteUrl/" }
    if ($content -notmatch [regex]::Escape($expectedCanonical + "/?")) { }

    foreach ($pattern in $prohibited) {
      if ([regex]::IsMatch($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        $errors.Add("Prohibited sales or medical language pattern '$pattern' found in $($file.FullName)")
      }
    }

    $hrefs = [regex]::Matches($content, 'href="(/locations/[^"]*/)"') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
    foreach ($href in $hrefs) {
      $targetPath = $href.TrimStart('/').Replace('/', '\')
      $targetFile = Join-Path $repoRoot $targetPath
      if (-not (Test-Path (Join-Path $targetFile "index.html"))) {
        $errors.Add("Broken internal location link $href in $($file.FullName)")
      }
    }
  }

  if ($errors.Count -gt 0) {
    throw ($errors -join "`n")
  }
}

$siteUrl = Get-SiteUrl
$rows = Import-Csv $dataPath
Validate-LocationData $rows
$lookup = @{}
foreach ($row in $rows) { $lookup[$row.slug] = $row }

if (-not (Test-Path $locationsRoot)) {
  New-Item -ItemType Directory -Path $locationsRoot | Out-Null
}

Ensure-LocationStyles
Ensure-EducationLink

$hubHtml = New-LocationsHub $rows $siteUrl
Set-Content (Join-Path $locationsRoot "index.html") $hubHtml

foreach ($row in $rows) {
  $cityDir = Join-Path $locationsRoot $row.slug
  if (-not (Test-Path $cityDir)) {
    New-Item -ItemType Directory -Path $cityDir | Out-Null
  }
  $pageHtml = New-LocationPage $row $lookup $siteUrl
  Set-Content (Join-Path $cityDir "index.html") $pageHtml
}

Update-Sitemap $rows $siteUrl
Verify-Locations $siteUrl
