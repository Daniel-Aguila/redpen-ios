import asyncio, math
from gochi_lib import *

def suit(c, belly=None, ears="", cap="", cloth="", st="", pre="", **kw):
    o = dict(body_fill=c, mood="happy", hood=pre + hoodback(c, st) + ears, top=hoodcap(c, st) + cap,
             cloth=(f'<ellipse cx="110" cy="174" rx="36" ry="26" fill="{belly}"/>' if belly else "") + cloth)
    o.update(kw); return o
def ears_round(c, inner, r=13, st=""): return "".join(f'<circle cx="{x}" cy="36" r="{r}" fill="{c}" {st}/><circle cx="{x}" cy="37" r="{r*0.5:.1f}" fill="{inner}"/>' for x in (68, 152))
def ears_point(c, inner, st=""):
    return (f'<path d="M58 52 L64 10 L94 40 Z" fill="{c}" {st}/><path d="M67 42 L69 23 L84 38 Z" fill="{inner}"/><path d="M162 52 L156 10 L126 40 Z" fill="{c}" {st}/><path d="M153 42 L151 23 L136 38 Z" fill="{inner}"/>')
def tail(c, w=10): return f'<path d="M168 182 Q208 184 200 146" fill="none" stroke="{c}" stroke-width="{w}" stroke-linecap="round"/>'
def heart(x, y, s=1, c=RED): return f'<path transform="translate({x},{y}) scale({s})" d="M0 9 l-9 -10 a5.5 5.5 0 0 1 9 -6 a5.5 5.5 0 0 1 9 6 z" fill="{c}"/>'
def burst(x, y, c, r1=5, r2=13): return "".join(f'<path d="M{x+r1*math.cos(math.radians(a)):.1f} {y+r1*math.sin(math.radians(a)):.1f} L{x+r2*math.cos(math.radians(a)):.1f} {y+r2*math.sin(math.radians(a)):.1f}" stroke="{c}" stroke-width="2.5" stroke-linecap="round"/>' for a in range(0, 360, 45))
def collar(c="#C62B35", tag=True): return f'<path d="M88 134 Q110 150 132 134" fill="none" stroke="{c}" stroke-width="5"/>' + (f'<circle cx="110" cy="148" r="6" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1"/>' if tag else "")
TEETH = "".join(f'<path d="M{x-5} {y} L{x} {y+8} L{x+5} {y} Z" fill="#fff"/>' for x, y in ((74, 57.8), (86, 55.7), (98, 54.4), (110, 54), (122, 54.4), (134, 55.7), (146, 57.8)))
BEAK = f'<path d="M102 50 L110 62 L118 50 Z" fill="#F6A21E"/>'
STRIPES_T = '<path d="M98 42 L103 53 L108 42 Z M105 42 L110 56 L115 42 Z M112 42 L117 53 L122 42 Z" fill="#3A2A1A"/>'
LONG_EARS = (f'<ellipse cx="82" cy="26" rx="10" ry="22" fill="#fff" {WL} transform="rotate(-10 82 26)"/><ellipse cx="82" cy="28" rx="4.5" ry="14" fill="#FFC6D9" transform="rotate(-10 82 28)"/>'
             f'<ellipse cx="138" cy="26" rx="10" ry="22" fill="#fff" {WL} transform="rotate(10 138 26)"/><ellipse cx="138" cy="28" rx="4.5" ry="14" fill="#FFC6D9" transform="rotate(10 138 28)"/>')
WOOL = "".join(f'<circle cx="{110+66*math.cos(math.radians(a)):.1f}" cy="{88+58*math.sin(math.radians(a)):.1f}" r="13" fill="#fff" {WL}/>' for a in range(150, 400, 20))
SCARF = lambda c: f'<path d="M84 131 Q110 147 136 131 L138 142 Q110 158 82 142 Z" fill="{c}"/><rect x="88" y="144" width="14" height="30" rx="3" fill="{c}"/>'
CAPE = lambda c, s="": f'<path d="M52 110 Q18 150 26 200 L194 200 Q202 150 168 110 Z" fill="{c}" {s}/>'

Z = {}   # Korean zodiac
Z["rat"] = suit("#A7ABB3", "#E5E7EB", ears_round("#A7ABB3", "#F4A7B9", 15), back='<path d="M170 182 Q208 188 202 150" fill="none" stroke="#F4A7B9" stroke-width="4" stroke-linecap="round"/>',
    hand=f'<path d="M170 158 L200 140 L200 164 Z" fill="#F6C445" stroke="{GOLD_D}" stroke-width="1.5" stroke-linejoin="round"/>' + dots([(190, 152), (196, 158)], 2, GOLD_D) + paw(174, 162))
HORN = 'fill="#F7E7BE" stroke="#D9C28A" stroke-width="1.5" stroke-linejoin="round"'
Z["ox"] = suit("#9A6540", "#E8D5B5", f'<path d="M66 44 Q42 34 46 10 Q58 26 80 30 Z" {HORN}/><path d="M154 44 Q178 34 174 10 Q162 26 140 30 Z" {HORN}/>', cloth=collar())
Z["tiger"] = suit("#F28C28", "#FBE3C2", ears_round("#F28C28", "#FBE3C2"), STRIPES_T, back=tail("#F28C28"),
    cloth='<path d="M42 140 L66 146 L42 152 Z M42 160 L64 166 L42 172 Z M178 140 L154 146 L178 152 Z M178 160 L156 166 L178 172 Z" fill="#3A2A1A"/>')
