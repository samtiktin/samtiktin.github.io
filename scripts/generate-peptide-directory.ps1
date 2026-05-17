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

function Get-DiscountPercent($supplier) {
  switch ($supplier) {
    "Iron Peptides" { return "10%" }
    "Pinnacle Peptide Labs" { return "15%" }
    "Peptides Kingdom" { return "15%" }
    "Ascension Peptides" { return "20%" }
    "Amino Club" { return "20%" }
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
    "metabolic" { "For metabolic peptides, most people are looking for clear product details, easy-to-spot trust signals, and supplier pages that are simple to compare." }
    "recovery" { "Recovery-focused peptides are usually judged by how clearly the product is explained, how easy testing or documentation is to find, and how straightforward the listing feels." }
    "growth" { "Growth and performance entries are often compared by product format, category fit, and how clearly the supplier explains where the peptide belongs in the broader catalog." }
    "cognitive" { "For cognitive and longevity entries, people usually want clear explanations, careful wording, and supplier pages that feel informative without being overhyped." }
    "specialty" { "Specialty compounds are easier to browse when the product page clearly explains what makes the listing different and gives you enough detail to compare it with nearby options." }
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
    "tirzepatide" { "You will usually look up Tirzepatide when you want a direct route into a well-known metabolic compound without sorting through broader supplier pages first." }
    "semaglutide" { "You will usually land on Semaglutide pages when you already know the compound name and want a fast path into the product listing and surrounding trust signals." }
    "retatrutide" { "You will usually look up Retatrutide when you want to compare a newer multi-pathway metabolic compound and see which suppliers visibly list it." }
    "cagrilintide" { "You will usually land on Cagrilintide when you are comparing metabolic compounds that sit next to the more familiar GLP-1 names." }
    "tesofensine" { "Tesofensine usually attracts people who are comparing more niche appetite-related catalog entries." }
    "nad-plus" { "NAD+ often gets searched by people who care more about cellular-energy and longevity-style categories than strict peptide classification." }
    "aod-9604" { "AOD-9604 usually comes up when you are comparing body-composition focused compounds that appear alongside peptide products." }
    "5-amino-1mq" { "You will usually look up 5-amino 1MQ when you already know the compound name and want a quick route to the product page." }
    "mazdutide" { "Mazdutide usually gets attention from people scanning for newer metabolic compounds rather than only the best-known GLP-1 names." }
    default { "Most people land on a page like this because they want a quick overview of the peptide and an easy way to see where it is currently listed." }
  }
}

function Get-PeptideComparisonNote($key) {
  switch ($key) {
    "metabolic" { "People usually compare these entries by page clarity, supplier trust signals, and how easy it is to tell one metabolic listing from the next." }
    "recovery" { "Most visitors comparing recovery peptides want clear product details, easy-to-find documentation, and a page that explains the compound without much guesswork." }
    "growth" { "These compounds are usually compared by signaling class, product format, and how clearly the supplier places them inside a GH or performance-focused catalog." }
    "cognitive" { "For cognitive and longevity entries, the biggest differences are usually how clearly the peptide is explained and how careful the page feels overall." }
    "specialty" { "Specialty listings are usually compared by niche fit, product presentation, and how clearly the supplier explains what makes them different from more common entries." }
  }
}

