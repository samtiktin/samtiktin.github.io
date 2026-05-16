$ErrorActionPreference = "Stop"

$root = "C:\Users\leaht\Downloads\samtiktin.github.io-main\samtiktin.github.io-main"
$peptidesRoot = Join-Path $root "peptides"
New-Item -ItemType Directory -Force -Path $peptidesRoot | Out-Null

function Get-DiscountCode($supplier) {
  switch ($supplier) {
    "Iron Peptides" { return "IRONMAN" }
    "Pinnacle Peptide Labs" { return "PPL15" }
    "Peptides Kingdom" { return "KING15" }
    "Ascension Peptides" { return "PEPTIDE10" }
    "Amino Club" { return "AMINOSAVE" }
    default { return $null }
  }
}

function Get-CategoryTitle($key) {
  switch ($key) {
    "metabolic" { "Metabolic & GLP-1" }
    "recovery" { "Recovery & Repair" }
    "growth" { "GH & Performance" }
    "cognitive" { "Cognitive & Longevity" }
    "specialty" { "Specialty & Blends" }
  }
}

function Get-CategoryBlurb($key) {
  switch ($key) {
    "metabolic" { "These entries usually show up in body-composition, appetite, metabolic, and broader weight-management research catalogs." }
    "recovery" { "These compounds are commonly grouped into repair, recovery, restoration, and appearance-oriented research categories." }
    "growth" { "These listings usually appear in growth-hormone, signaling, performance, and hormone-oriented research sections." }
    "cognitive" { "These peptides often sit in nootropic, sleep-support, neurotrophic, or longevity-oriented research collections." }
    "specialty" { "These are more niche or advanced entries that still benefit from direct, peptide-level navigation." }
  }
}

function Get-ResearchNote($key) {
  switch ($key) {
    "metabolic" { "Visitors usually compare this type of peptide by supplier clarity, category fit, product format, and whether the site makes trust signals obvious before checkout." }
    "recovery" { "On this site, recovery-oriented peptides are usually compared by documentation visibility, batch presentation, site clarity, and whether the supplier makes the product easy to contextualize." }
    "growth" { "Growth and performance compounds often get compared by product format, catalog depth, research-use framing, and how polished the supplier pages feel." }
    "cognitive" { "Cognitive and longevity entries are usually evaluated by clarity, supplier transparency, formulation visibility, and how confidently the site explains the product without over-claiming." }
    "specialty" { "Specialty compounds benefit from direct product pages because visitors often want to compare the supplier presentation, product specifics, and trust signals quickly." }
  }
}

