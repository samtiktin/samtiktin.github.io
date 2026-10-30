#!/usr/bin/env python3
"""Builds the supplier database page and homepage from data/suppliers.json.

Run from the repo root:  python scripts/build_site.py
Edit data/suppliers.json to add or change suppliers, then re-run this script
and commit the generated database/index.html and index.html.
"""
import html
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = json.loads((ROOT / "data" / "suppliers.json").read_text(encoding="utf-8"))
SUPPLIERS = DATA["suppliers"]
SITE = "https://peptidesuppliers.org"

PRICE_LABEL = {"budget": "Budget", "mid": "Mid-range", "premium": "Premium", "listed": "Publicly listed", "unknown": "Price not stated"}
PRICE_ORDER = {"budget": 1, "mid": 2, "premium": 3, "listed": 5, "unknown": 9}
COA_LABEL = {
    "strong": "Published COAs",
    "visible": "Testing language visible",
    "gated": "COAs gated / on request",
}

NAV = """      <nav class="nav" aria-label="Primary">
        <a href="/"{home}>Home</a>
        <a href="/database/"{database}>Database</a>
        <a href="/suppliers/"{suppliers}>Suppliers</a>
        <a href="/peptides/"{peptides}>Peptides</a>
        <a href="/tools/"{tools}>Tools</a>
        <a href="/reviews/"{reviews}>Reviews</a>
        <a href="/blog/"{blog}>Blog</a>
        <a href="/contact/"{contact}>Contact</a>
      </nav>"""

FOOTER = """  <footer class="footer">
    <div class="shell footer-row">
      <span>&copy; 2026 PeptideSuppliers.org</span>
      <div class="footer-links">
        <a href="/database/">Database</a>
        <a href="/suppliers/">Suppliers</a>
        <a href="/peptides/">Peptides</a>
        <a href="/tools/">Tools</a>
        <a href="/reviews/">Reviews</a>
        <a href="/blog/">Blog</a>
        <a href="/how-we-review-suppliers/">Methodology</a>
        <a href="/about/">About</a>
        <a href="/disclosure/">Disclosure</a>
        <a href="/privacy/">Privacy</a>
        <a href="/medical-disclaimer/">Medical disclaimer</a>
        <a href="/contact/">Contact</a>
        <a href="https://peptideforumhub.com/" target="_blank" rel="noopener noreferrer">Partner: Peptide Forum Hub</a>
      </div>
    </div>
  </footer>"""

HEADER = """  <header class="topbar">
    <div class="shell topbar-inner">
      <a class="brand" href="/">
        <span class="brand-mark">PS</span>
        <span class="brand-copy">
          <strong>PeptideSuppliers.org</strong>
          <span>The peptide supplier database</span>
        </span>
      </a>
{nav}
    </div>
  </header>"""


def nav(active):
    keys = ["home", "database", "suppliers", "peptides", "tools", "reviews", "blog", "contact"]
    return NAV.format(**{k: (' class="active"' if k == active else "") for k in keys})


def esc(s):
    return html.escape(str(s), quote=True)


def stars(n):
    if not n:
        return ""
    return "&#9733;" * n + "&#9734;" * (5 - n)


def first_sentence(text, limit=190):
    text = " ".join(text.split())
    m = re.match(r"(.+?[.!?])(\s|$)", text)
    s = m.group(1) if m else text
    if len(s) > limit:
        s = s[: limit - 1].rsplit(" ", 1)[0] + "…"
    return s


def ships_value(s):
    v = s.get("shipsOutsideUS")
    if v is True:
        return "intl"
    if v is False:
        return "us"
    return "unknown"


def ships_label(s):
    return {"intl": "Ships outside the US", "us": "US shipping only", "unknown": "International shipping not stated"}[ships_value(s)]


def card(s):
    compounds = "|".join(t.lower() for t in s["compoundTags"])
    blob = " ".join([s["name"], " ".join(s["compounds"]), s["summary"], s["bestFor"], s["coaLabel"]]).lower()
    badges = []
    if s.get("sponsored"):
        badges.append('<span class="db-badge db-badge-sponsored">Sponsored</span>')
    if s.get("orderedByUs"):
        badges.append('<span class="db-badge db-badge-ordered">Ordered &amp; received by us</span>')
    badges.append(f'<span class="db-badge">{esc(COA_LABEL.get(s["coa"], "COA info not stated"))}</span>')
    badges.append(f'<span class="db-badge">{esc(PRICE_LABEL.get(s["price"], "Price not stated"))}</span>')
    badges.append(f'<span class="db-badge">{esc(ships_label(s))}</span>')
    if s["country"] in ("US", "UK", "UAE"):
        badges.append(f'<span class="db-badge">Based in {esc(s["country"])}</span>')
    chips = "".join(f'<span class="pill">{esc(c)}</span>' for c in s["compounds"])
    code = f'<p class="db-code">Code: <strong>{esc(s["discountCode"])}</strong></p>' if s["discountCode"] else ""
    rel = s.get("linkRel") or ("sponsored nofollow noopener noreferrer" if (s.get("affiliate") or s.get("sponsored")) else "noopener noreferrer")
    pay = f'<p class="db-meta"><strong>Pays:</strong> {esc(", ".join(s["payments"]))}</p>' if s["payments"] else ""
    reviewed = f'<p class="db-meta"><strong>Reviewed:</strong> {esc(s["reviewed"])}</p>' if s["reviewed"] else ""
    rating = f'<span class="stars" aria-label="{s["rating"]} out of 5 stars">{stars(s["rating"])}</span>' if s["rating"] else ""
    return f'''          <article class="db-card" data-name="{esc(s["name"].lower())}" data-price="{esc(s["price"])}" data-coa="{esc(s["coa"])}" data-ships="{ships_value(s)}" data-country="{esc(s["country"])}" data-ordered="{1 if s.get("orderedByUs") else 0}" data-code="{1 if s["discountCode"] else 0}" data-compounds="{esc(compounds)}" data-rating="{s["rating"] or 0}" data-priceorder="{PRICE_ORDER.get(s["price"], 9)}" data-text="{esc(blob)}">
            <div class="db-card-head">
              <img src="{esc(s["cover"])}" alt="{esc(s["name"])} cover" loading="lazy" width="72" height="72">
              <div>
                <h3><a href="{esc(s["reviewUrl"])}">{esc(s["name"])}</a> {rating}</h3>
                <p class="db-best">Best for: {esc(s["bestFor"])}</p>
              </div>
            </div>
            <p class="db-summary">{esc(first_sentence(s["summary"]))}</p>
            <div class="db-badges">{"".join(badges)}</div>
            <div class="db-compounds">{chips}</div>
            {pay}{reviewed}{code}
            <div class="button-row">
              <a class="button button-primary" href="{esc(s["reviewUrl"])}">Read review</a>
              <a class="button button-ghost" href="{esc(s["website"])}" target="_blank" rel="{rel}">Visit site</a>
            </div>
          </article>'''


