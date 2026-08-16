-- Personal keybinding overrides. Omarchy's defaults load first (see
-- default/hypr/bindings/*.lua), so unbind a default before rebinding its key.
-- See current bindings: omarchy menu keybindings --print

-- Obsidian with Wayland IME + GPU disabled (overrides the plain default).
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian -disable-gpu --enable-wayland-ime", focus = "^obsidian$" })

-- Typora on SUPER+SHIFT+W (default here is Omawrite).
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", { launch = "typora --enable-wayland-ime" })

-- Screenshot on SUPER+SHIFT+S for keyboards without a Print key
-- (default here is the Google Maps web app).
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Screenshot with editing", "omarchy capture screenshot region")

-- Fresh, independent tmux session each time (default runs `tmux attach ||
-- tmux new -s Work`, which double-attaches to the most-recent session and
-- mirrors it).
hl.unbind("SUPER + ALT + RETURN")
o.bind("SUPER + ALT + RETURN", "Tmux", "omarchy-launch-terminal bash -c 'tmux new'")

-- Media controls via playerctl.
o.bind("SUPER + bracketright", "Next track", "playerctl next")
o.bind("SUPER + bracketleft", "Pause", "playerctl play-pause")

-- Vim-style window-group navigation (default SUPER+L toggles workspace layout).
hl.unbind("SUPER + L")
o.bind("SUPER + H", "Previous window in group", hl.dsp.group.prev())
o.bind("SUPER + L", "Next window in group", hl.dsp.group.next())

-- Move window to workspace 2 and place it on that monitor's right half.
-- Replaces the default plain "move to workspace 2" (bound as code:11).
hl.unbind("SUPER + SHIFT + code:11")
o.bind("SUPER + SHIFT + code:11", "Move window to workspace 2 (half)", "/home/tsewnai/.config/hypr/scripts/move-to-ws2-half.sh")
