import asyncio, os, itertools
from playwright.async_api import async_playwright

RED, GOLD, GOLD_D, WOOD, INK = "#E63946", "#F2C14E", "#D9A21B", "#7E5236", "#2B2B2B"
BASE = dict(FUR="#C08D62", FUR_B="#B07C54", FUR_D="#7E5236", MUZ="#E6BE94")
OL = 'stroke="#77777D" stroke-width="1.5" stroke-linejoin="round"'
WL = 'stroke="#CFCFD6" stroke-width="1.5" stroke-linejoin="round"'
SAEK = ["#E63946", "#F6C445", "#2E8B57", "#3D5A98", "#FFFFFF", "#E0457B", "#F28C28"]
_ids = itertools.count()

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

def fig(stage="adult", mood="neutral", body_fill=None, body_stroke=None, cloth="", raw="", feet=True, feet_fill=None, feet_stroke=None,
        hand="", face="", top="", hood="", back="", cheeks=True, width=220):
    FUR, FUR_B, FUR_D, MUZ = BASE["FUR"], BASE["FUR_B"], BASE["FUR_D"], BASE["MUZ"]
    d = D[stage]; hx, hy, hw, hh, hr = d["head"]; bx, by, bw, bh, br = d["body"]; mx, my0, mw, mh, mr = d["muz"]
    fy, f1, f2, frx, fry = d["feet"]; ey, r = d["ey"], d["er"]; n = next(_ids)
    s = [f'<defs><clipPath id="c{n}"><rect x="{bx}" y="{by}" width="{bw}" height="{bh}" rx="{br}"/></clipPath></defs>', back]
    for ex, ey_ in d["ears"]: s.append(f'<ellipse cx="{ex}" cy="{ey_}" rx="8" ry="6.5" fill="{FUR_D}"/>')
    s.append(hood)
    bs = f' stroke="{body_stroke}" stroke-width="1.5"' if body_stroke else ""
    s.append(f'<rect x="{bx}" y="{by}" width="{bw}" height="{bh}" rx="{br}" fill="{body_fill or FUR_B}"{bs}/>')
    s.append(f'<g clip-path="url(#c{n})">{cloth}</g>{raw}')
    if feet:
        fs = f' stroke="{feet_stroke}" stroke-width="1.5"' if feet_stroke else ""
        for fx in (f1, f2): s.append(f'<ellipse cx="{fx}" cy="{fy}" rx="{frx}" ry="{fry}" fill="{feet_fill or FUR_D}"{fs}/>')
    s.append(hand)
    s.append(f'<rect x="{hx}" y="{hy}" width="{hw}" height="{hh}" rx="{hr}" fill="{FUR}"/><rect x="{mx}" y="{my0}" width="{mw}" height="{mh}" rx="{mr}" fill="{MUZ}"/>')
    if cheeks:
        for cx_, cy_ in d["ch"]: s.append(f'<circle cx="{cx_}" cy="{cy_}" r="7" fill="#F4978E" opacity=".5"/>')
    for nx in d["nx"]: s.append(f'<ellipse cx="{nx}" cy="{d["ny"]}" rx="3.4" ry="2.4" fill="{FUR_D}"/>')
    st = f'fill="none" stroke="{INK}" stroke-width="3" stroke-linecap="round"'
    for ex in d["ex"]:
        if mood == "happy": s.append(f'<path d="M{ex-6} {ey+2} Q{ex} {ey-7} {ex+6} {ey+2}" {st}/>')
        else: s.append(f'<circle cx="{ex}" cy="{ey}" r="{r}" fill="{INK}"/><circle cx="{ex-1.5}" cy="{ey-1.6}" r="1.6" fill="#fff"/>')
    my = d["my"]
    if mood == "happy": s.append(f'<path d="M103 {my-2} Q110 {my+9} 117 {my-2} Z" fill="{FUR_D}" stroke="{FUR_D}" stroke-width="2" stroke-linejoin="round"/>')
    else: s.append(f'<path d="M104 {my} Q110 {my+5} 116 {my}" fill="none" stroke="{FUR_D}" stroke-width="2.5" stroke-linecap="round"/>')
    s += [face, top]
    return f'<svg viewBox="0 0 220 212" width="{width}" height="{width*212/220:.0f}" xmlns="http://www.w3.org/2000/svg" font-family="Arial, sans-serif">' + "".join(s) + '</svg>'

