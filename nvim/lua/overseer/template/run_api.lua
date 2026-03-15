return {
  name = "Run API",
  builder = function()
    return {
      cmd = { "dotnet" },
      args = { "run", "--project", "src/WaaS.IntegrationService.Api" },
      components = { "default", { "open_output", direction = "dock", focus = true }, "open_browser_on_ready" },
    }
  end,
  condition = {
    dir = "/home/tsewnai/repos/work/WaaS.IntegrationService",
  },
}
