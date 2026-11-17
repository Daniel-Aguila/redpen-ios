import asyncio, os, itertools
from playwright.async_api import async_playwright

RED, GOLD, GOLD_D, WOOD, INK = "#E63946", "#F2C14E", "#D9A21B", "#7E5236", "#2B2B2B"
BASE = dict(FUR="#C08D62", FUR_B="#B07C54", FUR_D="#7E5236", MUZ="#E6BE94")
GOLDPAL = dict(FUR="#F4C95D", FUR_B="#E6B23A", FUR_D="#B8860B", MUZ="#FFF3C9")
OL = 'stroke="#77777D" stroke-width="1.5" stroke-linejoin="round"'      # outline for black items
WL = 'stroke="#CFCFD6" stroke-width="1.5" stroke-linejoin="round"'      # outline for white items
_ids = itertools.count()

def vcollar(color, w=6):
    return f'<path d="M89 131 L110 156 L131 131" fill="none" stroke="{color}" stroke-width="{w}" stroke-linejoin="round" stroke-linecap="round"/>'
def paw(x, y, fur): return f'<ellipse cx="{x}" cy="{y}" rx="11" ry="9" fill="{fur}"/>'
def pen_up(L, w=8):
    h = w/2
    return (f'<rect x="{-h}" y="{-L}" width="{w}" height="{L}" rx="2.5" fill="{RED}"/><rect x="{-h}" y="{-L+3}" width="{w}" height="3" fill="#fff" opacity=".85"/>'
            f'<path d="M{-h} {-L} L{h} {-L} L0 {-L-9} Z" fill="#8A8F98" stroke="#8A8F98" stroke-width="1.2" stroke-linejoin="round"/>')
SKIRT = 'M58 152 Q110 144 162 152 L190 200 Q110 210 30 200 Z'
def skirt(fill, fold):
    return (f'<path d="{SKIRT}" fill="{fill}"/><path d="M84 156 L70 203 M110 154 L110 206 M136 156 L150 203" stroke="{fold}" stroke-width="2.5" stroke-linecap="round"/>')
def star(x, y, s=1, fill="#FFD166"):
    return f'<path transform="translate({x},{y}) scale({s})" d="M0 -9 L2.5 -2.5 L9 0 L2.5 2.5 L0 9 L-2.5 2.5 L-9 0 L-2.5 -2.5 Z" fill="{fill}"/>'

def gochi(back="", hood="", body_fill=None, body_stroke=None, cloth="", raw="", feet=True, hand="", face="", top="",
          mood="neutral", pal=None, cheeks=True):
    P = dict(BASE); P.update(pal or {}); FUR, FUR_B, FUR_D, MUZ = P["FUR"], P["FUR_B"], P["FUR_D"], P["MUZ"]
    n = next(_ids); s = [f'<defs><clipPath id="b{n}"><rect x="42" y="98" width="136" height="92" rx="46"/></clipPath></defs>', back]
    for ex in (68, 152): s.append(f'<ellipse cx="{ex}" cy="46" rx="8" ry="6.5" fill="{FUR_D}"/>')
    s.append(hood)
    bs = f' stroke="{body_stroke}" stroke-width="1.5"' if body_stroke else ""
    s.append(f'<rect x="42" y="98" width="136" height="92" rx="46" fill="{body_fill or FUR_B}"{bs}/>')
    s.append(f'<g clip-path="url(#b{n})">{cloth}</g>{raw}')
    if feet:
        for fx in (80, 140): s.append(f'<ellipse cx="{fx}" cy="190" rx="16" ry="7" fill="{FUR_D}"/>')
    s.append(hand.replace("@FUR", FUR))
    s.append(f'<rect x="52" y="42" width="116" height="92" rx="38" fill="{FUR}"/><rect x="70" y="82" width="80" height="50" rx="15" fill="{MUZ}"/>')
    if cheeks:
        for cx_ in (61, 159): s.append(f'<circle cx="{cx_}" cy="100" r="7" fill="#F4978E" opacity=".5"/>')
    for nx in (96, 124): s.append(f'<ellipse cx="{nx}" cy="94" rx="3.4" ry="2.4" fill="{FUR_D}"/>')
    st = f'fill="none" stroke="{INK}" stroke-width="3" stroke-linecap="round"'
    for ex in (78, 142):
        if mood == "happy": s.append(f'<path d="M{ex-6} 78 Q{ex} 69 {ex+6} 78" {st}/>')
        else: s.append(f'<circle cx="{ex}" cy="76" r="4.8" fill="{INK}"/><circle cx="{ex-1.5}" cy="74.4" r="1.6" fill="#fff"/>')
    if mood == "happy": s.append(f'<path d="M103 112 Q110 123 117 112 Z" fill="{FUR_D}" stroke="{FUR_D}" stroke-width="2" stroke-linejoin="round"/>')
    else: s.append(f'<path d="M104 114 Q110 119 116 114" fill="none" stroke="{FUR_D}" stroke-width="2.5" stroke-linecap="round"/>')
    s += [face, top]
    return '<svg viewBox="0 0 220 212" width="220" height="212" xmlns="http://www.w3.org/2000/svg" font-family="Arial, sans-serif">' + "".join(s) + '</svg>'