# ---------- helpers (adult absolute coordinates) ----------
def vcollar(color, w=6): return f'<path d="M89 131 L110 156 L131 131" fill="none" stroke="{color}" stroke-width="{w}" stroke-linejoin="round" stroke-linecap="round"/>'
def paw(x, y): return f'<ellipse cx="{x}" cy="{y}" rx="11" ry="9" fill="{BASE["FUR"]}"/>'
def skirt(fill, fold, band=True):
    return (f'<path d="M58 152 Q110 144 162 152 L190 200 Q110 210 30 200 Z" fill="{fill}"/><path d="M84 156 L70 203 M110 154 L110 206 M136 156 L150 203" stroke="{fold}" stroke-width="2.5" stroke-linecap="round"/>'
            + ('<path d="M58 152 Q110 144 162 152" fill="none" stroke="#fff" stroke-width="4"/>' if band else ""))
def goreum(c, x=118, y=148, w=6.5): return f'<path d="M{x} {y} L{x-8} {y+38} M{x} {y} L{x+10} {y+36}" stroke="{c}" stroke-width="{w}" stroke-linecap="round"/><circle cx="{x}" cy="{y}" r="{w*0.75:.1f}" fill="{c}"/>'
def goreum_m(c): return f'<path d="M116 150 L109 180 M116 150 L125 178" stroke="{c}" stroke-width="6" stroke-linecap="round"/><circle cx="116" cy="150" r="4.5" fill="{c}"/>'
def baji(c, line): return f'<rect x="42" y="168" width="136" height="24" fill="{c}"/><path d="M110 172 L110 192" stroke="{line}" stroke-width="2"/>'
def saek(xl, xr, w, y0, h, n): return "".join(f'<rect x="{x}" y="{y0+i*h}" width="{w}" height="{h}" fill="{SAEK[i % len(SAEK)]}"/>' for i in range(n) for x in (xl, xr))
def star(x, y, s=1, fill=GOLD): return f'<path transform="translate({x},{y}) scale({s})" d="M0 -9 L2.5 -2.5 L9 0 L2.5 2.5 L0 9 L-2.5 2.5 L-9 0 L-2.5 -2.5 Z" fill="{fill}"/>'
def hoodcap(c, extra=""): return f'<path d="M58 62 Q60 40 110 40 Q160 40 162 62 Q110 46 58 62 Z" fill="{c}" {extra}/>'
def hoodback(c, extra=""): return f'<rect x="45" y="33" width="130" height="108" rx="46" fill="{c}" {extra}/>'
GAT = (f'<path d="M87 46 L91 12 Q110 5 129 12 L133 46 Z" fill="{INK}" {OL}/><ellipse cx="110" cy="47" rx="80" ry="11" fill="{INK}" {OL}/>')
def gdots(pts, r=2.2): return "".join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{GOLD}"/>' for x, y in pts)
FLAP = 'M90 148 Q110 144 130 148 L126 184 Q110 198 94 184 Z'

