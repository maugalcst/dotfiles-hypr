#!/usr/bin/env bash
ANIDIR="$HOME/Videos/anifetch"
CONF="$ANIDIR/.selected"

PICK=$(find "$ANIDIR" -type f \( -iname "*.mp4" -o -iname "*.gif" \) ! -name ".*" | sort | while read -r f; do
    echo "$(basename "$f")"
done | rofi -dmenu -i -p "  Anifetch")

[[ -z "$PICK" ]] && exit 0

echo "$ANIDIR/$PICK" > "$CONF"
notify-send "Anifetch" "Animación: $PICK" -t 3000