HEADSET = f'<path d="M166 84 Q160 117 133 117" fill="none" stroke="{INK}" stroke-width="2.6" stroke-linecap="round"/><circle cx="131" cy="117" r="4.5" fill="{INK}"/>'
def hoodcap(c): return f'<path d="M58 62 Q60 40 110 40 Q160 40 162 62 Q110 46 58 62 Z" fill="{c}"/>'
def hoodback(c): return f'<rect x="45" y="33" width="130" height="108" rx="46" fill="{c}"/>'

O = {}
O["hanbok_m"] = gochi(body_fill="#3D5A98", mood="happy",
    cloth='<rect x="42" y="168" width="136" height="24" fill="#C9CDD6"/><path d="M110 172 L110 192" stroke="#AEB3BE" stroke-width="2"/>' + vcollar("#fff")
          + '<path d="M116 150 L109 180 M116 150 L125 178" stroke="#24345F" stroke-width="6" stroke-linecap="round"/><circle cx="116" cy="150" r="4.5" fill="#24345F"/>')
O["hanbok_f"] = gochi(body_fill="#F6D55C", mood="happy", feet=False, cloth=vcollar("#fff"),
    raw=skirt("#D7263D", "#B81E33") + '<path d="M58 152 Q110 144 162 152" fill="none" stroke="#fff" stroke-width="4"/>'
        '<path d="M118 148 L110 186 M118 148 L128 184" stroke="#8E1F4F" stroke-width="6.5" stroke-linecap="round"/><circle cx="118" cy="148" r="5" fill="#8E1F4F"/>',
    top='<path d="M152 46 L136 36 L136 56 Z M152 46 L168 36 L168 56 Z" fill="#D7263D"/><circle cx="152" cy="46" r="4.5" fill="#B81E33"/>')
O["groom"] = gochi(body_fill="#2F4B8F",
    cloth=vcollar("#fff", 5) + f'<rect x="94" y="146" width="32" height="26" rx="3" fill="#1E3266" stroke="{GOLD}" stroke-width="2"/><circle cx="110" cy="159" r="6" fill="none" stroke="{GOLD}" stroke-width="2"/>'
          '<rect x="42" y="177" width="136" height="7" fill="#1B1B1B"/>' + "".join(f'<circle cx="{x}" cy="180.5" r="2.2" fill="{GOLD}"/>' for x in (66, 84, 136, 154)),
    top=f'<ellipse cx="58" cy="34" rx="22" ry="6" fill="{INK}" {OL}/><ellipse cx="162" cy="34" rx="22" ry="6" fill="{INK}" {OL}/>'
        f'<path d="M90 26 Q110 4 130 26 Z" fill="{INK}" {OL}/><path d="M78 48 Q78 20 110 20 Q142 20 142 48 Z" fill="{INK}" {OL}/>')