def sponsored_slot():
    paid = [s for s in SUPPLIERS if s.get("sponsored")]
    if not paid:
        return """      <article class="db-sponsored-card db-sponsored-empty">
        <div class="db-sponsored-label">Sponsored placement &middot; available</div>
        <h3>Feature your company at the top of the database</h3>
        <p>Sponsored listings appear here, clearly labeled, for $25/month. Sponsorship pays for placement only. It does not change a supplier's rating or review.</p>
        <div class="button-row"><a class="button button-primary" href="/contact/">Get featured</a></div>
      </article>"""
    cards = []
    for s in paid:
        cards.append(f"""      <article class="db-sponsored-card">
        <div class="db-sponsored-label">Featured &middot; Sponsored</div>
        <h3>{esc(s["name"])}</h3>
        <p>{esc(first_sentence(s["summary"]))}</p>
        <div class="button-row"><a class="button button-primary" href="{esc(s["website"])}" target="_blank" rel="sponsored nofollow noopener noreferrer">Visit site</a></div>
      </article>""")
    return "\n".join(cards)


def compound_options():
    from collections import Counter
    c = Counter(t for s in SUPPLIERS for t in s["compoundTags"])
    items = sorted(c.items(), key=lambda kv: (-kv[1], kv[0].lower()))
    return items


def database_page():
    ordered = sorted(SUPPLIERS, key=lambda s: (-(s["rating"] or 0), s["name"].lower()))
    cards = "\n".join(card(s) for s in ordered)
    comp = compound_options()
    opts = "".join(f'<option value="{esc(k.lower())}">{esc(k)} ({n})</option>' for k, n in comp)
    n = len(SUPPLIERS)
    itemlist = {
        "@context": "https://schema.org",
        "@type": "ItemList",
        "name": "Peptide supplier database",
        "numberOfItems": n,
        "itemListElement": [
            {"@type": "ListItem", "position": i + 1, "name": s["name"], "url": SITE + s["reviewUrl"]}
            for i, s in enumerate(ordered)
        ],
    }
    crumbs = {
        "@context": "https://schema.org",
        "@type": "BreadcrumbList",
        "itemListElement": [
            {"@type": "ListItem", "position": 1, "name": "Home", "item": SITE + "/"},
            {"@type": "ListItem", "position": 2, "name": "Database", "item": SITE + "/database/"},
        ],
    }
    title = f"Peptide Supplier Database: Search {n} Suppliers by Compound, COA, Price and Shipping | PeptideSuppliers.org"
    desc = f"Search and filter {n} research peptide suppliers by compound, published COAs, price tier, shipping, and country. Each listing links to a full review. Updated October 2026."
    return f'''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{esc(title)}</title>
  <meta name="description" content="{esc(desc)}">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="{SITE}/database/">
  <meta property="og:type" content="website">
  <meta property="og:title" content="{esc(title)}">
  <meta property="og:description" content="{esc(desc)}">
  <meta property="og:url" content="{SITE}/database/">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="{SITE}/og-image.png">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="{esc(title)}">
  <meta name="twitter:description" content="{esc(desc)}">
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <link rel="stylesheet" href="/styles.css">
  <script type="application/ld+json">{json.dumps(itemlist, ensure_ascii=False)}</script>
  <script type="application/ld+json">{json.dumps(crumbs)}</script>
</head>
<body>
{HEADER.format(nav=nav("database"))}

  <main>
    <section class="page-hero">
      <div class="shell">
        <div class="page-hero-card db-hero">
          <div class="eyebrow">Supplier database</div>
          <h1 class="page-title">Search the peptide supplier database</h1>
          <p>Compare {n} research peptide suppliers by compound, published COAs, price tier, shipping, and payment terms. Every listing links to a full review so you can see how we scored it.</p>
          <form class="db-search" id="db-search-form" role="search" onsubmit="return false">
            <label class="sr-only" for="db-q">Search suppliers or compounds</label>
            <input id="db-q" class="input" type="search" placeholder="Search a supplier or compound, e.g. BPC-157, Amino Club" autocomplete="off">
          </form>
        </div>
      </div>
    </section>

    <section class="db-sponsored" aria-label="Sponsored placement">
      <div class="shell">
{sponsored_slot()}
      </div>
    </section>

    <section>
      <div class="shell db-layout">
        <aside class="db-filters" aria-label="Filters">
          <h2>Filters</h2>
          <label>Compound
            <select id="db-compound"><option value="">Any</option>{opts}</select>
          </label>
          <label>Price tier
            <select id="db-price"><option value="">Any</option><option value="budget">Budget</option><option value="mid">Mid-range</option><option value="premium">Premium</option></select>
          </label>
          <label>COA documentation
            <select id="db-coa"><option value="">Any</option><option value="strong">Published COAs</option><option value="visible">Testing language visible</option><option value="gated">COAs gated / on request</option></select>
          </label>
          <label>Shipping
            <select id="db-ships"><option value="">Any</option><option value="us">US shipping only</option><option value="intl">Ships outside the US</option></select>
          </label>
          <label>Based in
            <select id="db-country"><option value="">Any</option><option value="US">United States</option><option value="UK">United Kingdom</option><option value="UAE">United Arab Emirates</option></select>
          </label>
          <label class="db-check"><input type="checkbox" id="db-ordered"> Ordered &amp; received by us</label>
          <label class="db-check"><input type="checkbox" id="db-code"> Has a discount code</label>
          <label>Sort by
            <select id="db-sort"><option value="rating">Our rating (high to low)</option><option value="name">Name (A to Z)</option><option value="price">Price (low to high)</option></select>
          </label>
          <button class="button button-ghost" type="button" id="db-reset">Reset filters</button>
          <p class="tiny muted">Compound filters use the compounds each review highlights, not a supplier's full catalog. Open a review to see what else it carries.</p>
        </aside>

        <div class="db-results">
          <p class="db-count" id="db-count" aria-live="polite">Showing all {n} suppliers</p>
          <div class="db-grid" id="db-grid">
{cards}
          </div>
          <p class="db-empty" id="db-empty" hidden>No suppliers match those filters. Try removing one.</p>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="notice reveal">
          <div class="kicker">How to read this database</div>
          <h3>Signals, not guarantees</h3>
          <p>Ratings come from our <a href="/how-we-review-suppliers/">review methodology</a>. A badge such as "Published COAs" means certificates are public, not that we have tested the product. "Ordered &amp; received by us" means we bought from the supplier and the order arrived. Some links are affiliate links; see our <a href="/disclosure/">disclosure</a>. Everything here is for research-use-only reference and is not medical advice.</p>
        </div>
      </div>
    </section>
  </main>

{FOOTER}
  <script src="/assets/database.js" defer></script>
</body>
</html>
'''


