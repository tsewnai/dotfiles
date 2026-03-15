-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- DAP / Overseer (VS Code-style)
vim.keymap.set("n", "<F5>",   "<cmd>OverseerRun<cr>",                            { desc = "Run task" })
vim.keymap.set("n", "<C-F5>", function() require("dap").continue() end,          { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F9>",   function() require("dap").toggle_breakpoint() end, { desc = "Debug: Toggle breakpoint" })
vim.keymap.set("n", "<D-c>", '"+yy', { desc = "Copy line to clipboard" })
vim.keymap.set("v", "<D-c>", '"+y',  { desc = "Copy selection to clipboard" })
