return {
  -- Add Crashdummyy's registry so :MasonInstall roslyn works
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
    },
  },

  -- Format C# via Roslyn LSP (matches VS Code C# Dev Kit); don't run csharpier
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs = {},
      },
    },
  },

  -- Disable OmniSharp from the lang.dotnet extra
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = { enabled = false },
        -- lspconfig auto-enables this because mason has roslyn installed; it duplicates
        -- roslyn.nvim's client -- two servers per nvim, each with its own watches and heap.
        roslyn_ls = { enabled = false },
      },
    },
  },

  -- Roslyn LSP (modern C# language server used by VS Code & Visual Studio)
  {
    "seblj/roslyn.nvim",
    ft = "cs",
    opts = {
      broad_search = true,
      cmd = {
        vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "roslyn"),
        "--logLevel=Information",
        "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
        "--stdio",
      },
    },
  },

  -- Close dapui when the debug session disconnects (e.g. process killed externally)
  {
    "rcarriga/nvim-dap-ui",
    optional = true,
    opts = function()
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.before.disconnect["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- Aspire attach configs (launch.json processName/processId aren't resolved by netcoredbg)
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      dap.configurations.cs = dap.configurations.cs or {}
      table.insert(dap.configurations.cs, {
        type = "netcoredbg",
        name = "Attach to Aspire.ApiService (nvim)",
        request = "attach",
        processId = function()
          return require("dap.utils").pick_process({
            filter = function(proc) return proc.name:find("Aspire.ApiService/bin") ~= nil end
          })
        end,
      })
    end,
  },
}
