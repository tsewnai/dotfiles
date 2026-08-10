#!/usr/bin/bash
# Move active window to workspace 2 and place it on the right half of whichever
# monitor workspace 2 currently lives on (looked up dynamically, not hardcoded).

# Capture window address and float state before moving.
WIN_ADDR=$(hyprctl activewindow -j | jq -r '.address')
FLOATING=$(hyprctl activewindow -j | jq -r '.floating')

# Float before moving so resize/move work reliably.
if [ "$FLOATING" != "true" ]; then
    hyprctl dispatch togglefloating "address:$WIN_ADDR"
fi

hyprctl dispatch movetoworkspace "2,address:$WIN_ADDR"

# Find which monitor workspace 2 is on, then read that monitor's geometry.
MON_NAME=$(hyprctl workspaces -j | jq -r '.[] | select(.id == 2) | .monitor')
MON=$(hyprctl monitors -j | jq --arg n "$MON_NAME" '.[] | select(.name == $n)')

if [ -z "$MON" ]; then
    echo "move-to-ws2-half: could not resolve monitor for workspace 2" >&2
    exit 1
fi

# x/y and reserved are logical coords; width/height are physical pixels, so
# divide those by scale to keep everything in the same (logical) space.
MON_X=$(echo "$MON" | jq '.x')
MON_Y=$(echo "$MON" | jq '.y')
MON_W=$(echo "$MON" | jq '(.width / .scale) | floor')
MON_H=$(echo "$MON" | jq '(.height / .scale) | floor')
BAR_H=$(echo "$MON" | jq '.reserved[1]')

# Gap settings (gaps_in between windows, gaps_out from monitor edge).
GAPS_IN=5
GAPS_OUT=5

# Right half position and size, matching tiled window gaps.
WIN_X=$((MON_X + MON_W / 2 + GAPS_IN))
WIN_Y=$((MON_Y + BAR_H + GAPS_OUT))
WIN_W=$((MON_W / 2 - GAPS_IN - GAPS_OUT))
WIN_H=$((MON_H - BAR_H - GAPS_OUT * 2))

# Size and position on right half, targeting by address.
hyprctl dispatch resizewindowpixel "exact $WIN_W $WIN_H, address:$WIN_ADDR"
hyprctl dispatch movewindowpixel "exact $WIN_X $WIN_Y, address:$WIN_ADDR"
