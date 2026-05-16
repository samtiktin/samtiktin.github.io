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

function Get-PeptideOverview($slug) {
  switch ($slug) {
    "tirzepatide" { "Tirzepatide is generally described as an incretin-based compound that combines GIP and GLP-1 receptor activity in one molecule." }
    "semaglutide" { "Semaglutide is generally described as a GLP-1 receptor agonist that is commonly discussed in metabolic and appetite-related research." }
    "retatrutide" { "Retatrutide is commonly described as a multi-agonist research compound that targets GLP-1, GIP, and glucagon signaling pathways." }
    "cagrilintide" { "Cagrilintide is usually described as an amylin-analog compound that shows up in appetite and body-weight research discussions." }
    "tesofensine" { "Tesofensine is generally discussed as a centrally acting compound studied for appetite and body-composition related outcomes." }
    "nad-plus" { "NAD+ is not a peptide in the narrowest sense, but it is frequently grouped into peptide-adjacent research catalogs because of its role in cellular energy and redox biology." }
    "aod-9604" { "AOD-9604 is commonly described as a modified fragment of human growth hormone that appears in body-composition and fat-metabolism research conversations." }
    "5-amino-1mq" { "5-amino 1MQ is usually discussed as an NNMT-related research compound that is often grouped into metabolism-focused product catalogs." }
    "mazdutide" { "Mazdutide is generally described as a dual-agonist metabolic research compound associated with GLP-1 and glucagon signaling." }

    "bpc-157" { "BPC-157 is a synthetic peptide that is commonly discussed in preclinical research around tissue recovery, gut-related signaling, and repair-oriented models." }
    "tb-500" { "TB-500 is generally described as a fragment associated with thymosin beta-4 signaling and is frequently discussed in preclinical recovery and repair contexts." }
    "ghk-cu" { "GHK-Cu is a copper-binding peptide complex that is widely discussed in skin, collagen, wound-healing, and appearance-oriented research." }
    "mots-c" { "MOTS-c is a mitochondrial-derived peptide that is commonly studied in relation to metabolic stress, exercise signaling, and cellular adaptation." }
    "glow" { "Glow is best understood as a branded blend-style product entry rather than a single classical peptide, and it is usually positioned around appearance-oriented or restoration-oriented research themes." }
    "igf-1-des" { "IGF-1 DES is a shorter insulin-like growth factor analog that is commonly discussed in receptor signaling and growth-focused research." }

    "oxytocin" { "Oxytocin is a naturally occurring peptide hormone and neuropeptide that is widely known for its roles in social behavior, uterine contraction, and lactation biology." }
    "sermorelin" { "Sermorelin is generally described as a growth hormone releasing hormone analog that is used in research around pituitary signaling." }
    "tesamorelin" { "Tesamorelin is generally described as a GHRH analog that appears in research around growth hormone signaling and body-composition related outcomes." }
    "ipamorelin" { "Ipamorelin is usually described as a selective growth hormone secretagogue that is often grouped with GH-oriented research products." }
    "cjc-1295-ipamorelin" { "CJC-1295 / Ipamorelin is a combined product route that pairs two GH-related signaling compounds in one listing." }
    "cjc-1295" { "CJC-1295 is usually described as a growth hormone releasing hormone analog that appears in signaling and performance-oriented peptide catalogs." }
    "mk-677" { "MK-677 is not a peptide in the strict sense, but it is commonly grouped into peptide-adjacent research because it is studied as a ghrelin receptor agonist and GH secretagogue." }
    "igf-1-lr3" { "IGF-1 LR3 is a longer-acting insulin-like growth factor analog that is commonly discussed in growth-signaling research." }
    "pt-141" { "PT-141, also known as bremelanotide, is generally discussed as a melanocortin-related peptide analog with libido and signaling research interest." }
    "gonadorelin" { "Gonadorelin is a synthetic GnRH analog used in research around pituitary-gonadal signaling." }
    "hexarelin" { "Hexarelin is generally described as a GH secretagogue peptide that appears in performance and endocrine-signaling research." }
    "thymosin-alpha-1" { "Thymosin Alpha-1 is a thymic peptide that is commonly discussed in immune-related and signaling-focused research contexts." }
    "kisspeptin-10" { "Kisspeptin-10 is a short kisspeptin fragment studied in reproductive hormone signaling and neuroendocrine regulation." }

    "semax" { "Semax is a synthetic peptide analog that is often discussed in nootropic and neurotrophic research circles." }
    "selank" { "Selank is a synthetic peptide analog frequently grouped into anxiolytic, nootropic, and neuroregulation research discussions." }
    "cerebrolysin" { "Cerebrolysin is a peptide-rich neurotrophic preparation that is commonly discussed in brain and neuro-support research contexts." }
    "dsip" { "DSIP, or delta sleep-inducing peptide, is usually discussed in sleep-regulation and neuropeptide research conversations." }
    "dihexa" { "Dihexa is commonly discussed as a neurotrophic research compound associated with cognition-oriented experimentation." }
    "epitalon" { "Epitalon is a synthetic tetrapeptide that is often discussed in longevity and cellular aging research." }
    "foxo4-dri" { "FOXO4-DRI is generally discussed as a senescence-related research peptide designed around FOXO4 and p53 pathway interactions." }
    "thymalin" { "Thymalin is a thymic peptide preparation that appears in immune and longevity-oriented research discussions." }

    "melanotan-ii" { "Melanotan II is a melanocortin analog commonly discussed in pigmentation and melanocortin-receptor research." }
    "ara-290" { "ARA-290 is generally described as a small erythropoietin-derived peptide investigated in tissue-protection and signaling research." }
    "kpv" { "KPV is a short peptide fragment commonly discussed in inflammation and barrier-related research contexts." }
    "klow" { "KLOW is best treated as a branded specialty listing rather than a classical standalone peptide name, and visitors usually compare it as a niche catalog product." }
    default { "This page is designed to give a clearer peptide-by-peptide explanation than the directory card alone." }
  }
}

