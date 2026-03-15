return {
  desc = "Launch DAP after task completes successfully",
  params = {
    program = {
      desc = "Path to the DLL to debug",
      type = "string",
      optional = true,
    },
    cwd = {
      desc = "Working directory for the debug session",
      type = "string",
      optional = true,
    },
  },
  constructor = function(params)
    return {
      on_complete = function(self, task, status)
        if status == "SUCCESS" then
          vim.schedule(function()
            pcall(function()
              require("lazy").load({ plugins = { "nvim-dap" } })
            end)
            local ok, dap = pcall(require, "dap")
            if ok then
              if params.program then
                dap.run({
                  type = "netcoredbg",
                  name = "Debug",
                  request = "launch",
                  program = params.program,
                  cwd = params.cwd or vim.fn.fnamemodify(params.program, ":h"),
                  env = { ASPNETCORE_ENVIRONMENT = "Development" },
                })
              else
                dap.continue()
              end
            else
              vim.notify("nvim-dap not available. Enable the 'dap' LazyExtras extra.", vim.log.levels.ERROR)
            end
          end)
        end
      end,
    }
  end,
}
