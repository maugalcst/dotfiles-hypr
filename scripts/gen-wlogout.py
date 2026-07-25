#!/usr/bin/env python3
import json, os, re, colorsys

with open(os.path.expanduser("~/.cache/wal/colors.json")) as f:
    wal = json.load(f)

c = wal["colors"]
bg = wal["special"]["background"]

def hex_to_rgb(h):
    h = h.lstrip("#")
    return int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255

def rgb_to_hex(r, g, b):
    return "#{:02x}{:02x}{:02x}".format(int(r*255), int(g*255), int(b*255))

def hex_to_rgba(h, alpha=1.0):
    h = h.lstrip("#")
    r,g,b = int(h[0:2],16), int(h[2:4],16), int(h[4:6],16)
    return f"rgba({r}, {g}, {b}, {alpha})"

def noir_twist(hex_color, sat_mult=0.45, val_mult=0.75, val_floor=0.45):
    """
    Toma un color de pywal y lo convierte a versión noir:
    - Desatura (sat_mult < 1 = más gris)
    - Baja el brillo (val_mult)
    - Pero garantiza un mínimo de brillo (val_floor) para que resalte
    """
    r, g, b = hex_to_rgb(hex_color)
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    s = s * sat_mult
    v = max(val_floor, v * val_mult)
    r2, g2, b2 = colorsys.hsv_to_rgb(h, s, v)
    return rgb_to_hex(r2, g2, b2)

def noir_bright(hex_color, sat_mult=0.55, val_target=0.88):
    """
    Versión brillante para hover/resalte — más saturada y clara que la normal
    """
    r, g, b = hex_to_rgb(hex_color)
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    s = min(1.0, s * sat_mult)
    v = val_target
    r2, g2, b2 = colorsys.hsv_to_rgb(h, s, v)
    return rgb_to_hex(r2, g2, b2)

def dark_bg(hex_color, val_target=0.06):
    """Fondo muy oscuro con tinte del color"""
    r, g, b = hex_to_rgb(hex_color)
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    s = s * 0.3
    v = val_target
    r2, g2, b2 = colorsys.hsv_to_rgb(h, s, v)
    return rgb_to_hex(r2, g2, b2)

# Mapeo mitológico — cada botón toma su color de pywal base
RAW = {
    "lock":      c["color4"],   # Nyx      — azul frío
    "logout":    c["color7"],   # Hermes   — neutro/plata
    "suspend":   c["color6"],   # Hypnos   — azul noche
    "hibernate": c["color3"],   # Lethe    — cyan río
    "shutdown":  c["color1"],   # Thanatos — acento primario
    "reboot":    c["color5"],   # Phoenix  — cyan vivo
}

# Genera versiones noir de cada color
NOIR   = {k: noir_twist(v) for k, v in RAW.items()}
BRIGHT = {k: noir_bright(v) for k, v in RAW.items()}

ICONS_DIR = os.path.expanduser("~/.config/wlogout/icons")
CSS_PATH  = os.path.expanduser("~/.config/wlogout/style.css")

# 1. Recolorea SVGs con versión BRIGHT (para que resalten sobre el fondo oscuro)
for name, color in BRIGHT.items():
    svg_path = f"{ICONS_DIR}/{name}.svg"
    if not os.path.exists(svg_path):
        print(f"[!] no encontrado: {svg_path}")
        continue
    with open(svg_path) as f:
        content = f.read()
    content = re.sub(r'stroke="[^"]*"', f'stroke="{color}"', content)
    with open(svg_path, "w") as f:
        f.write(content)
    print(f"[✓] {name}.svg → {color} (bright)")

# 2. Fondo global: negro con tinte muy sutil del color dominante
dominant = dark_bg(c["color4"], val_target=0.05)
bg_window = hex_to_rgba(dominant, 0.97)  # casi opaco, muy oscuro
bg_hover  = hex_to_rgba(dark_bg(c["color4"], val_target=0.08), 0.9)

# 3. Genera CSS
def btn_css(name):
    icon_color = BRIGHT[name]   # color brillante en SVG
    border_dim  = hex_to_rgba(NOIR[name], 0.15)    # borde sutil en reposo
    text_hover  = hex_to_rgba(BRIGHT[name], 1.0)   # texto brillante en hover
    border_hov  = hex_to_rgba(BRIGHT[name], 0.45)  # borde más visible en hover
    return f"""
#{name} {{ background-image: url("/home/mau/.config/wlogout/icons/{name}.svg"); border-color: {border_dim}; }}
#{name}:hover, #{name}:focus {{ color: {text_hover}; border-color: {border_hov}; }}"""

css = f"""* {{
    all: unset;
    background-image: none;
    transition: 200ms cubic-bezier(0.05, 0.7, 0.1, 1);
    font-family: "JetBrainsMono Nerd Font";
    font-size: 14px;
    letter-spacing: 5px;
}}

window, box, scrolledwindow, viewport {{
    background-color: {bg_window};
}}

button {{
    color: rgba(80, 85, 85, 0.6);
    background-color: transparent;
    background-repeat: no-repeat;
    background-position: center 35%;
    background-size: 96px;
    border: 1px solid rgba(255, 255, 255, 0.04);
    margin: 6px;
    border-radius: 0px;
    padding-top: 80px;
    min-width: 160px;
    min-height: 160px;
}}

button:hover, button:focus {{
    background-color: {bg_hover};
}}
"""

for name in NOIR:
    css += btn_css(name)

with open(CSS_PATH, "w") as f:
    f.write(css)

print(f"\n[✓] style.css generado")
print(f"    fondo: {dominant} (99% opaco)")
print(f"    iconos: versión bright sobre negro")