function Get-PeptideMechanism($slug) {
  switch ($slug) {
    "tirzepatide" { "In research terms, Tirzepatide is usually framed around incretin receptor signaling, especially its combined GIP and GLP-1 activity, which is why it is often compared with other metabolic peptides." }
    "semaglutide" { "Semaglutide is usually explained through GLP-1 receptor signaling, with research discussions often focusing on appetite regulation, gastric emptying, and glucose-related effects." }
    "retatrutide" { "Retatrutide is commonly described through its triple-agonist design, which is why it is frequently positioned as a more complex metabolic-signaling entry than standard GLP-1 analogs." }
    "cagrilintide" { "Cagrilintide is usually explained through amylin-pathway signaling and satiety-related research, which is why it often appears next to GLP-1 compounds in supplier catalogs." }
    "tesofensine" { "Tesofensine is generally discussed through monoamine-related central nervous system signaling, which is part of why it gets grouped into appetite and body-composition research listings." }
    "nad-plus" { "NAD+ is usually explained through mitochondrial and cellular energy pathways, redox balance, and enzyme systems such as sirtuins and PARPs." }
    "aod-9604" { "AOD-9604 is often described through fragment-based growth hormone biology, particularly in relation to lipid metabolism research rather than full-spectrum GH signaling." }
    "5-amino-1mq" { "5-amino 1MQ is commonly framed around NNMT-related metabolic signaling, which is why it tends to show up in body-composition and energy-oriented research pages." }
    "mazdutide" { "Mazdutide is usually explained through dual GLP-1 and glucagon receptor activity, making it part of the newer generation of multi-pathway metabolic research compounds." }

    "bpc-157" { "BPC-157 is commonly described in preclinical literature through repair-oriented themes such as angiogenesis, tissue recovery, and gastrointestinal barrier signaling." }
    "tb-500" { "TB-500 is usually framed around cell migration, actin dynamics, and repair-oriented signaling connected to thymosin beta-4 biology." }
    "ghk-cu" { "GHK-Cu is often explained through copper-binding activity and downstream effects on collagen-related, skin-related, and repair-oriented signaling pathways." }
    "mots-c" { "MOTS-c is generally discussed as a mitochondrial signaling peptide involved in metabolic stress responses and exercise-related adaptation research." }
    "glow" { "Because Glow is a branded blend-style listing, the most useful way to think about it is as a packaged recovery or appearance-oriented route rather than a single mechanism peptide." }
    "igf-1-des" { "IGF-1 DES is commonly discussed through insulin-like growth factor receptor signaling, especially in research that cares about growth and local tissue-level effects." }

    "oxytocin" { "Oxytocin is usually explained through oxytocin receptor signaling in both the nervous system and peripheral tissues." }
    "sermorelin" { "Sermorelin is generally described through GHRH receptor signaling and pituitary stimulation of endogenous growth hormone release." }
    "tesamorelin" { "Tesamorelin is usually explained similarly, with research discussions centered on GHRH analog activity and downstream GH signaling." }
    "ipamorelin" { "Ipamorelin is generally discussed as a ghrelin receptor agonist and GH secretagogue with relatively selective signaling compared with some older compounds." }
    "cjc-1295-ipamorelin" { "The combined route is usually explained as pairing a GHRH analog with a ghrelin-pathway secretagogue to create a broader GH-signaling product listing." }
    "cjc-1295" { "CJC-1295 is commonly framed around GHRH analog signaling and its role in growth-hormone related research." }
    "mk-677" { "MK-677 is generally explained through ghrelin receptor signaling and stimulation of endogenous GH and IGF-1 pathways, even though it is not a peptide molecule itself." }
    "igf-1-lr3" { "IGF-1 LR3 is usually described through insulin-like growth factor signaling with a longer-acting profile than some other IGF analogs." }
    "pt-141" { "PT-141 is generally explained through melanocortin receptor signaling rather than nitric-oxide focused pathways." }
    "gonadorelin" { "Gonadorelin is usually discussed through GnRH receptor signaling and downstream LH/FSH regulation." }
    "hexarelin" { "Hexarelin is usually explained through ghrelin receptor activity and GH secretagogue signaling." }
    "thymosin-alpha-1" { "Thymosin Alpha-1 is generally framed around immune modulation and thymic-peptide signaling." }
    "kisspeptin-10" { "Kisspeptin-10 is usually explained through kisspeptin receptor biology and its upstream role in reproductive hormone signaling." }

    "semax" { "Semax is often discussed through neurotrophic and neuromodulatory signaling, including research interest around BDNF-related pathways." }
    "selank" { "Selank is generally framed around neuromodulatory and anxiolytic research, often with discussion of GABA-related or neurochemical regulatory effects." }
    "cerebrolysin" { "Cerebrolysin is commonly explained through peptide-rich neurotrophic signaling and brain-support oriented research themes." }
    "dsip" { "DSIP is usually described through sleep-related neuropeptide signaling, though the exact biology is still debated in the literature." }
    "dihexa" { "Dihexa is often discussed through HGF/c-Met related neurotrophic signaling in cognition-focused research." }
    "epitalon" { "Epitalon is commonly explained through cellular aging, telomere-related, and longevity-oriented research frameworks." }
    "foxo4-dri" { "FOXO4-DRI is generally discussed through senescent cell biology and disruption of FOXO4-p53 related interactions." }
    "thymalin" { "Thymalin is usually explained through thymic peptide signaling and immune-focused research themes." }

    "melanotan-ii" { "Melanotan II is generally described through melanocortin receptor signaling, which is why it shows up in both pigmentation and libido-related discussions." }
    "ara-290" { "ARA-290 is often explained through tissue-protective receptor signaling derived from erythropoietin pathway research." }
    "kpv" { "KPV is commonly discussed through anti-inflammatory signaling themes and barrier-related preclinical research." }
    "klow" { "For KLOW, the practical comparison point is usually the product positioning itself, because branded specialty listings often communicate less about a single clean mechanism than classical peptides do." }
    default { "This page uses cautious research-oriented language rather than treatment claims." }
  }
}

