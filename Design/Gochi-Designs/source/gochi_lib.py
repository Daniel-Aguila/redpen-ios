import asyncio, os, itertools, math
from playwright.async_api import async_playwright

RED, GOLD, GOLD_D, WOOD, INK, W = "#E63946", "#F2C14E", "#D9A21B", "#7E5236", "#2B2B2B", "#FAFAFA"
BLK, NAVY, GRN, BLU, CRM = "#1E1E24", "#27365E", "#2E8B57", "#2A6FDB", "#F3E9D2"
FUR, FUR_B, FUR_D, MUZ = "#C08D62", "#B07C54", "#7E5236", "#E6BE94"
OL = 'stroke="#77777D" stroke-width="1.5" stroke-linejoin="round"'
WL = 'stroke="#CFCFD6" stroke-width="1.5" stroke-linejoin="round"'
WS, DS = "#CFCFD6", "#55555C"   # body strokes for white / black outfits
_ids = itertools.count()

D = {
 "tiny":  dict(head=(66,88,88,70,31), body=(80,138,60,46,22), feet=(184,98,122,9,4.5), er=5.2, ey=118, ex=(88,132), muz=(83,121,54,32,11), ny=130, nx=(101,119), my=142, ears=((78,91),(142,91)), ch=((74,134),(146,134))),
 "baby":  dict(head=(58,70,104,82,36), body=(70,128,80,58,28), feet=(186,92,128,11,5.5), er=5.6, ey=104, ex=(83,137), muz=(78,108,64,38,13), ny=118, nx=(99,121), my=132, ears=((74,74),(146,74)), ch=((68,122),(152,122))),
 "kid":   dict(head=(56,62,108,86,36), body=(62,120,96,68,34), feet=(187,88,132,12,6), er=5.4, ey=97, ex=(81,139), muz=(76,101,68,41,14), ny=111, nx=(98,122), my=127, ears=((71,66),(149,66)), ch=((66,116),(154,116))),
 "young": dict(head=(55,56,110,88,37), body=(56,112,108,76,38), feet=(188,86,134,13,6), er=5.2, ey=90, ex=(80,140), muz=(74,94,72,44,14), ny=105, nx=(97,123), my=122, ears=((70,60),(150,60)), ch=((64,110),(156,110))),
 "teen":  dict(head=(54,50,112,90,37), body=(50,106,120,84,42), feet=(189,84,136,14,6.5), er=5, ey=84, ex=(79,141), muz=(72,89,76,47,15), ny=100, nx=(97,123), my=119, ears=((69,54),(151,54)), ch=((63,105),(157,105))),
 "adult": dict(head=(52,42,116,92,38), body=(42,98,136,92,46), feet=(190,80,140,16,7), er=4.8, ey=76, ex=(78,142), muz=(70,82,80,50,15), ny=94, nx=(96,124), my=114, ears=((68,46),(152,46)), ch=((61,100),(159,100))),
}

