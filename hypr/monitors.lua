-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Optimized for retina-class 2x displays.
hl.env("GDK_SCALE", "2")

-- HiDPI internal display (internal panel, stays on eDP-1).
hl.monitor({ output = "eDP-1", mode = "3456x2160@60", position = "0x1440", scale = 2 })

-- Left QHD -- ASUS PB278, serial J1LMTF116908.
hl.monitor({ output = "desc:Ancor Communications Inc ASUS PB278 J1LMTF116908", mode = "2560x1440@60", position = "-2560x0", scale = 1 })

-- Center QHD -- ASUS PB278, serial J9LMTF050838.
hl.monitor({ output = "desc:Ancor Communications Inc ASUS PB278 J9LMTF050838", mode = "2560x1440@60", position = "0x0", scale = 1 })

-- Right portrait 1080p -- Dell P2219H, serial GVY67W2 (transform 3 = 270 degrees).
hl.monitor({ output = "desc:Dell Inc. DELL P2219H GVY67W2", mode = "1920x1080@59.9510", position = "2560x-240", scale = 1, transform = 3 })

-- Fallback for any unrecognized monitor (e.g. projector, new display).
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- Workspace assignments.
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "desc:Ancor Communications Inc ASUS PB278 J1LMTF116908", default = true })
hl.workspace_rule({ workspace = "3", monitor = "desc:Ancor Communications Inc ASUS PB278 J9LMTF050838", default = true })
hl.workspace_rule({ workspace = "4", monitor = "desc:Dell Inc. DELL P2219H GVY67W2", default = true })