$peptides = @(
  [pscustomobject]@{slug="tirzepatide";name="Tirzepatide";category="metabolic";image="https://peptideskingdom.com/wp-content/uploads/2025/08/tirzepatide-research-peptide-20mg-vial-99-purity-lab-tested-768x768.png";suppliers=@(@{name="Peptides Kingdom";link="https://peptideskingdom.com/product/tirzepatide/?ref=isgicbuw"})},
  [pscustomobject]@{slug="semaglutide";name="Semaglutide";category="metabolic";image="https://ironpeptides.is/wp-content/uploads/2025/05/SEMA-GLP-1-10MG-scaled.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/sema-glp-1/?ref=ironman"},@{name="Peptides Kingdom";link="https://peptideskingdom.com/product/semaglutide/?ref=isgicbuw"})},
  [pscustomobject]@{slug="retatrutide";name="Retatrutide";category="metabolic";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2025/08/ChatGPT-Image-Sep-12-2025-08_55_03-PM.png?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/glp-3rt-peptide/aff/3/"},@{name="Iron Peptides";link="https://ironpeptides.is/product/glp-3/?ref=ironman"})},
  [pscustomobject]@{slug="cagrilintide";name="Cagrilintide";category="metabolic";image="https://ironpeptides.is/wp-content/uploads/2025/10/Cagrilintide-scaled.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/cagrilintide-10mg/?ref=ironman"})},
  [pscustomobject]@{slug="tesofensine";name="Tesofensine";category="metabolic";image="https://ironpeptides.is/wp-content/uploads/2025/05/500MCG-100-CAPSULES.png";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/tesofensine-500mcg-100-capsules/?ref=ironman"})},
  [pscustomobject]@{slug="nad-plus";name="NAD+";category="metabolic";image="https://spcdn.shortpixel.ai/spio/ret_img,q_cdnize,to_webp,s_webp/peptideskingdom.com/wp-content/uploads/2025/08/nad-research-peptide-500mg-vial-99-purity-lab-tested-768x768.png";suppliers=@(@{name="Peptides Kingdom";link="https://peptideskingdom.com/product/nad/?ref=isgicbuw"})},
  [pscustomobject]@{slug="aod-9604";name="AOD-9604";category="metabolic";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2025/08/ChatGPT-Image-Sep-11-2025-09_11_13-PM.png?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/aod-9604/aff/3/"})},
  [pscustomobject]@{slug="5-amino-1mq";name="5-amino 1MQ";category="metabolic";image="https://ironpeptides.is/wp-content/uploads/2025/11/5-amino-1mq-cap-scaled.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/5-amino-1mq-capsules/?ref=ironman"})},
  [pscustomobject]@{slug="mazdutide";name="Mazdutide";category="metabolic";image="https://ironpeptides.is/wp-content/uploads/2026/01/Mazdutide-10MG-scaled.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/mazdutide-10mg/?ref=ironman"})},

  [pscustomobject]@{slug="bpc-157";name="BPC-157";category="recovery";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2025/08/ChatGPT-Image-Sep-11-2025-08_41_35-PM.png?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/bpc-157/aff/3/"})},
  [pscustomobject]@{slug="tb-500";name="TB-500";category="recovery";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2025/07/ChatGPT-Image-Sep-26-2025-09_25_30-PM.png?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/tb-500-peptide-5-mg/aff/3/"})},
  [pscustomobject]@{slug="ghk-cu";name="GHK-Cu";category="recovery";image="https://spcdn.shortpixel.ai/spio/ret_img,q_cdnize,to_webp,s_webp/peptideskingdom.com/wp-content/uploads/2025/09/ghk-cu-50mg.png";suppliers=@(@{name="Peptides Kingdom";link="https://peptideskingdom.com/product/ghk-cu-copper-peptide/?ref=isgicbuw"},@{name="Amino Club";link="https://aminoclub.com?utm_source=affiliate_marketing&code=AMINOSAVE"})},
  [pscustomobject]@{slug="mots-c";name="MOTS-c";category="recovery";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2025/07/IMG_8347.jpeg?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/mots-c-peptide-10-mg/aff/3/"})},
  [pscustomobject]@{slug="glow";name="Glow";category="recovery";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2025/07/GLOW-70mg-vial.png?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/glow-peptide/aff/3/"})},
  [pscustomobject]@{slug="igf-1-des";name="IGF-1 DES";category="recovery";image="https://spcdn.shortpixel.ai/spio/ret_img,q_cdnize,to_webp,s_webp/peptideskingdom.com/wp-content/uploads/2025/08/igf-1-research-peptide-1mg-vial-99-purity-lab-tested-768x768.png";suppliers=@(@{name="Peptides Kingdom";link="https://peptideskingdom.com/product/igf-1-des/?ref=isgicbuw"})},

  [pscustomobject]@{slug="oxytocin";name="Oxytocin";category="growth";image="https://ironpeptides.is/wp-content/uploads/2025/10/Oxytocin-5mg-scaled.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/oxytocin-5mg/?ref=ironman"})},
  [pscustomobject]@{slug="sermorelin";name="Sermorelin";category="growth";image="https://spcdn.shortpixel.ai/spio/ret_img,q_cdnize,to_webp,s_webp/peptideskingdom.com/wp-content/uploads/2026/03/Sermorelin-research-peptides-10mg-768x768.png";suppliers=@(@{name="Peptides Kingdom";link="https://peptideskingdom.com/product/sermorelin/?ref=isgicbuw"})},
  [pscustomobject]@{slug="tesamorelin";name="Tesamorelin";category="growth";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2025/06/ChatGPT-Image-Sep-23-2025-09_06_10-PM.png?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/tesamorelin-peptide-5-mg/aff/3/"})},
  [pscustomobject]@{slug="ipamorelin";name="Ipamorelin";category="growth";image="https://spcdn.shortpixel.ai/spio/ret_img,q_cdnize,to_webp,s_webp/peptideskingdom.com/wp-content/uploads/2025/08/ipamorelin-research-peptide-5mg-vial-99-purity-lab-tested-768x768.png";suppliers=@(@{name="Peptides Kingdom";link="https://peptideskingdom.com/product/ipamorelin/?ref=isgicbuw"})},
  [pscustomobject]@{slug="cjc-1295-ipamorelin";name="CJC-1295 / Ipamorelin";category="growth";image="https://ironpeptides.is/wp-content/uploads/2025/08/Ipamorelin-CJC-1295-No-Dac-10mg-600x522.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/ipamorelin-cjc-1295-no-dac/?ref=ironman"})},
  [pscustomobject]@{slug="cjc-1295";name="CJC-1295";category="growth";image="https://spcdn.shortpixel.ai/spio/ret_img,q_cdnize,to_webp,s_webp/peptideskingdom.com/wp-content/uploads/2025/08/cjc-1295-without-dac-research-peptide-2mg-vial-99-purity-lab-tested-768x768.png";suppliers=@(@{name="Peptides Kingdom";link="https://peptideskingdom.com/product/cjc-1295-without-dac-mod-grf-1-29/?ref=isgicbuw"})},
  [pscustomobject]@{slug="mk-677";name="MK-677";category="growth";image="https://ironpeptides.is/wp-content/uploads/2025/07/MK-677-12.5MG-60-CAPSULES.png";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/mk-677-12-5mg-60-capsules/?ref=ironman"})},
  [pscustomobject]@{slug="igf-1-lr3";name="IGF-1 LR3";category="growth";image="https://spcdn.shortpixel.ai/spio/ret_img,q_cdnize,to_webp,s_webp/peptideskingdom.com/wp-content/uploads/2025/08/igf-1-research-peptide-1mg-vial-99-purity-lab-tested-768x768.png";suppliers=@(@{name="Peptides Kingdom";link="https://peptideskingdom.com/product/igf-1-lr3/?ref=isgicbuw"})},
  [pscustomobject]@{slug="pt-141";name="PT-141";category="growth";image="https://ironpeptides.is/wp-content/uploads/2025/05/PT-141-render_0605.jpg";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/pt-141-10mg/?ref=ironman"})},
  [pscustomobject]@{slug="gonadorelin";name="Gonadorelin";category="growth";image="https://ironpeptides.is/wp-content/uploads/2025/10/Gonadorelin-2mg-scaled.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/gonadorelin/?ref=ironman"})},
  [pscustomobject]@{slug="hexarelin";name="Hexarelin";category="growth";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2025/12/ChatGPT-Image-Dec-5-2025-05_53_10-PM.png?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/hexarelin-5mg/aff/3/"})},
  [pscustomobject]@{slug="thymosin-alpha-1";name="Thymosin Alpha-1";category="growth";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2025/10/thymosin-alpha-1-research-peptide.jpg.png?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/thymosin-alpha-1/aff/3/"})},
  [pscustomobject]@{slug="kisspeptin-10";name="Kisspeptin-10";category="growth";image="https://ironpeptides.is/wp-content/uploads/2025/09/Kisspeptin-10-10mg-scaled.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/kisspeptin-10/?ref=ironman"})},

  [pscustomobject]@{slug="semax";name="Semax";category="cognitive";image="https://spcdn.shortpixel.ai/spio/ret_img,q_cdnize,to_webp,s_webp/peptideskingdom.com/wp-content/uploads/2025/08/semax-research-peptide-5mg-vial-99-purity-lab-tested-2-768x768.png";suppliers=@(@{name="Peptides Kingdom";link="https://peptideskingdom.com/product/semax/?ref=isgicbuw"})},
  [pscustomobject]@{slug="selank";name="Selank";category="cognitive";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2025/09/ChatGPT-Image-Sep-12-2025-10_19_26-PM.png?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/selank-peptide-10-mg/aff/3/"})},
  [pscustomobject]@{slug="cerebrolysin";name="Cerebrolysin";category="cognitive";image="https://ironpeptides.is/wp-content/uploads/2025/11/Cerebrolysin-60MG-scaled.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/cerebrolysin-60mg/?ref=ironman"})},
  [pscustomobject]@{slug="dsip";name="DSIP";category="cognitive";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2025/06/ChatGPT-Image-Sep-12-2025-08_11_31-PM.png?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/dsip/aff/3/"})},
  [pscustomobject]@{slug="dihexa";name="Dihexa";category="cognitive";image="https://ironpeptides.is/wp-content/uploads/2026/02/Untitled-design-3.png";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/dihexa/?ref=ironman"})},
  [pscustomobject]@{slug="epitalon";name="Epitalon";category="cognitive";image="https://ascensionpeptides.com/wp-content/uploads/2024/03/Ascension-Epithalon-10mg-600x600.jpg";suppliers=@(@{name="Ascension Peptides";link="https://ascensionpeptides.com/ref/PEPTIDE10/?s=epitalon"},@{name="Iron Peptides";link="https://ironpeptides.is/product/epitalon/?ref=ironman"})},
  [pscustomobject]@{slug="foxo4-dri";name="FOXO4-DRI";category="cognitive";image="https://ironpeptides.is/wp-content/uploads/2025/07/FOXO4-DRI-D-Retro-Inverso-10mg-scaled.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/foxo4-dri-d-retro-inverso-10mg/?ref=ironman"})},
  [pscustomobject]@{slug="thymalin";name="Thymalin";category="cognitive";image="https://ironpeptides.is/wp-content/uploads/2025/11/Thymalin-10mg-scaled.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/thymalin/?ref=ironman"})},

  [pscustomobject]@{slug="melanotan-ii";name="Melanotan II";category="specialty";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2025/07/ChatGPT-Image-Sep-23-2025-08_09_24-PM.png?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/melanotan/aff/3/"},@{name="Peptides Kingdom";link="https://peptideskingdom.com/product/melanotan-ii-mt-2-10mg-nasal-spray-5ml/?ref=isgicbuw"})},
  [pscustomobject]@{slug="ara-290";name="ARA-290";category="specialty";image="https://i0.wp.com/pinnaclepeptidelabs.com/wp-content/uploads/2026/02/ARA-290-Vial.png?fit=1024%2C1024&ssl=1";suppliers=@(@{name="Pinnacle Peptide Labs";link="https://pinnaclepeptidelabs.com/product/ara-290-10mg/aff/3/"})},
  [pscustomobject]@{slug="kpv";name="KPV";category="specialty";image="https://ironpeptides.is/wp-content/uploads/2025/10/KPV-10MG-scaled.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/kpv/?ref=ironman"})},
  [pscustomobject]@{slug="klow";name="KLOW";category="specialty";image="https://ironpeptides.is/wp-content/uploads/2025/10/KLOW-%E2%80%93-80-mg-scaled.webp";suppliers=@(@{name="Iron Peptides";link="https://ironpeptides.is/product/klow-80mg/?ref=ironman"})}
)