O["bride"] = gochi(body_fill="#2E8B57", feet=False, cheeks=False, mood="happy", cloth=vcollar("#fff", 5),
    raw=skirt("#C62B35", "#A51F2B") + '<rect x="101" y="138" width="18" height="58" rx="3" fill="#8E1F2F"/>' + "".join(f'<circle cx="110" cy="{y}" r="3" fill="{GOLD}"/>' for y in (150, 166, 182)),
    face=f'<circle cx="61" cy="100" r="6" fill="{RED}"/><circle cx="159" cy="100" r="6" fill="{RED}"/><circle cx="110" cy="61" r="4" fill="{RED}"/>',
    top=f'<rect x="95" y="24" width="30" height="22" rx="9" fill="{INK}" {OL}/><circle cx="110" cy="22" r="5" fill="{RED}"/><circle cx="101" cy="31" r="2.6" fill="{GOLD}"/><circle cx="119" cy="31" r="2.6" fill="{GOLD}"/><circle cx="110" cy="37" r="2.6" fill="#3BB273"/>')
O["queen"] = gochi(body_fill="#A3162E", mood="happy",
    cloth=vcollar(GOLD, 5) + f'<circle cx="110" cy="164" r="13" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="2"/><circle cx="110" cy="164" r="7" fill="none" stroke="{GOLD_D}" stroke-width="2"/><rect x="42" y="182" width="136" height="10" fill="{GOLD}"/>',
    top=f'<ellipse cx="54" cy="52" rx="13" ry="15" fill="{INK}" {OL}/><ellipse cx="166" cy="52" rx="13" ry="15" fill="{INK}" {OL}/><ellipse cx="110" cy="38" rx="64" ry="20" fill="{INK}" {OL}/>'
        f'<rect x="38" y="37" width="144" height="5" rx="2.5" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1"/>'
        + "".join(f'<circle cx="{x}" cy="{y}" r="6" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1"/><circle cx="{x}" cy="{y}" r="2.2" fill="{RED}"/>' for x, y in ((86, 25), (110, 20), (134, 25))))
O["general"] = gochi(body_fill="#8B1E1E",
    cloth=vcollar(GOLD, 5) + "".join(f'<circle cx="{x + (7 if i % 2 else 0)}" cy="{y}" r="2.6" fill="{GOLD}"/>' for i, y in enumerate((146, 158, 170, 182)) for x in range(50, 172, 14)),
    hand=f'<path d="M184 178 L184 108" stroke="{WOOD}" stroke-width="4" stroke-linecap="round"/><path d="M184 108 L208 118 L184 129 Z" fill="{RED}"/>' + paw(177, 156, "@FUR"),
    top=f'<rect x="54" y="46" width="15" height="40" rx="6" fill="#8B1E1E" stroke="{GOLD_D}" stroke-width="1.5"/><rect x="151" y="46" width="15" height="40" rx="6" fill="#8B1E1E" stroke="{GOLD_D}" stroke-width="1.5"/>'
        f'<path d="M68 50 Q68 13 110 13 Q152 13 152 50 Z" fill="#3A3A40" stroke="{GOLD_D}" stroke-width="2"/><rect x="64" y="44" width="92" height="9" rx="4" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1.2"/>'
        f'<circle cx="110" cy="9" r="6" fill="{RED}"/>')
O["pungmul"] = gochi(body_fill="#FAFAFA", body_stroke="#CFCFD6", mood="happy",
    cloth=f'<path d="M62 130 L150 194" stroke="{RED}" stroke-width="9"/><path d="M158 130 L70 194" stroke="#F6C445" stroke-width="9"/><rect x="42" y="168" width="136" height="8" fill="#3D5A98"/>',
    top=f'<path d="M90 46 Q90 22 110 22 Q130 22 130 46 Z" fill="{INK}" {OL}/><ellipse cx="110" cy="46" rx="48" ry="8" fill="{INK}" {OL}/>'
        '<path d="M110 20 C138 2 190 8 180 33 C172 52 198 62 208 44" fill="none" stroke="#B8BCC4" stroke-width="6.5" stroke-linecap="round"/>'
        '<path d="M110 20 C138 2 190 8 180 33 C172 52 198 62 208 44" fill="none" stroke="#fff" stroke-width="4" stroke-linecap="round"/>'
        f'<circle cx="110" cy="20" r="4.5" fill="{RED}"/>')