O = {}
# first birthday (baby form)
O["dol_boy"] = fig("baby", "happy", body_fill="#2E8B57",
    cloth=saek(70, 136, 14, 152, 6, 6) + '<path d="M98 150 L110 164 L122 150" fill="none" stroke="#fff" stroke-width="4" stroke-linejoin="round"/>'
          '<rect x="70" y="169" width="80" height="5" fill="#C62B35"/>' + f'<circle cx="98" cy="178" r="3.5" fill="{GOLD}"/><circle cx="110" cy="179" r="3.5" fill="#3D5A98"/><circle cx="122" cy="178" r="3.5" fill="#E0457B"/>',
    hood=f'<rect x="51" y="61" width="118" height="98" rx="44" fill="{INK}" {OL}/><path d="M62 72 L70 46 L88 64 Z" fill="{INK}" {OL}/><path d="M69 66 L72 54 L80 62 Z" fill="{GOLD}"/>'
         f'<path d="M158 72 L150 46 L132 64 Z" fill="{INK}" {OL}/><path d="M151 66 L148 54 L140 62 Z" fill="{GOLD}"/>',
    top=f'<path d="M64 90 Q66 68 110 68 Q154 68 156 90 Q110 76 64 90 Z" fill="{INK}"/>'
        f'<path d="M88 79 L93 74 L98 79 L103 74 L108 79 L113 74 L118 79 L123 74 L128 79 L132 75" fill="none" stroke="{GOLD}" stroke-width="1.8" stroke-linejoin="round" stroke-linecap="round"/>')
O["dol_girl"] = fig("baby", "happy", body_fill="#F6D55C", feet=False,
    cloth=saek(70, 136, 14, 152, 6, 3) + '<path d="M98 150 L110 164 L122 150" fill="none" stroke="#fff" stroke-width="4" stroke-linejoin="round"/>',
    raw='<path d="M78 162 Q110 156 142 162 L158 193 Q110 200 62 193 Z" fill="#D7263D"/><path d="M95 165 L88 195 M110 163 L110 197 M125 165 L132 195" stroke="#B81E33" stroke-width="2" stroke-linecap="round"/>'
        '<path d="M115 158 L110 178 M115 158 L122 177" stroke="#3D5A98" stroke-width="4" stroke-linecap="round"/><circle cx="115" cy="158" r="3.2" fill="#3D5A98"/>',
    top='<path d="M62 96 Q62 62 110 62 Q158 62 158 96 Q110 78 62 96 Z" fill="#C62B35"/><path d="M110 63 L84 84" stroke="#2E8B57" stroke-width="7"/><path d="M110 63 L110 84" stroke="#F6C445" stroke-width="7"/><path d="M110 63 L136 84" stroke="#3D5A98" stroke-width="7"/>'
        f'<circle cx="110" cy="61" r="5" fill="#fff" {WL}/><path d="M62 94 L55 130" stroke="#3D5A98" stroke-width="6" stroke-linecap="round"/><path d="M158 94 L165 130" stroke="#F6C445" stroke-width="6" stroke-linecap="round"/>')
# kids
O["saek_boy"] = fig(mood="happy", body_fill="#F3E9D2",
    cloth=saek(42, 148, 30, 134, 8, 7) + '<rect x="72" y="130" width="76" height="62" fill="#27365E"/><path d="M110 152 L110 192" stroke="#F3E9D2" stroke-width="2.5"/>' + vcollar("#fff", 5) + '<rect x="72" y="168" width="76" height="7" fill="#C62B35"/>',
    hood=hoodback(INK, OL), top=f'<path d="M58 62 Q62 34 110 26 Q158 34 162 62 Q110 46 58 62 Z" fill="{INK}" {OL}/>' + gdots(((88, 47), (110, 39), (132, 47)), 2.6))
O["saek_girl"] = fig(mood="happy", body_fill="#F3E9D2", feet=False, cloth=saek(42, 148, 30, 134, 8, 7) + vcollar("#fff", 5),
    raw=skirt("#D7263D", "#B81E33") + goreum("#3D5A98"),
    top=f'<path d="M104 50 L99 63 M116 50 L121 63" stroke="#3D5A98" stroke-width="4" stroke-linecap="round"/><circle cx="110" cy="45" r="8" fill="#D7263D"/><circle cx="110" cy="45" r="3.5" fill="{GOLD}"/>'
        '<path d="M152 46 L138 37 L138 55 Z M152 46 L166 37 L166 55 Z" fill="#FF8FB1"/><circle cx="152" cy="46" r="4" fill="#F06292"/>')