$siteUrls = @(
  "https://peptidesuppliers.org/","https://peptidesuppliers.org/about/","https://peptidesuppliers.org/faq/","https://peptidesuppliers.org/reviews/","https://peptidesuppliers.org/contact/","https://peptidesuppliers.org/peptide-directory/","https://peptidesuppliers.org/suppliers/","https://peptidesuppliers.org/best-peptide-suppliers/","https://peptidesuppliers.org/cheapest-peptide-suppliers/","https://peptidesuppliers.org/fastest-shipping-suppliers/","https://peptidesuppliers.org/international-shipping-peptide-suppliers/","https://peptidesuppliers.org/peptide-suppliers-canada/","https://peptidesuppliers.org/peptide-suppliers-uk/","https://peptidesuppliers.org/peptide-suppliers-australia/","https://peptidesuppliers.org/find-suppliers/","https://peptidesuppliers.org/guides/evaluate-peptide-suppliers/","https://peptidesuppliers.org/verify/","https://peptidesuppliers.org/how-we-review-suppliers/","https://peptidesuppliers.org/best-bpc-157-suppliers/","https://peptidesuppliers.org/best-tb-500-suppliers/","https://peptidesuppliers.org/best-ghk-cu-suppliers/","https://peptidesuppliers.org/best-glp-1-peptide-suppliers/","https://peptidesuppliers.org/what-is-a-coa/","https://peptidesuppliers.org/submit-a-supplier/","https://peptidesuppliers.org/privacy/","https://peptidesuppliers.org/disclosure/","https://peptidesuppliers.org/suppliers/iron-peptides/","https://peptidesuppliers.org/suppliers/pinnacle-peptide-labs/","https://peptidesuppliers.org/suppliers/amino-club/","https://peptidesuppliers.org/suppliers/ascension-peptides/","https://peptidesuppliers.org/suppliers/peptides-kingdom/"
)

