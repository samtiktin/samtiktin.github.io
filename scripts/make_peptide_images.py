#!/usr/bin/env python3
"""Draws one original sequence/structure illustration per compound into assets/peptides/."""
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "peptides"
OUT.mkdir(parents=True, exist_ok=True)
NAVY, TEAL = "#0f2742", "#0f766e"
COL = {"hyd": "#cfe8e4", "pol": "#e6edf5", "pos": "#cde0f7", "neg": "#f9d9d4", "spec": "#fdebb8", "gly": "#eef0f2"}
CLS = {}
for c in "AVILMFWP": CLS[c] = "hyd"
for c in "STNQYC": CLS[c] = "pol"
for c in "KRH": CLS[c] = "pos"
for c in "DE": CLS[c] = "neg"
CLS["G"] = "gly"
LEG = [("hyd", "Hydrophobic"), ("pol", "Polar"), ("pos", "Positive"), ("neg", "Negative"), ("gly", "Glycine"), ("spec", "Modified / non-natural")]

def svg_wrap(w, h, title, sub, body, legend=True):
    leg = ""
    if legend:
        x = 30
        for k, t in LEG:
            leg += f'<rect x="{x}" y="{h-34}" width="14" height="14" rx="3" fill="{COL[k]}" stroke="#9fb0c3"/><text x="{x+20}" y="{h-23}" font-size="12" fill="#445">{t}</text>'
            x += 30 + len(t) * 7
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" role="img" aria-label="{title}. {sub}" font-family="Inter,Arial,sans-serif">
<rect width="{w}" height="{h}" rx="14" fill="#f7fafc" stroke="#d5dee8"/>
<text x="30" y="40" font-size="22" font-weight="700" fill="{NAVY}">{title}</text>
<text x="30" y="62" font-size="13" fill="#51606f">{sub}</text>
{body}{leg}</svg>'''

def chain(residues, y, w, r=None):
    """residues: list of (label, class). Wraps to rows."""
    n = len(residues)
    per = min(n, 15)
    gap = (w - 120) / per
    r = r or min(24, gap / 2 - 3)
    out = ""
    for i, (lab, cl) in enumerate(residues):
        row, col = divmod(i, per)
        cx = 70 + col * gap + gap / 2 - 10
        cy = y + row * (r * 2 + 36)
        if col:
            out += f'<line x1="{cx-gap+r}" y1="{cy}" x2="{cx-r}" y2="{cy}" stroke="#8a9bb0" stroke-width="2"/>'
        fs = 14 if len(lab) <= 1 else (11 if len(lab) <= 3 else 9)
        out += f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{COL[cl]}" stroke="#7d93ab" stroke-width="1.5"/><text x="{cx}" y="{cy+5}" text-anchor="middle" font-size="{fs}" font-weight="600" fill="{NAVY}">{lab}</text><text x="{cx}" y="{cy+r+14}" text-anchor="middle" font-size="10" fill="#7a8794">{i+1}</text>'
    return out

def seq(s): return [(c, CLS[c]) for c in s]

def make(slug, title, sub, residues, h=None, nterm="N", cterm="C", note=None, r=None):
    rows = (len(residues) - 1) // 15 + 1
    h = h or 150 + rows * 90
    body = chain(residues, 120, 860, r)
    body += f'<text x="30" y="125" font-size="11" fill="{TEAL}" font-weight="700">{nterm}</text>'
    if note: body += f'<text x="30" y="{h-50}" font-size="12" fill="#51606f">{note}</text>'
    (OUT / f"{slug}.svg").write_text(svg_wrap(900, h, title, sub, body), encoding="utf-8")

def bars(slug, title, sub, items, w=900, h=300, note=None):
    """items: list of (label, start, end, total, color, text)"""
    body = ""
    y = 100
    for lab, a, b, tot, colr, txt in items:
        L = 800
        body += f'<text x="30" y="{y}" font-size="13" font-weight="600" fill="{NAVY}">{lab}</text>'
        body += f'<rect x="30" y="{y+10}" width="{L*tot/ max(i[3] for i in items):.0f}" height="26" rx="6" fill="#e6edf5" stroke="#9fb0c3"/>'
        scale = L / max(i[3] for i in items)
        body += f'<rect x="{30+a*scale:.0f}" y="{y+10}" width="{(b-a)*scale:.0f}" height="26" rx="6" fill="{colr}"/>'
        body += f'<text x="30" y="{y+54}" font-size="12" fill="#51606f">{txt}</text>'
        y += 80
    if note: body += f'<text x="30" y="{h-20}" font-size="12" fill="#51606f">{note}</text>'
    (OUT / f"{slug}.svg").write_text(svg_wrap(w, h, title, sub, body, legend=False), encoding="utf-8")

if __name__ == "__main__":
    make("bpc-157", "BPC-157 amino-acid sequence", "15 residues, N-terminus to C-terminus; average mass about 1,419 Da", seq("GEPPPGKPADDAGLV"), h=270, nterm="N", note="Five prolines and two aspartates give the chain a rigid, acidic character.")
    bars("tb-500", "TB-500 versus thymosin beta-4", "The name is used for different molecules by different sellers",
         [("Thymosin beta-4, full protein (43 amino acids, about 4,963 Da)", 0, 43, 43, "#9fb8d4", "Full-length natural protein; hard to synthesize cleanly"),
          ("Short fragment, residues 17-23: Ac-LKKTETQ (about 889 Da)", 16, 23, 43, TEAL, "Actin-binding region; the form described in anti-doping literature")],
         h=300, note="Always check the certificate of analysis mass to see which one a listing is.")

    # GHK-Cu
    body = ""
    cx, cy = 450, 160
    pts = {"G": (230, 190, "gly", "Glycine"), "H": (450, 85, "pos", "Histidine"), "K": (670, 190, "pos", "Lysine")}
    order = ["G", "H", "K"]
    body += f'<line x1="254" y1="188" x2="426" y2="95" stroke="#8a9bb0" stroke-width="2"/><line x1="474" y1="95" x2="646" y2="188" stroke="#8a9bb0" stroke-width="2"/>'
    for k in order:
        x, y, cl, nm = pts[k]
        body += f'<line x1="{x}" y1="{y}" x2="{cx}" y2="{cy}" stroke="#4aa3c7" stroke-width="2" stroke-dasharray="5 4"/>'
    body += f'<circle cx="{cx}" cy="{cy}" r="30" fill="#4aa3c7" stroke="#1f6f94" stroke-width="2"/><text x="{cx}" y="{cy+5}" text-anchor="middle" font-size="15" font-weight="700" fill="#fff">Cu2+</text>'
    for k in order:
        x, y, cl, nm = pts[k]
        body += f'<circle cx="{x}" cy="{y}" r="28" fill="{COL[cl]}" stroke="#7d93ab" stroke-width="1.5"/><text x="{x}" y="{y+6}" text-anchor="middle" font-size="18" font-weight="700" fill="{NAVY}">{k}</text><text x="{x}" y="{y+48}" text-anchor="middle" font-size="12" fill="#51606f">{nm}</text>'
    (OUT / "ghk-cu.svg").write_text(svg_wrap(900, 300, "GHK-Cu: a tripeptide holding a copper ion", "Gly-His-Lys binds copper(II); the complex is about 400 Da and is blue", body, legend=False), encoding="utf-8")

    bars("tesamorelin", "Tesamorelin compared with a 29-residue GHRH analog", "44 amino acids plus an N-terminal hexenoyl cap; about 5,136 Da",
         [("Tesamorelin: GHRH 1-44 with trans-3-hexenoyl cap (about 5,136 Da)", 0, 44, 44, TEAL, "Full-length chain; harder to synthesize cleanly, so the chromatogram matters"),
          ("CJC-1295 no DAC (Modified GRF 1-29): 29 residues", 0, 29, 44, "#9fb8d4", "Shorter analog built on the first 29 residues of GHRH")],
         h=300, note="Unmodified GHRH(1-44) is about 5,040 Da; the cap adds roughly 96 Da.")

    make("ipamorelin", "Ipamorelin: a pentapeptide with non-natural residues", "Aib-His-D-2Nal-D-Phe-Lys-NH2; about 712 Da",
         [("Aib", "spec"), ("His", "pos"), ("D-2Nal", "spec"), ("D-Phe", "spec"), ("Lys-NH2", "spec")], h=270, r=36,
         note="Mirror-image (D) residues have the same mass as natural ones, so chirality errors show up only on chromatography.")

    bars("cjc-1295", "CJC-1295 without DAC versus with DAC", "Two different molecules sold under one name",
         [("CJC-1295 with DAC: 29-residue backbone plus albumin-binding linker (about 3,647 Da)", 0, 33, 33, "#d9a441", "Longer-acting form; the added linker is the difference"),
          ("CJC-1295 no DAC / Modified GRF 1-29: 29 residues (about 3,368 Da)", 0, 29, 33, TEAL, "Shorter-acting form; often listed simply as CJC-1295")],
         h=300, note="A mass of about 3,368 Da versus about 3,647 Da on the COA tells you which one you are looking at.")

    make("mots-c", "MOTS-c amino-acid sequence", "16 residues, encoded in mitochondrial DNA; about 2,174 Da", seq("MRWQEMGYIFYPRKLR"), h=330,
         note="Methionines at positions 1 and 6 and tryptophan at 3 are the easiest sites to oxidize (+16 Da per oxygen).")

    # NAD+ block diagram
    parts = [("Nicotinamide", "#cde0f7"), ("Ribose", "#e6edf5"), ("Pyrophosphate", "#fdebb8"), ("Ribose", "#e6edf5"), ("Adenine", "#cfe8e4")]
    body = ""
    x = 40
    for i, (nm, c) in enumerate(parts):
        w = 150
        body += f'<rect x="{x}" y="110" width="{w}" height="70" rx="12" fill="{c}" stroke="#7d93ab" stroke-width="1.5"/><text x="{x+w/2}" y="151" text-anchor="middle" font-size="15" font-weight="600" fill="{NAVY}">{nm}</text>'
        if i < 4: body += f'<line x1="{x+w}" y1="145" x2="{x+w+25}" y2="145" stroke="#8a9bb0" stroke-width="3"/>'
        x += w + 25
    body += f'<text x="40" y="215" font-size="12" fill="#51606f">C21H27N7O14P2, about 663 Da. Not a peptide: it has no amino acids or sequence.</text>'
    body += f'<text x="40" y="236" font-size="12" fill="#51606f">The nicotinamide-ribose bond is the weak point: heat and moisture break it down to nicotinamide and ADP-ribose.</text>'
    (OUT / "nad.svg").write_text(svg_wrap(900, 280, "NAD+ at a glance", "A dinucleotide coenzyme: two nucleotide halves joined by a pyrophosphate bridge", body, legend=False), encoding="utf-8")

    # Semax vs ACTH(4-10)
    rows = [("ACTH(4-10)", "MEHFRWG", [0, 0, 0, 0, 0, 0, 0]), ("Semax", "MEHFPGP", [0, 0, 0, 0, 1, 0, 1])]
    body = ""
    for ri, (nm, sq, diff) in enumerate(rows):
        y = 130 + ri * 100
        body += f'<text x="30" y="{y-38}" font-size="13" font-weight="700" fill="{TEAL}">{nm}</text>'
        for i, c in enumerate(sq):
            cx = 120 + i * 105
            fill = COL["spec"] if (ri == 1 and i >= 4) else COL[CLS[c]]
            if i: body += f'<line x1="{cx-105+24}" y1="{y}" x2="{cx-24}" y2="{y}" stroke="#8a9bb0" stroke-width="2"/>'
            body += f'<circle cx="{cx}" cy="{y}" r="26" fill="{fill}" stroke="#7d93ab" stroke-width="1.5"/><text x="{cx}" y="{y+6}" text-anchor="middle" font-size="17" font-weight="700" fill="{NAVY}">{c}</text><text x="{cx}" y="{y+44}" text-anchor="middle" font-size="10" fill="#7a8794">{i+4 if ri==0 else i+1}</text>'
    body += f'<text x="30" y="{h_ if False else 290}" font-size="12" fill="#51606f">In Semax the last three ACTH residues (Arg-Trp-Gly) are replaced by Pro-Gly-Pro (highlighted), which resists breakdown.</text>'
    (OUT / "semax.svg").write_text(svg_wrap(900, 330, "Semax compared with the ACTH(4-10) fragment", "Same first four residues, different tail; about 814 Da", body), encoding="utf-8")

    # Selank vs tuftsin
    rows = [("Tuftsin (4 residues)", "TKPR", 0), ("Selank (7 residues, about 752 Da)", "TKPRPGP", 1)]
    body = ""
    for ri, (nm, sq, sel) in enumerate(rows):
        y = 130 + ri * 100
        body += f'<text x="30" y="{y-38}" font-size="13" font-weight="700" fill="{TEAL}">{nm}</text>'
        for i, c in enumerate(sq):
            cx = 120 + i * 105
            fill = COL["spec"] if (sel and i >= 4) else COL[CLS[c]]
            if i: body += f'<line x1="{cx-105+24}" y1="{y}" x2="{cx-24}" y2="{y}" stroke="#8a9bb0" stroke-width="2"/>'
            body += f'<circle cx="{cx}" cy="{y}" r="26" fill="{fill}" stroke="#7d93ab" stroke-width="1.5"/><text x="{cx}" y="{y+6}" text-anchor="middle" font-size="17" font-weight="700" fill="{NAVY}">{c}</text><text x="{cx}" y="{y+44}" text-anchor="middle" font-size="10" fill="#7a8794">{i+1}</text>'
    body += f'<text x="30" y="290" font-size="12" fill="#51606f">Tuftsin comes from an antibody heavy chain; the added Pro-Gly-Pro tail (highlighted) slows enzymatic breakdown.</text>'
    (OUT / "selank.svg").write_text(svg_wrap(900, 330, "Selank is tuftsin with a stabilizing tail", "Thr-Lys-Pro-Arg extended by Pro-Gly-Pro", body), encoding="utf-8")

    # KPV in alpha-MSH
    sq = "SYSMEHFRWGKPV"
    body = ""
    for i, c in enumerate(sq):
        cx = 75 + i * 62
        y = 150
        fill = COL["spec"] if i >= 10 else COL[CLS[c]]
        if i: body += f'<line x1="{cx-62+22}" y1="{y}" x2="{cx-22}" y2="{y}" stroke="#8a9bb0" stroke-width="2"/>'
        body += f'<circle cx="{cx}" cy="{y}" r="22" fill="{fill}" stroke="#7d93ab" stroke-width="1.5"/><text x="{cx}" y="{y+6}" text-anchor="middle" font-size="16" font-weight="700" fill="{NAVY}">{c}</text><text x="{cx}" y="{y+40}" text-anchor="middle" font-size="10" fill="#7a8794">{i+1}</text>'
    body += f'<text x="30" y="154" font-size="11" fill="{TEAL}" font-weight="700">Ac</text>'
    body += f'<text x="{75+12*62+34}" y="154" font-size="11" fill="{TEAL}" font-weight="700">NH2</text>'
    body += f'<rect x="{75+10*62-30}" y="105" width="{2*62+60}" height="90" rx="12" fill="none" stroke="{TEAL}" stroke-width="2" stroke-dasharray="6 4"/><text x="{75+11*62}" y="98" text-anchor="middle" font-size="13" font-weight="700" fill="{TEAL}">KPV (11-13)</text>'
    body += f'<text x="30" y="260" font-size="12" fill="#51606f">Alpha-MSH is 13 residues; KPV is its last three. Pigmentation activity sits in the middle of the chain (His-Phe-Arg-Trp), not in KPV.</text>'
    (OUT / "kpv.svg").write_text(svg_wrap(900, 330, "KPV is the C-terminal tripeptide of alpha-MSH", "Lys-Pro-Val; about 342 Da", body), encoding="utf-8")

    make("ss-31", "SS-31 (elamipretide): a designed tetrapeptide", "D-Arg-Dmt-Lys-Phe-NH2; about 640 Da",
         [("D-Arg", "spec"), ("Dmt", "spec"), ("Lys", "pos"), ("Phe-NH2", "spec")], h=270, r=38,
         note="D-Arg and Dmt (2',6'-dimethyltyrosine) are non-natural; swapping Dmt for tyrosine would shift the mass by about 28 Da.")
