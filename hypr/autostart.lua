-- omarchy-launch-browser spawns through `systemd-run --user`, so Hyprland cannot
-- attribute the window back to the exec and an exec-scoped { workspace = "3" }
-- rule silently does nothing (omarchy also defaults initial_workspace_tracking
-- to 0). A class rule is the only thing that survives the detached launch.
-- Anchored so it misses the chrome-outlook.* / chrome-teams.* web apps.
o.window("^chromium$", { workspace = "3" })

-- Extra autostart processes.
hl.on("hyprland.start", function()
  hl.exec_cmd("az login && omarchy-launch-webapp https://outlook.office.com && omarchy-launch-webapp https://teams.cloud.microsoft/")
  hl.exec_cmd("omarchy-launch-browser")
  hl.exec_cmd("sleep 3 && omarchy shell -q quickshell.spotify.player toggleFullPlayer")
  hl.exec_cmd("sleep 2 && uwsm-app -- ghostty -e tmux new-session -s GitHub 'bash -i -c \"ghdash\"'", { workspace = "2 silent" })
  hl.exec_cmd("solaar --window=hide")
end)