def fig(o, stage="adult", width=220):
    g = lambda k, dflt="": o.get(k, dflt)
    d = D[stage]; hx, hy, hw, hh, hr = d["head"]; bx, by, bw, bh, br = d["body"]; mx, my0, mw, mh, mr = d["muz"]
    fy, f1, f2, frx, fry = d["feet"]; ey, r = d["ey"], d["er"]; n = next(_ids); mood = g("mood", "neutral")
    Tb = f'translate({bx},{by}) scale({bw/136:.4f},{bh/92:.4f}) translate(-42,-98)'
    Th = f'translate({hx},{hy}) scale({hw/116:.4f},{hh/92:.4f}) translate(-52,-42)'
    s = [f'<defs><clipPath id="w{n}"><rect x="{bx}" y="{by}" width="{bw}" height="{bh}" rx="{br}"/></clipPath></defs>', f'<g transform="{Tb}">{g("back")}</g>']
    for ex, ey_ in d["ears"]: s.append(f'<ellipse cx="{ex}" cy="{ey_}" rx="8" ry="6.5" fill="{FUR_D}"/>')
    s.append(f'<g transform="{Th}">{g("hood")}</g>')
    bs = f' stroke="{g("body_stroke")}" stroke-width="1.5"' if g("body_stroke") else ""
    s.append(f'<rect x="{bx}" y="{by}" width="{bw}" height="{bh}" rx="{br}" fill="{g("body_fill") or FUR_B}"{bs}/>')
    s.append(f'<g clip-path="url(#w{n})"><g transform="{Tb}">{g("cloth")}</g></g><g transform="{Tb}">{g("raw")}</g>')
    if g("feet", True):
        fs = f' stroke="{g("feet_stroke")}" stroke-width="1.5"' if g("feet_stroke") else ""
        for fx in (f1, f2): s.append(f'<ellipse cx="{fx}" cy="{fy}" rx="{frx}" ry="{fry}" fill="{g("feet_fill") or FUR_D}"{fs}/>')
    s.append(f'<g transform="{Tb}">{g("hand")}</g>')
    s.append(f'<rect x="{hx}" y="{hy}" width="{hw}" height="{hh}" rx="{hr}" fill="{FUR}"/><rect x="{mx}" y="{my0}" width="{mw}" height="{mh}" rx="{mr}" fill="{MUZ}"/>')
    if g("cheeks", True):
        for cx_, cy_ in d["ch"]: s.append(f'<circle cx="{cx_}" cy="{cy_}" r="7" fill="#F4978E" opacity=".5"/>')
    for nx in d["nx"]: s.append(f'<ellipse cx="{nx}" cy="{d["ny"]}" rx="3.4" ry="2.4" fill="{FUR_D}"/>')
    st = f'fill="none" stroke="{INK}" stroke-width="3" stroke-linecap="round"'
    for ex in d["ex"]:
        if mood == "happy": s.append(f'<path d="M{ex-6} {ey+2} Q{ex} {ey-7} {ex+6} {ey+2}" {st}/>')
        elif mood == "sleepy": s.append(f'<path d="M{ex-6} {ey} Q{ex} {ey+6} {ex+6} {ey}" {st}/>')
        else: s.append(f'<circle cx="{ex}" cy="{ey}" r="{r}" fill="{INK}"/><circle cx="{ex-1.5}" cy="{ey-1.6}" r="1.6" fill="#fff"/>')
    my = d["my"]
    if mood == "happy": s.append(f'<path d="M103 {my-2} Q110 {my+9} 117 {my-2} Z" fill="{FUR_D}" stroke="{FUR_D}" stroke-width="2" stroke-linejoin="round"/>')
    else: s.append(f'<path d="M104 {my} Q110 {my+5} 116 {my}" fill="none" stroke="{FUR_D}" stroke-width="2.5" stroke-linecap="round"/>')
    s.append(f'<g transform="{Th}">{g("face")}{g("top")}</g>')
    return f'<svg viewBox="0 0 220 212" width="{width}" height="{width*212/220:.0f}" xmlns="http://www.w3.org/2000/svg">' + "".join(s) + '</svg>'