def home_sponsored():
    paid = [s for s in SUPPLIERS if s.get("sponsored")]
    if not paid:
        return ""
    cards = "\n".join(
        f'''          <article class="db-sponsored-card">
            <div class="db-sponsored-label">Featured &middot; Sponsored</div>
            <h3>{esc(s["name"])}</h3>
            <p>{esc(first_sentence(s["summary"]))}</p>
            <div class="button-row"><a class="button button-primary" href="{esc(s["website"])}" target="_blank" rel="sponsored nofollow noopener noreferrer">Visit site</a><a class="button button-ghost" href="{esc(s["reviewUrl"])}">Read our review</a></div>
          </article>''' for s in paid)
    return f'''    <section class="db-sponsored">
      <div class="shell">
        <div class="section-head reveal"><div><h2>Featured supplier</h2></div></div>
{cards}
      </div>
    </section>

'''


def home_page():
    n = len(SUPPLIERS)
    strong = sum(1 for s in SUPPLIERS if s["coa"] == "strong")
    ordered_n = sum(1 for s in SUPPLIERS if s.get("orderedByUs"))
    top = sorted(SUPPLIERS, key=lambda s: (-(s["rating"] or 0), not s.get("orderedByUs"), s["name"].lower()))[:6]
    comp = compound_options()[:10]
    chips = "".join(
        f'<a class="pill" href="/database/?compound={esc(k.lower())}">{esc(k)} <span class="muted">({c})</span></a>' for k, c in comp
    )
    tops = "\n".join(
        f'''          <a class="card card-link reveal" href="{esc(s["reviewUrl"])}">
            <div class="review-media"><img class="directory-image" src="{esc(s["cover"])}" alt="{esc(s["name"])} cover" loading="lazy"></div>
            <div class="kicker">{esc(PRICE_LABEL.get(s["price"], ""))} &middot; {esc(COA_LABEL.get(s["coa"], ""))}</div>
            <h3>{esc(s["name"])} <span class="stars">{stars(s["rating"])}</span></h3>
            <p>{esc(first_sentence(s["summary"], 150))}</p>
          </a>'''
        for s in top
    )
    title = "PeptideSuppliers.org | The Peptide Supplier Database"
    desc = f"Search a database of {n} research peptide suppliers by compound, published COAs, price, and shipping, with full reviews and hands-on order notes."
    site_ld = {
        "@context": "https://schema.org",
        "@type": "WebSite",
        "name": "PeptideSuppliers.org",
        "url": SITE + "/",
        "potentialAction": {
            "@type": "SearchAction",
            "target": SITE + "/database/?q={search_term_string}",
            "query-input": "required name=search_term_string",
        },
    }
    return f'''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{esc(title)}</title>
  <meta name="description" content="{esc(desc)}">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="{SITE}/">
  <meta property="og:type" content="website">
  <meta property="og:title" content="{esc(title)}">
  <meta property="og:description" content="{esc(desc)}">
  <meta property="og:url" content="{SITE}/">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="{SITE}/og-image.png">
  <meta name="msvalidate.01" content="C8719FB191BECC97924097624E16EAE4">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="{esc(title)}">
  <meta name="twitter:description" content="{esc(desc)}">
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <link rel="stylesheet" href="/styles.css">
  <script type="application/ld+json">{json.dumps(site_ld)}</script>
</head>
<body>
{HEADER.format(nav=nav("home"))}

  <main>
    <section class="page-hero">
      <div class="shell">
        <div class="page-hero-card db-hero">
          <div class="eyebrow">Independent reviews + hands-on orders</div>
          <h1 class="page-title">Peptide Supplier Database: compare {n} suppliers</h1>
          <p>Search {n} research peptide suppliers by compound, published COAs, price, and shipping. Every listing has a review, and we place real orders to check what suppliers actually send.</p>
          <form class="db-search" action="/database/" method="get" role="search">
            <label class="sr-only" for="home-q">Search suppliers or compounds</label>
            <input id="home-q" class="input" name="q" type="search" placeholder="Search a supplier or compound, e.g. BPC-157, Amino Club">
            <button class="button button-primary" type="submit">Search</button>
          </form>
          <div class="db-stats">
            <div><strong>{n}</strong><span>suppliers listed</span></div>
            <div><strong>{strong}</strong><span>publish COAs</span></div>
            <div><strong>{ordered_n}</strong><span>orders we received</span></div>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Browse by compound</h2>
            <p>Jump straight to suppliers that highlight a compound.</p>
          </div>
        </div>
        <div class="pill-row reveal">{chips}</div>
        <div class="button-row" style="margin-top:20px;"><a class="button button-primary" href="/database/">Open the full database</a></div>
      </div>
    </section>

{home_sponsored()}    <section>
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>Highest-rated suppliers</h2>
            <p>Ranked by our review rating. Ratings reflect documentation, clarity, and buyer risk, not paid placement.</p>
          </div>
        </div>
        <div class="supplier-grid">
{tops}
        </div>
      </div>
    </section>

    <section>
      <div class="shell resource-grid">
        <article class="card reveal">
          <div class="kicker">How we rate</div>
          <h3>Documentation first</h3>
          <p>We weigh readable, lot-specific COAs, site clarity, research-use framing, and buyer risk such as hard-to-reverse payment methods. Read the <a href="/how-we-review-suppliers/">full methodology</a>.</p>
        </article>
        <article class="card reveal delay-1">
          <div class="kicker">Hands-on checks</div>
          <h3>We order when we can</h3>
          <p>Suppliers marked "Ordered &amp; received by us" were bought and delivered, and we reviewed the COA that came with them. Other listings are reviewed from public pages and say so.</p>
        </article>
        <article class="card reveal delay-2">
          <div class="kicker">Add your company</div>
          <h3>Get listed or featured</h3>
          <p>Suppliers can request a listing, or pay for a clearly labeled sponsored placement at the top of the database. Sponsorship never changes a rating. <a href="/contact/">Contact us</a>.</p>
        </article>
      </div>
    </section>

    <section>
      <div class="shell">
        <div class="notice reveal">
          <div class="kicker">Educational reference only</div>
          <h3>Research use only, not medical advice</h3>
          <p>PeptideSuppliers.org does not sell peptides, provide medical advice, or recommend human use. Some links are affiliate links; see our <a href="/disclosure/">disclosure</a>.</p>
        </div>
      </div>
    </section>
  </main>

{FOOTER}
</body>
</html>
'''