Z["rabbit"] = suit("#fff", "#FFE3EC", st=WL, pre=LONG_EARS, body_stroke=WS,
    hand='<path d="M182 132 q-6 -12 0 -16 M186 132 q0 -14 2 -18 M190 132 q6 -12 2 -16" fill="none" stroke="#5BAA5B" stroke-width="3.5" stroke-linecap="round"/><path d="M176 132 L196 132 L186 172 Z" fill="#F28C28" stroke="#F28C28" stroke-width="2" stroke-linejoin="round"/>' + paw(175, 156))
Z["dragon"] = suit("#3BA55D", "#F6E7A8", cap='<path d="M96 42 L103 24 L110 42 Z M110 42 L117 24 L124 42 Z" fill="#F6C445"/>'
        + "".join(f'<path d="M{110+sg*27} 48 L{110+sg*37} 20 M{110+sg*32} 34 L{110+sg*20} 22" fill="none" stroke="{GOLD}" stroke-width="6" stroke-linecap="round"/>' for sg in (-1, 1)),
    cloth='<path d="M82 164 L138 164 M78 176 L142 176" stroke="#D9C97A" stroke-width="2"/>', back=tail("#3BA55D") + '<path d="M196 146 L206 132 L208 150 Z" fill="#F6C445"/>')
Z["snake"] = suit("#8BC34A", "#F3F7C8", cap="".join(f'<circle cx="{x}" cy="38" r="9" fill="#fff"/><circle cx="{x}" cy="38" r="4" fill="{INK}"/>' for x in (86, 134))
        + f'<path d="M110 54 L110 63 L105 69 M110 63 L115 69" fill="none" stroke="{RED}" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>',
    cloth="".join(f'<path d="M{x} {y} l6 8 -6 8 -6 -8 z" fill="#689F38"/>' for x, y in ((54, 142), (166, 142), (58, 166), (162, 166))), back=tail("#8BC34A", 8))
Z["horse"] = suit("#A86B3C", "#E8D5B5", ears_point("#A86B3C", "#E8B58C"), '<path d="M106 42 L114 42 L112 55 L108 55 Z" fill="#fff"/><path d="M92 44 Q96 12 118 18 Q128 28 124 42 Q110 36 92 44 Z" fill="#4A2E1A"/>',
    back='<path d="M168 176 Q204 174 200 202 Q186 190 172 192 Z" fill="#4A2E1A"/>')
Z["goat"] = suit("#FAFAFA", "#fff", f'<path d="M70 40 Q52 22 62 6 Q66 22 84 30 Z" {HORN}/><path d="M150 40 Q168 22 158 6 Q154 22 136 30 Z" {HORN}/>', st=WL, pre=WOOL, body_stroke=WS, cloth=collar("#2E8B57"))
Z["monkey"] = suit("#8B5A3C", "#E8C9A0", "".join(f'<circle cx="{x}" cy="84" r="14" fill="#8B5A3C"/><circle cx="{x}" cy="84" r="8" fill="#E8C9A0"/>' for x in (44, 176)),
    back='<path d="M170 178 Q210 176 204 150 Q200 136 190 144" fill="none" stroke="#8B5A3C" stroke-width="7" stroke-linecap="round"/>',
    hand=f'<path d="M172 150 Q186 172 204 146 Q190 158 178 142 Z" fill="#F6D21E" stroke="{GOLD_D}" stroke-width="1.5" stroke-linejoin="round"/>' + paw(173, 160))
Z["rooster"] = suit("#FAFAFA", "#fff", "", BEAK, st=WL, body_stroke=WS, feet_fill="#F6A21E", pre=f'<circle cx="98" cy="30" r="8" fill="{RED}"/><circle cx="110" cy="24" r="9" fill="{RED}"/><circle cx="122" cy="30" r="8" fill="{RED}"/>',
    back='<path d="M168 176 Q202 168 204 136" fill="none" stroke="#2E8B57" stroke-width="8" stroke-linecap="round"/><path d="M168 182 Q208 182 212 154" fill="none" stroke="#27365E" stroke-width="8" stroke-linecap="round"/>'
         f'<path d="M168 188 Q204 196 214 176" fill="none" stroke="{RED}" stroke-width="8" stroke-linecap="round"/>')
Z["dog"] = suit("#D9A066", "#FBF1E0", ears_point("#D9A066", "#FBF1E0"), cloth=collar(), back='<circle cx="186" cy="174" r="13" fill="#D9A066"/><circle cx="188" cy="172" r="6" fill="#FBF1E0"/>',
    hand='<g transform="translate(188,146) rotate(-30)"><rect x="-14" y="-4" width="28" height="8" rx="4" fill="#F7E7BE"/>' + dots([(-14, -4), (-14, 4), (14, -4), (14, 4)], 5, "#F7E7BE") + '</g>' + paw(175, 158))
