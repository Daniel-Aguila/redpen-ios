import asyncio, os
from playwright.async_api import async_playwright

RED = "#E63946"
FUR, FUR_B, FUR_D, MUZ = "#C08D62", "#B07C54", "#7E5236", "#E6BE94"
INK = "#2B2B2B"

D = {
 "baby":  dict(head=(58,70,104,82,36), body=(70,128,80,58,28), feet=(186,92,128,11,5.5), er=5.6, ey=104, ex=(83,137),
               muz=(78,108,64,38,13), ny=118, nx=(99,121), my=132, ears=((74,74),(146,74)), ch=((68,122),(152,122))),
 "young": dict(head=(55,56,110,88,37), body=(56,112,108,76,38), feet=(188,86,134,13,6), er=5.2, ey=90, ex=(80,140),
               muz=(74,94,72,44,14), ny=105, nx=(97,123), my=122, ears=((70,60),(150,60)), ch=((64,110),(156,110))),
 "adult": dict(head=(52,42,116,92,38), body=(42,98,136,92,46), feet=(190,80,140,16,7), er=4.8, ey=76, ex=(78,142),
               muz=(70,82,80,50,15), ny=94, nx=(96,124), my=114, ears=((68,46),(152,46)), ch=((61,100),(159,100))),
}

def rr(t, fill): x,y,w,h,r = t; return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}"/>'

def capy(stage, mood="neutral", pen=False, fruit=False, scholar=False):
    d = D[stage]; s = []
    for ex, ey in d["ears"]:
        s.append(f'<ellipse cx="{ex}" cy="{ey}" rx="8" ry="6.5" fill="{FUR_D}"/>')
    if pen:
        s.append(f'<g transform="translate(160,56) rotate(32)"><rect x="-4" y="-36" width="8" height="36" rx="2.5" fill="{RED}"/>'
                 f'<rect x="-4" y="-33" width="8" height="3" fill="#fff" opacity=".85"/>'
                 f'<path d="M-4 -36 L4 -36 L0 -45 Z" fill="#8A8F98" stroke="#8A8F98" stroke-width="1.2" stroke-linejoin="round"/></g>')
    s.append(rr(d["body"], FUR_B))
    fy, f1, f2, frx, fry = d["feet"]
    for fx in (f1, f2): s.append(f'<ellipse cx="{fx}" cy="{fy}" rx="{frx}" ry="{fry}" fill="{FUR_D}"/>')
    if scholar:
        s.append(f'<g transform="translate(176,150) rotate(12)"><rect x="-3" y="-54" width="6" height="54" rx="2" fill="{FUR_D}"/>'
                 f'<path d="M-5.5 -54 Q0 -80 5.5 -54 Z" fill="{RED}"/></g>')
        s.append(f'<ellipse cx="172" cy="142" rx="11" ry="9" fill="{FUR}"/>')
    s.append(rr(d["head"], FUR)); s.append(rr(d["muz"], MUZ))
    for cx_, cy_ in d["ch"]: s.append(f'<circle cx="{cx_}" cy="{cy_}" r="7" fill="#F4978E" opacity=".5"/>')
    for nx in d["nx"]: s.append(f'<ellipse cx="{nx}" cy="{d["ny"]}" rx="3.4" ry="2.4" fill="{FUR_D}"/>')
    st = f'fill="none" stroke="{INK}" stroke-width="3" stroke-linecap="round"'
    ey, r = d["ey"], d["er"]
    for ex in d["ex"]:
        if mood == "happy": s.append(f'<path d="M{ex-6} {ey+2} Q{ex} {ey-7} {ex+6} {ey+2}" {st}/>')
        elif mood == "sleepy": s.append(f'<path d="M{ex-6} {ey} Q{ex} {ey+6} {ex+6} {ey}" {st}/>')
        else: s.append(f'<circle cx="{ex}" cy="{ey}" r="{r}" fill="{INK}"/><circle cx="{ex-1.5}" cy="{ey-1.6}" r="1.6" fill="#fff"/>')
    my = d["my"]
    if mood == "happy": s.append(f'<path d="M103 {my-2} Q110 {my+9} 117 {my-2} Z" fill="{FUR_D}" stroke="{FUR_D}" stroke-width="2" stroke-linejoin="round"/>')
    else: s.append(f'<path d="M104 {my} Q110 {my+5} 116 {my}" fill="none" stroke="{FUR_D}" stroke-width="2.5" stroke-linecap="round"/>')
    if mood == "sleepy": s.append('<text x="172" y="40" font-size="20" font-weight="700" fill="#9AA0A6">z</text><text x="186" y="24" font-size="14" font-weight="700" fill="#9AA0A6">z</text>')
    top = d["head"][1]
    if fruit:
        s.append(f'<circle cx="110" cy="{top-8}" r="12" fill="#F59E2E"/><circle cx="106" cy="{top-12}" r="3" fill="#fff" opacity=".35"/>'
                 f'<ellipse cx="116" cy="{top-20}" rx="6" ry="3" fill="#5BAA5B" transform="rotate(-25 116 {top-20})"/>')
    if scholar:
        s.append(f'<path d="M87 46 L91 12 Q110 5 129 12 L133 46 Z" fill="{INK}" stroke="#77777D" stroke-width="1.5" stroke-linejoin="round"/>'
                 f'<ellipse cx="110" cy="47" rx="80" ry="11" fill="{INK}" stroke="#77777D" stroke-width="1.5"/>')
    return '<svg viewBox="0 0 220 205" width="220" height="205" xmlns="http://www.w3.org/2000/svg" font-family="Arial, sans-serif">' + "".join(s) + '</svg>'

