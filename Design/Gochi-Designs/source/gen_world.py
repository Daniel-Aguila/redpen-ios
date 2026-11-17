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

T = {}   # themes
T["chef"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth=f'<path d="M96 133 L110 148 L124 133 Z" fill="{RED}"/>' + dots([(98, 150), (122, 150), (98, 164), (122, 164), (98, 178), (122, 178)], 3, "#3B4252"),
    top=f'<path d="M80 50 L80 30 Q62 26 68 12 Q78 0 96 8 Q110 -2 124 8 Q142 0 152 12 Q158 26 140 30 L140 50 Z" fill="#fff" {WL}/><path d="M80 40 L140 40" stroke="#CFCFD6" stroke-width="1.5"/>',
    hand='<path d="M184 170 L184 120" stroke="#8A8F98" stroke-width="4" stroke-linecap="round"/><ellipse cx="184" cy="113" rx="11" ry="8" fill="#8A8F98"/>' + paw(177, 156))
T["barista"] = dict(body_fill=CRM, mood="happy", cloth=apron("#2E6B4F") + '<path d="M92 170 L128 170" stroke="#24553F" stroke-width="2.5"/>', top=cap("#5A3A29", "#3A2A1A"),
    hand=f'<path d="M198 138 q10 6 -2 16" fill="none" stroke="#CFCFD6" stroke-width="3"/><path d="M170 132 L198 132 L194 162 Q184 168 174 162 Z" fill="#fff" {WL}/><ellipse cx="184" cy="132" rx="14" ry="4" fill="#B5835A"/>' + paw(173, 157))
T["rider"] = dict(body_fill="#2AC1BC", cloth=band(156, 6, "#E5E7EB") + '<path d="M110 134 L110 192" stroke="#1E9C97" stroke-width="2.5"/>',
    top=f'<path d="M60 60 Q58 16 110 16 Q162 16 160 60 Z" fill="#2AC1BC"/><path d="M62 60 Q110 48 158 60 L158 51 Q110 39 62 51 Z" fill="{BLK}"/>',
    hand=f'<path d="M176 126 q9 -12 18 0" fill="none" stroke="{BLK}" stroke-width="3"/><rect x="166" y="126" width="38" height="34" rx="4" fill="#2AC1BC" stroke="#1E9C97" stroke-width="1.5"/><path d="M166 140 L204 140" stroke="#fff" stroke-width="3"/>' + paw(171, 160))
T["doctor"] = dict(body_fill=W, body_stroke=WS, mood="happy",
    cloth='<path d="M90 132 L110 162 L130 132 Z" fill="#4FA3D9"/><path d="M90 132 L110 162 L130 132 M110 162 L110 192" fill="none" stroke="#CFCFD6" stroke-width="2.5"/>'
          f'<rect x="130" y="160" width="20" height="16" rx="2" fill="none" stroke="#CFCFD6" stroke-width="2"/><path d="M136 160 L136 151" stroke="{RED}" stroke-width="3" stroke-linecap="round"/>'
          '<path d="M94 134 Q86 168 102 173" fill="none" stroke="#3B4252" stroke-width="3" stroke-linecap="round"/><circle cx="104" cy="174" r="5" fill="#8A8F98" stroke="#3B4252" stroke-width="2"/>')
T["tteok"] = dict(body_fill=CRM, mood="happy", cloth=apron("#D7263D") + '<path d="M92 170 L128 170" stroke="#B81E33" stroke-width="2.5"/>', top=hoodcap("#D7263D") + dots([(86, 50), (110, 45), (134, 50)], 2.4, "#fff"),
    hand='<rect x="173" y="120" width="8" height="18" rx="4" fill="#E4572E"/><rect x="182" y="116" width="8" height="22" rx="4" fill="#E4572E"/><rect x="190" y="121" width="8" height="18" rx="4" fill="#E4572E"/>'
         f'<path d="M170 134 L200 134 L195 166 L175 166 Z" fill="#fff" {WL}/>' + paw(173, 158))
T["kimbap"] = dict(body_fill="#1F2A24", body_stroke=DS, mood="happy", hood=hoodback("#1F2A24", OL), top=hoodcap("#1F2A24", OL) + dots([(92, 50), (104, 46), (118, 46), (130, 50)], 1.8, "#F3E9D2"),
    cloth='<circle cx="110" cy="164" r="24" fill="#fff"/>' + dots([(102, 157)], 6, "#F6C445") + dots([(118, 157)], 6, "#F28C28") + dots([(103, 172)], 6, "#3BB273") + dots([(118, 172)], 6, "#F7A8C4"))
T["chicken"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth="".join(f'<rect x="{x}" y="98" width="8" height="94" fill="#E4572E"/>' for x in range(52, 178, 16)),
    top=f'<path d="M70 50 L78 22 L142 22 L150 50 Z" fill="#fff" {WL}/><path d="M77 31 L143 31" stroke="#E4572E" stroke-width="5"/>',
    hand='<path d="M186 162 L186 138" stroke="#F7E7BE" stroke-width="6" stroke-linecap="round"/><circle cx="183" cy="164" r="3.5" fill="#F7E7BE"/><circle cx="189" cy="164" r="3.5" fill="#F7E7BE"/>'
         '<ellipse cx="186" cy="124" rx="13" ry="16" fill="#D98A2B" stroke="#B36A16" stroke-width="1.5"/>' + paw(177, 152))
T["bibimbap"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth=apron("#D8C9A8"),
    hand=f'<path d="M182 132 L160 164" stroke="#8A8F98" stroke-width="3.5" stroke-linecap="round"/>' + paw(181, 138) + f'<path d="M76 170 L144 170 Q142 200 110 202 Q78 200 76 170 Z" fill="{INK}" {OL}/><ellipse cx="110" cy="170" rx="34" ry="7" fill="{CRM}"/>'
         + dots([(90, 169)], 5, "#3BB273") + dots([(100, 167)], 5, "#F28C28") + dots([(121, 167)], 5, "#8B5E3C") + dots([(131, 169)], 5, "#C62B35") + '<ellipse cx="110" cy="166" rx="9" ry="5" fill="#fff"/><circle cx="110" cy="165" r="3.5" fill="#F6C445"/>')
T["baseball"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth="".join(f'<path d="M{x} 98 L{x} 192" stroke="#C9CDD6" stroke-width="1.5"/>' for x in range(50, 178, 12)) + f'<path d="M110 134 L110 192" stroke="{NAVY}" stroke-width="3"/>' + vcollar(NAVY, 4),
    top=cap(NAVY, "#1B2644") + '<circle cx="110" cy="36" r="5" fill="#fff"/>',
    hand='<rect x="170" y="96" width="10" height="64" rx="5" fill="#F6C445" transform="rotate(12 175 128)"/><rect x="186" y="98" width="10" height="64" rx="5" fill="#F6C445" transform="rotate(24 191 130)"/>' + paw(176, 158))
