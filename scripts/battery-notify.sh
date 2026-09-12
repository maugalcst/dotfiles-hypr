#!/bin/bash
while true; do
    level=$(cat /sys/class/power_supply/BAT0/capacity)
    status=$(cat /sys/class/power_supply/BAT0/status)
    
    if [[ "$level" == "20" || "$level" == "10" || "$level" == "5" ]] && [[ "$status" == "Discharging" ]]; then
        notify-send -u critical "Batería baja" "${level}% restante"
        paplay ~/.config/sounds/battery-low.mp3
    fi
    
    sleep 60
done