def suppliers_hub():
    """Regenerates the body of suppliers/index.html from the data file."""
    ordered = sorted(SUPPLIERS, key=lambda s: s["name"].lower())
    cards = "\n".join(
        f'''          <a class="card card-link reveal" href="{esc(s["reviewUrl"])}">
            <div class="review-media"><img class="directory-image" src="{esc(s["cover"])}" alt="{esc(s["name"])} supplier cover" loading="lazy"></div>
            <div class="kicker">{esc(PRICE_LABEL.get(s["price"], ""))} &middot; {esc(COA_LABEL.get(s["coa"], "COA info not stated"))}</div>
            <h3>{esc(s["name"])} <span class="stars">{stars(s["rating"])}</span></h3>
            <p>{esc(first_sentence(s["summary"], 150))}</p>
          </a>'''
        for s in ordered
    )
    main = f'''<main>
    <section class="page-hero supplier-hero">
      <div class="shell">
        <div class="page-hero-card">
          <div class="eyebrow">Supplier reviews</div>
          <h1 class="page-title">All reviewed peptide suppliers</h1>
          <p>Every supplier in the database has its own review page covering documentation, shipping, payment terms, and who it suits. Want to filter instead of browse? Use the database.</p>
          <div class="button-row">
            <a class="button button-primary" href="/database/">Search the database</a>
            <a class="button button-ghost" href="/how-we-review-suppliers/">Read methodology</a>
          </div>
        </div>
      </div>
    </section>

    <section id="all-suppliers">
      <div class="shell">
        <div class="section-head reveal">
          <div>
            <h2>{len(SUPPLIERS)} suppliers, A to Z</h2>
            <p>Click a supplier for the full review. Some outbound links are affiliate links; see the <a href="/disclosure/">disclosure</a>.</p>
          </div>
        </div>
        <div class="supplier-grid">
{cards}
        </div>
      </div>
    </section>
  </main>'''
    p = ROOT / "suppliers" / "index.html"
    t = p.read_text(encoding="utf-8")
    t = re.sub(r"<main>.*?</main>", lambda m: main, t, count=1, flags=re.S)
    t = re.sub(r"<title>.*?</title>", f"<title>Peptide Supplier Reviews: All {len(SUPPLIERS)} Reviewed Suppliers | PeptideSuppliers.org</title>", t, count=1, flags=re.S)
    t = re.sub(r'(<meta name="description" content=")[^"]*(">)', lambda m: m.group(1) + f"Browse all {len(SUPPLIERS)} reviewed research peptide suppliers, each with documentation, shipping, and payment notes. Search and filter in the database." + m.group(2), t, count=1)
    p.write_text(t, encoding="utf-8")


def retrofit_nav_and_footer():
    """Swap nav and footer on the pages we keep so navigation is consistent."""
    pages = {
        "about/index.html": "about",
        "how-we-review-suppliers/index.html": "reviews",
        "disclosure/index.html": "",
        "privacy/index.html": "",
        "medical-disclaimer/index.html": "",
        "reviews/index.html": "reviews",
        "contact/index.html": "contact",
        "suppliers/index.html": "suppliers",
        "blog/index.html": "blog",
        "tools/index.html": "tools",
        "tools/coa-mass-check/index.html": "tools",
    }
    for d in (ROOT / "blog").iterdir():
        if d.is_dir() and (d / "index.html").exists():
            pages[f"blog/{d.name}/index.html"] = "blog"
    for d in (ROOT / "suppliers").iterdir():
        if d.is_dir() and (d / "index.html").exists():
            pages[f"suppliers/{d.name}/index.html"] = "suppliers"
    for rel, active in pages.items():
        p = ROOT / rel
        s = p.read_text(encoding="utf-8")
        s = re.sub(r'<nav class="nav"[^>]*>.*?</nav>', nav(active), s, count=1, flags=re.S)
        s = re.sub(r'<footer class="footer">.*?</footer>', FOOTER.strip(), s, count=1, flags=re.S)
        s = s.replace("<span>Finding the right peptide supplier for you</span>", "<span>The peptide supplier database</span>")
        p.write_text(s, encoding="utf-8")


