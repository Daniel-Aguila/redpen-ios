import asyncio, os
from playwright.async_api import async_playwright

RED, GOLD, GOLD_D, WOOD, INK = "#E63946", "#F2C14E", "#D9A21B", "#7E5236", "#2B2B2B"
BASE = dict(FUR="#C08D62", FUR_B="#B07C54", FUR_D="#7E5236", MUZ="#E6BE94")
JADE = dict(FUR="#52B8A6", FUR_B="#43A795", FUR_D="#2B7468", MUZ="#D4F0E2")

D = {
 "tiny":  dict(head=(66,88,88,70,31), body=(80,138,60,46,22), feet=(184,98,122,9,4.5), er=5.2, ey=118, ex=(88,132),
               muz=(83,121,54,32,11), ny=130, nx=(101,119), my=142, ears=((78,91),(142,91)), ch=((74,134),(146,134))),
 "baby":  dict(head=(58,70,104,82,36), body=(70,128,80,58,28), feet=(186,92,128,11,5.5), er=5.6, ey=104, ex=(83,137),
               muz=(78,108,64,38,13), ny=118, nx=(99,121), my=132, ears=((74,74),(146,74)), ch=((68,122),(152,122))),
 "kid":   dict(head=(56,62,108,86,36), body=(62,120,96,68,34), feet=(187,88,132,12,6), er=5.4, ey=97, ex=(81,139),
               muz=(76,101,68,41,14), ny=111, nx=(98,122), my=127, ears=((71,66),(149,66)), ch=((66,116),(154,116))),
 "young": dict(head=(55,56,110,88,37), body=(56,112,108,76,38), feet=(188,86,134,13,6), er=5.2, ey=90, ex=(80,140),
               muz=(74,94,72,44,14), ny=105, nx=(97,123), my=122, ears=((70,60),(150,60)), ch=((64,110),(156,110))),
 "teen":  dict(head=(54,50,112,90,37), body=(50,106,120,84,42), feet=(189,84,136,14,6.5), er=5, ey=84, ex=(79,141),
               muz=(72,89,76,47,15), ny=100, nx=(97,123), my=119, ears=((69,54),(151,54)), ch=((63,105),(157,105))),
 "adult": dict(head=(52,42,116,92,38), body=(42,98,136,92,46), feet=(190,80,140,16,7), er=4.8, ey=76, ex=(78,142),
               muz=(70,82,80,50,15), ny=94, nx=(96,124), my=114, ears=((68,46),(152,46)), ch=((61,100),(159,100))),
}
SVG_OPEN = '<svg viewBox="0 0 220 212" width="220" height="212" xmlns="http://www.w3.org/2000/svg" font-family="Arial, sans-serif">'

def pen_up(L, w=8):
    h = w/2
    return (f'<rect x="{-h}" y="{-L}" width="{w}" height="{L}" rx="2.5" fill="{RED}"/>'
            f'<rect x="{-h}" y="{-L+3}" width="{w}" height="3" fill="#fff" opacity=".85"/>'
            f'<path d="M{-h} {-L} L{h} {-L} L0 {-L-9} Z" fill="#8A8F98" stroke="#8A8F98" stroke-width="1.2" stroke-linejoin="round"/>')

def bean():
    s = [f'<circle cx="92" cy="140" r="6" fill="{BASE["FUR_D"]}"/><circle cx="128" cy="140" r="6" fill="{BASE["FUR_D"]}"/>',
         f'<ellipse cx="110" cy="164" rx="36" ry="29" fill="{BASE["FUR"]}"/>',
         f'<ellipse cx="96" cy="192" rx="8" ry="4" fill="{BASE["FUR_D"]}"/><ellipse cx="124" cy="192" rx="8" ry="4" fill="{BASE["FUR_D"]}"/>',
         f'<rect x="94" y="164" width="32" height="20" rx="8" fill="{BASE["MUZ"]}"/>',
         f'<circle cx="84" cy="172" r="5.5" fill="#F4978E" opacity=".5"/><circle cx="136" cy="172" r="5.5" fill="#F4978E" opacity=".5"/>',
         f'<ellipse cx="104" cy="170" rx="2.4" ry="1.8" fill="{BASE["FUR_D"]}"/><ellipse cx="116" cy="170" rx="2.4" ry="1.8" fill="{BASE["FUR_D"]}"/>',
         f'<path d="M106 177 Q110 180 114 177" fill="none" stroke="{BASE["FUR_D"]}" stroke-width="2" stroke-linecap="round"/>']
    for ex in (93, 127):
        s.append(f'<path d="M{ex-5} 158 Q{ex} 163 {ex+5} 158" fill="none" stroke="{INK}" stroke-width="2.6" stroke-linecap="round"/>')
    return SVG_OPEN + "".join(s) + '</svg>'