# court
EMB = f'<circle cx="110" cy="166" r="13" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="2"/><circle cx="110" cy="166" r="7" fill="none" stroke="{GOLD_D}" stroke-width="2"/>'
O["prince"] = fig(body_fill="#1F2A56",
    cloth=vcollar("#fff", 5) + EMB + f'<circle cx="58" cy="142" r="8" fill="{GOLD}"/><circle cx="162" cy="142" r="8" fill="{GOLD}"/><rect x="42" y="184" width="136" height="4" fill="{GOLD}"/>',
    top=f'<rect x="91" y="3" width="8" height="26" rx="4" fill="{INK}" {OL}/><rect x="121" y="3" width="8" height="26" rx="4" fill="{INK}" {OL}/><path d="M84 32 Q110 8 136 32 Z" fill="{INK}" {OL}/><path d="M72 52 Q72 24 110 24 Q148 24 148 52 Z" fill="{INK}" {OL}/>')
O["princess"] = fig(mood="happy", body_fill="#F7A8C4", feet=False, cloth=vcollar("#fff", 5) + gdots(((58, 142), (162, 142), (67, 151), (153, 151))),
    raw=skirt("#C62B35", "#A51F2B", False) + f'<path d="{FLAP}" fill="#F7A8C4" stroke="{GOLD}" stroke-width="1.5"/>' + gdots(((104, 172), (116, 172), (110, 184))) + goreum("#6A3D9A", 118, 150, 5.5),
    top=f'<path d="M93 34 L86 46 M127 34 L134 46" stroke="{GOLD}" stroke-width="2" stroke-linecap="round"/><circle cx="86" cy="48" r="2.6" fill="{RED}"/><circle cx="134" cy="48" r="2.6" fill="{RED}"/>'
        f'<rect x="93" y="22" width="34" height="24" rx="9" fill="#1E1E24" {OL}/><circle cx="110" cy="20" r="5" fill="{RED}"/><circle cx="100" cy="29" r="3" fill="{GOLD}"/><circle cx="120" cy="29" r="3" fill="{GOLD}"/>'
        '<circle cx="110" cy="31" r="3" fill="#4FA3D9"/><circle cx="104" cy="39" r="2.6" fill="#3BB273"/><circle cx="116" cy="39" r="2.6" fill="#3BB273"/>')
O["court_lady"] = fig(body_fill="#2E8B57", feet=False, cloth=vcollar("#fff", 5) + gdots(((58, 142), (162, 142), (67, 151), (153, 151))),
    raw=skirt("#27365E", "#1B2644", False) + f'<path d="{FLAP}" fill="#2E8B57" stroke="{GOLD}" stroke-width="1.5"/>' + gdots(((104, 172), (116, 172), (110, 184))) + goreum("#B5172B", 118, 150, 5.5),
    hood=f'<circle cx="171" cy="72" r="12" fill="{INK}" {OL}/>',
    top=hoodcap(INK, OL) + f'<path d="M110 41 L110 53" stroke="#77777D" stroke-width="1.5"/><circle cx="110" cy="45" r="4.5" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1"/><path d="M168 72 L192 72" stroke="{GOLD}" stroke-width="3.5" stroke-linecap="round"/>')
O["dopo"] = fig(mood="happy", body_fill="#F3F1EA", body_stroke="#CFCFD6",
    cloth=vcollar("#BFD3E6", 6) + '<path d="M42 152 L178 152" stroke="#3D5A98" stroke-width="3"/><path d="M120 152 L118 180 M126 152 L128 178" stroke="#3D5A98" stroke-width="3" stroke-linecap="round"/>'
          '<rect x="114.5" y="178" width="7" height="10" rx="2" fill="#3D5A98"/><rect x="124.5" y="176" width="7" height="10" rx="2" fill="#3D5A98"/>',
    hand=f'<path d="M182 158 L162 122 A42 42 0 0 1 204 126 Z" fill="#fff" {WL}/><path d="M182 158 L172 120 M182 158 L183 116 M182 158 L194 119" stroke="#CFCFD6" stroke-width="1.5"/>' + paw(177, 156), top=GAT)
