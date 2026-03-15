return {
  name = "Debug API",
  builder = function()
    local cwd = vim.fn.getcwd()
    return {
      cmd = { "dotnet" },
      args = { "build", "src/WaaS.IntegrationService.Api" },
      components = {
        "default",
        {
          "dap_launch",
          program = cwd .. "/src/WaaS.IntegrationService.Api/bin/Debug/net10.0/WaaS.IntegrationService.Api.dll",
          cwd = cwd .. "/src/WaaS.IntegrationService.Api",
        },
      },
    }
  end,
  condition = {
    dir = "/home/tsewnai/repos/work/WaaS.IntegrationService",
  },
}