Z["pig"] = suit("#F7A8C4", "#FFD6E4", '<path d="M60 48 L62 18 L90 38 Z M160 48 L158 18 L130 38 Z" fill="#F48FB1"/>', '<ellipse cx="110" cy="50" rx="13" ry="7.5" fill="#F48FB1"/>' + dots([(105, 50), (115, 50)], 2, "#C2185B"),
    back='<path d="M172 176 q16 -6 14 6 q-2 10 -10 2 q-2 -8 12 -8" fill="none" stroke="#F48FB1" stroke-width="4" stroke-linecap="round"/>')

A = {}   # more animals
A["panda"] = suit("#fff", None, ears_round(BLK, BLK, 13, OL), st=WL, body_stroke=WS, cloth=sleeves(BLK),
    hand='<path d="M186 178 L186 110" stroke="#5BAA5B" stroke-width="6" stroke-linecap="round"/><path d="M183 132 L189 132 M183 154 L189 154" stroke="#3E8E41" stroke-width="2"/>'
         '<ellipse cx="197" cy="116" rx="10" ry="3.8" fill="#5BAA5B" transform="rotate(-30 197 116)"/>' + paw(178, 150))
A["cat"] = suit("#9AA0A6", "#fff", ears_point("#9AA0A6", "#F4A7B9"), '<path d="M100 42 L102 52 M110 41 L110 54 M120 42 L118 52" stroke="#6B7280" stroke-width="3" stroke-linecap="round"/>', collar(), back=tail("#9AA0A6", 9),
    hand='<g transform="translate(188,148)"><path d="M11 0 L22 -8 L22 8 Z" fill="#4FA3D9"/><ellipse rx="13" ry="7" fill="#4FA3D9"/><circle cx="-6" cy="-2" r="1.6" fill="#fff"/></g>' + paw(175, 158))
A["frog"] = suit("#6CC04A", "#D9F0B8", "".join(f'<circle cx="{x}" cy="36" r="13" fill="#6CC04A"/><circle cx="{x}" cy="36" r="8" fill="#fff"/><circle cx="{x}" cy="36" r="3.5" fill="{INK}"/>' for x in (82, 138)))
PEN = "#2B3A55"
A["penguin"] = suit(PEN, None, "", BEAK, f'<ellipse cx="110" cy="170" rx="42" ry="32" fill="#fff"/><path d="M110 142 L98 135 L98 149 Z M110 142 L122 135 L122 149 Z" fill="{RED}"/>', st=OL, body_stroke=DS, feet_fill="#F28C28",
    back=f'<path d="M44 130 Q20 150 30 178 Q44 166 50 146 Z" fill="{PEN}" {OL}/><path d="M176 130 Q200 150 190 178 Q176 166 170 146 Z" fill="{PEN}" {OL}/>')
A["chick"] = suit("#FFD84D", "#FFF1B8", "", BEAK + f'<path d="M82 42 Q84 8 110 8 Q136 8 138 42 L130 34 L122 42 L114 34 L106 42 L98 34 L90 42 Z" fill="#fff" {WL}/>', feet_fill="#F28C28",
    back='<ellipse cx="40" cy="150" rx="10" ry="16" fill="#FFC93C"/><ellipse cx="180" cy="150" rx="10" ry="16" fill="#FFC93C"/>')
A["bee"] = suit("#FFD84D", None, "", f'<path d="M96 42 Q90 22 82 16 M124 42 Q130 22 138 16" fill="none" stroke="{BLK}" stroke-width="3" stroke-linecap="round"/><circle cx="82" cy="15" r="5" fill="{BLK}" {OL}/><circle cx="138" cy="15" r="5" fill="{BLK}" {OL}/>',
    "".join(band(y, 8, BLK) for y in (140, 156, 172)),
    back='<ellipse cx="34" cy="128" rx="20" ry="28" fill="#DDF1FB" stroke="#A8D5EE" stroke-width="1.5" transform="rotate(-20 34 128)"/><ellipse cx="186" cy="128" rx="20" ry="28" fill="#DDF1FB" stroke="#A8D5EE" stroke-width="1.5" transform="rotate(20 186 128)"/>',
    hand='<path d="M172 138 Q168 166 186 168 Q204 166 200 138 Z" fill="#F2A72E" stroke="#C98A2B" stroke-width="1.5"/><rect x="170" y="134" width="32" height="7" rx="3.5" fill="#C98A2B"/>' + paw(173, 160))
DINO = "#57B894"
A["dino"] = suit(DINO, "#DDF3E4", '<path d="M88 40 L96 20 L104 38 Z M102 38 L110 14 L118 38 Z M116 38 L124 20 L132 40 Z" fill="#F28C28"/>', TEETH,
    back=f'<path d="M166 178 Q202 180 210 200 Q186 198 168 192 Z" fill="{DINO}"/><path d="M190 180 L198 170 L202 186 Z" fill="#F28C28"/>')
