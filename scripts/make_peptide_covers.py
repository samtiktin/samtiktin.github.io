#!/usr/bin/env python3
"""Draws an original cover image per compound (assets/peptides/cover-<slug>.svg) for the hub cards and page heroes."""
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "peptides"
# slug: (name, type, chips, residues for the decorative chain, hue pair)
C = {
 "bpc-157": ("BPC-157", "Pentadecapeptide", ["15 residues", "~1,419 Da"], "GEPPPGKPADDAGLV", ("#0f2742", "#0f766e")),
 "tb-500": ("TB-500", "Thymosin beta-4 related", ["43-mer or 7-mer", "~889 / 4,963 Da"], "LKKTETQ", ("#12304f", "#2563a8")),
 "ghk-cu": ("GHK-Cu", "Copper tripeptide", ["3 residues", "~400 Da"], "GHK", ("#0c3b5c", "#1d8fb5")),
 "tesamorelin": ("Tesamorelin", "GHRH analog", ["44 residues", "~5,136 Da"], "YADAIFTNSYRKVLGQLSARKLLQDIMSRQQGESNQ", ("#1b2a52", "#6b4bb8")),
 "ipamorelin": ("Ipamorelin", "Ghrelin-receptor agonist", ["5 residues", "~712 Da"], "AHFFK", ("#0f2742", "#0e7a6b")),
 "cjc-1295": ("CJC-1295", "GHRH analog", ["DAC / no DAC", "~3,368 / 3,647 Da"], "YADAIFTNSYRKVLGQLSARKLLQDIMSR", ("#222f55", "#3b6fd0")),
 "mots-c": ("MOTS-c", "Mitochondrial-derived peptide", ["16 residues", "~2,174 Da"], "MRWQEMGYIFYPRKLR", ("#0f3a3a", "#1c9a7e")),
 "nad": ("NAD+", "Coenzyme (not a peptide)", ["Dinucleotide", "~663 Da"], "", ("#33301a", "#b58a1c")),
 "semax": ("Semax", "ACTH(4-10) analog", ["7 residues", "~814 Da"], "MEHFPGP", ("#1a2f4e", "#0f766e")),
 "selank": ("Selank", "Tuftsin analog", ["7 residues", "~752 Da"], "TKPRPGP", ("#142a46", "#2a8f9d")),
 "kpv": ("KPV", "alpha-MSH fragment", ["3 residues", "~342 Da"], "KPV", ("#3a2442", "#b0527a")),
 "ss-31": ("SS-31", "Elamipretide", ["4 residues", "~640 Da"], "RYKF", ("#17284a", "#0d7c91")),
}
def svg(slug):
    name, typ, chips, seq, (c1, c2) = C[slug]
    w, h = 640, 360
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" role="img" aria-label="{name}: {typ}" font-family="Inter,Arial,sans-serif">',
             f'<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></linearGradient></defs>',
             f'<rect width="{w}" height="{h}" fill="url(#g)"/>',
             '<circle cx="560" cy="60" r="150" fill="#fff" fill-opacity=".05"/><circle cx="600" cy="330" r="110" fill="#fff" fill-opacity=".05"/>']
    # decorative chain
    seq = seq[:28]
    if seq:
        n = len(seq); per = min(n, 14); gap = 520 / max(per - 1, 1) if per > 1 else 0
        gap = min(gap, 62)
        total = gap * (per - 1)
        x0 = 40
        for i, c in enumerate(seq):
            row, col = divmod(i, per)
            cx = x0 + col * gap + 14; cy = 232 + row * 46
            if col: parts.append(f'<line x1="{cx-gap+13}" y1="{cy}" x2="{cx-13}" y2="{cy}" stroke="#fff" stroke-opacity=".45" stroke-width="2"/>')
            parts.append(f'<circle cx="{cx}" cy="{cy}" r="13" fill="#fff" fill-opacity=".92"/><text x="{cx}" y="{cy+4.5}" text-anchor="middle" font-size="12" font-weight="700" fill="{c1}">{c}</text>')
    else:
        x = 40
        for lab in ("Nicotinamide", "Ribose", "PP", "Ribose", "Adenine"):
            wd = 40 + len(lab) * 7
            parts.append(f'<rect x="{x}" y="212" width="{wd}" height="40" rx="10" fill="#fff" fill-opacity=".92"/><text x="{x+wd/2}" y="237" text-anchor="middle" font-size="12" font-weight="700" fill="{c1}">{lab}</text>')
            x += wd + 8
    parts.append(f'<text x="40" y="92" font-size="14" font-weight="700" letter-spacing="2" fill="#fff" fill-opacity=".75">RESEARCH COMPOUND</text>')
    parts.append(f'<text x="40" y="150" font-size="{54 if len(name) < 9 else 44}" font-weight="800" fill="#fff">{name}</text>')
    parts.append(f'<text x="40" y="184" font-size="18" fill="#fff" fill-opacity=".85">{typ}</text>')
    x = 40
    for ch in chips:
        wd = 24 + len(ch) * 8
        parts.append(f'<rect x="{x}" y="310" width="{wd}" height="30" rx="15" fill="#fff" fill-opacity=".16" stroke="#fff" stroke-opacity=".4"/><text x="{x+wd/2}" y="330" text-anchor="middle" font-size="13" font-weight="600" fill="#fff">{ch}</text>')
        x += wd + 10
    parts.append('</svg>')
    return "".join(parts)
if __name__ == "__main__":
    for s in C:
        (OUT / f"cover-{s}.svg").write_text(svg(s), encoding="utf-8")
    print("covers:", len(C))
