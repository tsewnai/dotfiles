-- All workspace-to-monitor rules live here. This file is the ONLY source of
-- truth for workspace placement.
--
-- hyprmoncfg owns monitor geometry and nothing else: its workspace management
-- is switched off at the source (workspaces.enabled = false in
-- ~/.config/hyprmoncfg/profiles/profile-1.json), so the file it generates
-- contains no workspace rules to fight with. Parse order does not matter any
-- more -- and it could not have settled this on its own, because hyprmoncfgd
-- dispatches moveworkspacetomonitor at runtime and was always the last writer.
--
-- Do not re-save the profile with `hyprmoncfg save` or the TUI without
-- re-checking that flag: a fresh capture can turn workspace rules back on.

local LAPTOP = "eDP-1"
local LAPTOP_FALLBACK = "DP-5"

local LEFT = "desc:Ancor Communications Inc ASUS PB278 J1LMTF116908"
local CENTER = "desc:Ancor Communications Inc ASUS PB278 J9LMTF050838"
local PORTRAIT = "desc:Dell Inc. DELL P2219H GVY67W2"
local HOME = "desc:Acer Technologies K272HL H 12110194E3W01"

local function apply()
  -- A disabled monitor is dropped from the monitor list, so a nil lookup means "off".
  local laptop = hl.get_monitor(LAPTOP) and LAPTOP or LAPTOP_FALLBACK

  -- Every output that can be connected owns a workspace, so none is ever left
  -- to claim a free id on its own. Rules naming an absent monitor are ignored,
  -- so the docked set (1-4) and the home set (1, 5) coexist in one file.
  hl.workspace_rule({ workspace = "1", monitor = laptop, default = true })
  hl.workspace_rule({ workspace = "2", monitor = LEFT, default = true })
  hl.workspace_rule({ workspace = "3", monitor = CENTER, default = true })
  hl.workspace_rule({ workspace = "4", monitor = PORTRAIT, default = true })
  hl.workspace_rule({ workspace = "5", monitor = HOME, default = true })

  if hl.get_monitor(laptop) then
    hl.dispatch(hl.dsp.workspace.move({ workspace = "1", monitor = laptop }))
  end
end

-- monitor.removed fires before the monitor leaves the list, so re-check on the next tick.
local function apply_soon()
  hl.timer(apply, { timeout = 250, type = "oneshot" })
end

apply()

-- Re-assert on every layout change: hyprmoncfg rewrites its rules at runtime,
-- not only at config load, so a one-shot apply() at startup is not enough.
hl.on("monitor.added", apply_soon)
hl.on("monitor.removed", apply_soon)
hl.on("monitor.layout_changed", apply_soon)