SHK = "#6E8FB3"
A["shark"] = suit(SHK, "#fff", "", TEETH, pre=f'<path d="M98 40 Q104 8 126 12 Q118 26 122 40 Z" fill="{SHK}"/>', back=f'<path d="M168 180 L206 158 L196 184 L208 206 Z" fill="{SHK}"/>')
A["unicorn"] = suit("#fff", "#FFE3EC", ears_point("#fff", "#FFC6D9", WL) + dots([(170, 56)], 11, "#F7A8C4") + dots([(176, 75)], 11, "#FFD84D") + dots([(176, 95)], 11, "#8BC34A") + dots([(172, 114)], 11, "#4FA3D9") + dots([(164, 130)], 11, "#B388FF"),
    f'<path d="M103 44 L110 6 L117 44 Z" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1.2" stroke-linejoin="round"/><path d="M105 34 L115 30 M106 24 L113 21" stroke="{GOLD_D}" stroke-width="1.5"/>', st=WL, body_stroke=WS,
    back='<path d="M168 180 Q204 180 200 148" fill="none" stroke="#F7A8C4" stroke-width="6" stroke-linecap="round"/><path d="M168 186 Q210 188 208 154" fill="none" stroke="#4FA3D9" stroke-width="6" stroke-linecap="round"/>')
FOX = "#F2803A"
A["fox"] = suit(FOX, "#fff", ears_point(FOX, "#3A2A1A"), back=f'<path d="M166 182 Q212 180 204 136 Q188 150 176 166 Z" fill="{FOX}"/><path d="M204 136 Q200 152 192 158 Q204 156 208 148 Z" fill="#fff"/>')
A["koala"] = suit("#A7ABB3", "#F3F4F6", "".join(f'<circle cx="{x}" cy="52" r="17" fill="#A7ABB3"/><circle cx="{x}" cy="52" r="10" fill="#fff"/>' for x in (54, 166)), f'<ellipse cx="110" cy="50" rx="9" ry="7" fill="{INK}"/>',
    hand='<path d="M186 172 L186 122" stroke="#7A8F6A" stroke-width="3.5" stroke-linecap="round"/>' + "".join(f'<ellipse cx="{x}" cy="{y}" rx="9" ry="4" fill="#8FBF8F" transform="rotate({a} {x} {y})"/>' for x, y, a in ((195, 126, -30), (177, 134, 30), (195, 144, -30))) + paw(177, 158))
AXO, GILL = "#FFB3C7", "#F06292"
A["axolotl"] = suit(AXO, "#FFE3EC", pre="".join(f'<path d="M{x1} {y1} L{x2} {y2}" stroke="{GILL}" stroke-width="8" stroke-linecap="round"/>' for x1, y1, x2, y2 in ((54, 70, 30, 56), (50, 86, 24, 86), (54, 102, 30, 114), (166, 70, 190, 56), (170, 86, 196, 86), (166, 102, 190, 114))),
    back='<path d="M168 176 Q206 170 206 202 Q186 192 170 194 Z" fill="#FF8FB1"/>')

H = {}   # holidays and seasons
H["newyear"] = dict(body_fill=BLK, body_stroke=DS, mood="happy", back=burst(30, 44, GOLD) + burst(194, 34, "#F06292") + dots([(20, 100), (204, 84), (14, 146)], 3, "#4FA3D9") + dots([(44, 18), (206, 128)], 3, GOLD),
    cloth=shirtv() + f'<path d="M110 144 L96 137 L96 151 Z M110 144 L124 137 L124 151 Z" fill="{GOLD}"/><circle cx="110" cy="144" r="3.5" fill="{GOLD_D}"/>' + star(64, 160, .5) + star(156, 162, .5) + star(140, 182, .4) + star(80, 182, .4),
    top=f'<path d="M84 48 L110 8 L136 48 Z" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="1.2" stroke-linejoin="round"/>' + star(110, 30, .5, "#fff") + star(102, 42, .4, "#fff") + star(120, 42, .4, "#fff") + f'<circle cx="110" cy="8" r="5.5" fill="#F06292"/>',
    hand='<path d="M186 172 L186 130" stroke="#8A8F98" stroke-width="2.5" stroke-linecap="round"/>' + star(186, 120, 1.5) + burst(186, 120, GOLD, 15, 21) + paw(178, 160))
H["valentine"] = dict(body_fill="#FFB3C7", mood="happy", cloth=heart(110, 166, 1.9),
    top='<path d="M88 44 L84 27 M132 44 L136 27" stroke="#F06292" stroke-width="2.5"/><path d="M62 56 Q110 34 158 56" fill="none" stroke="#F06292" stroke-width="5" stroke-linecap="round"/>' + heart(84, 20, .9) + heart(136, 20, .9),
    hand='<path d="M178 158 L188 138" stroke="#9AA0A6" stroke-width="1.5"/>' + heart(190, 120, 2) + paw(175, 160))