function Get-PeptideInterest($slug) {
  switch ($slug) {
    "tirzepatide" { "People usually search Tirzepatide pages because they want a direct route into a well-known metabolic compound without sorting through broader supplier pages first." }
    "semaglutide" { "Semaglutide pages tend to get attention because visitors already know the compound name and want a fast path into the product listing and surrounding trust signals." }
    "retatrutide" { "Retatrutide gets attention largely because it is treated as a newer multi-pathway metabolic entry and comparison shoppers want to see who visibly lists it." }
    "cagrilintide" { "Visitors usually land on Cagrilintide pages when they are comparing metabolic compounds that sit adjacent to the more familiar GLP-1 class." }
    "tesofensine" { "Tesofensine tends to attract comparison shoppers who care about more niche appetite-related catalog entries." }
    "nad-plus" { "NAD+ often gets searched by visitors who are less interested in peptide classification and more interested in cellular-energy and longevity-style catalog sections." }
    "aod-9604" { "AOD-9604 tends to draw interest from visitors comparing body-composition focused compounds that appear alongside peptide products." }
    "5-amino-1mq" { "5-amino 1MQ usually gets looked up by visitors who already know the compound name and want a quick route to the mapped product page." }
    "mazdutide" { "Mazdutide tends to interest visitors who are scanning for newer metabolic compounds rather than just the best-known GLP-1 names." }
    default { "Most people use peptide-specific pages because they want a clearer explanation and a quicker route into the mapped supplier pages for that compound." }
  }
}