# winter and outdoors
O["durumagi"] = fig(body_fill="#6B7280", cloth=vcollar("#fff", 6) + '<path d="M110 156 L110 192" stroke="#596070" stroke-width="2"/>' + goreum_m("#4B5563"),
    hood=hoodback(INK, OL), top=hoodcap(INK) + f'<path d="M58 62 Q110 46 162 62" fill="none" stroke="#8B5E3C" stroke-width="6" stroke-linecap="round"/><circle cx="110" cy="38" r="5.5" fill="{RED}"/>')
O["baeja"] = fig(mood="happy", body_fill="#F3E9D2", feet=False, cloth=vcollar("#fff", 5),
    raw=skirt("#6A3D9A", "#56307F", False) + '<path d="M70 132 L70 172 L103 172 L103 132 Z M117 132 L117 172 L150 172 L150 132 Z" fill="#B5172B"/>'
        '<path d="M103 136 L103 172 M117 136 L117 172" stroke="#fff" stroke-width="5" stroke-linecap="round"/>' + f'<circle cx="110" cy="152" r="3.5" fill="{GOLD}"/>',
    top=f'<path d="M56 68 Q110 42 164 68 L161 54 Q110 28 59 54 Z" fill="{INK}" {OL}/><path d="M56 68 Q110 42 164 68" fill="none" stroke="#8B5E3C" stroke-width="5" stroke-linecap="round"/>'
        f'<circle cx="110" cy="34" r="5.5" fill="{RED}"/><circle cx="110" cy="49" r="3.5" fill="#3BB273"/>')
O["jangot"] = fig(body_fill="#F7A8C4", hood='<path d="M36 192 Q26 62 110 20 Q194 62 184 192 Z" fill="#2E8B57"/>',
    cloth='<rect x="42" y="160" width="136" height="32" fill="#27365E"/><path d="M42 98 L88 98 L80 192 L42 192 Z M178 98 L132 98 L140 192 L178 192 Z" fill="#2E8B57"/>'
          + vcollar("#fff", 5) + '<path d="M88 134 L80 192 M132 134 L140 192" stroke="#6A3D9A" stroke-width="4"/>',
    top=hoodcap("#2E8B57") + '<path d="M58 63 Q110 47 162 63" fill="none" stroke="#fff" stroke-width="4" stroke-linecap="round"/>')
O["seollal"] = fig(mood="happy", body_fill="#3BA99C", cloth=baji("#6A3D9A", "#56307F") + vcollar("#fff") + goreum_m("#1F7A70"),
    hand=f'<path d="M186 170 L186 183" stroke="{GOLD}" stroke-width="2.5" stroke-linecap="round"/><path d="M176 142 Q166 166 186 170 Q206 166 196 142 Q186 148 176 142 Z" fill="{RED}"/>'
         f'<path d="M177 142 L195 142" stroke="{GOLD}" stroke-width="3.5" stroke-linecap="round"/><circle cx="186" cy="157" r="5" fill="none" stroke="{GOLD}" stroke-width="2"/>' + paw(174, 152))
# modern and colorways
O["modern_a"] = fig(mood="happy", body_fill="#EADBC0", feet_fill="#fff", feet_stroke="#B8BCC4", cloth=vcollar("#fff", 5),
    raw='<path d="M60 152 Q110 146 160 152 L174 186 Q110 194 46 186 Z" fill="#9DB8A0"/><path d="M86 156 L78 188 M110 154 L110 190 M134 156 L142 188" stroke="#86A38A" stroke-width="2.5" stroke-linecap="round"/>'
        '<path d="M118 148 L113 174 M118 148 L126 172" stroke="#D88FA0" stroke-width="4.5" stroke-linecap="round"/><circle cx="118" cy="148" r="4" fill="#D88FA0"/>',
    top=f'<circle cx="152" cy="48" r="6.5" fill="#D88FA0"/><circle cx="152" cy="48" r="2.6" fill="{GOLD}"/>')