T["archer"] = dict(body_fill=W, body_stroke=WS, cloth=vcollar(NAVY, 4) + f'<path d="M70 134 Q100 150 96 192 L42 192 L42 134 Z" fill="{BLK}"/>',
    top=f'<path d="M70 52 Q72 20 110 20 Q148 20 150 52 Z" fill="#fff" {WL}/><path d="M54 59 Q110 40 166 59 Q110 52 54 59 Z" fill="#fff" {WL}/>',
    hand=f'<path d="M194 96 L194 184" stroke="#8A8F98" stroke-width="1.5"/><path d="M194 96 Q168 140 194 184" fill="none" stroke="{RED}" stroke-width="5" stroke-linecap="round"/>' + paw(183, 140))
T["football"] = dict(body_fill="#D7263D", mood="happy", cloth=band(176, 16, "#fff"),
    raw=f'<path d="M84 131 Q110 147 136 131 L138 141 Q110 157 82 141 Z" fill="#fff"/><rect x="124" y="142" width="14" height="30" rx="3" fill="#fff"/><path d="M124 152 L138 152 M124 162 L138 162" stroke="{RED}" stroke-width="3"/>',
    hand=ball() + paw(175, 158))
T["esports"] = dict(body_fill="#16193A", body_stroke=DS, mood="happy", cloth='<path d="M60 134 L52 192 M160 134 L168 192" stroke="#3DF2C4" stroke-width="4"/>' + vcollar("#3DF2C4", 4) + star(110, 170, 1, "#3DF2C4"),
    face=HEADSET, top=f'<path d="M54 78 Q54 30 110 30 Q166 30 166 78" fill="none" stroke="{BLK}" stroke-width="7" stroke-linecap="round"/><rect x="42" y="66" width="18" height="30" rx="8" fill="{BLK}" {OL}/><rect x="160" y="66" width="18" height="30" rx="8" fill="{BLK}" {OL}/>'
        + dots([(51, 81), (169, 81)], 3, "#3DF2C4"))
T["chuseok"] = dict(body_fill="#E07B2A", mood="happy", back='<circle cx="42" cy="44" r="27" fill="#FBE8A6"/>',
    cloth=band(168, 24, "#7A4E33") + vcollar("#fff") + '<path d="M116 150 L109 180 M116 150 L125 178" stroke="#A9541A" stroke-width="6" stroke-linecap="round"/><circle cx="116" cy="150" r="4.5" fill="#A9541A"/>',
    hand=f'<ellipse cx="186" cy="152" rx="19" ry="6" fill="#fff" {WL}/><path d="M171 150 q6 -11 12 0 z" fill="#fff" {WL}/><path d="M180 150 q6 -11 12 0 z" fill="#BFE3B4"/><path d="M189 150 q6 -11 12 0 z" fill="#F9C6D3"/>' + paw(174, 160))
T["christmas"] = dict(body_fill="#C62B35", mood="happy", cloth='<rect x="104" y="134" width="12" height="58" fill="#fff"/>' + band(166, 8, BLK), raw=f'<rect x="102" y="164" width="16" height="12" rx="2" fill="{GOLD}"/>',
    top=f'<path d="M62 56 Q70 14 120 10 Q160 12 176 44 Q150 30 150 56 Z" fill="{RED}"/><rect x="58" y="48" width="100" height="14" rx="7" fill="#fff" {WL}/><circle cx="176" cy="46" r="8" fill="#fff" {WL}/>',
    hand=f'<circle cx="178" cy="132" r="5" fill="none" stroke="{GOLD}" stroke-width="3"/><circle cx="188" cy="132" r="5" fill="none" stroke="{GOLD}" stroke-width="3"/><rect x="168" y="136" width="30" height="28" rx="3" fill="{GRN}"/>'
         f'<path d="M183 136 L183 164 M168 150 L198 150" stroke="{GOLD}" stroke-width="4"/>' + paw(171, 160))
T["birthday"] = dict(body_fill="#8FA0FF", mood="happy", back=dots([(22, 40), (198, 60), (30, 110)], 4, "#F6C445") + dots([(40, 70), (204, 110), (16, 150)], 3.5, "#F06292") + dots([(190, 28), (26, 16)], 3.5, "#3BB273"),
    cloth=dots([(60, 146), (84, 160), (64, 176), (136, 146), (156, 162), (140, 180), (110, 150)], 3.5, "#fff"),
    top=f'<path d="M84 48 L110 8 L136 48 Z" fill="#F06292"/><path d="M96 30 L124 30 M90 40 L130 40" stroke="#fff" stroke-width="3"/><circle cx="110" cy="8" r="5.5" fill="{GOLD}"/>',
    hand='<path d="M184 142 L184 130" stroke="#4FA3D9" stroke-width="3"/><path d="M184 130 q-4 -6 0 -10 q4 4 0 10z" fill="#F6C445"/><rect x="166" y="142" width="36" height="20" rx="4" fill="#FFF1DC" stroke="#E6BE94" stroke-width="1.5"/>'
         '<path d="M166 148 q6 6 12 0 q6 6 12 0 q6 6 12 0" fill="none" stroke="#F06292" stroke-width="3"/>' + paw(171, 162))
T["hangul"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth=f'<path d="M94 148 L126 148 L126 178" fill="none" stroke="{RED}" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/>', hand=BRUSH)
T["magpie"] = dict(body_fill=BLK, body_stroke=DS, back=f'<path d="M166 176 L208 202 L174 192 Z" fill="{NAVY}"/>', hood=hoodback(BLK, OL),
    cloth=f'<ellipse cx="110" cy="174" rx="36" ry="26" fill="#fff"/><path d="M42 134 L62 140 L50 182 L42 178 Z M178 134 L158 140 L170 182 L178 178 Z" fill="{NAVY}"/>',
    top=hoodcap(BLK, OL) + f'<path d="M102 50 L110 62 L118 50 Z" fill="{GOLD}"/>')
MANE = "".join(f'<circle cx="{110+66*math.cos(math.radians(a)):.1f}" cy="{88+58*math.sin(math.radians(a)):.1f}" r="13" fill="{CRM}"/>' for a in range(150, 400, 20))
T["haetae"] = dict(body_fill="#3F8FA8", mood="happy", back=f'<circle cx="186" cy="178" r="12" fill="{CRM}"/>', hood=MANE + hoodback("#3F8FA8"),
    cloth=f'<ellipse cx="110" cy="174" rx="34" ry="24" fill="{CRM}"/>' + "".join(f'<path d="M{x} {y} q6 7 12 0" fill="none" stroke="#2F7388" stroke-width="2"/>' for x, y in ((48, 144), (62, 154), (48, 166), (148, 154), (160, 144), (160, 166))),
    top=hoodcap("#3F8FA8") + '<path d="M103 44 L110 18 L117 44 Z" fill="#F7E7BE" stroke="#D9C28A" stroke-width="1.5" stroke-linejoin="round"/>')
T["bear"] = dict(body_fill="#6B4226", mood="happy", hood=hoodback("#6B4226") + "".join(f'<circle cx="{x}" cy="36" r="13" fill="#6B4226"/><circle cx="{x}" cy="37" r="6.5" fill="{FUR}"/>' for x in (68, 152)),
    cloth='<ellipse cx="110" cy="174" rx="34" ry="24" fill="#C9A27E"/>', top=hoodcap("#6B4226"),
    hand='<path d="M174 134 q-8 -14 2 -24" fill="none" stroke="#5BAA5B" stroke-width="3.5" stroke-linecap="round"/><path d="M186 162 Q170 158 174 142 Q180 132 186 122 Q192 132 198 142 Q202 158 186 162 Z" fill="#FAF3E3" stroke="#CFC6AE" stroke-width="1.5"/>'
         '<path d="M186 126 L186 160 M180 138 Q178 150 182 160 M192 138 Q194 150 190 160" fill="none" stroke="#CFC6AE" stroke-width="1.2"/>' + paw(175, 160))
