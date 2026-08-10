require("config.remote_clipboard").setup()
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.backupcopy = "yes" -- fix Vite HMR: prevents atomic rename that breaks inotify watchers
vim.opt.scrolloff = 8

-- Prioritize git root over LSP root so Telescope searches from the repo root
-- instead of the nearest package.json/LSP root (e.g. a vite subdirectory).
-- LSP root detection is unaffected — each LSP still uses its own root_dir logic.
vim.g.root_spec = { ".git", "lsp", "cwd" }