O["modern_b"] = fig(body_fill="#3B4252", feet_fill="#fff", feet_stroke="#B8BCC4",
    cloth='<rect x="42" y="170" width="136" height="22" fill="#D8C9A8"/>' + vcollar("#fff", 5) + '<path d="M116 150 L112 166" stroke="#232831" stroke-width="5" stroke-linecap="round"/><circle cx="116" cy="150" r="4" fill="#232831"/>',
    face="".join(f'<circle cx="{x}" cy="76" r="11.5" fill="#fff" fill-opacity=".2" stroke="{INK}" stroke-width="2.6"/>' for x in (78, 142)) + f'<path d="M89.5 74 Q110 67 130.5 74" fill="none" stroke="{INK}" stroke-width="2.6"/>')
PETAL = "".join(f'<ellipse cx="{x}" cy="{y}" rx="5" ry="3" fill="#FF9EBB" transform="rotate({a} {x} {y})"/>' for x, y, a in ((24, 52, 30), (198, 72, -40), (28, 124, 60), (202, 132, 20), (44, 22, -20)))
O["spring"] = fig(mood="happy", body_fill="#FFD1DC", feet=False, back=PETAL, cloth=vcollar("#fff", 5), raw=skirt("#A8E0C8", "#8CCBB0") + goreum("#F06292"),
    top='<g transform="translate(152,46)">' + "".join(f'<ellipse cx="0" cy="-6.5" rx="4.4" ry="6.2" fill="#FF9EBB" transform="rotate({a})"/>' for a in range(0, 360, 72)) + f'<circle r="3.2" fill="{GOLD}"/></g>')
O["night"] = fig(mood="happy", body_fill="#16193A", body_stroke="#55555C",
    back=f'<path d="M36 28 A17 17 0 1 0 54 52 A13 13 0 1 1 36 28 Z" fill="{GOLD}"/>' + star(196, 36, .6) + star(204, 96, .45) + star(18, 100, .45),
    cloth=baji("#2A2F5B", "#1E2247") + vcollar(GOLD, 5) + goreum_m(GOLD) + "".join(star(x, y, .42) for x, y in ((58, 146), (162, 146), (76, 160), (146, 162), (92, 142), (134, 140))))

# ---------- parametric hanbok for every growth size ----------
def P(stage):
    d = D[stage]; hx, hy, hw, hh, hr = d["head"]; bx, by, bw, bh, br = d["body"]
    neck = hy + hh; return d, bx, by, bw, bh, neck, by + bh - neck, bw / 136
def pcollar(stage, c="#fff"):
    d, bx, by, bw, bh, neck, th, k = P(stage)
    return f'<path d="M{110-0.155*bw:.1f} {neck-3} L110 {neck+0.39*th:.1f} L{110+0.155*bw:.1f} {neck-3}" fill="none" stroke="{c}" stroke-width="{6*k:.1f}" stroke-linejoin="round" stroke-linecap="round"/>'
def sprout(stage):
    top = D[stage]["head"][1]
    return (f'<path d="M110 {top+2} L110 {top-12}" stroke="#4C9A4C" stroke-width="3" stroke-linecap="round"/><ellipse cx="103" cy="{top-15}" rx="8" ry="4" fill="#5BAA5B" transform="rotate(28 103 {top-15})"/>'
            f'<ellipse cx="117" cy="{top-15}" rx="8" ry="4" fill="#6BBF6B" transform="rotate(-28 117 {top-15})"/>')