T["rabbit"] = dict(body_fill=W, body_stroke=WS, mood="happy", back='<circle cx="40" cy="48" r="28" fill="#FBE8A6"/>',
    hood=f'<ellipse cx="82" cy="26" rx="10" ry="22" fill="#fff" {WL} transform="rotate(-10 82 26)"/><ellipse cx="82" cy="28" rx="4.5" ry="14" fill="#FFC6D9" transform="rotate(-10 82 28)"/>'
         f'<ellipse cx="138" cy="26" rx="10" ry="22" fill="#fff" {WL} transform="rotate(10 138 26)"/><ellipse cx="138" cy="28" rx="4.5" ry="14" fill="#FFC6D9" transform="rotate(10 138 28)"/>' + hoodback("#fff", WL),
    top=hoodcap("#fff", WL), hand=f'<path d="M186 172 L186 120" stroke="{WOOD}" stroke-width="4" stroke-linecap="round"/><rect x="170" y="104" width="32" height="18" rx="5" fill="#9A6540"/>' + paw(177, 156))

C = {}   # countries
SILVER = "#D9DCE3"
C["mariachi"] = dict(body_fill=BLK, body_stroke=DS, mood="happy",
    cloth='<path d="M94 132 L110 158 L126 132 Z" fill="#fff"/>' + f'<path d="M110 144 L94 136 L94 152 Z M110 144 L126 136 L126 152 Z" fill="{RED}"/><circle cx="110" cy="144" r="4" fill="#C62B35"/>'
          + dots([(x, y) for y in (150, 160, 170, 180) for x in (62, 158)], 2.6, SILVER) + f'<path d="M70 146 q8 -6 14 2 M150 146 q-8 -6 -14 2" fill="none" stroke="{SILVER}" stroke-width="2"/>',
    top=SOMBRERO,
    hand='<g transform="translate(184,152) rotate(24)"><rect x="-3" y="-52" width="6" height="40" fill="#5A3A29"/><rect x="-5" y="-60" width="10" height="10" rx="2" fill="#3A2A1A"/>'
         '<ellipse cx="0" cy="0" rx="15" ry="18" fill="#C98A4B" stroke="#8B5E3C" stroke-width="1.5"/><circle cx="0" cy="-3" r="5" fill="#3A2A1A"/></g>' + paw(173, 152))
C["folklorico"] = dict(body_fill="#E0457B", mood="happy", feet=False, cloth='<path d="M84 134 Q110 157 136 134" fill="none" stroke="#fff" stroke-width="9" stroke-linecap="round"/><path d="M82 142 Q110 166 138 142" fill="none" stroke="#3BB273" stroke-width="3"/>',
    raw=FOLK_SKIRT,
    top='<path d="M60 70 Q48 100 56 128" fill="none" stroke="#3A2A1A" stroke-width="9" stroke-linecap="round"/><path d="M160 70 Q172 100 164 128" fill="none" stroke="#3A2A1A" stroke-width="9" stroke-linecap="round"/>'
        + dots([(56, 130), (164, 130)], 6, RED) + hoodcap("#3A2A1A") + flower(88, 41, 8, RED) + flower(110, 35, 9, "#F6C445", "#F28C28") + flower(132, 41, 8, "#F28C28"))
MARI = "#F28C28"
C["catrina"] = dict(body_fill=BLK, body_stroke=DS, feet=False, cloth="".join(flower(x, y, 6, MARI, "#F6C445") for x, y in ((90, 139), (100, 147), (110, 151), (120, 147), (130, 139))),
    raw=skirt("#5B2A6E", "#47205A") + f'<path d="M32 199 Q110 209 188 199" fill="none" stroke="{MARI}" stroke-width="4"/>', face=CALAVERA,
    top=f'<path d="M140 30 Q170 4 178 20 Q168 22 150 38 Z" fill="#5B2A6E"/><path d="M84 44 Q86 14 110 14 Q134 14 136 44 Z" fill="{BLK}" {OL}/><ellipse cx="110" cy="46" rx="84" ry="13" fill="{BLK}" {OL}/>'
        + "".join(flower(x, y, 9, MARI, "#F6C445") for x, y in ((70, 41), (92, 35), (128, 35), (150, 41))))
C["catrin"] = dict(body_fill=BLK, body_stroke=DS, cloth=shirtv() + '<path d="M110 144 L96 137 L96 151 Z M110 144 L124 137 L124 151 Z" fill="#5B2A6E"/><circle cx="110" cy="144" r="3.5" fill="#47205A"/>' + flower(142, 152, 6, MARI, "#F6C445") + dots([(110, 170), (110, 182)], 2.6, SILVER),
    face=CALAVERA, top=f'<rect x="80" y="4" width="60" height="40" rx="4" fill="{BLK}" {OL}/><rect x="80" y="30" width="60" height="8" fill="#5B2A6E"/><ellipse cx="110" cy="46" rx="52" ry="8" fill="{BLK}" {OL}/>' + flower(130, 34, 7, MARI, "#F6C445"),
    hand=f'<path d="M186 182 L186 126" stroke="{WOOD}" stroke-width="4" stroke-linecap="round"/><circle cx="186" cy="122" r="5.5" fill="{GOLD}"/>' + paw(178, 152))
C["luchador"] = dict(cheeks=False, back='<path d="M52 110 Q18 150 26 200 L194 200 Q202 150 168 110 Z" fill="#C62B35"/>', cloth=band(160, 32, BLU) + band(154, 10, GOLD),
    raw=f'<ellipse cx="110" cy="159" rx="17" ry="10" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="2"/><circle cx="110" cy="159" r="4" fill="{RED}"/>',
    face=f'<path d="{MASK}" fill="{BLU}" fill-rule="evenodd"/><ellipse cx="78" cy="75" rx="12" ry="6.5" fill="none" stroke="{GOLD}" stroke-width="2.5"/><ellipse cx="142" cy="75" rx="12" ry="6.5" fill="none" stroke="{GOLD}" stroke-width="2.5"/>'
         f'<rect x="70" y="82" width="80" height="50" rx="15" fill="none" stroke="{GOLD}" stroke-width="2.5"/>' + star(110, 56, 1, GOLD))
