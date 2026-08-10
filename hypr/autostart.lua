-- Personal startup processes.
hl.on("hyprland.start", function()
  -- Sign in to Azure, then open Outlook and Teams as web apps.
  hl.exec_cmd("az login && omarchy-launch-webapp https://outlook.office.com && omarchy-launch-webapp https://teams.cloud.microsoft/")

  -- Browser on workspace 3.
  hl.exec_cmd("[workspace 3] omarchy-launch-browser")

  -- Spotify on workspace 1.
  hl.exec_cmd("[workspace 1 silent] uwsm-app -- spotify")

  -- GitHub dashboard in a tmux session on workspace 2.
  hl.exec_cmd([[ [workspace 2 silent] sleep 2 && uwsm-app -- ghostty -e tmux new-session -s GitHub 'bash -i -c "ghdash"' ]])

  -- Solaar (Logitech) to tray, started hidden.
  hl.exec_cmd(o.launch("solaar --window=hide"))
end)