function Get-PeptideStackInfo($slug, $category) {
  switch ($slug) {
    "tirzepatide" { return @{ title = "Semaglutide, Cagrilintide, and Retatrutide"; pairing = "Tirzepatide is most often looked at next to Semaglutide, Cagrilintide, and Retatrutide because those are the pages people usually open when they are comparing the best-known metabolic and GLP-1 related listings."; why = "The usual reason people move between these pages is simple: they want to compare which compounds feel more established, which ones sound newer or more advanced, and which supplier pages do the best job explaining the difference without sounding confusing."; note = "This section is here to help you explore nearby metabolic entries and compare supplier pages more easily. It is not a recommendation to combine compounds." } }
    "semaglutide" { return @{ title = "Tirzepatide, Cagrilintide, and Retatrutide"; pairing = "Semaglutide is usually viewed alongside Tirzepatide, Cagrilintide, and sometimes Retatrutide because those are the compounds people most often compare when they want to look at GLP-1 and broader metabolic product listings side by side."; why = "Most people are using these pages to answer a practical question: which compounds keep showing up across supplier catalogs, which pages feel the clearest, and which supplier makes it easiest to understand what you are actually looking at."; note = "Think of this as a related-compounds section for browsing and comparison. It is not telling you to stack or combine the products." } }
    "retatrutide" { return @{ title = "Tirzepatide, Semaglutide, and Cagrilintide"; pairing = "Retatrutide is most often looked at next to Tirzepatide, Semaglutide, and Cagrilintide because people usually find it while comparing newer GLP-1 and broader metabolic listings that sit in the same part of supplier catalogs."; why = "Most people are opening these pages together because they want to understand which compounds feel more familiar, which ones sound newer or more advanced, and which supplier does the best job explaining that without making the page feel confusing."; note = "Use this section to compare nearby metabolic entries and see how different supplier pages frame them. It is not a recommendation to combine compounds." } }
    "cagrilintide" { return @{ title = "Semaglutide and Tirzepatide"; pairing = "Cagrilintide is commonly discussed next to Semaglutide and Tirzepatide because it often appears in the same appetite and metabolic research categories."; why = "People usually open those pages side by side when they want to compare how each supplier explains the compound family and whether the listing feels clear and well-supported."; note = "Think of these pairings as related research categories and supplier-navigation shortcuts, not usage advice." } }
    "tesofensine" { return @{ title = "GLP-1 and metabolic catalog entries"; pairing = "Tesofensine is often browsed alongside GLP-1 and broader metabolic catalog entries because it tends to attract people already comparing appetite and body-composition focused products."; why = "The pairing usually comes from the kind of category someone is browsing rather than a one-to-one overlap in mechanism."; note = "The goal here is to show related product pages that are commonly explored together, not to recommend a stack." } }
    "nad-plus" { return @{ title = "MOTS-c and Epitalon"; pairing = "NAD+ is often discussed near MOTS-c and longevity-oriented entries such as Epitalon because people usually encounter it while browsing energy, recovery, and cellular-support style categories."; why = "The overlap is mostly about the broader wellness and longevity research theme rather than a strict peptide family match."; note = "This page stays focused on related research categories and supplier navigation, not on how to combine compounds." } }
    "aod-9604" { return @{ title = "Tesofensine and metabolic entries"; pairing = "AOD-9604 is often grouped with other body-composition focused listings such as Tesofensine and the broader metabolic section."; why = "People usually browse these entries together when they want to compare how supplier sites organize weight-management and physique-oriented research products."; note = "Use this as a category guide rather than a stack recommendation." } }
    "5-amino-1mq" { return @{ title = "Tesofensine and AOD-9604"; pairing = "5-amino 1MQ is usually discussed alongside Tesofensine and AOD-9604 because those entries often live in the same metabolism-focused area of a supplier catalog."; why = "People usually look across those pages to compare how the site frames the product, whether the listing looks credible, and how easy the compound is to understand."; note = "These related entries are here to help you browse nearby compounds, not to tell you what to combine." } }
    "mazdutide" { return @{ title = "Tirzepatide and Retatrutide"; pairing = "Mazdutide is usually mentioned next to Tirzepatide and Retatrutide because people often discover it while comparing newer multi-pathway metabolic compounds."; why = "The main reason people browse these pages together is to compare how the compounds are described and which suppliers actually list them clearly."; note = "This page points you toward nearby research categories and listings rather than promoting any specific stack." } }

    "bpc-157" { return @{ title = "TB-500 and GHK-Cu"; pairing = "BPC-157 is most often paired with TB-500 and sometimes GHK-Cu because those are the names people usually run into when they are browsing recovery, tissue-support, and repair-focused supplier pages."; why = "In practice, people usually open these pages together because they want to compare the overall recovery category, see which supplier pages feel the most complete, and figure out whether the product presentation looks polished or rushed."; note = "This section is meant to show the recovery-related compounds people commonly compare on supplier sites. It is not a real-world stack or treatment recommendation." } }
    "tb-500" { return @{ title = "BPC-157, GHK-Cu, and recovery blends"; pairing = "TB-500 is usually looked at with BPC-157, GHK-Cu, and sometimes recovery-oriented blends because those are the listings that often sit closest together in repair-focused supplier catalogs."; why = "People usually compare these pages because they want to see which recovery compounds are easiest to find, which ones are presented most clearly, and whether the supplier seems stronger in injury, repair, or restoration-oriented categories."; note = "Use this section as a way to explore nearby recovery entries and supplier pages, not as guidance to combine products." } }
    "ghk-cu" { return @{ title = "BPC-157, TB-500, and Glow"; pairing = "GHK-Cu is most often looked at with BPC-157, TB-500, and sometimes Glow because those are the pages people usually open when they are browsing skin, collagen, repair, or appearance-focused supplier categories."; why = "People tend to move between these listings because they want to compare which pages feel the most polished, which suppliers seem strongest in restoration-style products, and which entries are easiest to understand at a glance."; note = "This section is here to help you explore nearby recovery and appearance entries. It is not meant as a recommendation to stack products together." } }
    "mots-c" { return @{ title = "NAD+ and metabolic entries"; pairing = "MOTS-c is often discussed near NAD+ and other metabolic-support style listings because they are frequently grouped together in energy and adaptation-oriented supplier sections."; why = "People usually compare these pages when they care about cellular-energy language, mitochondrial themes, and how clearly the product page explains the entry."; note = "This section highlights related browsing paths, not a recommendation to combine compounds." } }
    "glow" { return @{ title = "GHK-Cu and recovery-oriented blends"; pairing = "Glow is usually viewed alongside GHK-Cu and other appearance or restoration-oriented listings because it sits in a similar cosmetic-support and recovery-focused part of the catalog."; why = "People tend to compare these entries when they want to understand how the blend is positioned and whether the supplier explains the ingredients clearly enough."; note = "Because Glow is a branded blend-style listing, the most useful comparison is usually category fit and page clarity rather than a formal stack recommendation." } }
    "igf-1-des" { return @{ title = "IGF-1 LR3 and GH-focused entries"; pairing = "IGF-1 DES is often discussed alongside IGF-1 LR3 and broader GH-oriented entries because visitors usually encounter it while browsing growth and recovery-related product pages."; why = "People usually compare these names side by side to understand the signaling family and see which supplier page gives the clearest context."; note = "This page is for related-category browsing and education, not usage guidance." } }

    "oxytocin" { return @{ title = "PT-141 and Melanotan II"; pairing = "Oxytocin is sometimes discussed near PT-141 and Melanotan II because people browsing signaling and intimacy-related product categories often open those listings in the same session."; why = "The overlap usually comes from browsing behavior and category proximity rather than from them being presented as interchangeable compounds."; note = "This is a related-category section, not a recommendation to combine products." } }
    "sermorelin" { return @{ title = "Tesamorelin, CJC-1295, and Ipamorelin"; pairing = "Sermorelin is commonly discussed alongside Tesamorelin, CJC-1295, and Ipamorelin because they all sit in the broader GH-signaling area of many supplier catalogs."; why = "People usually compare these pages to see how each compound is framed, how the supplier organizes GH-related entries, and whether the listing feels easy to follow."; note = "These are common GH-category pairings for browsing purposes, not stack instructions." } }
    "tesamorelin" { return @{ title = "Sermorelin, CJC-1295, and Ipamorelin"; pairing = "Tesamorelin is usually grouped with Sermorelin, CJC-1295, and Ipamorelin because they all tend to appear in the same growth-hormone signaling section."; why = "People often compare these pages to see how the compounds differ on supplier sites and which listing provides the clearest explanation."; note = "Treat this as a supplier-navigation and category context section rather than a combining guide." } }
    "ipamorelin" { return @{ title = "CJC-1295 and Sermorelin"; pairing = "Ipamorelin is often discussed alongside CJC-1295 and Sermorelin because those names are commonly paired in GH-oriented supplier categories."; why = "People usually browse them together because they want to compare the signaling class, the product format, and how clearly the supplier explains the relationship between secretagogues and GHRH analogs."; note = "This section highlights related GH-category listings rather than advising real-world combinations." } }
    "cjc-1295-ipamorelin" { return @{ title = "CJC-1295, Ipamorelin, and Sermorelin"; pairing = "CJC-1295 / Ipamorelin is already a combined route, so it is usually discussed next to the individual CJC-1295, Ipamorelin, and Sermorelin pages."; why = "People usually want to compare the bundled listing with the single-compound routes to understand how the supplier frames the combined product."; note = "The page is useful for comparing a pre-paired listing against the individual entries, not for adding more compounds on top." } }
    "cjc-1295" { return @{ title = "Ipamorelin and Sermorelin"; pairing = "CJC-1295 is usually discussed alongside Ipamorelin and Sermorelin because those entries often sit together in GH-oriented catalogs."; why = "People often compare them to understand whether they are looking at a GHRH analog, a secretagogue, or a combined product route."; note = "The pairing reflects how supplier sites organize GH-related listings, not a recommendation to combine compounds." } }
    "mk-677" { return @{ title = "Ipamorelin, CJC-1295, and IGF-1 LR3"; pairing = "MK-677 is often discussed next to GH-related entries such as Ipamorelin, CJC-1295, and IGF-1 LR3 because people usually find it while browsing the same performance-oriented section."; why = "The comparison usually comes from the broader GH and body-composition category rather than from the compounds being direct substitutes."; note = "This section is a guide to related catalog paths, not a stacking recommendation." } }
    "igf-1-lr3" { return @{ title = "IGF-1 DES and GH-signaling entries"; pairing = "IGF-1 LR3 is commonly discussed alongside IGF-1 DES and other GH-signaling products because they often appear in the same performance and growth-related catalog area."; why = "People usually compare these pages to understand the signaling family and how the supplier differentiates the product listings."; note = "Use the pairings for context and browsing, not as a guide to combining compounds." } }
    "pt-141" { return @{ title = "Oxytocin and Melanotan II"; pairing = "PT-141 is often discussed next to Oxytocin and Melanotan II because those names can appear in the same signaling and specialty product conversations."; why = "People usually compare these pages when they want to see how the supplier frames the category and whether the listing feels clear and credible."; note = "This page is meant for related-entry browsing rather than real-world stack guidance." } }
    "gonadorelin" { return @{ title = "Kisspeptin-10 and growth-hormone signaling pages"; pairing = "Gonadorelin is often discussed near Kisspeptin-10 and other endocrine-signaling entries because visitors usually find it while browsing hormone-focused catalog sections."; why = "People often compare those pages to understand whether the supplier handles reproductive and pituitary signaling entries clearly."; note = "These are nearby category pairings, not a recommendation to combine products." } }
    "hexarelin" { return @{ title = "Ipamorelin, CJC-1295, and MK-677"; pairing = "Hexarelin is usually grouped with Ipamorelin, CJC-1295, and MK-677 because it sits in the same GH-secretagogue and performance-oriented part of many catalogs."; why = "People usually browse these pages together when they want to compare how each supplier presents GH-related compounds and whether the listing feels polished."; note = "This is a browsing and category context section, not a stacking protocol." } }
    "thymosin-alpha-1" { return @{ title = "Thymalin and specialty immune-support entries"; pairing = "Thymosin Alpha-1 is often mentioned alongside Thymalin and other immune-oriented specialty listings because they are usually found in the same signaling or restoration sections."; why = "People usually compare those entries to see how carefully the supplier explains the category and whether the page feels trustworthy."; note = "The pairings are for education and category context, not instructions to combine products." } }
    "kisspeptin-10" { return @{ title = "Gonadorelin and endocrine-signaling entries"; pairing = "Kisspeptin-10 is often discussed alongside Gonadorelin because both appear in hormone-signaling and reproductive research categories."; why = "People usually browse those pages together to see how the supplier handles endocrine-related entries and whether the explanation is clear enough to follow."; note = "Treat this as a related-category browsing section rather than a recommendation." } }

    "semax" { return @{ title = "Selank and Cerebrolysin"; pairing = "Semax is often discussed alongside Selank and sometimes Cerebrolysin because those names are frequently grouped together in nootropic and neuro-support oriented catalog sections."; why = "People usually compare these pages to understand how the supplier frames cognition-related entries and whether the listing feels careful and readable."; note = "These are common neuro-category pairings on supplier sites, not real-world stack instructions." } }
    "selank" { return @{ title = "Semax and DSIP"; pairing = "Selank is often discussed next to Semax and sometimes DSIP because those entries commonly appear together in nootropic, calming, and neuroregulation-themed sections."; why = "People usually browse these pages together to compare how the category is explained and whether the supplier makes the distinction between the compounds easy to follow."; note = "This is meant to help you navigate related cognitive listings, not recommend combining them." } }
    "cerebrolysin" { return @{ title = "Semax, Selank, and Dihexa"; pairing = "Cerebrolysin is often discussed alongside Semax, Selank, and Dihexa because people interested in brain-support categories often open those listings together."; why = "The overlap usually comes from category browsing and interest in neuro-support themes rather than from the products being direct equivalents."; note = "Use the pairings as a way to explore related cognitive listings, not as stack advice." } }
    "dsip" { return @{ title = "Selank and Semax"; pairing = "DSIP is often mentioned near Selank and Semax because those entries can show up together in sleep, calming, and nootropic-oriented catalog sections."; why = "People usually compare them to understand how the supplier organizes neuropeptide and sleep-related entries."; note = "This page is for browsing and education, not for building a combination plan." } }
    "dihexa" { return @{ title = "Semax, Selank, and Cerebrolysin"; pairing = "Dihexa is often discussed alongside Semax, Selank, and Cerebrolysin because visitors interested in cognition-related research frequently browse those listings together."; why = "People usually compare them to see how the supplier explains neurotrophic or cognition-oriented compounds and whether the page feels careful rather than overhyped."; note = "These pairings are about related research interest, not usage guidance." } }
    "epitalon" { return @{ title = "NAD+, Thymalin, and FOXO4-DRI"; pairing = "Epitalon is most often looked at alongside NAD+, Thymalin, and sometimes FOXO4-DRI because those are the pages people usually explore when they are browsing longevity and cellular-aging oriented supplier categories."; why = "Most people are comparing these listings because they want to see which longevity-style entries keep appearing across catalogs, which pages feel easiest to understand, and which supplier frames the category in a careful way instead of sounding overhyped."; note = "Use this as a related-longevity browsing section for comparison and discovery. It is not a recommendation to combine compounds." } }
    "foxo4-dri" { return @{ title = "Epitalon and longevity-oriented entries"; pairing = "FOXO4-DRI is often discussed near Epitalon and other longevity-oriented entries because people usually encounter it while browsing more advanced senescence-related categories."; why = "The pairing helps people compare how suppliers explain complex longevity compounds and whether the page stays careful enough for a niche entry."; note = "This section is for related-category context only and should not be read as stack advice." } }
    "thymalin" { return @{ title = "Thymosin Alpha-1 and Epitalon"; pairing = "Thymalin is often discussed alongside Thymosin Alpha-1 and sometimes Epitalon because it appears in immune and longevity-oriented sections that overlap on supplier sites."; why = "People usually browse these pages together when they want to compare how the supplier frames thymic or restoration-related compounds."; note = "Use these pairings to explore nearby categories, not to infer a recommended combination." } }

    "melanotan-ii" { return @{ title = "PT-141 and Oxytocin"; pairing = "Melanotan II is often discussed alongside PT-141 and sometimes Oxytocin because those names can show up together in specialty and melanocortin-related browsing paths."; why = "People usually compare them to understand how the supplier organizes more niche signaling entries rather than because the compounds are treated as direct substitutes."; note = "This is a related-category view, not a recommendation to combine compounds." } }
    "ara-290" { return @{ title = "KPV and recovery-oriented specialty entries"; pairing = "ARA-290 is often discussed near KPV and other niche recovery-oriented entries because it tends to live in the same specialty section on supplier sites."; why = "People usually browse these listings together when they want to compare lesser-known repair and signaling compounds in one place."; note = "The pairings are here to help you discover adjacent specialty listings, not to suggest usage combinations." } }
    "kpv" { return @{ title = "BPC-157 and ARA-290"; pairing = "KPV is often discussed alongside BPC-157 and ARA-290 because those entries commonly show up in inflammation, barrier, and repair-oriented browsing paths."; why = "People usually compare them when they want to see which supplier pages give the clearest context for niche recovery-related products."; note = "Use this section to explore nearby specialty and recovery entries rather than as stack advice." } }
    "klow" { return @{ title = "Glow and other branded specialty listings"; pairing = "KLOW is best compared with other branded specialty listings such as Glow because people usually browse it as a niche catalog entry rather than a classic standalone peptide."; why = "The main reason to open those pages together is to compare how the supplier explains the branded product and whether the listing feels clear enough to trust."; note = "Because branded entries vary a lot, this section works best as a product-context guide rather than any kind of stack recommendation." } }

    default {
      switch ($category) {
        "metabolic" { return @{ title = "Related metabolic entries"; pairing = "This peptide is usually browsed alongside other metabolic and appetite-focused entries because people often compare how supplier sites organize that category."; why = "The most useful comparison is usually page clarity, product presentation, and whether the surrounding trust signals feel easy to follow."; note = "These related entries are meant to help you browse nearby compounds, not suggest what to combine." } }
        "recovery" { return @{ title = "Related recovery entries"; pairing = "This peptide is often discussed alongside other repair and restoration-oriented entries because supplier catalogs usually place them in the same general section."; why = "People usually compare them to see which site explains the product most clearly and whether the category feels coherent."; note = "Use the pairings for navigation and context rather than as stack guidance." } }
        "growth" { return @{ title = "Related GH and signaling entries"; pairing = "This peptide is usually viewed next to other GH, endocrine, or performance-oriented entries because that is how many supplier catalogs are organized."; why = "People often compare those pages to understand the signaling class and whether the listing feels polished and easy to interpret."; note = "This is a category-context section, not a recommendation to combine compounds." } }
        "cognitive" { return @{ title = "Related cognitive and longevity entries"; pairing = "This peptide is often discussed alongside other cognition, sleep, neuro-support, or longevity entries because those categories frequently overlap on supplier sites."; why = "People usually browse them together to compare how readable and careful the research framing feels."; note = "These pairings are for education and browsing rather than stacking guidance." } }
        "specialty" { return @{ title = "Related specialty entries"; pairing = "This peptide is usually compared with other niche specialty listings because people want to understand where it sits in the broader catalog."; why = "The main value is seeing how clearly the supplier explains a less common product and whether the listing feels easy to trust."; note = "Use this section to explore related niche entries, not to infer a recommended stack." } }
      }
    }
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
  "https://peptidesuppliers.org/","https://peptidesuppliers.org/about/","https://peptidesuppliers.org/faq/","https://peptidesuppliers.org/education/","https://peptidesuppliers.org/reviews/","https://peptidesuppliers.org/contact/","https://peptidesuppliers.org/peptide-directory/","https://peptidesuppliers.org/suppliers/","https://peptidesuppliers.org/best-peptide-suppliers/","https://peptidesuppliers.org/cheapest-peptide-suppliers/","https://peptidesuppliers.org/fastest-shipping-suppliers/","https://peptidesuppliers.org/international-shipping-peptide-suppliers/","https://peptidesuppliers.org/peptide-suppliers-canada/","https://peptidesuppliers.org/peptide-suppliers-uk/","https://peptidesuppliers.org/peptide-suppliers-australia/","https://peptidesuppliers.org/find-suppliers/","https://peptidesuppliers.org/guides/evaluate-peptide-suppliers/","https://peptidesuppliers.org/verify/","https://peptidesuppliers.org/how-we-review-suppliers/","https://peptidesuppliers.org/best-bpc-157-suppliers/","https://peptidesuppliers.org/best-tb-500-suppliers/","https://peptidesuppliers.org/best-ghk-cu-suppliers/","https://peptidesuppliers.org/best-glp-1-peptide-suppliers/","https://peptidesuppliers.org/what-is-a-coa/","https://peptidesuppliers.org/submit-a-supplier/","https://peptidesuppliers.org/privacy/","https://peptidesuppliers.org/disclosure/","https://peptidesuppliers.org/medical-disclaimer/","https://peptidesuppliers.org/suppliers/iron-peptides/","https://peptidesuppliers.org/suppliers/pinnacle-peptide-labs/","https://peptidesuppliers.org/suppliers/amino-club/","https://peptidesuppliers.org/suppliers/ascension-peptides/","https://peptidesuppliers.org/suppliers/peptides-kingdom/"
)

$categoryOrder = @("metabolic","recovery","growth","cognitive","specialty")

function Render-SupplierButtons($suppliers, $slug) {
  $buttons = New-Object System.Collections.Generic.List[string]
  for ($i = 0; $i -lt $suppliers.Count; $i++) {
    $supplier = $suppliers[$i]
    $class = if ($i -eq 0) { "button button-primary" } else { "button button-ghost" }
  $buttons.Add("<a class=`"$class`" href=`"$($supplier.link)`" target=`"_blank`" rel=`"sponsored nofollow noopener noreferrer`">$($supplier.name)</a>")
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
  $stackInfo = Get-PeptideStackInfo $peptide.slug $peptide.category

  $supplierCards = foreach ($supplier in $peptide.suppliers) {
    $code = Get-DiscountCode $supplier.name
    $percent = Get-DiscountPercent $supplier.name
    $discountHtml = if ($code -and $percent) {
      "<div class=`"discount-note`">$percent off with code: $code</div>"
    } elseif ($code) {
      "<div class=`"discount-note`">Discount code: $code</div>"
    } else { "" }
@"
          <article class="peptide-supplier-card reveal">
            <div class="kicker">Supplier link</div>
            <h3>$($supplier.name)</h3>
            <p>This is one of the current supplier product pages connected to $($peptide.name) in the directory.</p>
            <div class="button-row">
            <a class="button button-primary" href="$($supplier.link)" target="_blank" rel="sponsored nofollow noopener noreferrer">View product at $($supplier.name)</a>
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

  $heroSupplierLinks = foreach ($supplier in $peptide.suppliers) {
    $code = Get-DiscountCode $supplier.name
    $percent = Get-DiscountPercent $supplier.name
    $discountText = if ($code -and $percent) {
      "$percent off with code $code"
    } elseif ($code) {
      "Code: $code"
    } else {
      "See supplier page for current offer details"
    }
@"
              <div class="peptide-quick-link">
                <a class="button button-primary" href="$($supplier.link)" target="_blank" rel="sponsored nofollow noopener noreferrer">View product at $($supplier.name)</a>
                <div class="discount-note">$discountText</div>
              </div>
"@
  }

  $pageHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$($peptide.name) peptide suppliers and overview | PeptideSuppliers.org</title>
  <meta name="description" content="Learn more about $($peptide.name), see where it is listed, and check discount codes and product routes on PeptideSuppliers.org.">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="https://peptidesuppliers.org/peptides/$($peptide.slug)/">
  <meta property="og:type" content="article">
  <meta property="og:title" content="$($peptide.name) peptide suppliers and overview | PeptideSuppliers.org">
  <meta property="og:description" content="Learn more about $($peptide.name), see where it is listed, and browse the connected product routes on PeptideSuppliers.org.">
  <meta property="og:url" content="https://peptidesuppliers.org/peptides/$($peptide.slug)/">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="$($peptide.image)">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="$($peptide.name) peptide suppliers and overview | PeptideSuppliers.org">
  <meta name="twitter:description" content="Learn more about $($peptide.name), see where it is listed, and browse connected product routes.">
  <meta name="twitter:image" content="$($peptide.image)">
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <link rel="stylesheet" href="/styles.css">
  <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "WebPage",
      "name": "$($peptide.name)",
      "url": "https://peptidesuppliers.org/peptides/$($peptide.slug)/",
      "description": "Learn more about $($peptide.name), see where it is listed, and check discount codes and product routes."
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
          <div class="page-hero-grid peptide-detail-grid">
            <div class="hero-art reveal">
              <img class="peptide-hero-image" src="$($peptide.image)" alt="$($peptide.name) product image">
              <div class="peptide-quick-links">
$($heroSupplierLinks -join "`n")
              </div>
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
        <div class="notice reveal">
          <div class="kicker">Educational disclaimer</div>
          <h3>Research information only</h3>
          <p>
            This page is educational and informational. It summarizes how a compound is commonly described on research-focused supplier sites and is not medical advice, treatment guidance, or a recommendation to purchase.
          </p>
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
            <a href="#supplier-shortcuts">Where to find it</a>
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
              <li>Start here if you want a quick explanation before opening a supplier page.</li>
              <li>The discount code notes can save you time if you are comparing where to click first.</li>
              <li>If you want nearby compounds, the category label makes it easy to jump back into the directory.</li>
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
            <h3>How it is usually described</h3>
            <p>$mechanism</p>
          </article>
          <article class="card reveal delay-1">
            <div class="kicker">Search context</div>
            <h3>Why people look it up</h3>
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
            <h2>Possible stack pairings for $($peptide.name)</h2>
            <p>
              These are the compounds people most often look at alongside $($peptide.name) when they are browsing related supplier categories and product pages.
            </p>
          </div>
        </div>
        <div class="cards">
          <article class="card reveal">
            <div class="kicker">Related entries</div>
            <h3>What it is often paired with</h3>
            <p>$($stackInfo.pairing)</p>
          </article>
          <article class="card reveal delay-1">
            <div class="kicker">Nearby compounds</div>
            <h3>$($stackInfo.title)</h3>
            <p>$($stackInfo.why)</p>
          </article>
          <article class="card reveal delay-2">
            <div class="kicker">Important note</div>
            <h3>Keep it high-level</h3>
            <p>$($stackInfo.note)</p>
          </article>
        </div>
      </div>
    </section>

    <section id="supplier-shortcuts">
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Where to find $($peptide.name)</h2>
            <p>
              These are the current product routes connected to this peptide in the directory.
            </p>
          </div>
        </div>
        <div class="notice reveal">
          <div class="kicker">Disclosure</div>
          <h3>Affiliate and research-use note</h3>
          <p>
            Some supplier links on this page may be affiliate links, which means PeptideSuppliers.org may earn a commission if you click through and make a purchase. This page is for educational and research-information purposes only and is not medical advice.
          </p>
          <p>
            For more detail, see the <a href="/disclosure/">affiliate disclosure</a> and <a href="/medical-disclaimer/">medical disclaimer</a>.
          </p>
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
        <a href="/privacy/">Privacy</a>
        <a href="/medical-disclaimer/">Medical Disclaimer</a>
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