O["haenyeo"] = gochi(body_fill="#23262B", body_stroke="#55555C", mood="happy",
    cloth='<path d="M62 134 L58 192 M158 134 L162 192" stroke="#F77F00" stroke-width="3.5"/>',
    hand='<circle cx="186" cy="150" r="15" fill="#F77F00"/><path d="M175 141 L197 159 M175 159 L197 141 M186 135 L186 165 M171 150 L201 150" stroke="#C25E00" stroke-width="1.6"/>' + paw(176, 158, "@FUR"),
    top=f'<rect x="60" y="50" width="100" height="6" rx="3" fill="{INK}"/><rect x="80" y="42" width="60" height="23" rx="11" fill="#A8DADC" stroke="{INK}" stroke-width="3.2"/><path d="M90 50 L98 46" stroke="#fff" stroke-width="2.5" stroke-linecap="round"/>')
SHIRT_V = '<path d="M92 132 L110 160 L128 132 Z" fill="#fff"/><path d="M92 132 L110 160 L128 132" fill="none" stroke="#1B2644" stroke-width="3" stroke-linejoin="round"/>'
O["school_m"] = gochi(body_fill="#27365E",
    cloth=SHIRT_V + f'<path d="M106 138 L114 138 L116 156 L110 163 L104 156 Z" fill="{RED}"/><circle cx="110" cy="174" r="3" fill="{GOLD}"/><circle cx="138" cy="152" r="4.5" fill="{GOLD}"/><rect x="42" y="183" width="136" height="9" fill="#6B7280"/>')
O["school_f"] = gochi(body_fill="#27365E", mood="happy",
    cloth=SHIRT_V + '<rect x="42" y="168" width="136" height="24" fill="#8A3040"/>' + "".join(f'<path d="M{x} 168 L{x} 192" stroke="#6E2331" stroke-width="2"/>' for x in range(54, 172, 14))
          + '<path d="M42 181 L178 181" stroke="#B45A6A" stroke-width="1.5"/>'
          + f'<path d="M110 146 L96 138 L96 154 Z M110 146 L124 138 L124 154 Z" fill="{RED}"/><circle cx="110" cy="146" r="4" fill="#C62B35"/>',
    top='<path d="M68 52 L56 44 L56 60 Z M68 52 L80 44 L80 60 Z" fill="#FF8FB1"/><circle cx="68" cy="52" r="3.5" fill="#F06292"/>')
O["idol_m"] = gochi(body_fill="#1E1E24", body_stroke="#55555C", mood="happy",
    cloth='<path d="M94 132 L110 154 L126 132 Z" fill="#fff"/>' + f'<path d="M96 138 Q110 152 124 138" fill="none" stroke="{GOLD}" stroke-width="2.5"/>'
          + "".join(star(x, y, .55) for x, y in ((62, 150), (76, 174), (150, 148), (160, 172), (132, 182), (92, 186))),
    face=HEADSET, top='<path d="M62 62 Q66 24 110 24 Q150 24 158 56 Q132 38 104 46 Q80 52 62 62 Z" fill="#8FA0FF"/>')
O["idol_f"] = gochi(body_fill="#FF7EB6", mood="happy",
    cloth='<rect x="42" y="170" width="136" height="22" fill="#FFB3D1"/>' + "".join(star(x, y, .5, "#fff") for x, y in ((64, 152), (84, 162), (140, 150), (156, 162), (110, 160)))
          + f'<path d="M110 142 L98 135 L98 149 Z M110 142 L122 135 L122 149 Z" fill="{GOLD}"/>',
    face=HEADSET, top=f'<path d="M150 46 Q184 20 194 54 Q196 78 176 88 Q183 62 160 58 Z" fill="#FFB3D1" stroke="#FF7EB6" stroke-width="1.5"/><circle cx="153" cy="48" r="7" fill="{GOLD}"/>' + star(72, 54, .8, GOLD))
