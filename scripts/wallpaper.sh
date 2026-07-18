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