def blog_pages():
    posts = json.loads((ROOT / "data" / "posts.json").read_text(encoding="utf-8"))["posts"]
    posts = sorted(posts, key=lambda x: x["date"], reverse=True)
    n = len(SUPPLIERS)
    head = lambda title, desc, url, extra="": f'''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{esc(title)}</title>
  <meta name="description" content="{esc(desc)}">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="{SITE}{url}">
  <meta property="og:type" content="article">
  <meta property="og:title" content="{esc(title)}">
  <meta property="og:description" content="{esc(desc)}">
  <meta property="og:url" content="{SITE}{url}">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="{SITE}/og-image.png">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="{esc(title)}">
  <meta name="twitter:description" content="{esc(desc)}">
  <meta name="twitter:image" content="{SITE}/og-image.png">
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <link rel="stylesheet" href="/styles.css">
{extra}</head>
<body>
{HEADER.format(nav=nav("blog"))}
'''
    tail = FOOTER + '\n  <script src="/assets/site.js" defer></script>\n</body>\n</html>\n'
    # index
    items = "\n".join(
        f'''        <a class="card card-link reveal" href="/blog/{x["slug"]}/">
          <div class="kicker">{esc(x["dateLabel"])}</div>
          <h3>{esc(x["title"])}</h3>
          <p>{esc(x["description"])}</p>
        </a>''' for x in posts)
    idx = head("Peptide Supplier Blog: Guides and Updates | PeptideSuppliers.org",
               "News, guides and updates from PeptideSuppliers.org on choosing a research peptide supplier, reading COAs, and how our database works.",
               "/blog/") + f'''
  <main>
    <section class="page-hero">
      <div class="shell">
        <div class="page-hero-card db-hero">
          <div class="eyebrow">Blog</div>
          <h1 class="page-title">Notes on finding a peptide supplier</h1>
          <p>Guides and updates from the team behind the {n}-supplier database: what we look for, how we rate, and what we learn from ordering.</p>
        </div>
      </div>
    </section>
    <section>
      <div class="shell">
        <div class="supplier-grid">
{items}
        </div>
      </div>
    </section>
  </main>
''' + tail
    (ROOT / "blog").mkdir(exist_ok=True)
    (ROOT / "blog" / "index.html").write_text(idx, encoding="utf-8")
    for x in posts:
        url = f"/blog/{x['slug']}/"
        body = x["body"].replace("{n}", str(n))
        ld = {"@context": "https://schema.org", "@type": "BlogPosting", "headline": x["title"], "description": x["description"],
              "datePublished": x["date"], "dateModified": x.get("modified", x["date"]),
              "mainEntityOfPage": SITE + url,
              "author": {"@type": "Organization", "name": "PeptideSuppliers.org editorial team", "url": SITE + "/about/"},
              "publisher": {"@type": "Organization", "name": "PeptideSuppliers.org", "url": SITE + "/"}}
        bc = {"@context": "https://schema.org", "@type": "BreadcrumbList", "itemListElement": [
            {"@type": "ListItem", "position": 1, "name": "Home", "item": SITE + "/"},
            {"@type": "ListItem", "position": 2, "name": "Blog", "item": SITE + "/blog/"},
            {"@type": "ListItem", "position": 3, "name": x["title"], "item": SITE + url}]}
        extra = '  <script type="application/ld+json">' + json.dumps(ld) + '</script>\n  <script type="application/ld+json">' + json.dumps(bc) + '</script>\n'
        page = head(x["title"] + " | PeptideSuppliers.org", x["description"], url, extra) + f'''
  <main>
    <section class="page-hero">
      <div class="shell">
        <div class="page-hero-card db-hero">
          <div class="eyebrow"><a href="/blog/">Blog</a> &middot; {esc(x["dateLabel"])}</div>
          <h1 class="page-title">{esc(x["h1"])}</h1>
          <p class="byline tiny muted">By the PeptideSuppliers.org editorial team &middot; <a href="/how-we-review-suppliers/">How we review</a></p>
        </div>
      </div>
    </section>
    <section>
      <div class="shell">
        <article class="post">
{body}
        </article>
      </div>
    </section>
  </main>
''' + tail
        (ROOT / "blog" / x["slug"]).mkdir(exist_ok=True)
        (ROOT / "blog" / x["slug"] / "index.html").write_text(page, encoding="utf-8")
    return posts


REL_SP = "sponsored nofollow noopener noreferrer"
GENERIC_CHECKS = [
    "A COA dated and numbered for the batch printed on your vial, not a generic or reused file.",
    "HPLC purity with the trace shown, and mass-spec confirming identity.",
    "The testing lab's name and a way to verify the report independently.",
    "Fill amount, counter-ion and storage guidance on the label or listing.",
]