$categoryOrder = @("metabolic","recovery","growth","cognitive","specialty")

function Render-SupplierButtons($suppliers, $slug) {
  $buttons = New-Object System.Collections.Generic.List[string]
  for ($i = 0; $i -lt $suppliers.Count; $i++) {
    $supplier = $suppliers[$i]
    $class = if ($i -eq 0) { "button button-primary" } else { "button button-ghost" }
    $buttons.Add("<a class=`"$class`" href=`"$($supplier.link)`" target=`"_blank`" rel=`"noopener noreferrer`">$($supplier.name)</a>")
  }
  $buttons.Add("<a class=`"button button-ghost`" href=`"/peptides/$slug/`">Learn more</a>")
  return ($buttons -join "`n              ")
}

$directorySections = foreach ($category in $categoryOrder) {
  $title = Get-CategoryTitle $category
  $blurb = Get-CategoryBlurb $category
  $cards = foreach ($peptide in ($peptides | Where-Object category -eq $category)) {
@"
          <article class="card reveal">
            <div class="review-media"><img class="directory-image" src="$($peptide.image)" alt="$($peptide.name) directory image"></div>
            <div class="kicker">Peptide listing</div>
            <h3>$($peptide.name)</h3>
            <div class="button-row">
              $(Render-SupplierButtons $peptide.suppliers $peptide.slug)
            </div>
          </article>
"@
  }
@"
    <section id="$category">
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>$title peptides</h2>
            <p>$blurb</p>
          </div>
        </div>

        <div class="supplier-grid">
$($cards -join "`n")
        </div>
      </div>
    </section>
"@
}

$directoryHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Peptide Directory | PeptideSuppliers.org</title>
  <meta name="description" content="Browse the Peptide Directory for compound-by-compound supplier links, product shortcuts, and mapped peptide categories.">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="https://peptidesuppliers.org/peptide-directory/">
  <meta property="og:type" content="website">
  <meta property="og:title" content="Peptide Directory | PeptideSuppliers.org">
  <meta property="og:description" content="A peptide-by-peptide directory with mapped supplier links for compounds like Tirzepatide, Semaglutide, BPC-157, and GHK-Cu.">
  <meta property="og:url" content="https://peptidesuppliers.org/peptide-directory/">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="https://peptidesuppliers.org/og-image.svg">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="Peptide Directory | PeptideSuppliers.org">
  <meta name="twitter:description" content="Browse the peptide directory for mapped compound links and supplier shortcuts.">
  <meta name="twitter:image" content="https://peptidesuppliers.org/og-image.svg">
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
                This directory organizes individual peptides into one place so visitors can jump
                straight to mapped supplier links instead of hunting through broader supplier pages.
              </p>
              <div class="button-row">
                <a class="button button-primary" href="#metabolic">Browse peptides</a>
                <a class="button button-ghost" href="/find-suppliers/">Open supplier finder</a>
              </div>
            </div>
            <div class="hero-art reveal delay-1">
              <img src="/assets/research-panels.svg" alt="Illustration representing peptide categories and supplier mapping">
            </div>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="jump-nav sticky-directory-nav reveal">
          <strong>Jump to</strong>
          <div class="jump-links">
            <a href="#metabolic">Metabolic &amp; GLP-1</a>
            <a href="#recovery">Recovery &amp; Repair</a>
            <a href="#growth">GH &amp; Performance</a>
            <a href="#cognitive">Cognitive &amp; Longevity</a>
            <a href="#specialty">Specialty &amp; Blends</a>
          </div>
        </div>
      </div>
    </section>

$($directorySections -join "`n")
  </main>

  <footer class="footer">
    <div class="shell footer-row">
      <span>&copy; 2026 PeptideSuppliers.org</span>
      <div class="footer-links">
        <a href="/suppliers/">Suppliers</a>
        <a href="/find-suppliers/">Find Suppliers</a>
        <a href="/disclosure/">Disclosure</a>
      </div>
    </div>
  </footer>
</body>
</html>
"@
Set-Content -Path (Join-Path $root "peptide-directory\index.html") -Value $directoryHtml -Encoding UTF8

foreach ($peptide in $peptides) {
  $folder = Join-Path $peptidesRoot $peptide.slug
  New-Item -ItemType Directory -Force -Path $folder | Out-Null
  $categoryTitle = Get-CategoryTitle $peptide.category
  $categoryBlurb = Get-CategoryBlurb $peptide.category
  $researchNote = Get-ResearchNote $peptide.category

  $supplierCards = foreach ($supplier in $peptide.suppliers) {
    $code = Get-DiscountCode $supplier.name
    $discountHtml = if ($code) { "<div class=`"discount-note`">Discount code: $code</div>" } else { "" }
@"
          <article class="peptide-supplier-card reveal">
            <div class="kicker">Supplier shortcut</div>
            <h3>$($supplier.name)</h3>
            <p>This supplier is one of the mapped directory routes currently connected to the $($peptide.name) listing.</p>
            <div class="button-row">
              <a class="button button-primary" href="$($supplier.link)" target="_blank" rel="noopener noreferrer">Buy from $($supplier.name)</a>
            </div>
            $discountHtml
          </article>
"@
  }

  $metaPills = New-Object System.Collections.Generic.List[string]
  $metaPills.Add("<span class=`"pill`">Category: $categoryTitle</span>")
  foreach ($supplier in $peptide.suppliers) {
    $code = Get-DiscountCode $supplier.name
    if ($code) {
      $metaPills.Add("<span class=`"pill`">$($supplier.name): $code</span>")
    }
  }

  $pageHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$($peptide.name) peptide suppliers and overview | PeptideSuppliers.org</title>
  <meta name="description" content="Learn more about $($peptide.name), compare mapped supplier shortcuts, and see discount codes and product routes on PeptideSuppliers.org.">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="https://peptidesuppliers.org/peptides/$($peptide.slug)/">
  <meta property="og:type" content="article">
  <meta property="og:title" content="$($peptide.name) peptide suppliers and overview | PeptideSuppliers.org">
  <meta property="og:description" content="Learn more about $($peptide.name) and compare the mapped supplier shortcuts on PeptideSuppliers.org.">
  <meta property="og:url" content="https://peptidesuppliers.org/peptides/$($peptide.slug)/">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="$($peptide.image)">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="$($peptide.name) peptide suppliers and overview | PeptideSuppliers.org">
  <meta name="twitter:description" content="Learn more about $($peptide.name) and compare mapped supplier routes.">
  <meta name="twitter:image" content="$($peptide.image)">
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <link rel="stylesheet" href="/styles.css">
  <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "WebPage",
      "name": "$($peptide.name)",
      "url": "https://peptidesuppliers.org/peptides/$($peptide.slug)/",
      "description": "Learn more about $($peptide.name), compare mapped supplier shortcuts, and see discount codes and product routes."
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
        <a href="/about/">About</a>
        <a href="/faq/">FAQ</a>
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
          <div class="page-hero-grid peptide-detail-grid">
            <div class="hero-art reveal">
              <img class="peptide-hero-image" src="$($peptide.image)" alt="$($peptide.name) product image">
            </div>
            <div class="page-hero-copy reveal delay-1">
              <div class="eyebrow">Peptide detail page</div>
              <h1 class="page-title">$($peptide.name)</h1>
              <p>
                $($peptide.name) is a peptide entry on PeptideSuppliers.org that is currently grouped under $categoryTitle research listings.
              </p>
              <p>
                $categoryBlurb $researchNote
              </p>
              <div class="peptide-meta">
                $($metaPills -join "`n                ")
              </div>
              <div class="button-row" style="margin-top:18px;">
                <a class="button button-primary" href="/peptide-directory/#$($peptide.category)">Back to directory section</a>
                <a class="button button-ghost" href="/suppliers/">Browse suppliers</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="jump-nav reveal">
          <strong>On this page</strong>
          <div class="jump-links">
            <a href="#overview">Overview</a>
            <a href="#what-to-compare">What to compare</a>
            <a href="#supplier-shortcuts">Supplier shortcuts</a>
          </div>
        </div>
      </div>
    </section>

    <section id="overview">
      <div class="shell">
        <div class="lede-grid">
          <article class="story-card reveal">
            <div class="kicker">Overview</div>
            <h2>What visitors usually want from the $($peptide.name) page</h2>
            <p>
              Most visitors who land on a peptide-specific page are trying to skip the broader supplier browsing phase and go straight to the compound they already care about.
            </p>
            <p>
              For $($peptide.name), that usually means comparing which supplier actually lists the product clearly, how polished the product page feels, and whether the surrounding trust signals match the rest of the site.
            </p>
          </article>
          <article class="card reveal delay-1">
            <div class="kicker">Quick frame</div>
            <h3>How this page is meant to help</h3>
            <ul class="checklist">
              <li>Give you a direct path into the mapped $($peptide.name) product pages</li>
              <li>Keep the category context visible so the peptide is easier to place on the site</li>
              <li>Surface any mapped discount code tied to the supplier shortcut</li>
              <li>Make it easier to move back into supplier reviews if needed</li>
            </ul>
          </article>
        </div>
      </div>
    </section>

    <section id="what-to-compare">
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>What to compare on $($peptide.name) supplier pages</h2>
            <p>
              These are the practical things visitors usually look at once they click into a specific peptide route.
            </p>
          </div>
        </div>
        <div class="cards">
          <article class="card reveal">
            <div class="kicker">Listing quality</div>
            <h3>Product clarity</h3>
            <p>Check whether the supplier makes the product, format, and category fit obvious without making you hunt through the site.</p>
          </article>
          <article class="card reveal delay-1">
            <div class="kicker">Trust signals</div>
            <h3>Documentation visibility</h3>
            <p>Look for the same trust-signal basics used elsewhere on the site: clear documentation, consistent framing, and a polished path around the product page.</p>
          </article>
          <article class="card reveal delay-2">
            <div class="kicker">Buying path</div>
            <h3>Shortcut usefulness</h3>
            <p>A strong mapped route should feel direct, easy to understand, and compatible with the larger supplier review flow.</p>
          </article>
        </div>
      </div>
    </section>

    <section id="supplier-shortcuts">
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>$($peptide.name) supplier shortcuts</h2>
            <p>
              These are the mapped supplier routes currently connected to this peptide entry in the directory.
            </p>
          </div>
        </div>
        <div class="cards">
$($supplierCards -join "`n")
        </div>
      </div>
    </section>
  </main>

  <footer class="footer">
    <div class="shell footer-row">
      <span>&copy; 2026 PeptideSuppliers.org</span>
      <div class="footer-links">
        <a href="/peptide-directory/">Peptide Directory</a>
        <a href="/suppliers/">Suppliers</a>
        <a href="/disclosure/">Disclosure</a>
      </div>
    </div>
  </footer>
</body>
</html>
"@

  Set-Content -Path (Join-Path $folder "index.html") -Value $pageHtml -Encoding UTF8
  $siteUrls += "https://peptidesuppliers.org/peptides/$($peptide.slug)/"
}

$urlsXml = ($siteUrls | ForEach-Object { "  <url>`n    <loc>$_</loc>`n  </url>" }) -join "`n"
$sitemap = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n$urlsXml`n</urlset>`n"
Set-Content -Path (Join-Path $root "sitemap.xml") -Value $sitemap -Encoding UTF8
