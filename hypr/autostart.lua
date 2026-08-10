-- Extra autostart processes.
hl.on("hyprland.start", function()
  hl.exec_cmd("az login && omarchy-launch-webapp https://outlook.office.com && omarchy-launch-webapp https://teams.cloud.microsoft/")
  hl.exec_cmd("omarchy-launch-browser", { workspace = "3" })
  hl.exec_cmd("uwsm-app -- spotify", { workspace = "1 silent" })
  hl.exec_cmd("sleep 2 && uwsm-app -- ghostty -e tmux new-session -s GitHub 'bash -i -c \"ghdash\"'", { workspace = "2 silent" })
  hl.exec_cmd("solaar --window=hide")
end)