HALO = f'<ellipse cx="110" cy="86" rx="68" ry="60" fill="#fff" {WL}/>' + "".join(f'<circle cx="{110+72*math.cos(math.radians(a)):.1f}" cy="{86+63*math.sin(math.radians(a)):.1f}" r="12" fill="#fff" {WL}/>' for a in range(0, 360, 18))
C["tehuana"] = dict(body_fill=BLK, body_stroke=DS, feet=False, mood="happy", hood=HALO,
    cloth=flower(66, 146, 8, "#E0457B") + flower(154, 146, 8, "#F6C445", "#F28C28") + flower(84, 140, 6, RED) + flower(136, 140, 6, MARI) + f'<path d="M96 136 Q110 150 124 136" fill="none" stroke="{GOLD}" stroke-width="2.5"/>',
    raw=skirt("#8E1F2F", "#741828") + flower(80, 176, 8, "#E0457B") + flower(140, 176, 8, "#F6C445", "#F28C28") + flower(110, 184, 8, MARI) + '<path d="M31 197 Q110 207 189 197" fill="none" stroke="#fff" stroke-width="9"/>',
    top=hoodcap("#3A2A1A") + flower(92, 41, 7, RED) + flower(110, 36, 8, "#E0457B") + flower(128, 41, 7, "#F6C445", "#F28C28"))
# Asia
C["japan"] = dict(body_fill="#F7A8C4", mood="happy", cloth=vcollar("#fff", 5) + '<path d="M89 131 L118 172" stroke="#E07BA0" stroke-width="3"/>' + dots([(60, 146), (160, 148), (72, 184), (150, 186)], 3, "#fff") + band(158, 20, "#C62B35") + band(166, 4, GOLD),
    top='<g transform="translate(152,46)">' + "".join(f'<ellipse cx="0" cy="-6.5" rx="4.4" ry="6.2" fill="#fff" transform="rotate({a})"/>' for a in range(0, 360, 72)) + f'<circle r="3.2" fill="{GOLD}"/></g>',
    hand=f'<path d="M186 148 L186 168" stroke="{WOOD}" stroke-width="4" stroke-linecap="round"/><circle cx="186" cy="132" r="16" fill="#fff" {WL}/><circle cx="186" cy="132" r="6" fill="{RED}"/>' + paw(178, 160))
C["china"] = dict(body_fill="#C62B35", mood="happy", cloth=f'<path d="M95 132 L110 145 L125 132" fill="none" stroke="{GOLD}" stroke-width="5" stroke-linejoin="round"/>'
          + "".join(f'<path d="M100 {y} L120 {y}" stroke="{GOLD}" stroke-width="3" stroke-linecap="round"/><circle cx="110" cy="{y}" r="3" fill="{GOLD}"/>' for y in (154, 167, 180)) + band(187, 5, GOLD),
    hand=f'<path d="M172 162 L186 112 L186 122" fill="none" stroke="{WOOD}" stroke-width="3" stroke-linecap="round"/><rect x="172" y="122" width="28" height="30" rx="12" fill="{RED}" stroke="{GOLD_D}" stroke-width="1.5"/>'
         f'<rect x="178" y="119" width="16" height="5" rx="2" fill="{GOLD}"/><rect x="178" y="150" width="16" height="5" rx="2" fill="{GOLD}"/><path d="M186 155 L186 168" stroke="{GOLD}" stroke-width="3" stroke-linecap="round"/>' + paw(171, 160))
C["vietnam"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth=vcollar("#CFCFD6", 3) + '<path d="M70 150 L62 192 M150 150 L158 192" stroke="#CFCFD6" stroke-width="2"/>' + flower(134, 154, 6, "#F7A8C4"),
    top='<path d="M30 58 L110 6 L190 58 Q110 72 30 58 Z" fill="#E8D5A3" stroke="#C9B37A" stroke-width="1.5" stroke-linejoin="round"/><path d="M110 6 L70 62 M110 6 L110 65 M110 6 L150 62" stroke="#C9B37A" stroke-width="1.2"/>')
C["thailand"] = dict(body_fill=CRM, cloth=band(166, 26, "#6A3D9A") + band(160, 6, GOLD_D) + f'<path d="M60 130 L100 130 L150 192 L104 192 Z" fill="{GOLD}"/>' + dots([(92, 144), (106, 160), (120, 176)], 2.6, GOLD_D) + band(186, 3, GOLD),
    top=f'<path d="M60 58 L50 38 L68 46 Z M160 58 L170 38 L152 46 Z" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1.2" stroke-linejoin="round"/><path d="M104 28 L110 2 L116 28 Z" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1.2" stroke-linejoin="round"/>'
        f'<path d="M90 46 L95 26 Q110 20 125 26 L130 46 Z" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1.2" stroke-linejoin="round"/>' + dots([(110, 36)], 3.5, RED))
C["india"] = dict(body_fill="#C2185B", mood="happy", cloth=band(184, 8, GOLD) + f'<path d="M178 120 L140 120 L64 192 L104 192 Z" fill="#17A2A2"/><path d="M140 120 L64 192" stroke="{GOLD}" stroke-width="4"/><path d="M94 135 Q110 152 126 135" fill="none" stroke="{GOLD}" stroke-width="3"/>',
    top=hoodcap(INK, OL) + f'<path d="M110 42 L110 50" stroke="{GOLD}" stroke-width="2"/><circle cx="110" cy="53" r="3.5" fill="{GOLD}"/>' + dots([(54, 114), (166, 114)], 4.5, GOLD))
C["philippines"] = dict(body_fill="#F5EBD0", body_stroke="#D8CBA6", mood="happy",
    cloth='<path d="M96 132 L110 146 L124 132" fill="none" stroke="#D8CBA6" stroke-width="4" stroke-linejoin="round"/><rect x="98" y="146" width="24" height="46" fill="none" stroke="#C9B37A" stroke-width="1.5"/>'
          + "".join(f'<path d="M110 {y-5} l6 5 -6 5 -6 -5 z" fill="none" stroke="#C9B37A" stroke-width="1.5"/>' for y in (155, 167, 179)) + band(184, 8, INK),
    raw="".join(f'<circle cx="{x}" cy="{y}" r="4" fill="#fff" {WL}/>' for x, y in ((88, 138), (96, 145), (105, 150), (115, 150), (124, 145), (132, 138))))
