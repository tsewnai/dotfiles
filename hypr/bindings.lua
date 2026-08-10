-- Personal keybinding overrides. Omarchy defaults load first, so unbind an
-- existing key before rebinding it.
-- See current bindings: omarchy menu keybindings --print

-- Typora instead of the default Omawrite on SUPER+SHIFT+W.
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", { launch = "typora --enable-wayland-ime" })

-- Screenshot on SUPER+SHIFT+S (default was Google Maps) — for keyboards
-- without a PrintScreen key.
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Screenshot with editing", "omarchy capture screenshot region")

-- Workspace navigation with , and .
o.bind("SUPER + comma", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("SUPER + period", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))

-- Media controls (playerctl is gone in quattro; use the shell's media bridge).
o.bind("SUPER + bracketright", "Next track", "omarchy-shell media next")
o.bind("SUPER + bracketleft", "Pause", "omarchy-shell media playPause")

-- Move window to workspace 2 with half-width pseudo-tiling on the center monitor.
hl.unbind("SUPER + SHIFT + 2")
o.bind(
  "SUPER + SHIFT + 2",
  "Move window to workspace 2 (half)",
  os.getenv("HOME") .. "/.config/hypr/scripts/move-to-ws2-half.sh"
)

-- Vim-style window group navigation (SUPER+L default was: toggle workspace layout).
hl.unbind("SUPER + L")
o.bind("SUPER + H", "Previous window in group", hl.dsp.group.prev())
o.bind("SUPER + L", "Next window in group", hl.dsp.group.next())

-- Free up SUPER+/ (was unused in the old setup).
hl.unbind("SUPER + Slash")
