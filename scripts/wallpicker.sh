#!/usr/bin/env bash
WALLDIR="$HOME/Pictures/wallpapers"
THEME="$HOME/.cache/wal/wallpicker.rasi"

PICK=$(find "$WALLDIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort | while read -r img; do
    echo -en "$(basename "$img")\0icon\x1f$img\n"
done | rofi -dmenu -i -p "  Wallpaper" -show-icons -theme "$THEME")

[[ -z "$PICK" ]] && exit 0

WALL="$WALLDIR/$PICK"
~/.config/hypr/scripts/wallpaper.sh "$WALL"