def capy(stage, mood="neutral", opts=(), pal=None):
    P = dict(BASE); P.update(pal or {})
    FUR, FUR_B, FUR_D, MUZ = P["FUR"], P["FUR_B"], P["FUR_D"], P["MUZ"]
    d = D[stage]; hx, hy, hw, hh, hr = d["head"]; bx, by, bw, bh, br = d["body"]
    mx, my0, mw, mh, mr = d["muz"]; mb = my0 + mh
    fy, f1, f2, frx, fry = d["feet"]; top, cx = hy, 110
    (e1x, e1y), (e2x, e2y) = d["ears"]; ex1, ex2 = d["ex"]; ey, r = d["ey"], d["er"]
    rx_, ry_ = bx + bw - 2, by + bh * 0.55
    lx = bx + 2
    s = []
    if "cloud" in opts:
        s.append('<g fill="#E4ECF7"><circle cx="68" cy="198" r="13"/><circle cx="93" cy="193" r="17"/><circle cx="127" cy="193" r="17"/><circle cx="152" cy="198" r="13"/><rect x="60" y="196" width="100" height="14" rx="7"/></g>')
    for ex, ey_ in d["ears"]:
        s.append(f'<ellipse cx="{ex}" cy="{ey_}" rx="8" ry="6.5" fill="{FUR_D}"/>')
    if "pen_ear" in opts:
        s.append(f'<g transform="translate({e2x+8},{e2y+10}) rotate(32)">{pen_up(36)}</g>')
    s.append(f'<rect x="{bx}" y="{by}" width="{bw}" height="{bh}" rx="{br}" fill="{"#C62B35" if "robe" in opts else FUR_B}"/>')
    if "robe" in opts:
        s.append(f'<circle cx="{cx}" cy="{by+bh*0.66:.0f}" r="15" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="2"/>'
                 f'<circle cx="{cx}" cy="{by+bh*0.66:.0f}" r="8" fill="none" stroke="{GOLD_D}" stroke-width="2"/>')
    if "straps" in opts:
        for sx in (bx + 20, bx + bw - 29):
            s.append(f'<rect x="{sx}" y="{by+4}" width="9" height="{bh*0.62:.0f}" rx="4.5" fill="{RED}"/>')
    for fx in (f1, f2): s.append(f'<ellipse cx="{fx}" cy="{fy}" rx="{frx}" ry="{fry}" fill="{FUR_D}"/>')
    if "brush" in opts:
        s.append(f'<g transform="translate({rx_},{ry_+2}) rotate(12)"><rect x="-3" y="-54" width="6" height="54" rx="2" fill="{WOOD}"/><path d="M-5.5 -54 Q0 -80 5.5 -54 Z" fill="{RED}"/></g>')
        s.append(f'<ellipse cx="{rx_-4}" cy="{ry_-7}" rx="11" ry="9" fill="{FUR}"/>')
    if "pen_hand" in opts:
        s.append(f'<g transform="translate({rx_},{ry_+2}) rotate(12)">{pen_up(52, 9)}</g>')
        s.append(f'<ellipse cx="{rx_-4}" cy="{ry_-7}" rx="11" ry="9" fill="{FUR}"/>')
    if "orb" in opts:
        s.append(f'<circle cx="{rx_+2}" cy="{ry_-16}" r="18" fill="#FFD166" opacity=".45"/><circle cx="{rx_+2}" cy="{ry_-16}" r="12" fill="{RED}"/>'
                 f'<circle cx="{rx_-2}" cy="{ry_-20}" r="3.5" fill="#fff" opacity=".6"/><ellipse cx="{rx_-5}" cy="{ry_-1}" rx="11" ry="8" fill="{FUR}"/>')
    if "staff" in opts:
        s.append(f'<rect x="{lx-3}" y="{top+22}" width="6" height="{fy-top-20}" rx="3" fill="{WOOD}"/><circle cx="{lx}" cy="{top+20}" r="7.5" fill="{WOOD}"/>')
        s.append(f'<ellipse cx="{lx+5}" cy="{by+bh*0.48:.0f}" rx="11" ry="9" fill="{FUR}"/>')
    s.append(f'<rect x="{hx}" y="{hy}" width="{hw}" height="{hh}" rx="{hr}" fill="{FUR}"/>')
    s.append(f'<rect x="{mx}" y="{my0}" width="{mw}" height="{mh}" rx="{mr}" fill="{MUZ}"/>')
    for cx_, cy_ in d["ch"]: s.append(f'<circle cx="{cx_}" cy="{cy_}" r="7" fill="#F4978E" opacity=".5"/>')
    for nx in d["nx"]: s.append(f'<ellipse cx="{nx}" cy="{d["ny"]}" rx="3.4" ry="2.4" fill="{FUR_D}"/>')
    st = f'fill="none" stroke="{INK}" stroke-width="3" stroke-linecap="round"'
    for ex in (ex1, ex2):
        if mood == "happy": s.append(f'<path d="M{ex-6} {ey+2} Q{ex} {ey-7} {ex+6} {ey+2}" {st}/>')
        elif mood == "sleepy": s.append(f'<path d="M{ex-6} {ey} Q{ex} {ey+6} {ex+6} {ey}" {st}/>')
        else: s.append(f'<circle cx="{ex}" cy="{ey}" r="{r}" fill="{INK}"/><circle cx="{ex-1.5}" cy="{ey-1.6}" r="1.6" fill="#fff"/>')
    my = d["my"]
    if mood == "happy": s.append(f'<path d="M103 {my-2} Q110 {my+9} 117 {my-2} Z" fill="{FUR_D}" stroke="{FUR_D}" stroke-width="2" stroke-linejoin="round"/>')
    else: s.append(f'<path d="M104 {my} Q110 {my+5} 116 {my}" fill="none" stroke="{FUR_D}" stroke-width="2.5" stroke-linecap="round"/>')
    if mood == "sleepy": s.append('<text x="176" y="40" font-size="20" font-weight="700" fill="#9AA0A6">z</text><text x="190" y="24" font-size="14" font-weight="700" fill="#9AA0A6">z</text>')
    if "beard" in opts:
        s.append(f'<path d="M{mx+8} {mb-6} C{mx+2} {mb+24} {cx-10} {mb+38} {cx} {mb+50} C{cx+10} {mb+38} {mx+mw-2} {mb+24} {mx+mw-8} {mb-6} Q{cx} {mb+7} {mx+8} {mb-6} Z" fill="#F7F7F7" stroke="#D5D5DB" stroke-width="1.5" stroke-linejoin="round"/>')
    if "brows" in opts:
        s.append(f'<path d="M{ex1-12} {ey-8} L{ex1+5} {ey-14}" stroke="#F7F7F7" stroke-width="5.5" stroke-linecap="round"/><path d="M{ex2+12} {ey-8} L{ex2-5} {ey-14}" stroke="#F7F7F7" stroke-width="5.5" stroke-linecap="round"/>')
    if "glasses" in opts:
        for ex in (ex1, ex2): s.append(f'<circle cx="{ex}" cy="{ey}" r="11.5" fill="#fff" fill-opacity=".2" stroke="{INK}" stroke-width="2.6"/>')
        s.append(f'<path d="M{ex1+11.5} {ey-2} Q{cx} {ey-9} {ex2-11.5} {ey-2}" fill="none" stroke="{INK}" stroke-width="2.6"/>')
    if "whiskers" in opts:
        s.append(f'<path d="M{mx+3} {my0+20} C{mx-22} {my0+18} {mx-32} {my0} {mx-27} {my0-16}" fill="none" stroke="{GOLD}" stroke-width="3.4" stroke-linecap="round"/>'
                 f'<path d="M{mx+mw-3} {my0+20} C{mx+mw+22} {my0+18} {mx+mw+32} {my0} {mx+mw+27} {my0-16}" fill="none" stroke="{GOLD}" stroke-width="3.4" stroke-linecap="round"/>')
    if "sprout" in opts:
        s.append(f'<path d="M{cx} {top+2} L{cx} {top-12}" stroke="#4C9A4C" stroke-width="3" stroke-linecap="round"/>'
                 f'<ellipse cx="{cx-7}" cy="{top-15}" rx="8" ry="4" fill="#5BAA5B" transform="rotate(28 {cx-7} {top-15})"/>'
                 f'<ellipse cx="{cx+7}" cy="{top-15}" rx="8" ry="4" fill="#6BBF6B" transform="rotate(-28 {cx+7} {top-15})"/>')
    if "hat" in opts:
        rh = hw/2 - 5
        s.append(f'<path d="M{cx-rh} {top+15} Q{cx-rh} {top-22} {cx} {top-24} Q{cx+rh} {top-22} {cx+rh} {top+15} Z" fill="#F7C948"/>'
                 f'<rect x="{cx-rh-7}" y="{top+10}" width="{2*rh+14}" height="9" rx="4.5" fill="#EBA91A"/><circle cx="{cx}" cy="{top-24}" r="4.5" fill="#EBA91A"/>')
    if "fruit" in opts:
        s.append(f'<circle cx="{cx}" cy="{top-8}" r="12" fill="#F59E2E"/><circle cx="{cx-4}" cy="{top-12}" r="3" fill="#fff" opacity=".35"/>'
                 f'<ellipse cx="{cx+6}" cy="{top-20}" rx="6" ry="3" fill="#5BAA5B" transform="rotate(-25 {cx+6} {top-20})"/>')
    if "topknot" in opts:
        s.append(f'<circle cx="{cx}" cy="{top-7}" r="10" fill="{FUR_D}"/><rect x="{cx-9}" y="{top-1}" width="18" height="5" rx="2.5" fill="{RED}"/>')
    if "gat" in opts:
        s.append(f'<path d="M{cx-23} {top+4} L{cx-19} {top-30} Q{cx} {top-37} {cx+19} {top-30} L{cx+23} {top+4} Z" fill="{INK}" stroke="#77777D" stroke-width="1.5" stroke-linejoin="round"/>'
                 f'<ellipse cx="{cx}" cy="{top+5}" rx="80" ry="11" fill="{INK}" stroke="#77777D" stroke-width="1.5"/>')
    if "crown" in opts:
        g = f'fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1.3"'
        for dx in (-24, 0, 24):
            h = 30 if dx == 0 else 21
            s.append(f'<rect x="{cx+dx-4}" y="{top-6-h}" width="8" height="{h+4}" rx="3" {g}/><rect x="{cx+dx-10}" y="{top-6-h*0.58:.0f}" width="20" height="5" rx="2.5" {g}/><circle cx="{cx+dx}" cy="{top-6-h}" r="5" {g}/>')
        s.append(f'<rect x="{cx-37}" y="{top-7}" width="74" height="15" rx="4" {g}/>')
        for dx in (-22, 0, 22): s.append(f'<circle cx="{cx+dx}" cy="{top+0.5}" r="3.2" fill="#3BB273"/>')
    if "horns" in opts:
        for sg in (-1, 1):
            s.append(f'<path d="M{cx+sg*27} {top+6} L{cx+sg*37} {top-22} M{cx+sg*32} {top-8} L{cx+sg*20} {top-20}" fill="none" stroke="{GOLD}" stroke-width="6" stroke-linecap="round"/>')
    if "tub" in opts:
        s.append(f'<rect x="{cx-18}" y="{top-9}" width="36" height="13" rx="5" fill="#fff" stroke="#D5D5DB" stroke-width="1.5"/>')
        s.append('<rect x="28" y="142" width="164" height="62" rx="14" fill="#96613D"/><rect x="28" y="162" width="164" height="5" fill="#7A4C2E"/><rect x="28" y="184" width="164" height="5" fill="#7A4C2E"/>'
                 '<rect x="22" y="134" width="176" height="15" rx="7.5" fill="#B67C4F"/><ellipse cx="110" cy="141" rx="76" ry="5.5" fill="#A8DADC"/>')
        for sx in (34, 186):
            s.append(f'<path d="M{sx} 124 q-6 -8 0 -16 q6 -8 0 -16" fill="none" stroke="#B8BCC4" stroke-width="3" stroke-linecap="round" opacity=".85"/>')
    return SVG_OPEN + "".join(s) + '</svg>'

