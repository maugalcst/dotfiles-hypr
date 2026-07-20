#!/usr/bin/env bash
state=$(cat /sys/class/leds/*capslock*/brightness 2>/dev/null | head -1)
if [[ "$state" == "1" ]]; then
    echo "󰘲 Bloq Mayús activado"
fi
