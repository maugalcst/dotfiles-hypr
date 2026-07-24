#!/usr/bin/env bash
VIDEO="$HOME/Videos/anifetch/flower.mp4"
W=30
H=15

STYLES=(
  "braille|--symbols braille"
  "block (el que ya tienes)|--symbols block"
  "wide|--symbols wide"
  "ascii|--symbols ascii"
  "extra|--symbols extra"
  "legacy|--symbols legacy"
  "geometric|--symbols geometric"
  "hankaku (estilo japones/katakana)|--symbols hankaku"
  "stipple|--symbols stipple"
  "technical|--symbols technical"
  "solid|--symbols solid"
  "mix denso|--symbols space+solid+stipple+block+border+diagonal+quad"
  "braille sin color|--symbols braille --fg-only"
  "block sin color|--symbols block --fg-only"
)

echo "==========================================="
echo " Probando estilos con: $(basename "$VIDEO")"
echo " Total: ${#STYLES[@]} estilos"
echo "==========================================="
read -p "Presiona ENTER para empezar... " _

i=0
for entry in "${STYLES[@]}"; do
  i=$((i+1))
  name="${entry%%|*}"
  flags="${entry#*|}"
  clear
  echo "-- [$i/${#STYLES[@]}] $name --"
  echo "   flags: $flags"
  echo ""
  anifetch "$VIDEO" -w "$W" -H "$H" -r 12 -l 1 --no-input-restore -ca "$flags"
  echo ""
  read -p ">> Enter para siguiente (o Ctrl+C para quedarte aqui)... " _
done

clear
echo "Terminado. Dime el numero/nombre del que te gusto."
