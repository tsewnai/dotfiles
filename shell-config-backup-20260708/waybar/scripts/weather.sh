#!/bin/bash

# Get location from IP
location=$(curl -s --max-time 5 "https://ipinfo.io/json" 2>/dev/null)
if [[ -z "$location" ]]; then
    echo ""
    exit 0
fi

lat=$(echo "$location" | grep -oP '"loc": "\K[^,]+')
lon=$(echo "$location" | grep -oP '"loc": "[^,]+,\K[^"]+')

if [[ -z "$lat" || -z "$lon" ]]; then
    echo ""
    exit 0
fi

# Fetch weather from Open-Meteo
weather=$(curl -s --max-time 5 "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code&temperature_unit=fahrenheit" 2>/dev/null)
if [[ -z "$weather" ]]; then
    echo ""
    exit 0
fi

temp=$(echo "$weather" | grep -oP '"temperature_2m":\K[0-9.]+')
code=$(echo "$weather" | grep -oP '"weather_code":\K[0-9]+')

# Map WMO weather codes to icons
case "$code" in
    0)          icon="☀️" ;;
    1|2|3)      icon="⛅" ;;
    45|48)      icon="🌫️" ;;
    51|53|55)   icon="🌦️" ;;
    61|63|65)   icon="🌧️" ;;
    71|73|75)   icon="🌨️" ;;
    77)         icon="🌨️" ;;
    80|81|82)   icon="🌧️" ;;
    85|86)      icon="🌨️" ;;
    95|96|99)   icon="⛈️" ;;
    *)          icon="🌡️" ;;
esac

# Round temp to integer
temp_int=$(printf "%.0f" "$temp")
echo "${icon} ${temp_int}°F"