def hb_m(stage):
    d, bx, by, bw, bh, neck, th, k = P(stage)
    kx, ky = 110 + 0.044*bw, neck + 0.29*th
    cloth = (f'<rect x="{bx}" y="{neck+0.61*th:.1f}" width="{bw}" height="{th}" fill="#C9CDD6"/><path d="M110 {neck+0.68*th:.1f} L110 {by+bh+2}" stroke="#AEB3BE" stroke-width="{2*k:.1f}"/>' + pcollar(stage)
             + f'<path d="M{kx:.1f} {ky:.1f} L{110-0.007*bw:.1f} {neck+0.82*th:.1f} M{kx:.1f} {ky:.1f} L{110+0.11*bw:.1f} {neck+0.79*th:.1f}" stroke="#24345F" stroke-width="{6*k:.1f}" stroke-linecap="round"/><circle cx="{kx:.1f}" cy="{ky:.1f}" r="{4.5*k:.1f}" fill="#24345F"/>')
    return fig(stage, "happy", body_fill="#3D5A98", cloth=cloth, top=sprout(stage) if stage == "tiny" else "", width=150)
def hb_f(stage):
    d, bx, by, bw, bh, neck, th, k = P(stage)
    x0, x1, yt, yb = bx + 0.12*bw, bx + 0.88*bw, neck + 0.32*th, by + bh + 10*k
    kx, ky = 110 + 0.06*bw, neck + 0.25*th; (e2x, e2y) = d["ears"][1]
    raw = (f'<path d="M{x0:.1f} {yt:.1f} Q110 {yt-8*k:.1f} {x1:.1f} {yt:.1f} L{bx+1.09*bw:.1f} {yb:.1f} Q110 {yb+10*k:.1f} {bx-0.09*bw:.1f} {yb:.1f} Z" fill="#D7263D"/>'
           f'<path d="M{x0+0.19*bw:.1f} {yt+4*k:.1f} L{x0+0.09*bw:.1f} {yb+3*k:.1f} M110 {yt+2*k:.1f} L110 {yb+6*k:.1f} M{x1-0.19*bw:.1f} {yt+4*k:.1f} L{x1-0.09*bw:.1f} {yb+3*k:.1f}" stroke="#B81E33" stroke-width="{2.5*k:.1f}" stroke-linecap="round"/>'
           f'<path d="M{x0:.1f} {yt:.1f} Q110 {yt-8*k:.1f} {x1:.1f} {yt:.1f}" fill="none" stroke="#fff" stroke-width="{4*k:.1f}"/>'
           f'<path d="M{kx:.1f} {ky:.1f} L110 {neck+0.93*th:.1f} M{kx:.1f} {ky:.1f} L{110+0.13*bw:.1f} {neck+0.89*th:.1f}" stroke="#8E1F4F" stroke-width="{6.5*k:.1f}" stroke-linecap="round"/><circle cx="{kx:.1f}" cy="{ky:.1f}" r="{5*k:.1f}" fill="#8E1F4F"/>')
    a, b = 16*k, 10*k
    bow = f'<path d="M{e2x} {e2y} l{-a:.1f} {-b:.1f} l0 {2*b:.1f} Z M{e2x} {e2y} l{a:.1f} {-b:.1f} l0 {2*b:.1f} Z" fill="#D7263D"/><circle cx="{e2x}" cy="{e2y}" r="{4.5*k:.1f}" fill="#B81E33"/>'
    return fig(stage, "happy", body_fill="#F6D55C", feet=False, cloth=pcollar(stage), raw=raw, top=bow + (sprout(stage) if stage == "tiny" else ""), width=150)

L = {"dol_boy": ("First birthday A", "tiger hood, five-color coat"), "dol_girl": ("First birthday B", "gulle cap, rainbow sleeves"),
     "saek_boy": ("Saekdong A", "rainbow sleeves, bokgeon hood"), "saek_girl": ("Saekdong B", "rainbow sleeves, red skirt"),
     "prince": ("Prince", "navy dragon robe"), "princess": ("Princess", "pink dangui, flower crown"),
     "court_lady": ("Court lady", "green dangui, gold leaf"), "dopo": ("Dopo", "white scholar robe, fan"),
     "durumagi": ("Durumagi", "winter coat, fur cap"), "baeja": ("Baeja", "fur vest, ayam cap"),
     "jangot": ("Jangot", "veil cloak"), "seollal": ("Seollal", "New Year lucky pouch"),
     "modern_a": ("Modern A", "wrap skirt, sneakers"), "modern_b": ("Modern B", "jacket, trousers, sneakers"),
     "spring": ("Spring", "blossom colorway"), "night": ("Night", "gold-leaf colorway")}