# ---------- helpers (adult coordinates) ----------
def vcollar(c, w=6): return f'<path d="M89 131 L110 156 L131 131" fill="none" stroke="{c}" stroke-width="{w}" stroke-linejoin="round" stroke-linecap="round"/>'
def shirtv(c="#fff"): return f'<path d="M92 132 L110 160 L128 132 Z" fill="{c}"/>'
def paw(x, y): return f'<ellipse cx="{x}" cy="{y}" rx="11" ry="9" fill="{FUR}"/>'
def band(y, h, c): return f'<rect x="42" y="{y}" width="136" height="{h}" fill="{c}"/>'
def skirt(fill, fold): return f'<path d="M58 152 Q110 144 162 152 L190 200 Q110 210 30 200 Z" fill="{fill}"/><path d="M84 156 L70 203 M110 154 L110 206 M136 156 L150 203" stroke="{fold}" stroke-width="2.5" stroke-linecap="round"/>'
def star(x, y, s=1, fill=GOLD): return f'<path transform="translate({x},{y}) scale({s})" d="M0 -9 L2.5 -2.5 L9 0 L2.5 2.5 L0 9 L-2.5 2.5 L-9 0 L-2.5 -2.5 Z" fill="{fill}"/>'
def hoodcap(c, extra=""): return f'<path d="M58 62 Q60 40 110 40 Q160 40 162 62 Q110 46 58 62 Z" fill="{c}" {extra}/>'
def hoodback(c, extra=""): return f'<rect x="45" y="33" width="130" height="108" rx="46" fill="{c}" {extra}/>'
def dots(pts, r, c): return "".join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c}"/>' for x, y in pts)
def flower(x, y, r, c, cc=GOLD): return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c}"/><circle cx="{x}" cy="{y}" r="{r*0.38:.1f}" fill="{cc}"/>'
def apron(c): return f'<path d="M84 132 L136 132 L144 192 L76 192 Z" fill="{c}"/>'
def kerchief(c): return f'<path d="M92 133 Q110 147 128 133 L126 142 Q110 156 94 142 Z" fill="{c}"/><path d="M110 150 L104 164 L116 162 Z" fill="{c}"/>'
def hstripes(c, y0=138, step=10, h=5): return "".join(band(y, h, c) for y in range(y0, 192, step))
def ball(x=186, y=150): return f'<circle cx="{x}" cy="{y}" r="15" fill="#fff" stroke="{INK}" stroke-width="1.5"/><path d="M{x} {y-8} l7 5 -3 8 h-8 l-3 -8 z" fill="{INK}"/>'
def fan(fill, rib): return f'<path d="M182 158 L162 122 A42 42 0 0 1 204 126 Z" fill="{fill}" stroke="{rib}" stroke-width="1.5" stroke-linejoin="round"/><path d="M182 158 L172 120 M182 158 L183 116 M182 158 L194 119" stroke="{rib}" stroke-width="1.5"/>'
def sleeves(c): return f'<rect x="42" y="98" width="20" height="62" fill="{c}"/><rect x="158" y="98" width="20" height="62" fill="{c}"/>'
PONCHO = 'M62 128 Q110 118 158 128 L176 176 L110 196 L44 176 Z'
def crownarc(cols, r=8):   # flowers along the top of the head
    pts = ((70, 50), (84, 40), (98, 34), (110, 32), (122, 34), (136, 40), (150, 50))
    return "".join(flower(x, y, r, cols[i % len(cols)], "#fff") for i, (x, y) in enumerate(pts))
HEADSET = f'<path d="M166 84 Q160 117 133 117" fill="none" stroke="{INK}" stroke-width="2.6" stroke-linecap="round"/><circle cx="131" cy="117" r="4.5" fill="{INK}"/>'
BRUSH = f'<g transform="translate(176,150) rotate(12)"><rect x="-3" y="-54" width="6" height="54" rx="2" fill="{WOOD}"/><path d="M-5.5 -54 Q0 -80 5.5 -54 Z" fill="{RED}"/></g>' + paw(172, 143)
def cap(c, brim): return f'<path d="M64 56 Q64 20 110 20 Q156 20 156 56 Z" fill="{c}"/><path d="M58 57 Q110 43 162 57 Q110 68 58 57 Z" fill="{brim}"/>'
def brimhat(c, s, rx=56): return f'<path d="M80 46 Q82 14 110 14 Q138 14 140 46 Z" fill="{c}" stroke="{s}" stroke-width="1.5"/><ellipse cx="110" cy="47" rx="{rx}" ry="9" fill="{c}" stroke="{s}" stroke-width="1.5"/>'
CALAVERA = ("".join(f'<circle cx="{x}" cy="76" r="10.5" fill="none" stroke="{BLK}" stroke-width="5"/>' + "".join(
              f'<circle cx="{x+17*math.cos(math.radians(a)):.1f}" cy="{76+17*math.sin(math.radians(a)):.1f}" r="2.4" fill="{"#E0457B" if i % 2 else "#4FA3D9"}"/>' for i, a in enumerate(range(0, 360, 45))) for x in (78, 142))
            + f'<path d="M110 91 l-5 -6 a3.5 3.5 0 0 1 5 -4 a3.5 3.5 0 0 1 5 4 z" fill="{BLK}"/><path d="M88 122 Q110 130 132 122 M96 121 l0 6 M110 124 l0 6 M124 121 l0 6" fill="none" stroke="{BLK}" stroke-width="2" stroke-linecap="round"/>'
            + flower(110, 57, 5.5, "#E0457B"))
MASK = ('M90 42 H130 A38 38 0 0 1 168 80 V96 A38 38 0 0 1 130 134 H90 A38 38 0 0 1 52 96 V80 A38 38 0 0 1 90 42 Z '
        'M66 75 a12 6.5 0 1 0 24 0 a12 6.5 0 1 0 -24 0 Z M130 75 a12 6.5 0 1 0 24 0 a12 6.5 0 1 0 -24 0 Z '
        'M85 82 H135 A15 15 0 0 1 150 97 V117 A15 15 0 0 1 135 132 H85 A15 15 0 0 1 70 117 V97 A15 15 0 0 1 85 82 Z')
