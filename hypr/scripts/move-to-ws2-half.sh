#!/usr/bin/bash
# Move active window to workspace slot 2 of the focused monitor and place it on
# that monitor's right half.

set -u

# Hyprland 0.56 replaced the string dispatchers with Lua expressions
# (hyprctl dispatch now evals `hl.dispatch(...)`).
dsp() { hyprctl dispatch "$1" >/dev/null; }

WIN_ADDR=$(hyprctl activewindow -j | jq -r '.address // empty')
if [ -z "$WIN_ADDR" ] || [ "$WIN_ADDR" = "null" ]; then
    echo "move-to-ws2-half: no active window" >&2
    exit 1
fi
WIN="address:$WIN_ADDR"

# Float before moving so resize/move work reliably.
dsp "hl.dsp.window.float({ window = \"$WIN\", action = \"on\" })"
# Omarchy numbers workspaces per monitor (blocks of 10), so global id 2 is slot 2
# of the first monitor only; o.workspaces maps the slot onto the focused one.
dsp "o.workspaces.move_window(2)"

MON_ID=$(hyprctl clients -j | jq --arg a "$WIN_ADDR" '.[] | select(.address == $a) | .monitor')
MON=$(hyprctl monitors -j | jq --argjson id "${MON_ID:-null}" '.[] | select(.id == $id)')

if [ -z "$MON" ]; then
    echo "move-to-ws2-half: could not resolve monitor for window" >&2
    exit 1
fi

# x/y and reserved are logical coords; width/height are physical pixels, so
# divide those by scale to keep everything in the same (logical) space.
MON_X=$(echo "$MON" | jq '.x')
MON_Y=$(echo "$MON" | jq '.y')
MON_W=$(echo "$MON" | jq '(.width / .scale) | floor')
MON_H=$(echo "$MON" | jq '(.height / .scale) | floor')
# reserved is [left, top, right, bottom] -- the bar eats the top.
RES_T=$(echo "$MON" | jq '.reserved[1]')
RES_B=$(echo "$MON" | jq '.reserved[3]')

# Gaps come back as a CSS shorthand string: "top right bottom left".
read -r GO_T GO_R GO_B GO_L < <(hyprctl getoption general:gaps_out -j | jq -r '.css')
read -r _ _ _ GI_L < <(hyprctl getoption general:gaps_in -j | jq -r '.css')
BORDER=$(hyprctl getoption general:border_size -j | jq '.int')

# Tiled windows report their position offset by the border, so mirror that
# here to line the floating window up with a real right-half tile.
WIN_X=$((MON_X + MON_W / 2 + GI_L + BORDER))
WIN_Y=$((MON_Y + RES_T + GO_T + BORDER))
WIN_W=$((MON_X + MON_W - GO_R - BORDER - WIN_X))
WIN_H=$((MON_Y + MON_H - RES_B - GO_B - BORDER - WIN_Y))

# Resize first: it re-centers the window, so position has to come after.
dsp "hl.dsp.window.resize({ window = \"$WIN\", x = $WIN_W, y = $WIN_H })"
dsp "hl.dsp.window.move({ window = \"$WIN\", x = $WIN_X, y = $WIN_Y })"
