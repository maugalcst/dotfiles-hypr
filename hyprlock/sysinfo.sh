#!/usr/bin/env bash

# Colores desde pywal
K=$(jq -r '.colors.color6' ~/.cache/wal/colors.json 2>/dev/null || echo "#986F51")
V=$(jq -r '.special.foreground' ~/.cache/wal/colors.json 2>/dev/null || echo "#d4cfc9")

cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2+$4)}')
read used total <<< $(free -g | awk '/^Mem:/ {print $3, $2}')
if [[ "$used" == "0" ]]; then
    used=$(free -m | awk '/^Mem:/ {print $3}')
    ram="${used}M/${total}G"
else
    ram="${used}/${total}G"
fi
read dused dtotal <<< $(df -BG / | awk 'NR==2 {gsub("G",""); print $3, $2}')
up=$(uptime -p | sed 's/up //; s/ hours\?/h/; s/ minutes\?/m/; s/,//g; s/ days\?/d/; s/ //g')

printf "<span color='%s'>cpu</span> <span color='%s'>: %s%%</span>\n" "$K" "$V" "$cpu"
printf "<span color='%s'>ram</span> <span color='%s'>: %s</span>\n" "$K" "$V" "$ram"
printf "<span color='%s'>ssd</span> <span color='%s'>: %s/%sG</span>\n" "$K" "$V" "$dused" "$dtotal"
printf "<span color='%s'>upt</span> <span color='%s'>: %s</span>\n" "$K" "$V" "$up"