def peptides_pages():
    """Hub is generated; each compound page body is hand-written in data/peptide-pages/<slug>.html."""
    data = json.loads((ROOT / "data" / "peptides.json").read_text(encoding="utf-8"))
    sup, peps = data["suppliers"], data["peptides"]
    head = lambda title, desc, url, extra="": f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{esc(title)}</title>
  <meta name="description" content="{esc(desc)}">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="{SITE}{url}">
  <meta property="og:type" content="article">
  <meta property="og:title" content="{esc(title)}">
  <meta property="og:description" content="{esc(desc)}">
  <meta property="og:url" content="{SITE}{url}">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="{SITE}/og-image.png">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="{esc(title)}">
  <meta name="twitter:description" content="{esc(desc)}">
  <meta name="twitter:image" content="{SITE}/og-image.png">
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <link rel="stylesheet" href="/styles.css">
{extra}</head>
<body>
{HEADER.format(nav=nav("peptides"))}
"""
    tail = FOOTER + '\n  <script src="/assets/site.js" defer></script>\n</body>\n</html>\n'
    ready = [p for p in peps if (ROOT / "data" / "peptide-pages" / f"{p['slug']}.html").exists()]
    cards = "\n".join(
        f"""        <a class="card card-link reveal" href="/peptides/{p["slug"]}/">
          <img class="pep-card-img" src="/assets/peptides/cover-{p["slug"]}.svg" alt="{esc(p["name"])} cover illustration" width="640" height="360" loading="lazy">
          <div class="kicker">{esc(p["type"])}</div>
          <h3>{esc(p["name"])}</h3>
          <p>{esc(p["summary"])}</p>
        </a>""" for p in ready)
    checklist = "\n".join("            <li>" + esc(c) + "</li>" for c in GENERIC_CHECKS)
    hub = head("Research Peptide Directory: Overviews and Suppliers | PeptideSuppliers.org",
               "A directory of commonly searched research peptides with in-depth overviews, documentation guidance and supplier links. Research use only.",
               "/peptides/") + f"""
  <main>
    <section class="page-hero">
      <div class="shell">
        <div class="page-hero-card db-hero">
          <div class="eyebrow">Peptide directory</div>
          <h1 class="page-title">Research peptides: what they are and where to find them</h1>
          <p>In-depth guides to commonly searched compounds: what each one is, what to look for on a certificate of analysis, and links to suppliers we list. For laboratory research only. Supplier links on these pages are affiliate links; see our <a href="/disclosure/">disclosure</a>.</p>
        </div>
      </div>
    </section>
    <section>
      <div class="shell">
        <div class="supplier-grid">
{cards}
        </div>
        <article class="post post-wide" id="checklist" style="margin-top:32px;">
          <h2>The batch-record checklist for any peptide</h2>
          <p>Whichever compound you are looking at, these are the documents worth having before you trust a vial:</p>
          <ul>
{checklist}
          </ul>
          <p>More on our approach in <a href="/how-we-review-suppliers/">how we review suppliers</a>. Looking for more suppliers? Use the <a href="/database/">supplier database</a> and filter by compound.</p>
        </article>
      </div>
    </section>
  </main>
""" + tail
    (ROOT / "peptides").mkdir(exist_ok=True)
    (ROOT / "peptides" / "index.html").write_text(hub, encoding="utf-8")
    urls = ["/peptides/"]
    for p in ready:
        url = f"/peptides/{p['slug']}/"
        urls.append(url)
        frag = (ROOT / "data" / "peptide-pages" / f"{p['slug']}.html").read_text(encoding="utf-8")
        for key, tok in (("iron", "IRON"), ("ngp", "NGP"), ("vortex", "VORTEX")):
            frag = frag.replace("{{" + tok + "}}", esc(sup[key]["base"].format(h=p["suppliers"][key])))
        frag = frag.replace("{{REL}}", REL_SP)
        toc_items = []
        def _id(m):
            title = re.sub(r"<[^>]+>", "", m.group(1))
            sid = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")[:48]
            toc_items.append((sid, title))
            return f'<h2 id="{sid}">{m.group(1)}</h2>'
        frag = re.sub(r"<h2>(.*?)</h2>", _id, frag)
        toc = "".join(f'<li><a href="#{a}">{esc(t)}</a></li>' for a, t in toc_items)
        buy = "".join(
            f'<a class="button button-ghost" href="{esc(sup[k]["base"].format(h=p["suppliers"][k]))}" target="_blank" rel="{REL_SP}">{esc(sup[k]["name"])}</a>'
            for k in ("iron", "ngp", "vortex"))
        aside = f'''<aside class="pep-aside">
          <div class="pep-aside-card">
            <div class="kicker">On this page</div>
            <ol class="pep-toc">{toc}</ol>
          </div>
          <div class="pep-aside-card">
            <div class="kicker">Suppliers that list {esc(p["name"])}</div>
            <div class="pep-buy">{buy}</div>
            <p class="tiny muted">Affiliate links; we may earn a commission at no cost to you. <a href="/disclosure/">Disclosure</a>. Research use only.</p>
          </div>
        </aside>'''
        desc = p["metaDesc"]
        ld = {"@context": "https://schema.org", "@type": "Article", "headline": p["h1"],
              "description": desc, "mainEntityOfPage": SITE + url, "dateModified": "2026-10-25", "datePublished": "2026-10-25",
              "image": f"{SITE}/assets/peptides/{p['slug']}.svg",
              "author": {"@type": "Organization", "name": "PeptideSuppliers.org editorial team", "url": SITE + "/about/"},
              "publisher": {"@type": "Organization", "name": "PeptideSuppliers.org", "url": SITE + "/"}}
        bc = {"@context": "https://schema.org", "@type": "BreadcrumbList", "itemListElement": [
            {"@type": "ListItem", "position": 1, "name": "Home", "item": SITE + "/"},
            {"@type": "ListItem", "position": 2, "name": "Peptides", "item": SITE + "/peptides/"},
            {"@type": "ListItem", "position": 3, "name": p["name"], "item": SITE + url}]}
        extra = '  <script type="application/ld+json">' + json.dumps(ld) + '</script>\n  <script type="application/ld+json">' + json.dumps(bc) + '</script>\n'
        page = head(p["title"] + " | PeptideSuppliers.org", desc, url, extra) + f"""
  <main>
    <section class="page-hero">
      <div class="shell">
        <div class="page-hero-card db-hero">
          <div class="pep-hero">
            <div>
              <div class="eyebrow"><a href="/peptides/">Peptides</a> &middot; {esc(p["type"])}</div>
              <h1 class="page-title">{esc(p["h1"])}</h1>
              <p>{esc(p["summary"])}</p>
            </div>
            <img class="pep-hero-img" src="/assets/peptides/cover-{p["slug"]}.svg" alt="{esc(p["name"])} cover illustration" width="640" height="360">
          </div>
        </div>
      </div>
    </section>
    <section>
      <div class="shell">
        <div class="pep-layout">
        <article class="post post-wide">
{frag}
        </article>
        {aside}
        </div>
      </div>
    </section>
  </main>