RAINBOW = (RED, "#F28C28", "#F6C445", "#3BB273", "#4FA3D9", "#8E6AD9")
H["children"] = dict(body_fill=W, body_stroke=WS, mood="happy", cloth="".join(band(138 + i * 9, 7, c) for i, c in enumerate(RAINBOW)),
    back=f'<path d="M32 94 L40 170" stroke="#9AA0A6" stroke-width="1.5"/><ellipse cx="32" cy="74" rx="17" ry="21" fill="{RED}"/><path d="M26 64 q4 -6 10 -6" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" opacity=".7"/>',
    top=f'<path d="M110 24 L110 12" stroke="{INK}" stroke-width="2.5"/><rect x="92" y="8" width="36" height="6" rx="3" fill="{RED}"/><path d="M70 50 Q72 22 110 22 Q148 22 150 50 Q110 40 70 50 Z" fill="#4FA3D9"/>',
    hand=f'<path d="M186 172 L186 124" stroke="{WOOD}" stroke-width="3.5" stroke-linecap="round"/><path d="M186 124 L186 104 L200 118 Z" fill="{RED}"/><path d="M186 124 L206 124 L192 138 Z" fill="#F6C445"/><path d="M186 124 L186 144 L172 130 Z" fill="#3BB273"/>'
         '<path d="M186 124 L166 124 L180 110 Z" fill="#4FA3D9"/><circle cx="186" cy="124" r="3" fill="#fff"/>' + paw(178, 162))
H["parents"] = dict(body_fill=CRM, mood="happy", cloth=vcollar("#fff", 5) + '<ellipse cx="141" cy="158" rx="6" ry="3" fill="#3BB273" transform="rotate(40 141 158)"/>' + flower(134, 150, 7.5, RED, "#C62B35"),
    hand=f'<path d="M172 170 L186 134 L200 170 Q186 176 172 170 Z" fill="#FBE3C2" stroke="{MUZ}" stroke-width="1.5" stroke-linejoin="round"/><ellipse cx="174" cy="134" rx="7" ry="3" fill="#3BB273" transform="rotate(-30 174 134)"/><ellipse cx="198" cy="134" rx="7" ry="3" fill="#3BB273" transform="rotate(30 198 134)"/>'
         + flower(178, 128, 8, RED, "#C62B35") + flower(194, 128, 8, RED, "#C62B35") + flower(186, 118, 8, "#F06292", "#C2185B") + paw(174, 162))
H["pumpkin"] = dict(body_fill="#F28C28", mood="happy",
    cloth='<path d="M76 100 Q64 146 76 192 M110 98 L110 192 M144 100 Q156 146 144 192" fill="none" stroke="#D9701A" stroke-width="3"/><path d="M84 152 L94 139 L104 152 Z M116 152 L126 139 L136 152 Z" fill="#3A2A1A"/>'
          '<path d="M82 165 L92 172 L100 165 L110 172 L120 165 L128 172 L138 165 L132 183 L88 183 Z" fill="#3A2A1A"/>',
    top='<path d="M116 34 Q136 22 146 38 Q130 46 116 34 Z" fill="#6CC04A"/><path d="M104 44 Q102 22 114 18 L120 24 Q112 28 116 44 Z" fill="#5A7F2B"/>')
HEM = 'M42 150 L42 196 q11 12 22 0 q11 12 23 0 q11 12 23 0 q11 12 23 0 q11 12 23 0 q11 12 22 0 L178 150'
H["ghost"] = dict(body_fill="#fff", body_stroke=WS, feet=False, mood="happy", hood=hoodback("#fff", WL), top=hoodcap("#fff", WL), raw=f'<path d="{HEM} Z" fill="#fff"/><path d="{HEM}" fill="none" {WL}/>')
H["witch"] = dict(body_fill="#4B2A6B", mood="happy", cloth=vcollar("#fff", 4) + band(162, 8, "#F28C28") + band(184, 5, "#F28C28"), raw=f'<rect x="103" y="160" width="14" height="12" rx="2" fill="none" stroke="{GOLD}" stroke-width="3"/>',
    top=f'<path d="M82 46 L108 6 Q122 2 134 12 Q124 12 120 20 L138 46 Z" fill="{BLK}" {OL}/><ellipse cx="110" cy="46" rx="70" ry="10" fill="{BLK}" {OL}/><path d="M91 35 Q110 42 129 35" fill="none" stroke="#F28C28" stroke-width="5"/>',
    hand=f'<path d="M186 178 L186 110" stroke="{WOOD}" stroke-width="4" stroke-linecap="round"/><path d="M176 112 L196 112 L204 82 L168 82 Z" fill="#D9A441" stroke="#B5762B" stroke-width="1.5" stroke-linejoin="round"/><rect x="176" y="108" width="20" height="6" rx="2" fill="#B5762B"/>' + paw(178, 152))
H["vampire"] = dict(body_fill=BLK, body_stroke=DS, back=CAPE(BLK, OL), hood=f'<path d="M52 122 L32 50 L86 96 Z M168 122 L188 50 L134 96 Z" fill="#C62B35" stroke="{BLK}" stroke-width="2" stroke-linejoin="round"/>',
    cloth=shirtv() + '<path d="M84 152 L136 152 L132 192 L88 192 Z" fill="#8E1F2F"/>' + f'<path d="M110 144 L97 137 L97 151 Z M110 144 L123 137 L123 151 Z" fill="{RED}"/><circle cx="110" cy="144" r="3.5" fill="#C62B35"/>',
    face='<path d="M103 116 L106 125 L109 116 Z M111 116 L114 125 L117 116 Z" fill="#fff"/>', top=f'<path d="M58 62 Q60 40 110 40 Q160 40 162 62 Q134 48 110 61 Q86 48 58 62 Z" fill="{BLK}" {OL}/>')
