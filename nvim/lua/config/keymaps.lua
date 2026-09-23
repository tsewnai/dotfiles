-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- DAP / Overseer (VS Code-style)
vim.keymap.set("n", "<F4>",   "<cmd>OverseerRun<cr>",                            { desc = "Run task" })
vim.keymap.set("n", "<F5>",   function() require("dap").continue() end,          { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F9>",   function() require("dap").toggle_breakpoint() end, { desc = "Debug: Toggle breakpoint" })
vim.keymap.set("n", "<F10>",  function() require("dap").step_over() end,         { desc = "Debug: Step over" })
vim.keymap.set("n", "<F11>",  function() require("dap").step_into() end,         { desc = "Debug: Step into" })
vim.keymap.set("n", "<F12>",  function() require("dap").step_out() end,          { desc = "Debug: Step out" })
vim.keymap.set("n", "<D-c>", '"+yy', { desc = "Copy line to clipboard" })
vim.keymap.set("v", "<D-c>", '"+y',  { desc = "Copy selection to clipboard" })

vim.keymap.set("n", "<leader>gm", function() Snacks.picker.git_diff({ base = "origin/main" }) end, { desc = "Git diff vs origin/main" })