forms = [
 (bean(), "1 · Bean", "start"),
 (capy("tiny", opts=("sprout",)), "2 · Sprout", "5 pts"),
 (capy("baby"), "3 · Baby", "15 pts"),
 (capy("kid", "happy", ("hat",)), "4 · Kinder", "40 pts"),
 (capy("young"), "5 · Young", "80 pts"),
 (capy("teen", "happy", ("straps", "pen_ear")), "6 · Student", "150 pts"),
 (capy("adult", opts=("pen_ear", "fruit")), "7 · Adult", "250 pts"),
 (capy("adult", "happy", ("glasses", "pen_hand")), "8 · Teacher", "400 pts"),
 (capy("adult", "happy", ("gat", "brush")), "9 · Scholar", "600 pts"),
 (capy("adult", opts=("topknot", "beard", "brows", "staff")), "10 · Sage", "900 pts"),
 (capy("adult", "happy", ("robe", "crown")), "11 · King", "1,300 pts"),
 (capy("adult", "happy", ("cloud", "horns", "whiskers", "orb"), JADE), "12 · Dragon", "1,800 pts"),
]
states = [
 (capy("adult", "happy", ("tub",)), "Hot spring", "streak freeze is on"),
 (capy("adult", "sleepy"), "Sleepy", "missed a few days"),
 (capy("adult", "happy", ("pen_ear", "fruit")), "Streak fruit", "streak is alive"),
]
dark = [forms[0], forms[8], forms[10], forms[11]]