O["office"] = gochi(body_fill="#FAFAFA", body_stroke="#CFCFD6",
    cloth='<rect x="42" y="180" width="136" height="12" fill="#3B4252"/><path d="M90 132 L110 164 L130 132" fill="none" stroke="#2E8B57" stroke-width="3.2" stroke-linejoin="round"/>'
          '<rect x="101" y="160" width="18" height="22" rx="3" fill="#fff" stroke="#9AA0A6" stroke-width="1.5"/><rect x="105" y="164" width="10" height="7" rx="1.5" fill="#C08D62"/><path d="M105 176 L115 176" stroke="#9AA0A6" stroke-width="2"/>',
    hand='<path d="M186 122 L192 100" stroke="#2E8B57" stroke-width="3.5" stroke-linecap="round"/><path d="M170 126 L196 126 L192 166 L174 166 Z" fill="#6B4226"/>'
         '<rect x="176" y="134" width="7" height="7" rx="1.5" fill="#fff" opacity=".35"/><rect x="184" y="146" width="7" height="7" rx="1.5" fill="#fff" opacity=".35"/>'
         '<rect x="167" y="121" width="32" height="7" rx="3.5" fill="#E5E7EB" stroke="#B8BCC4" stroke-width="1"/>' + paw(173, 158, "@FUR"))
O["hiker"] = gochi(body_fill="#E0457B", mood="happy",
    cloth='<rect x="42" y="166" width="136" height="26" fill="#17A2A2"/><rect x="42" y="150" width="136" height="6" fill="#F6C445"/><path d="M110 134 L110 192" stroke="#fff" stroke-width="2.5"/>',
    hand=f'<path d="M185 112 L189 202" stroke="#6B7280" stroke-width="4" stroke-linecap="round"/><rect x="180" y="103" width="10" height="13" rx="4" fill="{INK}"/>' + paw(178, 150, "@FUR"),
    top=f'<rect x="64" y="48" width="92" height="8" rx="4" fill="{INK}"/><path d="M48 64 Q110 28 172 64 Q110 50 48 64 Z" fill="#6B4FBB" opacity=".92"/>')
O["jjimjilbang"] = gochi(body_fill="#F4A259", mood="happy",
    cloth='<path d="M94 134 Q110 148 126 134" fill="none" stroke="#E07B2A" stroke-width="4"/><circle cx="134" cy="156" r="5" fill="none" stroke="#E07B2A" stroke-width="2"/><path d="M42 172 L178 172" stroke="#E07B2A" stroke-width="2.5"/>',
    hand='<ellipse cx="184" cy="144" rx="9" ry="11.5" fill="#D9B48C" stroke="#A9744F" stroke-width="1.5"/>' + paw(177, 155, "@FUR"),
    top=f'<path d="M62 56 Q110 26 158 56 L158 66 Q110 40 62 66 Z" fill="#fff" {WL}/>'
        + "".join(f'<circle cx="{x}" cy="60" r="15" fill="#fff" {WL}/><path d="M{x-7} 60 a7 7 0 1 1 7 7" fill="none" stroke="#CFCFD6" stroke-width="2" stroke-linecap="round"/>' for x in (58, 162)))
O["ramyeon"] = gochi(body_fill="#9AA0A6", mood="happy",
    cloth='<path d="M100 134 L98 156 M120 134 L122 156" stroke="#fff" stroke-width="2.5" stroke-linecap="round"/>',
    hand=f'<path d="M98 160 q-4 -6 0 -11 M122 160 q4 -6 0 -11" fill="none" stroke="#E5E7EB" stroke-width="2.5" stroke-linecap="round"/>'
         f'<rect x="64" y="171" width="16" height="6" rx="3" fill="{GOLD_D}"/><rect x="140" y="171" width="16" height="6" rx="3" fill="{GOLD_D}"/>'
         f'<path d="M78 170 L142 170 L136 198 Q110 204 84 198 Z" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1.8"/>'
         '<path d="M84 169 q6 -8 12 0 q6 -8 12 0 q6 -8 12 0 q6 -8 12 0" fill="none" stroke="#F7E08A" stroke-width="4" stroke-linecap="round"/>'
         f'<path d="M178 132 L150 166 M185 137 L157 169" stroke="{WOOD}" stroke-width="3" stroke-linecap="round"/>' + paw(178, 142, "@FUR"))