function Get-PeptideComparisonNote($key) {
  switch ($key) {
    "metabolic" { "Visitors often compare these compounds side by side with other metabolism-focused entries and look for the clearest supplier pages, the cleanest product presentation, and the most obvious trust signals." }
    "recovery" { "Visitors often compare these compounds based on how recovery-focused the listing feels, how easy the documentation is to locate, and whether the supplier makes the product category easy to understand." }
    "growth" { "Visitors often compare these compounds by signaling class, product format, and whether the supplier presents the peptide clearly inside a larger GH or performance-oriented catalog." }
    "cognitive" { "Visitors often compare these compounds by how clearly the site explains the peptide, how polished the listing feels, and whether the surrounding research framing stays careful and readable." }
    "specialty" { "Visitors often compare these entries by niche fit, supplier presentation, and how easy it is to understand what makes the product distinct from more common peptide listings." }
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
  $overview = Get-PeptideOverview $peptide.slug
  $mechanism = Get-PeptideMechanism $peptide.slug
  $interest = Get-PeptideInterest $peptide.slug
  $comparisonNote = Get-PeptideComparisonNote $peptide.category

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
                $overview
              </p>
              <p>
                $mechanism
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
            <h2>What $($peptide.name) is</h2>
            <p>
              $overview
            </p>
            <p>
              $comparisonNote
            </p>
          </article>
          <article class="card reveal delay-1">
            <div class="kicker">Research frame</div>
            <h3>Why people look up $($peptide.name)</h3>
            <ul class="checklist">
              <li>$interest</li>
              <li>Visitors usually want to compare product clarity, supplier fit, and surrounding trust signals.</li>
              <li>The mapped discount-code shortcuts make it easier to move from research into the supplier page quickly.</li>
              <li>The category placement helps visitors understand how the peptide fits into the rest of the directory.</li>
            </ul>
          </article>
        </div>
      </div>
    </section>

    <section id="what-to-compare">
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>How $($peptide.name) is generally described in research</h2>
            <p>
              This section stays high-level and research-oriented rather than making treatment claims.
            </p>
          </div>
        </div>
        <div class="cards">
          <article class="card reveal">
            <div class="kicker">Mechanism</div>
            <h3>How it works</h3>
            <p>$mechanism</p>
          </article>
          <article class="card reveal delay-1">
            <div class="kicker">Why it matters</div>
            <h3>Why people research it</h3>
            <p>$interest</p>
          </article>
          <article class="card reveal delay-2">
            <div class="kicker">Comparison lens</div>
            <h3>What to compare on supplier pages</h3>
            <p>Check whether the product page feels clear, whether the surrounding trust signals match the rest of the supplier site, and whether the listing is easy to contextualize inside the broader catalog.</p>
          </article>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Common comparisons for $($peptide.name)</h2>
            <p>
              Visitors rarely look at a peptide page in isolation. They usually compare it against adjacent compounds, neighboring categories, or alternative supplier listings.
            </p>
          </div>
        </div>
        <div class="cards">
          <article class="card reveal">
            <div class="kicker">Category context</div>
            <h3>Where it usually sits</h3>
            <p>$comparisonNote</p>
          </article>
          <article class="card reveal delay-1">
            <div class="kicker">Page reading pattern</div>
            <h3>How visitors usually browse</h3>
            <p>Most visitors move between the peptide explainer, the supplier shortcut, and the broader directory section before deciding which supplier page to open next.</p>
          </article>
          <article class="card reveal delay-2">
            <div class="kicker">Next step</div>
            <h3>How to keep researching</h3>
            <p>Use this page for the peptide overview, then compare the mapped supplier routes, and finally use the supplier hub if you want rankings, broader reviews, or shipping-focused pages.</p>
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
