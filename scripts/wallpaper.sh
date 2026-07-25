#!/usr/bin/env bash
WALLDIR="$HOME/Pictures/wallpapers"
WALL="$1"

# Si no se pasó argumento, usa el último wallpaper
if [[ -z "$WALL" ]]; then
    WALL=$(cat ~/.cache/wal/wal 2>/dev/null)
    [[ -z "$WALL" ]] && WALL="$WALLDIR/camille.jpg"
fi

# Generar paleta
wal -i "$WALL" -n -q -e

# Aplicar wallpaper
pgrep -x awww-daemon >/dev/null || { awww-daemon & sleep 1; }
awww img "$WALL"

# Recargar kitty (colores en vivo)
for pid in $(pgrep -x kitty); do
    kill -SIGUSR1 "$pid" 2>/dev/null
done

# Recargar waybar
pkill -SIGUSR2 waybar 2>/dev/null

# Recargar hyprland (borders)
hyprctl reload >/dev/null 2>&1

# Regenerar fastfetch
python3 ~/.config/hypr/scripts/gen-fastfetch.py

# Recargar btop si está abierto
pkill -USR1 btop 2>/dev/null

# Regenerar wlogout
python3 ~/.config/hypr/scripts/gen-wlogout.py

# Regenerar hyprlock colors
python3 - << 'PYEOF'
import json, os
with open(os.path.expanduser("~/.cache/wal/colors.json")) as f:
    wal = json.load(f)
c = wal["colors"]
bg = wal["special"]["background"]
fg = wal["special"]["foreground"]
wall = open(os.path.expanduser("~/.cache/wal/wal")).read().strip()

def to_rgba(h, a="FF"):
    h = h.lstrip("#")
    return f"rgba({h}{a})"

conf = f"""$text_color = {to_rgba(fg)}
$text_dim = {to_rgba(c["color8"], "AA")}
$entry_background_color = {to_rgba(bg, "99")}
$entry_border_color = {to_rgba(c["color8"], "33")}
$entry_color = {to_rgba(fg)}
$font_family = JetBrainsMono Nerd Font
$font_family_clock = JetBrainsMono Nerd Font
$background_image = {wall}
"""

with open(os.path.expanduser("~/.config/hypr/hyprlock/colors.conf"), "w") as f:
    f.write(conf)
print("[✓] hyprlock colors regenerados")
PYEOF