C["indonesia"] = dict(body_fill="#7A4E2D", mood="happy", cloth=vcollar(CRM, 4) + "".join(f'<path d="M{x} {y} q5 -7 10 0 q-5 7 -10 0z" fill="#D9A441"/>' for y in (146, 160, 174, 188) for x in range(46 + (8 if (y // 14) % 2 else 0), 176, 20)) + dots([(110, 164), (110, 178)], 2.6, CRM),
    top='<path d="M60 58 Q60 24 110 22 Q160 24 160 58 Q110 42 60 58 Z" fill="#5A3A22"/><circle cx="162" cy="50" r="7" fill="#5A3A22"/>' + dots([(84, 42), (100, 36), (120, 36), (136, 42)], 2.4, "#D9A441"))
C["mongolia"] = dict(body_fill=BLU, cloth=f'<path d="M92 132 L110 148 L132 132" fill="none" stroke="{GOLD}" stroke-width="5" stroke-linejoin="round"/><path d="M110 148 Q140 150 150 166" fill="none" stroke="{GOLD}" stroke-width="3"/>' + band(164, 10, "#F28C28") + band(186, 6, GOLD),
    top=f'<path d="M76 46 Q110 30 144 46 L110 6 Z" fill="{RED}"/><path d="M62 58 Q110 40 158 58 L158 46 Q110 28 62 46 Z" fill="#5A3A22"/><circle cx="110" cy="8" r="4.5" fill="{GOLD}"/>')
# Europe
C["scotland"] = dict(body_fill=BLK, body_stroke=DS, cloth=shirtv() + band(164, 28, "#2E6B4F") + "".join(f'<path d="M{x} 164 L{x} 192" stroke="#C62B35" stroke-width="2"/>' for x in range(50, 178, 16)) + '<path d="M42 174 L178 174 M42 184 L178 184" stroke="#F6C445" stroke-width="1.5"/>',
    raw='<path d="M100 166 Q110 162 120 166 L118 182 Q110 188 102 182 Z" fill="#E8E2D0" stroke="#8A8F98" stroke-width="1.5"/>' + dots([(105, 176), (110, 178), (115, 176)], 1.8, "#8A8F98"),
    top=f'<ellipse cx="110" cy="40" rx="50" ry="14" fill="#2E6B4F"/><rect x="66" y="44" width="88" height="8" rx="4" fill="{BLK}"/><circle cx="110" cy="26" r="7" fill="{RED}"/>')
C["uk"] = dict(body_fill="#C62B35", cloth=vcollar(BLK, 6) + dots([(110, 162), (110, 180)], 3.2, GOLD) + band(166, 8, "#fff") + band(186, 6, BLK), raw=f'<rect x="103" y="165" width="14" height="10" rx="2" fill="{GOLD}"/>',
    top=f'<rect x="68" y="2" width="84" height="56" rx="34" fill="{BLK}" {OL}/>')
C["netherlands"] = dict(body_fill="#3D5A98", mood="happy", feet_fill=GOLD, feet_stroke=GOLD_D,
    cloth='<path d="M84 140 L136 140 L142 192 L78 192 Z" fill="#fff"/>' + "".join(f'<path d="M{x} 140 L{x} 192" stroke="#8FB3E8" stroke-width="3"/>' for x in (92, 104, 116, 128)), raw=kerchief(RED),
    top=f'<path d="M62 60 L40 40 L72 46 Z M158 60 L180 40 L148 46 Z" fill="#fff" {WL}/><path d="M102 24 L110 8 L118 24 Z" fill="#fff" {WL}/><path d="M66 56 Q64 22 110 20 Q156 22 154 56 Q110 40 66 56 Z" fill="#fff" {WL}/>',
    hand=f'<path d="M186 168 L186 128" stroke="#3BB273" stroke-width="3.5" stroke-linecap="round"/><path d="M176 126 Q176 108 181 114 Q186 104 191 114 Q196 108 196 126 Q186 134 176 126 Z" fill="{RED}"/>' + paw(177, 158))
LEDER = "#7A4E2D"
C["germany"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth=band(162, 30, LEDER) + f'<path d="M78 134 L84 164 M142 134 L136 164" stroke="{LEDER}" stroke-width="8"/><rect x="80" y="146" width="60" height="9" rx="3" fill="{LEDER}"/><circle cx="110" cy="150.5" r="3" fill="#fff"/>',
    top=f'<path d="M138 36 Q156 8 164 18 Q156 22 146 40 Z" fill="#fff" {WL}/>' + brimhat("#2E6B4F", "#24553F", 50) + '<path d="M82 38 Q110 44 138 38" fill="none" stroke="#C62B35" stroke-width="4"/>',
    hand='<path transform="translate(188,146)" d="M-12 6 Q-18 -12 0 -10 Q18 -12 12 6 Q8 14 0 4 Q-8 14 -12 6 Z" fill="none" stroke="#B5762B" stroke-width="5" stroke-linejoin="round"/>' + paw(174, 158))
C["france"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth=hstripes(NAVY), raw=kerchief(RED),
    top=f'<path d="M112 22 L115 12" stroke="{BLK}" stroke-width="3.5" stroke-linecap="round"/><path d="M58 54 Q60 20 112 22 Q166 26 160 56 Q110 38 58 54 Z" fill="{BLK}" {OL}/>',
    hand='<g transform="translate(188,140) rotate(20)"><rect x="-7" y="-40" width="14" height="80" rx="7" fill="#E0A85A" stroke="#B5762B" stroke-width="1.5"/><path d="M-4 -24 L4 -18 M-4 -8 L4 -2 M-4 8 L4 14" stroke="#B5762B" stroke-width="2" stroke-linecap="round"/></g>' + paw(176, 156))
C["spain"] = dict(body_fill="#C62B35", mood="happy", feet=False, cloth=dots([(60, 146), (160, 146), (76, 138), (144, 138)], 3.5, BLK),
    raw=skirt("#C62B35", "#A51F2B") + dots([(70, 170), (96, 178), (124, 178), (150, 170), (58, 190), (84, 196), (136, 196), (162, 190), (110, 164)], 3.5, BLK) + f'<path d="M31 199 Q110 209 189 199" fill="none" stroke="{BLK}" stroke-width="5"/>',
    top=f'<path d="M96 44 Q110 18 124 44 Z" fill="{BLK}" {OL}/>' + hoodcap(INK, OL) + f'<circle cx="152" cy="46" r="9" fill="{RED}"/><path d="M148 46 a4 4 0 1 1 4 4" fill="none" stroke="#A51F2B" stroke-width="2"/>',
    hand=fan(RED, GOLD_D) + paw(177, 156))
C["italy"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth=hstripes("#C62B35") + band(184, 8, NAVY),
    top=f'<rect x="76" y="22" width="68" height="24" rx="4" fill="#F0DFA8" stroke="#C9B37A" stroke-width="1.5"/><rect x="76" y="34" width="68" height="8" fill="{RED}"/><ellipse cx="110" cy="47" rx="56" ry="8" fill="#F0DFA8" stroke="#C9B37A" stroke-width="1.5"/>',
    hand=f'<path d="M170 128 L204 136 L180 166 Z" fill="{GOLD}" stroke="#C98A2B" stroke-width="3" stroke-linejoin="round"/>' + dots([(184, 140), (187, 151)], 3.5, RED) + paw(173, 160))
LEAF = "".join(f'<ellipse cx="{x}" cy="{y}" rx="9" ry="4.2" fill="#5BAA5B" transform="rotate({a} {x} {y})"/>' for x, y, a in ((64, 58, -62), (70, 46, -44), (82, 37, -24), (97, 32, -8), (156, 58, 62), (150, 46, 44), (138, 37, 24), (123, 32, 8)))
C["greece"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth='<path d="M60 134 Q100 160 150 192 M80 134 Q110 156 170 180 M100 134 Q120 148 178 160" fill="none" stroke="#CFCFD6" stroke-width="2"/>' + band(184, 8, "#3D7EC9") + dots([(72, 141)], 6, GOLD), top=LEAF)
# East Europe, Middle East, Africa
C["russia"] = dict(body_fill="#C62B35", mood="happy", cloth=sleeves("#fff") + f'<rect x="102" y="134" width="16" height="58" fill="{GOLD}"/>' + dots([(110, 146), (110, 160), (110, 174)], 3, "#C62B35") + band(184, 8, GOLD),
    top=f'<path d="M58 60 Q56 6 110 6 Q164 6 162 60 Q110 30 58 60 Z" fill="{RED}" stroke="{GOLD}" stroke-width="2.5"/>' + dots([(110, 22)], 5, GOLD) + dots([(90, 28), (130, 28)], 3.5, GOLD) + dots([(78.8, 50.4), (94.4, 46.4), (110, 45), (125.6, 46.4), (141.2, 50.4)], 2.6, "#fff"))
VINOK = (RED, "#F6C445", "#4FA3D9")
C["ukraine"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth=vcollar(RED, 4) + "".join(f'<path d="M110 {y-5} l5 5 -5 5 -5 -5 z" fill="{RED}"/><circle cx="110" cy="{y+7}" r="1.6" fill="{BLK}"/>' for y in (160, 174))
          + f'<rect x="42" y="150" width="14" height="6" fill="{RED}"/><rect x="164" y="150" width="14" height="6" fill="{RED}"/>' + band(184, 8, "#C62B35"),
    top='<path d="M62 56 L52 110" stroke="#4FA3D9" stroke-width="5" stroke-linecap="round"/><path d="M68 60 L60 114" stroke="#F6C445" stroke-width="5" stroke-linecap="round"/><path d="M158 56 L168 110" stroke="#E63946" stroke-width="5" stroke-linecap="round"/><path d="M152 60 L160 114" stroke="#3BB273" stroke-width="5" stroke-linecap="round"/>' + crownarc(VINOK))
C["sweden"] = dict(body_fill=BLU, mood="happy", cloth=sleeves("#fff") + '<path d="M88 150 L132 150 L138 192 L82 192 Z" fill="#F6C445"/><path d="M98 134 L122 146 M122 134 L98 146" stroke="#F6C445" stroke-width="2"/>',
    top='<path d="M62 56 Q110 22 158 56" fill="none" stroke="#5BAA5B" stroke-width="7" stroke-linecap="round"/>' + crownarc(("#fff", "#F6C445", "#F7A8C4", "#8FB3E8"), 6.5))
NEMES = f'<path d="M34 146 L50 48 Q110 8 170 48 L186 146 Z" fill="{GOLD}"/>' + "".join(f'<path d="M{50-(y-48)*16/98:.1f} {y} L{170+(y-48)*16/98:.1f} {y}" stroke="{BLU}" stroke-width="5"/>' for y in range(60, 146, 12))
C["egypt"] = dict(body_fill=W, body_stroke=WS, hood=NEMES,
    cloth=f'<path d="M70 132 Q110 176 150 132" fill="none" stroke="{GOLD}" stroke-width="7"/><path d="M78 132 Q110 164 142 132" fill="none" stroke="{BLU}" stroke-width="6"/><path d="M86 132 Q110 153 134 132" fill="none" stroke="#C62B35" stroke-width="5"/>'
          + band(170, 6, GOLD) + f'<rect x="102" y="170" width="16" height="22" fill="{BLU}"/><path d="M102 180 L118 180" stroke="{GOLD}" stroke-width="2"/>',
    top=hoodcap(GOLD) + f'<path d="M72 52 Q110 40 148 52" fill="none" stroke="{BLU}" stroke-width="3"/><circle cx="110" cy="45" r="4" fill="{BLU}"/>')
C["morocco"] = dict(body_fill="#17A2A2", mood="happy", feet_fill=GOLD, feet_stroke=GOLD_D, cloth=f'<path d="M110 150 L110 192" stroke="{GOLD}" stroke-width="5"/><path d="M96 132 L110 152 L124 132" fill="none" stroke="{GOLD}" stroke-width="4" stroke-linejoin="round"/>' + dots([(110, 162), (110, 174), (110, 186)], 2.4, "#128686"),
    top=f'<path d="M88 46 L94 16 L126 16 L132 46 Z" fill="#C62B35"/><ellipse cx="110" cy="16" rx="16" ry="4" fill="#A51F2B"/><path d="M110 16 Q128 14 132 34" fill="none" stroke="{BLK}" stroke-width="2.5"/><rect x="129" y="32" width="6" height="12" rx="2" fill="{BLK}"/>',
    hand='<path d="M198 146 q12 -2 10 -14" fill="none" stroke="#8A8F98" stroke-width="3.5" stroke-linecap="round"/><path d="M180 140 L186 128 L192 140 Z" fill="#C9CDD6" stroke="#8A8F98" stroke-width="1.5" stroke-linejoin="round"/><ellipse cx="186" cy="150" rx="14" ry="12" fill="#C9CDD6" stroke="#8A8F98" stroke-width="1.5"/>' + paw(173, 157))
AGB = "#2A4FB5"
C["nigeria"] = dict(body_fill=AGB, mood="happy", raw=f'<path d="M52 128 Q110 120 168 128 L200 188 Q110 204 20 188 Z" fill="{AGB}"/><path d="M98 134 L110 160 L122 134" fill="none" stroke="{GOLD}" stroke-width="4" stroke-linejoin="round"/>'
        f'<circle cx="110" cy="168" r="6" fill="none" stroke="{GOLD}" stroke-width="3"/><path d="M110 174 L110 190" stroke="{GOLD}" stroke-width="3"/>',
    top=f'<path d="M62 56 Q58 20 104 18 Q150 14 168 34 Q150 36 158 56 Q110 40 62 56 Z" fill="{AGB}"/><path d="M76 40 Q110 26 150 30" fill="none" stroke="{GOLD}" stroke-width="3"/>')
KENTE = (GOLD, GRN, "#C62B35", BLK)
C["ghana"] = dict(body_fill=GOLD, mood="happy", cloth="".join(f'<rect x="{x}" y="{y}" width="17" height="12" fill="{KENTE[(i + j) % 4]}"/>' for j, y in enumerate(range(132, 192, 12)) for i, x in enumerate(range(42, 178, 17))),
    top=f'<path d="M66 54 Q66 22 110 22 Q154 22 154 54 Q110 40 66 54 Z" fill="{BLK}" {OL}/><path d="M74 44 Q110 30 146 44" fill="none" stroke="{GOLD}" stroke-width="4"/><path d="M80 36 Q110 24 140 36" fill="none" stroke="{GRN}" stroke-width="3"/>')
SHUKA = "#1E2A78"
C["kenya"] = dict(body_fill="#C62B35", mood="happy", cloth="".join(f'<path d="M{x} 98 L{x} 192" stroke="{SHUKA}" stroke-width="4"/>' for x in range(52, 178, 22)) + "".join(f'<path d="M42 {y} L178 {y}" stroke="{SHUKA}" stroke-width="4"/>' for y in (160, 180)),
    raw=f'<ellipse cx="110" cy="138" rx="44" ry="16" fill="#fff" stroke="{BLU}" stroke-width="3"/><ellipse cx="110" cy="138" rx="35" ry="12" fill="{RED}"/><ellipse cx="110" cy="138" rx="26" ry="8.5" fill="#F6C445"/><ellipse cx="110" cy="138" rx="17" ry="5" fill="{BLU}"/>',
    top='<path d="M60 58 Q110 40 160 58" fill="none" stroke="#fff" stroke-width="7" stroke-linecap="round"/>' + dots([(76, 52), (110, 49), (144, 52)], 3, RED) + dots([(93, 50), (127, 50)], 3, BLU))
# Americas
HATB, HATS = "#B5835A", "#8B5E3C"
C["usa"] = dict(body_fill="#4FA3D9", mood="happy", cloth=f'<path d="M42 98 L92 98 L84 192 L42 192 Z M178 98 L128 98 L136 192 L178 192 Z" fill="{HATS}"/>' + star(152, 152, 0.9) + band(176, 7, "#5A3A22"),
    raw=f'<rect x="102" y="174" width="16" height="11" rx="2" fill="{GOLD}"/><path d="M90 133 Q110 146 130 133 L110 160 Z" fill="{RED}"/>',
    top=f'<path d="M78 46 Q76 18 96 14 Q110 22 124 14 Q144 18 142 46 Z" fill="{HATB}" stroke="{HATS}" stroke-width="1.5"/><path d="M30 40 Q60 62 110 50 Q160 62 190 40 Q170 60 110 59 Q50 60 30 40 Z" fill="{HATB}" stroke="{HATS}" stroke-width="1.5" stroke-linejoin="round"/>'
        '<path d="M80 40 Q110 48 140 40" fill="none" stroke="#5A3A22" stroke-width="4"/>')
C["canada"] = dict(body_fill="#C62B35", cloth=vcollar("#1E2A56", 6) + dots([(110, 162)], 3.2, GOLD) + '<path d="M64 134 L150 174" stroke="#7A4E2D" stroke-width="7"/>' + band(170, 8, "#7A4E2D") + band(184, 8, "#1E2A56"),
    top='<path d="M84 44 L92 18 Q110 8 128 18 L136 44 Z" fill="#B58B5A" stroke="#8B6A3C" stroke-width="1.5" stroke-linejoin="round"/><ellipse cx="110" cy="46" rx="70" ry="9" fill="#B58B5A" stroke="#8B6A3C" stroke-width="1.5"/><path d="M87 37 Q110 44 133 37" fill="none" stroke="#5A3A22" stroke-width="4"/>')
C["brazil"] = dict(body_fill="#F6D21E", mood="happy", cloth=vcollar("#1E8E3E", 6) + f'<rect x="42" y="150" width="12" height="6" fill="#1E8E3E"/><rect x="166" y="150" width="12" height="6" fill="#1E8E3E"/>' + band(174, 18, AGB),
    face='<path d="M55 96 L67 96 M153 96 L165 96" stroke="#1E8E3E" stroke-width="3.5" stroke-linecap="round"/><path d="M55 103 L67 103 M153 103 L165 103" stroke="#F6D21E" stroke-width="3.5" stroke-linecap="round"/>',
    hand=ball() + paw(175, 158))
C["argentina"] = dict(body_fill=W, body_stroke=WS, raw=f'<path d="{PONCHO}" fill="#8E1F2F"/><path d="M52 163 L110 181 L168 163" fill="none" stroke="{BLK}" stroke-width="5"/><path d="M56 153 L110 169 L164 153" fill="none" stroke="{CRM}" stroke-width="3"/>',
    top=f'<rect x="82" y="22" width="56" height="24" rx="6" fill="{BLK}" {OL}/><ellipse cx="110" cy="47" rx="62" ry="8" fill="{BLK}" {OL}/>',
    hand='<path d="M188 144 L198 120" stroke="#C9CDD6" stroke-width="3" stroke-linecap="round"/><path d="M176 146 Q174 166 186 168 Q198 166 196 146 Z" fill="#7A4E2D"/><rect x="175" y="142" width="22" height="6" rx="3" fill="#C9CDD6"/>' + paw(174, 160))
C["peru"] = dict(body_fill="#C62B35", mood="happy", raw=f'<path d="{PONCHO}" fill="#C62B35"/><path d="M52 163 L110 181 L168 163" fill="none" stroke="#F6C445" stroke-width="5"/><path d="M56 153 L110 169 L164 153" fill="none" stroke="#17A2A2" stroke-width="4"/><path d="M60 143 L110 157 L160 143" fill="none" stroke="#E0457B" stroke-width="3"/>',
    top='<path d="M60 56 L50 100 L72 92 L74 54 Z M160 56 L170 100 L148 92 L146 54 Z" fill="#C62B35"/><path d="M58 98 L54 124 M162 98 L166 124" stroke="#F6C445" stroke-width="3"/>' + dots([(54, 128), (166, 128), (110, 14)], 6, "#F6C445")
        + '<path d="M62 60 Q60 18 110 16 Q160 18 158 60 Q110 42 62 60 Z" fill="#C62B35"/><path d="M70 46 l8 -7 8 7 8 -7 8 7 8 -7 8 7 8 -7 8 7 8 -7 8 7" fill="none" stroke="#fff" stroke-width="2.5" stroke-linejoin="round"/>' + dots([(90, 30), (110, 26), (130, 30)], 3, "#17A2A2"))
VUEL = "#F0E6C8"
C["colombia"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth=band(178, 14, CRM), raw=kerchief(RED),
    top=f'<path d="M82 46 Q84 16 110 16 Q136 16 138 46 Z" fill="{VUEL}" stroke="{BLK}" stroke-width="1.5"/><path d="M86 30 Q110 36 134 30 M84 39 Q110 45 136 39" fill="none" stroke="{BLK}" stroke-width="2.5"/>'
        f'<ellipse cx="110" cy="47" rx="72" ry="11" fill="{VUEL}" stroke="{BLK}" stroke-width="1.5"/><ellipse cx="110" cy="47" rx="60" ry="7.5" fill="none" stroke="{BLK}" stroke-width="3" stroke-dasharray="6 5"/>',
    hand=f'<path d="M180 134 q-4 -6 0 -12 M190 134 q4 -6 0 -12" fill="none" stroke="#B8BCC4" stroke-width="2.5" stroke-linecap="round"/><path d="M172 140 L198 140 L195 160 Q185 166 175 160 Z" fill="#fff" {WL}/><ellipse cx="185" cy="140" rx="13" ry="3.5" fill="#6B4226"/>' + paw(173, 158))

TL = {"chef": ("Chef", "tall hat, ladle"), "barista": ("Barista", "apron, latte"), "rider": ("Delivery rider", "helmet, delivery box"), "doctor": ("Doctor", "white coat, red pen"),
      "tteok": ("Tteokbokki stall", "apron, cup of rice cakes"), "kimbap": ("Kimbap", "seaweed roll costume"), "chicken": ("Fried chicken", "striped shirt, drumstick"), "bibimbap": ("Bibimbap", "stone bowl, spoon"),
      "baseball": ("Baseball fan", "cap, cheering sticks"), "archer": ("Archer", "bucket hat, bow"), "football": ("Football fan", "red shirt, scarf, ball"), "esports": ("Esports", "headset, team jersey"),
      "chuseok": ("Chuseok", "full moon, songpyeon"), "christmas": ("Christmas", "Santa hat, gift"), "birthday": ("Birthday", "party hat, cake"), "hangul": ("Hangul Day", "letter shirt, red brush"),
      "magpie": ("Magpie", "good-news bird suit"), "haetae": ("Haetae", "guardian beast suit"), "bear": ("Bear", "founding-myth bear, garlic"), "rabbit": ("Moon rabbit", "rice-cake mallet")}
TSEC = [("Jobs", ["chef", "barista", "rider", "doctor"]), ("Korean food", ["tteok", "kimbap", "chicken", "bibimbap"]), ("Sports", ["baseball", "archer", "football", "esports"]),
        ("Holidays", ["chuseok", "christmas", "birthday", "hangul"]), ("Folklore", ["magpie", "haetae", "bear", "rabbit"])]
CL = {"mariachi": ("Mariachi", "charro suit, sombrero, guitar"), "folklorico": ("Folklorico", "Jalisco ribbon dress"), "catrina": ("Catrina", "Day of the Dead"), "catrin": ("Catrin", "Day of the Dead"),
      "luchador": ("Luchador", "mask, cape, title belt"), "tehuana": ("Tehuana", "flower huipil, lace halo"),
      "japan": ("Japan", "kimono, fan"), "china": ("China", "tang suit, lantern"), "vietnam": ("Vietnam", "ao dai, conical hat"), "thailand": ("Thailand", "chut thai, gold crown"),
      "india": ("India", "sari"), "philippines": ("Philippines", "barong, sampaguita"), "indonesia": ("Indonesia", "batik, blangkon"), "mongolia": ("Mongolia", "deel, pointed hat"),
      "scotland": ("Scotland", "kilt, tam"), "uk": ("United Kingdom", "royal guard"), "netherlands": ("Netherlands", "cap, clogs, tulip"), "germany": ("Germany", "lederhosen, pretzel"),
      "france": ("France", "stripes, beret, baguette"), "spain": ("Spain", "flamenco dress, fan"), "italy": ("Italy", "gondolier, pizza"), "greece": ("Greece", "chiton, laurel wreath"),
      "russia": ("Russia", "sarafan, kokoshnik"), "ukraine": ("Ukraine", "vyshyvanka, flower crown"), "sweden": ("Sweden", "folk dress, midsummer crown"), "egypt": ("Egypt", "pharaoh costume"),
      "morocco": ("Morocco", "djellaba, fez, mint tea"), "nigeria": ("Nigeria", "agbada, fila cap"), "ghana": ("Ghana", "kente cloth"), "kenya": ("Kenya", "Maasai shuka, bead collar"),
      "usa": ("United States", "cowboy"), "canada": ("Canada", "Mountie"), "brazil": ("Brazil", "football kit"), "argentina": ("Argentina", "gaucho, mate"), "peru": ("Peru", "poncho, chullo"), "colombia": ("Colombia", "sombrero vueltiao, coffee")}
CSEC = [("Mexico", ["mariachi", "folklorico", "catrina", "catrin", "luchador", "tehuana"]), ("Asia", ["japan", "china", "vietnam", "thailand", "india", "philippines", "indonesia", "mongolia"]),
        ("Europe", ["scotland", "uk", "netherlands", "germany", "france", "spain", "italy", "greece"]), ("Europe, Middle East and Africa", ["russia", "ukraine", "sweden", "egypt", "morocco", "nigeria", "ghana", "kenya"]),
        ("Americas", ["usa", "canada", "brazil", "argentina", "peru", "colombia"])]
STAGES = [("tiny", "Sprout"), ("baby", "Baby"), ("kid", "Kinder"), ("young", "Young"), ("teen", "Student"), ("adult", "Adult")]

CSS = '''body{margin:0;font-family:Arial,Helvetica,sans-serif;background:#fff}
h1{font-size:20px;margin:0;padding:22px 32px 4px;color:#1c1c1e} .sub{padding:0 32px 14px;color:#6b7280;font-size:14px}
h2{font-size:14px;margin:0;padding:18px 32px 0;color:#6b7280;background:#F6F5F2;text-transform:uppercase;letter-spacing:.06em} h2.dk{background:#1C1C1E;color:#9aa0a6}
.grid{display:flex;flex-wrap:wrap;gap:8px;padding:14px 24px 22px;background:#F6F5F2} .grid.dark{background:#1C1C1E} .grid.six{gap:2px;padding-bottom:8px}
.cell{width:220px;text-align:center} .cell.s{width:150px} .t{font-weight:700;font-size:15px;color:#1c1c1e;margin-top:6px} .d{font-size:13px;color:#6b7280;margin-top:2px}
.dark .t{color:#f2f2f7} .dark .d{color:#9aa0a6}'''
def cells(src, lab, keys): return "".join(f'<div class="cell">{fig(src[k])}<div class="t">{lab[k][0]}</div><div class="d">{lab[k][1]}</div></div>' for k in keys)
def sec(src, lab, title, keys, dark=False): return f'<h2 class="{"dk" if dark else ""}">{title}</h2><div class="grid {"dark" if dark else ""}">{cells(src, lab, keys)}</div>'
def strip(o): return '<div class="grid six">' + "".join(f'<div class="cell s">{fig(o, s, 150)}<div class="t">{n}</div></div>' for s, n in STAGES) + '</div>'

themes = f'''<!doctype html><meta charset="utf-8"><style>{CSS}</style><div id="sheet" style="width:960px">
<div id="p1"><h1>Gochi themes, batch 2 (drawn in code)</h1><div class="sub">20 outfits: jobs, Korean food, sports, holidays and folklore.</div>{"".join(sec(T, TL, t, k) for t, k in TSEC[:3])}</div>
<div id="p2">{"".join(sec(T, TL, t, k) for t, k in TSEC[3:])}{sec(T, TL, "Dark mode check", ["kimbap", "esports", "magpie", "rabbit"], True)}</div></div>'''
world = f'''<!doctype html><meta charset="utf-8"><style>{CSS}</style><div id="sheet" style="width:960px">
<div id="p1"><h1>Gochi around the world, batch 1 (drawn in code)</h1><div class="sub">36 outfits from 31 countries, with six from Mexico. Two are shown on every growth size.</div>
{sec(C, CL, *CSEC[0])}<h2>Growing up as a mariachi</h2>{strip(C["mariachi"])}<h2>Growing up in folklorico</h2>{strip(C["folklorico"])}</div>
<div id="p2">{sec(C, CL, *CSEC[1])}{sec(C, CL, *CSEC[2])}</div>
<div id="p3">{sec(C, CL, *CSEC[3])}{sec(C, CL, *CSEC[4])}{sec(C, CL, "Dark mode check", ["mariachi", "catrina", "uk", "greece"], True)}</div></div>'''
open("themes.html", "w").write(themes); open("world.html", "w").write(world)

async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch()
        for name, parts in (("themes", 2), ("world", 3)):
            pg = await b.new_page(viewport={"width": 960, "height": 900}, device_scale_factor=2)
            await pg.goto("file://" + os.path.abspath(name + ".html"))
            await (await pg.query_selector("#sheet")).screenshot(path=f"/home/claude/gochi-{name}.png")
            await pg.close()
            pg = await b.new_page(viewport={"width": 960, "height": 900}, device_scale_factor=1)
            await pg.goto("file://" + os.path.abspath(name + ".html"))
            for i in range(1, parts + 1): await (await pg.query_selector(f"#p{i}")).screenshot(path=f"{name}{i}.png")
            await pg.close()
        await b.close()
asyncio.run(main())