O["winter"] = gochi(body_fill="#1F2430", body_stroke="#55555C", mood="happy",
    cloth='<path d="M42 148 L178 148 M42 162 L178 162 M42 176 L178 176" stroke="#3A4152" stroke-width="2.5"/><path d="M110 134 L110 192" stroke="#8A8F98" stroke-width="2"/>',
    hand='<g transform="translate(188,146) rotate(-25)"><path d="M14 0 L26 -9 L26 9 Z" fill="#D9A441" stroke="#A9741F" stroke-width="1.5" stroke-linejoin="round"/><ellipse cx="0" cy="0" rx="17" ry="10" fill="#D9A441" stroke="#A9741F" stroke-width="1.5"/>'
         '<circle cx="-9" cy="-2" r="1.8" fill="#7A4E12"/><path d="M-2 -6 Q2 0 -2 6 M5 -5 Q9 0 5 5" fill="none" stroke="#A9741F" stroke-width="1.5"/></g>' + paw(176, 158, "@FUR"),
    top=f'<path d="M62 56 Q62 16 110 16 Q158 16 158 56 Z" fill="{RED}"/><rect x="58" y="46" width="104" height="15" rx="7" fill="#C62B35"/>'
        + "".join(f'<path d="M{x} 49 L{x} 58" stroke="#A51F2B" stroke-width="2" stroke-linecap="round"/>' for x in range(70, 156, 10)) + f'<circle cx="110" cy="14" r="9" fill="#fff" {WL}/>')
O["rainy"] = gochi(body_fill="#F7C948", hood=hoodback("#F7C948"),
    back="".join(f'<path d="M{x} {y} q5 8 0 12 q-5 -4 0 -12z" fill="#4FA3D9"/>' for x, y in ((22, 58), (34, 100), (16, 134))),
    cloth="".join(f'<circle cx="110" cy="{y}" r="3" fill="{GOLD_D}"/>' for y in (146, 162, 178)),
    hand=f'<path d="M190 96 L190 104 M190 178 q0 10 9 8" fill="none" stroke="{INK}" stroke-width="3.5" stroke-linecap="round"/><path d="M190 104 L196 172 L184 172 Z" fill="#4FA3D9" stroke="#4FA3D9" stroke-width="5" stroke-linejoin="round"/><path d="M190 110 L190 170" stroke="#3B86B8" stroke-width="2"/>' + paw(180, 150, "@FUR"),
    top=hoodcap("#F7C948"))
O["taekwondo"] = gochi(body_fill="#FAFAFA", body_stroke="#CFCFD6",
    cloth=vcollar(INK, 5) + f'<rect x="42" y="164" width="136" height="8" fill="{INK}"/>',
    raw=f'<rect x="103" y="162" width="14" height="12" rx="3" fill="{INK}"/><path d="M106 173 L100 188 M114 173 L121 187" stroke="{INK}" stroke-width="5.5" stroke-linecap="round"/>',
    top=f'<rect x="62" y="52" width="96" height="9" rx="4.5" fill="#fff" {WL}/><circle cx="110" cy="56.5" r="3.6" fill="{RED}"/>')
O["graduation"] = gochi(body_fill="#1E1E24", body_stroke="#55555C", mood="happy",
    cloth=vcollar("#fff", 5) + f'<path d="M84 134 L92 192 M136 134 L128 192" stroke="{GOLD}" stroke-width="7"/>',
    hand=f'<g transform="translate(186,150) rotate(20)"><rect x="-6" y="-24" width="12" height="42" rx="6" fill="#fff" {WL}/><rect x="-6" y="-7" width="12" height="6" fill="{RED}"/></g>' + paw(177, 158, "@FUR"),
    top=f'<path d="M80 40 L80 52 Q110 62 140 52 L140 40 Z" fill="#1E1E24" {OL}/><path d="M54 34 L110 16 L166 34 L110 52 Z" fill="{INK}" {OL}/>'
        f'<path d="M110 34 L152 40 L154 60" fill="none" stroke="{GOLD}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/><circle cx="154" cy="62" r="4" fill="{GOLD}"/><circle cx="110" cy="34" r="3" fill="{GOLD}"/>')