""" + tail
        (ROOT / "peptides" / p["slug"]).mkdir(exist_ok=True)
        (ROOT / "peptides" / p["slug"] / "index.html").write_text(page, encoding="utf-8")
    sm = (ROOT / "sitemap.xml").read_text(encoding="utf-8")
    for u in urls:
        if SITE + u not in sm:
            sm = sm.replace("</urlset>", f"  <url>\n    <loc>{SITE}{u}</loc>\n    <lastmod>2026-10-25</lastmod>\n  </url>\n</urlset>")
    (ROOT / "sitemap.xml").write_text(sm, encoding="utf-8")


def tools_pages():
    masses = json.loads((ROOT / "data" / "tool-masses.json").read_text(encoding="utf-8"))
    head = lambda title, desc, url, extra="": f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{esc(title)}</title>
  <meta name="description" content="{esc(desc)}">
  <meta name="robots" content="index,follow">
  <link rel="canonical" href="{SITE}{url}">
  <meta property="og:type" content="website">
  <meta property="og:title" content="{esc(title)}">
  <meta property="og:description" content="{esc(desc)}">
  <meta property="og:url" content="{SITE}{url}">
  <meta property="og:site_name" content="PeptideSuppliers.org">
  <meta property="og:image" content="{SITE}/og-image.png">
  <meta name="twitter:card" content="summary">
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <link rel="stylesheet" href="/styles.css">
{extra}</head>
<body>
{HEADER.format(nav=nav("tools"))}
"""
    tail = FOOTER + '\n  <script src="/assets/site.js" defer></script>\n</body>\n</html>\n'
    (ROOT / "tools" / "coa-mass-check").mkdir(parents=True, exist_ok=True)
    hub = head("Free Peptide Research Tools | PeptideSuppliers.org", "Free tools for reading peptide documentation, starting with a certificate-of-analysis mass checker. No dosing tools.", "/tools/") + """
  <main>
    <section class="page-hero"><div class="shell"><div class="page-hero-card db-hero">
      <div class="eyebrow">Tools</div>
      <h1 class="page-title">Tools for reading peptide documentation</h1>
      <p>Free, no sign-up. These tools help you check supplier paperwork. We do not build dosing or reconstitution tools.</p>
    </div></div></section>
    <section><div class="shell"><div class="supplier-grid">
      <a class="card card-link" href="/tools/coa-mass-check/">
        <div class="kicker">COA tool</div>
        <h3>COA mass checker</h3>
        <p>Enter the mass from a certificate of analysis and see which compound it matches, including oxidation and look-alike forms.</p>
      </a>
    </div></div></section>
  </main>
""" + tail
    (ROOT / "tools" / "index.html").write_text(hub, encoding="utf-8")
    ld = {"@context": "https://schema.org", "@type": "WebApplication", "name": "COA Mass Checker", "url": SITE + "/tools/coa-mass-check/",
          "applicationCategory": "EducationalApplication", "operatingSystem": "Any", "offers": {"@type": "Offer", "price": "0", "priceCurrency": "USD"},
          "publisher": {"@type": "Organization", "name": "PeptideSuppliers.org", "url": SITE + "/"}}
    extra = '  <script type="application/ld+json">' + json.dumps(ld) + '</script>\n'
    data = json.dumps(masses["compounds"])
    page = head("COA Mass Checker: Does the Mass on Your Certificate Match? | PeptideSuppliers.org",
                "Free tool: enter the mass from a peptide certificate of analysis to see which compound it matches, spot oxidation (+16 Da) and catch look-alike forms such as CJC-1295 with and without DAC.",
                "/tools/coa-mass-check/", extra) + """
  <main>
    <section class="page-hero"><div class="shell"><div class="page-hero-card db-hero">
      <div class="eyebrow"><a href="/tools/">Tools</a> &middot; COA tool</div>
      <h1 class="page-title">COA mass checker</h1>
      <p>Type the mass printed on a certificate of analysis. The tool shows which compounds it matches, and flags oxidation and look-alike forms. It checks identity only; it says nothing about purity, sterility or safety.</p>
    </div></div></section>
    <section><div class="shell"><div class="mass-layout">
      <form class="mass-card" id="mass-form" autocomplete="off">
        <label class="field-label" for="mass-compound">Compound on the listing (optional)</label>
        <select class="input" id="mass-compound"><option value="">Not sure / any</option></select>
        <label class="field-label" for="mass-value">Mass on the COA (daltons)</label>
        <input class="input" id="mass-value" type="number" step="any" min="1" inputmode="decimal" placeholder="e.g. 1419.5" required>
        <label class="field-label" for="mass-type">What kind of number is it?</label>
        <select class="input" id="mass-type">
          <option value="neutral">Molecular weight / deconvoluted mass</option>
          <option value="mh">[M+H]+ ion (singly protonated)</option>
        </select>
        <button class="button button-primary" type="submit">Check mass</button>
        <p class="tiny muted">Spectra often show several charge states (for example [M+2H]2+). Use the deconvoluted or stated molecular mass where you can. Tolerance is about 1 Da, or 0.05% for large peptides.</p>
      </form>
      <div class="mass-card" id="mass-result" aria-live="polite"><p class="muted">Enter a mass to see matches.</p></div>
    </div></div></section>
    <section><div class="shell"><article class="post post-wide">
      <h2>How to use the result</h2>
      <p><strong>A match</strong> means the stated mass is consistent with that compound. It does not prove the batch is pure, correctly folded, sterile or the right stereoisomer: for example, a peptide with a D-amino acid has the same mass as its L-form. Use the chromatogram for those questions.</p>
      <p><strong>An oxidation match</strong> (+16 Da per oxygen) suggests some methionine has oxidized, common in older or poorly stored batches of peptides such as MOTS-c, Semax and tesamorelin. A small amount is normal; a large share is a quality concern.</p>
      <p><strong>A look-alike match</strong> means the mass fits a different form than the listing, such as CJC-1295 with DAC versus without, or tesamorelin versus unmodified GHRH(1-44). Ask the supplier which form they sell.</p>
      <p>Masses are approximate averages and vendors round differently. Read our <a href="/how-we-review-suppliers/">review methodology</a> and the <a href="/peptides/">compound guides</a> for the full documentation checklist. For research use only; not medical advice.</p>
    </article></div></section>
  </main>
  <script>
  (function () {
    var DATA = """ + data + """;
    var form = document.getElementById('mass-form'), sel = document.getElementById('mass-compound'),
        out = document.getElementById('mass-result');
    DATA.forEach(function (c) { var o = document.createElement('option'); o.value = c.id; o.textContent = c.name; sel.appendChild(o); });
    function tol(m) { return Math.max(1.0, m * 0.0005); }
    function fmt(x) { return ((Math.round(x * 10) / 10) || 0).toLocaleString(); }
    function esc(t) { return String(t).replace(/[&<>"]/g, function (c) { return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]; }); }
    function matches(m) {
      var res = [];
      DATA.forEach(function (c) {
        var variants = [{ label: '', mass: c.mass, kind: 'base' }];
        for (var k = 1; k <= c.met; k++) variants.push({ label: ' + ' + k + ' oxidation' + (k > 1 ? 's' : ''), mass: c.mass + 15.995 * k, kind: 'ox' });
        variants.forEach(function (v) {
          var d = m - v.mass;
          if (Math.abs(d) <= Math.max(tol(v.mass), 1.0)) res.push({ c: c, v: v, d: d });
        });
      });
      res.sort(function (a, b) { return Math.abs(a.d) - Math.abs(b.d); });
      return res;
    }
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var m = parseFloat(document.getElementById('mass-value').value);
      if (!(m > 0)) { out.innerHTML = '<p class="muted">Enter a valid mass.</p>'; return; }
      if (document.getElementById('mass-type').value === 'mh') m = m - 1.007;
      var want = sel.value, list = matches(m), html = '';
      var closest = DATA.map(function (c) { return { c: c, d: m - c.mass }; }).sort(function (a, b) { return Math.abs(a.d) - Math.abs(b.d); })[0];
      if (want) {
        var w = DATA.filter(function (c) { return c.id === want; })[0];
        var hit = list.filter(function (r) { return r.c.id === want; })[0];
        if (hit && hit.v.kind === 'base') {
          html += '<div class="mass-badge mass-ok">Consistent with ' + esc(w.name) + '</div><p>Observed ' + fmt(m) + ' Da versus expected ' + fmt(w.mass) + ' Da (difference ' + fmt(hit.d) + ').</p>';
        } else if (hit) {
          html += '<div class="mass-badge mass-warn">Matches ' + esc(w.name) + esc(hit.v.label) + '</div><p>Observed ' + fmt(m) + ' Da; expected ' + fmt(hit.v.mass) + ' Da. This pattern suggests partial oxidation. Check the chromatogram for an early-eluting satellite peak.</p>';
        } else {
          html += '<div class="mass-badge mass-bad">Does not match ' + esc(w.name) + '</div><p>Observed ' + fmt(m) + ' Da versus expected ' + fmt(w.mass) + ' Da (difference ' + fmt(m - w.mass) + ').</p>';
          if (list.length) html += '<p>It does fit a different compound below. Ask the supplier which form they sell.</p>';
          else html += '<p>It may be a multiply charged ion, a salt or adduct, a different form, or a different product. Ask the supplier for the full spectrum.</p>';
        }
        if (w.hint) html += '<p class="tiny muted">' + esc(w.hint) + ' <a href="' + w.page + '">Read the ' + esc(w.name.split(' (')[0]) + ' guide</a>.</p>';
      }
      if (!want) {
        if (list.length) html += '<div class="mass-badge mass-ok">' + list.length + ' possible match' + (list.length > 1 ? 'es' : '') + '</div>';
        else html += '<div class="mass-badge mass-bad">No match in our list</div><p>Closest: ' + esc(closest.c.name) + ' at ' + fmt(closest.c.mass) + ' Da (difference ' + fmt(closest.d) + '). It may be a charge state, an adduct, or a compound we do not cover.</p>';
      }
      var others = want ? list.filter(function (r) { return r.c.id !== want; }) : list;
      if (others.length) {
        html += '<h3>' + (want ? 'Also fits' : 'Matches') + '</h3><ul class="mass-list">';
        others.forEach(function (r) {
          html += '<li><strong>' + esc(r.c.name) + esc(r.v.label) + '</strong> <span class="muted">(' + esc(r.c.form) + '; expected ' + fmt(r.v.mass) + ', difference ' + fmt(r.d) + ')</span><br><span class="tiny muted">' + esc(r.c.hint) + '</span> <a class="tiny" href="' + r.c.page + '">Guide</a></li>';
        });
        html += '</ul>';
      }
      html += '<p class="tiny muted">Identity check only. Not a statement about purity, sterility or safety.</p>';
      out.innerHTML = html;
    });
  })();
  </script>
""" + tail
    (ROOT / "tools" / "coa-mass-check" / "index.html").write_text(page, encoding="utf-8")
    sm = (ROOT / "sitemap.xml").read_text(encoding="utf-8")
    for u in ("/tools/", "/tools/coa-mass-check/"):
        if SITE + u not in sm:
            sm = sm.replace("</urlset>", f"  <url><loc>{SITE}{u}</loc><lastmod>2026-10-30</lastmod></url>\n</urlset>")
    (ROOT / "sitemap.xml").write_text(sm, encoding="utf-8")


if __name__ == "__main__":
    (ROOT / "database").mkdir(exist_ok=True)
    (ROOT / "database" / "index.html").write_text(database_page(), encoding="utf-8")
    (ROOT / "index.html").write_text(home_page(), encoding="utf-8")
    suppliers_hub()
    blog_pages()
    peptides_pages()
    tools_pages()
    retrofit_nav_and_footer()
    print("built database/index.html, index.html and refreshed nav/footer")
