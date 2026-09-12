#!/usr/bin/env bash

K=$(jq -r '.colors.color6' ~/.cache/wal/colors.json 2>/dev/null || echo "#986F51")
V=$(jq -r '.special.foreground' ~/.cache/wal/colors.json 2>/dev/null || echo "#d4cfc9")

bat=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
bstatus=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)
bsuffix=""
[[ "$bstatus" == "Charging" ]] && bsuffix="+"

ssid=$(nmcli -t -f name connection show --active 2>/dev/null | head -1)
[[ -z "$ssid" ]] && ssid="offline"

temp=$(sensors 2>/dev/null | grep -m1 -E "Package id 0|Tctl|temp1" | grep -oE '[0-9]+\.[0-9]+' | head -1)
[[ -n "$temp" ]] && temp="${temp%.*}°C" || temp="--"

printf "<span color='%s'>bat</span> <span color='%s'>: %s%%%s</span>\n" "$K" "$V" "$bat" "$bsuffix"
printf "<span color='%s'>net</span> <span color='%s'>: %s</span>\n" "$K" "$V" "$ssid"
printf "<span color='%s'>tmp</span> <span color='%s'>: %s</span>\n" "$K" "$V" "$temp"