TIG, TD = "#F28C28", "#3A2A1A"
O["tiger"] = gochi(body_fill=TIG, mood="happy",
    back=f'<path d="M168 182 Q208 184 200 146" fill="none" stroke="{TIG}" stroke-width="10" stroke-linecap="round"/><path d="M194 178 L199 168 M201 164 L207 156" stroke="{TD}" stroke-width="4" stroke-linecap="round"/>',
    hood=hoodback(TIG) + "".join(f'<circle cx="{x}" cy="36" r="13" fill="{TIG}"/><circle cx="{x}" cy="37" r="6.5" fill="#FBE3C2"/>' for x in (68, 152)),
    cloth=f'<ellipse cx="110" cy="174" rx="36" ry="26" fill="#FBE3C2"/><path d="M42 140 L66 146 L42 152 Z M42 160 L64 166 L42 172 Z M178 140 L154 146 L178 152 Z M178 160 L156 166 L178 172 Z" fill="{TD}"/>',
    top=hoodcap(TIG) + f'<path d="M98 42 L103 53 L108 42 Z M105 42 L110 56 L115 42 Z M112 42 L117 53 L122 42 Z" fill="{TD}"/>')
O["dokkaebi"] = gochi(mood="happy",
    cloth='<rect x="42" y="158" width="136" height="34" fill="#F6C445"/>' + "".join(f'<circle cx="{x}" cy="{y}" r="4" fill="{TD}"/>' for x, y in ((62, 170), (82, 182), (100, 168), (122, 184), (140, 170), (160, 182))),
    hand=f'<g transform="translate(186,154) rotate(14)"><rect x="-3.5" y="-18" width="7" height="28" rx="3" fill="{WOOD}"/><rect x="-9" y="-68" width="18" height="52" rx="9" fill="#9A6540"/>'
         + "".join(f'<circle cx="{x}" cy="{y}" r="2.6" fill="#F7E7BE"/>' for x, y in ((-4, -58), (4, -50), (-4, -42), (4, -34), (-4, -26))) + '</g>' + paw(177, 154, "@FUR"),
    face='<path d="M104 113 L107 120 L110 113 Z" fill="#fff"/>',
    top='<path d="M99 48 Q104 22 112 10 Q118 24 121 48 Z" fill="#F7E7BE" stroke="#D9C28A" stroke-width="1.5" stroke-linejoin="round"/><path d="M103 36 L119 36 M106 25 L116 25" stroke="#D9C28A" stroke-width="2"/>')
O["gumiho"] = gochi(mood="happy",
    back="".join(f'<g transform="rotate({a} 110 166)"><ellipse cx="110" cy="108" rx="11" ry="36" fill="#fff" {WL}/><ellipse cx="110" cy="80" rx="6" ry="7" fill="#FFC6D9"/></g>' for a in (-96, -72, -48, -24, 0, 24, 48, 72, 96)),
    cloth=f'<path d="M90 134 Q110 150 130 134" fill="none" stroke="{RED}" stroke-width="5"/><circle cx="110" cy="147" r="5.5" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1"/>',
    hand='<circle cx="186" cy="142" r="16" fill="#7CC6FE" opacity=".35"/><circle cx="186" cy="142" r="10" fill="#7CC6FE"/><circle cx="183" cy="139" r="3" fill="#fff" opacity=".7"/>' + paw(177, 156, "@FUR"),
    top=f'<path d="M64 50 L74 12 L100 42 Z" fill="#fff" {WL}/><path d="M73 42 L77 25 L90 40 Z" fill="#FFC6D9"/><path d="M156 50 L146 12 L120 42 Z" fill="#fff" {WL}/><path d="M147 42 L143 25 L130 40 Z" fill="#FFC6D9"/>')
O["gold"] = gochi(pal=GOLDPAL, mood="happy", back=f'<g transform="translate(160,56) rotate(32)">{pen_up(36)}</g>',
    top=star(28, 64) + star(194, 40, .8) + star(202, 150, .9) + star(22, 150, .7) + star(44, 24, .6, "#FFE9A8"))

