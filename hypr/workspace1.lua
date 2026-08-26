-- Workspace 1 follows the laptop panel: eDP-1 when it is enabled, DP-5 otherwise.
-- Loaded after hyprmoncfg's generated rules so it wins over whatever profile is applied.

local PRIMARY = "eDP-1"
local FALLBACK = "DP-5"

local function apply()
  -- A disabled monitor is dropped from the monitor list, so a nil lookup means "off".
  local target = hl.get_monitor(PRIMARY) and PRIMARY or FALLBACK

  hl.workspace_rule({ workspace = "1", monitor = target, default = true })

  if hl.get_monitor(target) then
    hl.dispatch(hl.dsp.workspace.move({ workspace = "1", monitor = target }))
  end
end

-- monitor.removed fires before the monitor leaves the list, so re-check on the next tick.
local function apply_soon()
  hl.timer(apply, { timeout = 250, type = "oneshot" })
end

apply()

hl.on("monitor.added", apply_soon)
hl.on("monitor.removed", apply_soon)
hl.on("monitor.layout_changed", apply_soon)
