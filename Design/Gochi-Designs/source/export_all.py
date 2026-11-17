import asyncio, os, re, shutil, json
OUT = "/home/claude/gochi-designs"
shutil.rmtree(OUT, ignore_errors=True)
asyncio.run = lambda *a, **k: None   # skip rendering while loading scripts

def load(path):
    ns = {"__name__": "x"}
    exec(open(path).read(), ns); return ns

def slug(s): return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")
count = {}; manifest = []
def save(folder, name, svg):
    d = os.path.join(OUT, "svg", folder); os.makedirs(d, exist_ok=True)
    fn = slug(name) + ".svg"
    open(os.path.join(d, fn), "w").write(svg)
    count[folder] = count.get(folder, 0) + 1; manifest.append({"group": folder, "name": name, "file": f"svg/{folder}/{fn}"})

f = load("gen_forms.py")
for svg, t, _ in f["forms"]: save("01-growth-forms", t.replace(" · ", "-"), svg)
for svg, t, _ in f["states"]: save("02-special-states", t, svg)
w = load("gen_outfits.py")
for k, (t, _) in w["L"].items(): save("03-wardrobe", t, w["O"][k])
h = load("gen_hanbok.py")
for k, (t, _) in h["L"].items(): save("04-hanbok", t, h["O"][k])
g = load("gen_world.py")
for k, (t, _) in g["TL"].items(): save("05-themes", t, g["fig"](g["T"][k]))
for k, (t, _) in g["CL"].items(): save("06-world", t, g["fig"](g["C"][k]))
c = load("gen_cute.py")
for src, lab, folder in ((c["Z"], c["ZL"], "07-zodiac"), (c["A"], c["AL"], "08-animals"), (c["H"], c["HL"], "09-holidays-seasons"), (c["K"], c["KL"], "10-cute-costumes")):
    for k, (t, _) in lab.items(): save(folder, t, c["fig"](src[k]))
# growth-size samples for scalable outfits
for name, o in (("mariachi", g["C"]["mariachi"]), ("folklorico", g["C"]["folklorico"]), ("panda", c["A"]["panda"]), ("chick", c["A"]["chick"]), ("pumpkin", c["H"]["pumpkin"])):
    for st, _ in c["STAGES"]: save("11-size-samples", f"{name}-{st}", c["fig"](o, st))

os.makedirs(f"{OUT}/sheets", exist_ok=True)
for p in os.listdir("/home/claude"):
    if p.startswith("gochi-") and p.endswith(".png"): shutil.copy(f"/home/claude/{p}", f"{OUT}/sheets/{p}")
os.makedirs(f"{OUT}/source", exist_ok=True)
for p in ("gochi_lib.py", "gen_forms.py", "gen_outfits.py", "gen_hanbok.py", "gen_world.py", "gen_cute.py", "gen_capy.py", "export_all.py"):
    shutil.copy(p, f"{OUT}/source/{p}")
json.dump(manifest, open(f"{OUT}/manifest.json", "w"), indent=1, ensure_ascii=False)
print(count, sum(v for k, v in count.items() if k != "11-size-samples"))
