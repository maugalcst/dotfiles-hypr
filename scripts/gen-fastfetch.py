#!/usr/bin/env python3
import json, os

with open(os.path.expanduser("~/.cache/wal/colors.json")) as f:
    wal = json.load(f)

def hex_rgb(h):
    h = h.lstrip("#")
    return int(h[0:2],16), int(h[2:4],16), int(h[4:6],16)

def ansi(r, g, b):
    return f"38;2;{r};{g};{b}"

def lerp(a, b, t):
    return int(a + (b - a) * t)

def desaturate(r, g, b, amount=0.4):
    gray = int(r * 0.299 + g * 0.587 + b * 0.114)
    return lerp(r, gray, amount), lerp(g, gray, amount), lerp(b, gray, amount)

def gradient(c1, c2, steps, desat=0.4):
    r1, g1, b1 = desaturate(*hex_rgb(c1), desat)
    r2, g2, b2 = desaturate(*hex_rgb(c2), desat)
    return [ansi(lerp(r1,r2,i/(steps-1)), lerp(g1,g2,i/(steps-1)), lerp(b1,b2,i/(steps-1))) for i in range(steps)]

c = wal["colors"]
fg = ansi(*hex_rgb(wal["special"]["foreground"]))

# Duo gradient desaturado
keys = gradient(c["color4"], c["color2"], 11, desat=0.6)

# Logo: también desaturado pero menos
l5 = desaturate(*hex_rgb(c["color5"]), 0.25)
l6 = desaturate(*hex_rgb(c["color6"]), 0.25)
logo1 = ansi(*l5)
logo2 = ansi(*l6)

orig = os.path.expanduser("~/.config/fastfetch/config.jsonc.original")
icon_map = {}
if os.path.exists(orig):
    with open(orig) as f:
        original = json.load(f)
    for mod in original["modules"]:
        if "key" in mod:
            icon_map[mod["type"]] = mod["key"]

order = ["title","os","kernel","uptime","shell","terminal","wm","cpu","memory","disk","battery","wifi"]

mods = []
for i, typ in enumerate(order):
    if typ == "title":
        mods.append({"type": typ})
    else:
        key = icon_map.get(typ, typ)
        mods.append({"type": typ, "key": key, "keyColor": keys[i-1]})

config = {
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/main/doc/json_schema.json",
    "logo": {
        "type": "builtin",
        "source": "arch",
        "color": {
            "1": logo1,
            "2": logo2
        }
    },
    "display": {
        "separator": "  ",
        "color": fg
    },
    "modules": mods
}

out = os.path.expanduser("~/.config/fastfetch/config.jsonc")
with open(out, "w") as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
    f.write("\n")

print("done")