variants = [(capy("baby"), "Baby", "where everyone starts"),
            (capy("young", "happy"), "Young", "10 mistakes mastered"),
            (capy("adult", pen=True, fruit=True), "Adult", "50 mastered · fruit = streak"),
            (capy("adult", "happy", scholar=True), "Scholar", "200 mastered · final form")]

def row(dark):
    cells = "".join(f'<div class="cell">{svg}<div class="t">{t}</div><div class="d">{d}</div></div>' for svg, t, d in variants)
    return f'<div class="row {"dark" if dark else ""}">{cells}</div>'

def card(dark):
    return f'''<div class="row {"dark" if dark else ""}" style="justify-content:center;padding-top:0">
      <div class="card"><div class="mini">{capy("adult", "happy", pen=True, fruit=True)}</div>
        <div class="info"><div class="h">5-day streak</div><div class="p">62 mastered · 2 mistakes due</div></div>
        <div class="btn">Review</div></div></div>'''

html = f'''<!doctype html><meta charset="utf-8"><style>
body{{margin:0;font-family:Arial,Helvetica,sans-serif;background:#fff}}
h1{{font-size:20px;margin:0;padding:22px 32px 4px;color:#1c1c1e}} .sub{{padding:0 32px 14px;color:#6b7280;font-size:14px}}
.row{{display:flex;gap:8px;padding:26px 24px;background:#F6F5F2}} .row.dark{{background:#1C1C1E}}
.cell{{width:220px;text-align:center}} .t{{font-weight:700;font-size:15px;color:#1c1c1e;margin-top:6px}} .d{{font-size:13px;color:#6b7280;margin-top:2px}}
.dark .t{{color:#f2f2f7}} .dark .d{{color:#9aa0a6}}
.card{{display:flex;align-items:center;gap:14px;background:#fff;border-radius:22px;padding:14px 18px;width:520px;box-shadow:0 1px 3px rgba(0,0,0,.08)}}
.dark .card{{background:#2C2C2E;box-shadow:none}}
.mini{{width:88px;height:82px;overflow:hidden}} .mini svg{{transform:scale(.4);transform-origin:0 0}}
.info{{flex:1}} .h{{font-weight:700;font-size:18px;color:#1c1c1e}} .p{{font-size:14px;color:#6b7280;margin-top:3px}}
.dark .h{{color:#f2f2f7}} .dark .p{{color:#9aa0a6}}
.btn{{background:{RED};color:#fff;font-weight:700;font-size:15px;padding:10px 20px;border-radius:999px}}
</style><div id="sheet" style="width:960px">
<h1>Gochi the capybara, concept v1 (drawn in code)</h1><div class="sub">Grows as you master mistakes. Light and dark mode, plus a Home card.</div>
{row(False)}{card(False)}{row(True)}{card(True)}</div>'''
open("capy.html", "w").write(html)

async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await b.new_page(viewport={"width": 960, "height": 800}, device_scale_factor=2)
        await pg.goto("file://" + os.path.abspath("capy.html"))
        await (await pg.query_selector("#sheet")).screenshot(path="/home/claude/gochi-capybara-concept.png")
        await b.close()
asyncio.run(main())