H["beach"] = dict(mood="happy", cloth=band(172, 20, "#17A2A2"),
    raw=f'<ellipse cx="110" cy="158" rx="76" ry="19" fill="none" stroke="#fff" stroke-width="16"/><ellipse cx="110" cy="158" rx="76" ry="19" fill="none" stroke="{RED}" stroke-width="16" stroke-dasharray="26 36"/>',
    face=f'<rect x="63" y="66" width="31" height="20" rx="9" fill="{BLK}" {OL}/><rect x="126" y="66" width="31" height="20" rx="9" fill="{BLK}" {OL}/><path d="M94 73 L126 73" stroke="{BLK}" stroke-width="3"/><path d="M70 72 L78 72 M133 72 L141 72" stroke="#fff" stroke-width="2.5" stroke-linecap="round" opacity=".7"/>',
    hand=f'<path d="M170 122 A18 18 0 0 0 206 122 Z" fill="{RED}" stroke="#2E8B57" stroke-width="4" stroke-linejoin="round"/>' + dots([(182, 128), (190, 131), (196, 126)], 1.6, INK) + paw(176, 142))
H["autumn"] = dict(body_fill="#D9A441", mood="happy", back="".join(f'<ellipse cx="{x}" cy="{y}" rx="7" ry="4" fill="{c}" transform="rotate({a} {x} {y})"/>' for x, y, a, c in ((24, 50, 30, "#E4572E"), (198, 70, -40, "#F28C28"), (28, 124, 60, "#C62B35"), (204, 134, 20, "#E4572E"), (42, 22, -20, "#F28C28"))),
    raw=SCARF("#C62B35") + '<path d="M90 174 L90 180 M95 174 L95 180 M100 174 L100 180" stroke="#C62B35" stroke-width="2.5" stroke-linecap="round"/>',
    top='<path d="M112 22 L115 12" stroke="#7A4E2D" stroke-width="3.5" stroke-linecap="round"/><path d="M58 54 Q60 20 112 22 Q166 26 160 56 Q110 38 58 54 Z" fill="#7A4E2D"/>',
    hand='<path d="M180 128 q-4 -6 0 -12 M190 126 q4 -6 0 -12" fill="none" stroke="#B8BCC4" stroke-width="2.5" stroke-linecap="round"/><g transform="translate(188,146) rotate(-20)"><ellipse rx="17" ry="9.5" fill="#8E4A6B"/><path d="M-2 -9.4 A17 9.5 0 0 1 17 0 A17 9.5 0 0 1 -2 9.4 Z" fill="#F6C445"/></g>' + paw(175, 158))
H["snowman"] = dict(body_fill="#fff", body_stroke=WS, mood="happy", back="".join(burst(x, y, "#A8D5EE", 2, 7) for x, y in ((24, 60), (198, 44), (204, 120), (18, 130))),
    cloth=dots([(110, 160), (110, 174), (110, 187)], 4, BLK), raw=SCARF("#2E8B57"),
    top=f'<rect x="86" y="10" width="48" height="34" rx="4" fill="{BLK}" {OL}/><rect x="86" y="30" width="48" height="7" fill="{RED}"/><ellipse cx="110" cy="46" rx="44" ry="7" fill="{BLK}" {OL}/>',
    hand='<path d="M182 132 q-5 -10 0 -14 M186 132 q0 -12 2 -16 M190 132 q5 -10 2 -14" fill="none" stroke="#5BAA5B" stroke-width="3" stroke-linecap="round"/><path d="M177 132 L195 132 L186 166 Z" fill="#F28C28" stroke="#F28C28" stroke-width="2" stroke-linejoin="round"/>' + paw(175, 156))
H["blackday"] = dict(body_fill=BLK, body_stroke=DS, mood="happy", cloth='<path d="M100 134 L98 156 M120 134 L122 156" stroke="#fff" stroke-width="2.5" stroke-linecap="round"/>', face='<circle cx="123" cy="119" r="2.6" fill="#3A2A1A"/>',
    hand=f'<path d="M178 132 L150 166 M185 137 L157 169" stroke="{WOOD}" stroke-width="3" stroke-linecap="round"/>' + paw(179, 141) + f'<path d="M76 172 L144 172 Q140 200 110 202 Q80 200 76 172 Z" fill="#fff" {WL}/><ellipse cx="110" cy="172" rx="34" ry="7" fill="#3A2A1A"/>'
         '<path d="M88 171 q6 -6 12 0 q6 -6 12 0 q6 -6 12 0" fill="none" stroke="#6B4226" stroke-width="2.5" stroke-linecap="round"/><path d="M118 168 L130 170 M120 172 L132 173" stroke="#8BC34A" stroke-width="2.5" stroke-linecap="round"/>')