L = {"hanbok_m": ("Hanbok (baji)", "jacket and trousers"), "hanbok_f": ("Hanbok (chima)", "jacket and skirt"), "groom": ("Wedding: groom", "samo hat, blue robe"),
     "bride": ("Wedding: bride", "jokduri, red cheek dots"), "queen": ("Queen", "pairs with King"), "general": ("General", "helmet and banner"),
     "pungmul": ("Pungmul", "ribbon-hat drummer"), "haenyeo": ("Haenyeo", "Jeju diver"), "school_m": ("School A", "blazer and tie"), "school_f": ("School B", "ribbon and skirt"),
     "idol_m": ("Idol A", "stage jacket, mic"), "idol_f": ("Idol B", "ponytail, mic"), "office": ("Office", "ID badge, iced americano"), "hiker": ("Hiker", "sun visor, pole"),
     "jjimjilbang": ("Jjimjilbang", "sheep-head towel"), "ramyeon": ("Ramyeon night", "hoodie and pot"), "winter": ("Winter", "long padding, bungeoppang"),
     "rainy": ("Rainy day", "raincoat, umbrella"), "taekwondo": ("Taekwondo", "black belt"), "graduation": ("Graduation", "cap and diploma"),
     "tiger": ("Tiger", "folk-tale tiger suit"), "dokkaebi": ("Dokkaebi", "goblin with club"), "gumiho": ("Gumiho", "nine-tailed fox"), "gold": ("Gold Gochi", "Pro only")}
SECTIONS = [("Traditional", ["hanbok_m", "hanbok_f", "groom", "bride"]), ("Royal and folk", ["queen", "general", "pungmul", "haenyeo"]),
            ("School and stage", ["school_m", "school_f", "idol_m", "idol_f"]), ("Everyday Korea", ["office", "hiker", "jjimjilbang", "ramyeon"]),
            ("Seasons and milestones", ["winter", "rainy", "taekwondo", "graduation"]), ("Folklore and special", ["tiger", "dokkaebi", "gumiho", "gold"])]
DARK = ["taekwondo", "groom", "graduation", "gumiho"]

def cells(keys): return "".join(f'<div class="cell">{O[k]}<div class="t">{L[k][0]}</div><div class="d">{L[k][1]}</div></div>' for k in keys)
def sec(title, keys, dark=False):
    return f'<h2 class="{"dk" if dark else ""}">{title}</h2><div class="grid {"dark" if dark else ""}">{cells(keys)}</div>'

html = f'''<!doctype html><meta charset="utf-8"><style>
body{{margin:0;font-family:Arial,Helvetica,sans-serif;background:#fff}}
h1{{font-size:20px;margin:0;padding:22px 32px 4px;color:#1c1c1e}} .sub{{padding:0 32px 14px;color:#6b7280;font-size:14px}}
h2{{font-size:14px;margin:0;padding:18px 32px 0;color:#6b7280;background:#F6F5F2;text-transform:uppercase;letter-spacing:.06em}}
h2.dk{{background:#1C1C1E;color:#9aa0a6}}
.grid{{display:flex;flex-wrap:wrap;gap:8px;padding:14px 24px 22px;background:#F6F5F2}} .grid.dark{{background:#1C1C1E}}
.cell{{width:220px;text-align:center}} .t{{font-weight:700;font-size:15px;color:#1c1c1e;margin-top:6px}} .d{{font-size:13px;color:#6b7280;margin-top:2px}}
.dark .t{{color:#f2f2f7}} .dark .d{{color:#9aa0a6}}
</style><div id="sheet" style="width:960px">
<div id="p1"><h1>Gochi wardrobe, concept v1 (drawn in code)</h1><div class="sub">24 outfits on the adult form. Any Gochi can wear any outfit.</div>
{"".join(sec(t, k) for t, k in SECTIONS[:3])}</div>
<div id="p2">{"".join(sec(t, k) for t, k in SECTIONS[3:])}{sec("Dark mode check", DARK, True)}</div></div>'''
open("outfits.html", "w").write(html)

async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await b.new_page(viewport={"width": 960, "height": 900}, device_scale_factor=2)
        await pg.goto("file://" + os.path.abspath("outfits.html"))
        await (await pg.query_selector("#sheet")).screenshot(path="/home/claude/gochi-wardrobe.png")
        await pg.close()
        pg = await b.new_page(viewport={"width": 960, "height": 900}, device_scale_factor=1)
        await pg.goto("file://" + os.path.abspath("outfits.html"))
        await (await pg.query_selector("#p1")).screenshot(path="check1.png")
        await (await pg.query_selector("#p2")).screenshot(path="check2.png")
        await b.close()
asyncio.run(main())
