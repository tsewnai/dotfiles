local LEFT = "Ancor Communications Inc ASUS PB278 J1LMTF116908"
local CENTER = "Ancor Communications Inc ASUS PB278 J9LMTF050838"

-- Workspaces are per monitor now (Omarchy 4.5), so a slot's id depends on the
-- monitor's block. Nil when the monitor isn't connected. The workspace rule
-- matters when the slot doesn't exist yet: Hyprland would otherwise create it on
-- the focused monitor, and Omarchy's reconcile then renumbers it into that block.
local function slot_on(description, slot)
  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.description == description then
      local id = tostring(o.workspaces.workspace_id(monitor, slot))
      hl.workspace_rule({ workspace = id, monitor = "desc:" .. description })
      return id
    end
  end
end

-- omarchy-launch-browser spawns through `systemd-run --user`, so Hyprland cannot
-- attribute the window back to the exec and an exec-scoped workspace rule
-- silently does nothing (omarchy also defaults initial_workspace_tracking to 0).
-- A class rule is the only thing that survives the detached launch. It is named
-- so it can be re-pointed as monitors come and go.
-- Anchored so it misses the chrome-outlook.* / chrome-teams.* web apps.
local function place_chromium()
  local workspace = slot_on(CENTER, 1)
  if workspace then
    hl.window_rule({ name = "chromium-center", enabled = true, match = { class = "^chromium$" }, workspace = workspace })
  else
    hl.window_rule({ name = "chromium-center", enabled = false })
  end
end

-- lock-explorer picks the screen for its password field by connector name, and
-- shows it on every screen when that name is gone. The dock renames connectors
-- between plugs, so re-point it at the center ASUS whenever monitors change.
-- Compared against shell.json first because setInputMonitor rewrites it.
local function configured_lock_input()
  local file = io.open(os.getenv("HOME") .. "/.config/omarchy/shell.json", "r")
  if not file then
    return nil
  end
  local content = file:read("a")
  file:close()
  return content:match('"inputMonitor"%s*:%s*"([^"]*)"')
end

local function sync_lock_input(delay)
  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.description == CENTER and monitor.name ~= configured_lock_input() then
      local command = "omarchy shell lock setInputMonitor " .. monitor.name
      hl.exec_cmd(delay and ("sleep " .. delay .. " && " .. command) or command)
    end
  end
end

local function monitors_changed()
  place_chromium()
  sync_lock_input()
end

place_chromium()
sync_lock_input()
hl.on("monitor.added", monitors_changed)
hl.on("monitor.layout_changed", monitors_changed)
-- monitor.removed fires before the monitor leaves the list, so re-check on the next tick.
hl.on("monitor.removed", function()
  hl.timer(monitors_changed, { timeout = 250, type = "oneshot" })
end)

-- Extra autostart processes.
hl.on("hyprland.start", function()
  hl.exec_cmd("az login && omarchy-launch-webapp https://outlook.office.com && omarchy-launch-webapp https://teams.cloud.microsoft/")
  hl.exec_cmd("omarchy-launch-browser")
  local ghdash = slot_on(LEFT, 1)
  hl.exec_cmd(
    "sleep 2 && uwsm-app -- ghostty -e tmux new-session -s GitHub 'bash -i -c \"ghdash\"'",
    ghdash and { workspace = ghdash .. " silent" } or {}
  )
  hl.exec_cmd("solaar --window=hide")
  -- The shell isn't up yet when the config first loads.
  sync_lock_input(10)
end)