K = {}   # cute costumes
ZP = lambda x, y, s: f'<path transform="translate({x},{y}) scale({s})" d="M0 0 h10 l-10 12 h10" fill="none" stroke="#9AA0A6" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>'
K["pajamas"] = dict(body_fill="#BFD9F2", mood="sleepy", back=ZP(186, 70, 1.3) + ZP(202, 48, .9), cloth=vcollar("#fff", 4) + dots([(110, 166), (110, 180)], 3, "#fff") + star(64, 150, .5, "#F6C445") + star(156, 152, .5, "#F6C445") + star(74, 178, .45, "#F6C445") + star(148, 180, .45, "#F6C445"),
    top=f'<path d="M62 58 Q62 22 104 18 Q150 16 176 62 Q150 44 150 58 Q110 40 62 58 Z" fill="#8FB3E8"/><path d="M61 58 Q110 40 151 58" fill="none" stroke="#fff" stroke-width="8" stroke-linecap="round"/><circle cx="178" cy="66" r="8" fill="#fff" {WL}/>',
    hand=f'<rect x="166" y="132" width="38" height="28" rx="9" fill="#fff" {WL}/>' + paw(173, 160))
K["astronaut"] = dict(body_fill="#F3F4F6", body_stroke=WS, mood="happy", feet_fill="#D9DCE3", feet_stroke="#B8BCC4", back=star(22, 40, .6) + star(200, 170, .5) + star(18, 150, .45) + '<circle cx="198" cy="26" r="9" fill="#F28C28"/><ellipse cx="198" cy="26" rx="16" ry="4" fill="none" stroke="#F6C445" stroke-width="2" transform="rotate(-20 198 26)"/>',
    hood='<circle cx="110" cy="86" r="70" fill="#DDF1FB" fill-opacity=".55" stroke="#B8BCC4" stroke-width="4"/>',
    cloth='<path d="M52 134 L46 192 M168 134 L174 192" stroke="#4FA3D9" stroke-width="5"/><rect x="90" y="150" width="40" height="24" rx="4" fill="#D9DCE3" stroke="#B8BCC4" stroke-width="1.5"/>' + dots([(100, 162)], 3.5, RED) + dots([(110, 162)], 3.5, "#F6C445") + dots([(120, 162)], 3.5, "#4FA3D9"),
    raw='<ellipse cx="110" cy="138" rx="48" ry="10" fill="#B8BCC4"/>', top='<path d="M62 52 Q74 32 96 25" fill="none" stroke="#fff" stroke-width="5" stroke-linecap="round" opacity=".9"/>')
TEAL = "#17A2A2"
K["mermaid"] = dict(feet=False, mood="happy", raw=f'<path d="M56 156 Q110 144 164 156 Q166 186 130 196 L158 210 Q110 200 62 210 L90 196 Q54 186 56 156 Z" fill="{TEAL}"/><path d="M56 156 Q110 144 164 156" fill="none" stroke="#5FD0CB" stroke-width="5"/>'
        + "".join(f'<path d="M{x} {y} q7 8 14 0" fill="none" stroke="#5FD0CB" stroke-width="2"/>' for x, y in ((74, 166), (96, 164), (118, 164), (138, 166), (86, 178), (106, 178), (126, 178)))
        + "".join(f'<circle cx="{x}" cy="{y}" r="3.6" fill="#fff" {WL}/>' for x, y in ((90, 138), (98, 144), (106, 148), (114, 148), (122, 144), (130, 138))), top=star(152, 46, 1.3, "#F28C28"))
MASKB = 'M56 76 Q56 62 76 62 H144 Q164 62 164 76 Q164 90 144 90 H128 Q110 84 92 90 H76 Q56 90 56 76 Z M68 76 a10 6.5 0 1 0 20 0 a10 6.5 0 1 0 -20 0 Z M132 76 a10 6.5 0 1 0 20 0 a10 6.5 0 1 0 -20 0 Z'
K["hero"] = dict(body_fill=BLU, mood="happy", back=CAPE("#C62B35"), cloth=f'<circle cx="110" cy="156" r="14" fill="{GOLD}" stroke="{GOLD_D}" stroke-width="2"/>' + star(110, 156, 1.05, "#C62B35") + band(176, 7, GOLD), face=f'<path d="{MASKB}" fill="#1E2A78" fill-rule="evenodd"/>')
SEED = "#F6E27A"
K["strawberry"] = dict(body_fill=RED, mood="happy", hood=hoodback(RED), cloth=dots([(58, 150), (76, 164), (60, 180), (96, 176), (124, 176), (144, 164), (162, 150), (160, 180), (110, 188)], 2.4, SEED),
    raw='<path d="M80 132 L92 151 L100 139 L110 155 L120 139 L128 151 L140 132 Q110 143 80 132 Z" fill="#3BB273"/>',
    top=hoodcap(RED) + dots([(84, 50), (136, 50)], 2.2, SEED) + '<path d="M110 24 L110 12" stroke="#2E8B57" stroke-width="4" stroke-linecap="round"/><path d="M90 44 L99 26 L105 38 L110 20 L115 38 L121 26 L130 44 Q110 34 90 44 Z" fill="#3BB273"/>')