def cells(items): return "".join(f'<div class="cell">{svg}<div class="t">{t}</div><div class="d">{d}</div></div>' for svg, t, d in items)

html = f'''<!doctype html><meta charset="utf-8"><style>
body{{margin:0;font-family:Arial,Helvetica,sans-serif;background:#fff}}
h1{{font-size:20px;margin:0;padding:22px 32px 4px;color:#1c1c1e}} .sub{{padding:0 32px 14px;color:#6b7280;font-size:14px}}
h2{{font-size:14px;margin:0;padding:18px 32px 0;color:#6b7280;background:#F6F5F2;text-transform:uppercase;letter-spacing:.06em}}
h2.dk{{background:#1C1C1E;color:#9aa0a6}}
.grid{{display:flex;flex-wrap:wrap;gap:8px;row-gap:22px;padding:18px 24px 26px;background:#F6F5F2}} .grid.dark{{background:#1C1C1E}}
.cell{{width:220px;text-align:center}} .t{{font-weight:700;font-size:15px;color:#1c1c1e;margin-top:6px}} .d{{font-size:13px;color:#6b7280;margin-top:2px}}
.dark .t{{color:#f2f2f7}} .dark .d{{color:#9aa0a6}}
</style><div id="sheet" style="width:960px">
<h1>Gochi evolution line, concept v2 (drawn in code)</h1><div class="sub">12 growth forms, 3 special states, and a dark mode check. Points are placeholders.</div>
<h2>Growth forms</h2><div class="grid">{cells(forms)}</div>
<h2>Special states</h2><div class="grid">{cells(states)}</div>
<h2 class="dk">Dark mode check</h2><div class="grid dark">{cells(dark)}</div></div>'''
open("forms.html", "w").write(html)

async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await b.new_page(viewport={"width": 960, "height": 900}, device_scale_factor=2)
        await pg.goto("file://" + os.path.abspath("forms.html"))
        await (await pg.query_selector("#sheet")).screenshot(path="/home/claude/gochi-forms.png")
        await b.close()
asyncio.run(main())