SOMBRERO = (f'<path d="M80 44 Q82 6 110 6 Q138 6 140 44 Z" fill="{BLK}" {OL}/><ellipse cx="110" cy="46" rx="94" ry="15" fill="{BLK}" {OL}/>'
            '<ellipse cx="110" cy="46" rx="80" ry="10" fill="none" stroke="#D9DCE3" stroke-width="2.5" stroke-dasharray="3 5"/><path d="M83 33 Q110 41 137 33" fill="none" stroke="#D9DCE3" stroke-width="4"/>')
FOLK_SKIRT = ('<path d="M56 150 Q110 142 164 150 L204 198 Q110 212 16 198 Z" fill="#E0457B"/><path d="M37 176 Q110 190 183 176" fill="none" stroke="#4FA3D9" stroke-width="4"/>'
              '<path d="M31 184 Q110 198 189 184" fill="none" stroke="#F6C445" stroke-width="5"/><path d="M25 191 Q110 205 195 191" fill="none" stroke="#3BB273" stroke-width="5"/><path d="M16 198 Q110 212 204 198" fill="none" stroke="#fff" stroke-width="4"/>')


CSS = '''body{margin:0;font-family:Arial,Helvetica,sans-serif;background:#fff}
h1{font-size:20px;margin:0;padding:22px 32px 4px;color:#1c1c1e} .sub{padding:0 32px 14px;color:#6b7280;font-size:14px}
h2{font-size:14px;margin:0;padding:18px 32px 0;color:#6b7280;background:#F6F5F2;text-transform:uppercase;letter-spacing:.06em} h2.dk{background:#1C1C1E;color:#9aa0a6}
.grid{display:flex;flex-wrap:wrap;gap:8px;padding:14px 24px 22px;background:#F6F5F2} .grid.dark{background:#1C1C1E} .grid.six{gap:2px;padding-bottom:8px}
.cell{width:220px;text-align:center} .cell.s{width:150px} .t{font-weight:700;font-size:15px;color:#1c1c1e;margin-top:6px} .d{font-size:13px;color:#6b7280;margin-top:2px}
.dark .t{color:#f2f2f7} .dark .d{color:#9aa0a6}'''

STAGES = [("tiny", "Sprout"), ("baby", "Baby"), ("kid", "Kinder"), ("young", "Young"), ("teen", "Student"), ("adult", "Adult")]
def cells(src, lab, keys): return "".join(f'<div class="cell">{fig(src[k])}<div class="t">{lab[k][0]}</div><div class="d">{lab[k][1]}</div></div>' for k in keys)
def sec(src, lab, title, keys, dark=False): return f'<h2 class="{"dk" if dark else ""}">{title}</h2><div class="grid {"dark" if dark else ""}">{cells(src, lab, keys)}</div>'
def strip(o): return '<div class="grid six">' + "".join(f'<div class="cell s">{fig(o, s, 150)}<div class="t">{n}</div></div>' for s, n in STAGES) + '</div>'
def page(title, sub, parts): return f'<!doctype html><meta charset="utf-8"><style>{CSS}</style><div id="sheet" style="width:960px">' + "".join(f'<div id="p{i+1}">' + (f'<h1>{title}</h1><div class="sub">{sub}</div>' if i == 0 else "") + p + '</div>' for i, p in enumerate(parts)) + '</div>'
async def render(jobs):
    async with async_playwright() as p:
        b = await p.chromium.launch()
        for name, html, parts in jobs:
            open(name + ".html", "w").write(html)
            pg = await b.new_page(viewport={"width": 960, "height": 900}, device_scale_factor=2)
            await pg.goto("file://" + os.path.abspath(name + ".html"))
            await (await pg.query_selector("#sheet")).screenshot(path=f"/home/claude/gochi-{name}.png")
            await pg.close()
            pg = await b.new_page(viewport={"width": 960, "height": 900}, device_scale_factor=1)
            await pg.goto("file://" + os.path.abspath(name + ".html"))
            for i in range(1, parts + 1): await (await pg.query_selector(f"#p{i}")).screenshot(path=f"{name}{i}.png")
            await pg.close()
        await b.close()
