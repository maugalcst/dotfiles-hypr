#!/usr/bin/env bash
bat=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)

icon="󰁹"
[[ "$status" == "Charging" ]] && icon="󰂄"

if [[ -n "$bat" ]]; then
    echo "$icon $bat%"
else
    echo ""
fi