K["boba"] = dict(body_fill="#E8C9A0", mood="happy", cloth=band(146, 15, "#fff") + heart(110, 153, .8, "#F06292") + dots([(58, 184), (74, 174), (90, 186), (110, 178), (130, 186), (146, 174), (162, 184), (92, 168), (128, 168)], 6, "#3A2A1A"),
    top=f'<ellipse cx="110" cy="46" rx="58" ry="9" fill="#fff" fill-opacity=".92" {WL}/><path d="M62 43 Q110 16 158 43" fill="none" stroke="#CFCFD6" stroke-width="1.5"/><rect x="118" y="2" width="11" height="46" rx="3" fill="#F06292" transform="rotate(14 123 46)"/>')
K["sunflower"] = dict(body_fill="#4CAF50", mood="happy", hood="".join(f'<ellipse cx="110" cy="22" rx="10" ry="20" fill="#FFD84D" stroke="#F2B01E" stroke-width="1" transform="rotate({a} 110 88)"/>' for a in range(0, 360, 20)),
    cloth='<path d="M42 150 Q60 136 76 152 Q60 166 42 150 Z M178 150 Q160 136 144 152 Q160 166 178 150 Z" fill="#81C784"/><path d="M110 134 L110 192" stroke="#388E3C" stroke-width="4"/>')
K["mushroom"] = dict(body_fill="#FBF1E0", body_stroke="#E6D8BE", mood="happy", top=f'<path d="M30 62 Q32 4 110 4 Q188 4 190 62 Q110 44 30 62 Z" fill="{RED}"/>' + dots([(70, 36), (150, 36)], 9, "#fff") + dots([(110, 22)], 10, "#fff") + dots([(92, 47), (130, 47)], 5, "#fff"))

ZL = {"rat": ("Rat", "cheese"), "ox": ("Ox", "horns, bell"), "tiger": ("Tiger", "stripes"), "rabbit": ("Rabbit", "carrot"), "dragon": ("Dragon", "horns, spikes"), "snake": ("Snake", "hood eyes, tongue"),
      "horse": ("Horse", "mane, blaze"), "goat": ("Goat", "wool, horns"), "monkey": ("Monkey", "banana"), "rooster": ("Rooster", "comb, tail feathers"), "dog": ("Dog", "bone"), "pig": ("Pig", "snout, curly tail")}
AL = {"panda": ("Panda", "bamboo"), "cat": ("Cat", "bell, fish"), "frog": ("Frog", "big eyes"), "penguin": ("Penguin", "bow tie"), "chick": ("Chick", "eggshell hat"), "bee": ("Bee", "wings, honey"),
      "dino": ("Dinosaur", "spikes, teeth"), "shark": ("Shark", "fin, teeth"), "unicorn": ("Unicorn", "rainbow mane"), "fox": ("Fox", "bushy tail"), "koala": ("Koala", "eucalyptus"), "axolotl": ("Axolotl", "pink gills")}
HL = {"newyear": ("New Year's Eve", "gold hat, sparkler"), "valentine": ("Valentine's Day", "heart sweater, balloon"), "children": ("Children's Day", "May 5, pinwheel, balloon"), "parents": ("Parents' Day", "May 8, carnations"),
      "pumpkin": ("Pumpkin", "jack-o'-lantern"), "ghost": ("Ghost", "bed sheet"), "witch": ("Witch", "hat, broom"), "vampire": ("Vampire", "cape, fangs"),
      "beach": ("Summer", "swim ring, watermelon"), "autumn": ("Autumn", "scarf, roasted sweet potato"), "snowman": ("Snowman", "top hat, carrot"), "blackday": ("Black Day", "April 14, black bean noodles")}
KL = {"pajamas": ("Pajamas", "sleep cap, pillow"), "astronaut": ("Astronaut", "bubble helmet"), "mermaid": ("Mermaid", "tail, pearls"), "hero": ("Superhero", "mask, cape"),
      "strawberry": ("Strawberry", "leafy collar"), "boba": ("Bubble tea", "pearls, straw"), "sunflower": ("Sunflower", "petal mane"), "mushroom": ("Mushroom", "spotted cap")}
zk, ak, hk, kk = list(Z), list(A), list(H), list(K)
animals = page("Gochi animal costumes (drawn in code)", "24 hooded suits: the 12 Korean zodiac animals and 12 more. Two are shown on every growth size.",
    [sec(Z, ZL, "Korean zodiac", zk) + '<h2>Growing up as a panda</h2>' + strip(A["panda"]),
     sec(A, AL, "More animals", ak) + '<h2>Growing up as a chick</h2>' + strip(A["chick"]) + sec(A, AL, "Dark mode check", ["panda", "penguin", "bee", "unicorn"], True)])
seasons = page("Gochi holidays and cute costumes (drawn in code)", "12 holiday and season outfits and 8 cute costumes. One is shown on every growth size.",
    [sec(H, HL, "Celebrations", hk[:4]) + sec(H, HL, "Halloween", hk[4:8]) + sec(H, HL, "Seasons and food days", hk[8:]),
     sec(K, KL, "Cute costumes", kk) + '<h2>Growing up as a pumpkin</h2>' + strip(H["pumpkin"]) + sec(H, HL, "Dark mode check", ["ghost", "vampire", "newyear", "snowman"], True)])
print(len(Z), len(A), len(H), len(K))
asyncio.run(render([("animals", animals, 2), ("seasons", seasons, 2)]))