SECTIONS = [("First birthday and kids", ["dol_boy", "dol_girl", "saek_boy", "saek_girl"]), ("Court", ["prince", "princess", "court_lady", "dopo"]),
            ("Winter and holidays", ["durumagi", "baeja", "jangot", "seollal"]), ("Modern and colorways", ["modern_a", "modern_b", "spring", "night"])]
STAGES = [("tiny", "Sprout"), ("baby", "Baby"), ("kid", "Kinder"), ("young", "Young"), ("teen", "Student"), ("adult", "Adult")]
DARK = ["night", "dopo", "court_lady", "durumagi"]

def cells(keys): return "".join(f'<div class="cell">{O[k]}<div class="t">{L[k][0]}</div><div class="d">{L[k][1]}</div></div>' for k in keys)
def sec(title, keys, dark=False): return f'<h2 class="{"dk" if dark else ""}">{title}</h2><div class="grid {"dark" if dark else ""}">{cells(keys)}</div>'
def strip(fn): return '<div class="grid six">' + "".join(f'<div class="cell s">{fn(s)}<div class="t">{n}</div></div>' for s, n in STAGES) + '</div>'

html = f'''<!doctype html><meta charset="utf-8"><style>
body{{margin:0;font-family:Arial,Helvetica,sans-serif;background:#fff}}
h1{{font-size:20px;margin:0;padding:22px 32px 4px;color:#1c1c1e}} .sub{{padding:0 32px 14px;color:#6b7280;font-size:14px}}
h2{{font-size:14px;margin:0;padding:18px 32px 0;color:#6b7280;background:#F6F5F2;text-transform:uppercase;letter-spacing:.06em}}
h2.dk{{background:#1C1C1E;color:#9aa0a6}}
.grid{{display:flex;flex-wrap:wrap;gap:8px;padding:14px 24px 22px;background:#F6F5F2}} .grid.dark{{background:#1C1C1E}} .grid.six{{gap:2px;padding-bottom:8px}}
.cell{{width:220px;text-align:center}} .cell.s{{width:150px}} .t{{font-weight:700;font-size:15px;color:#1c1c1e;margin-top:6px}} .d{{font-size:13px;color:#6b7280;margin-top:2px}}
.dark .t{{color:#f2f2f7}} .dark .d{{color:#9aa0a6}}
</style><div id="sheet" style="width:960px">
<div id="p1"><h1>Gochi hanbok collection, concept v1 (drawn in code)</h1><div class="sub">16 more hanbok, plus the two basic hanbok on every growth size.</div>
<h2>Growing up in hanbok: trousers</h2>{strip(hb_m)}<h2>Growing up in hanbok: skirt</h2>{strip(hb_f)}
{sec(*SECTIONS[0])}</div>
<div id="p2">{"".join(sec(t, k) for t, k in SECTIONS[1:])}{sec("Dark mode check", DARK, True)}</div></div>'''
open("hanbok.html", "w").write(html)

async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await b.new_page(viewport={"width": 960, "height": 900}, device_scale_factor=2)
        await pg.goto("file://" + os.path.abspath("hanbok.html"))
        await (await pg.query_selector("#sheet")).screenshot(path="/home/claude/gochi-hanbok.png")
        await pg.close()
        pg = await b.new_page(viewport={"width": 960, "height": 900}, device_scale_factor=1)
        await pg.goto("file://" + os.path.abspath("hanbok.html"))
        await (await pg.query_selector("#p1")).screenshot(path="hcheck1.png")
        await (await pg.query_selector("#p2")).screenshot(path="hcheck2.png")
        await b.close()
asyncio.run(main())
