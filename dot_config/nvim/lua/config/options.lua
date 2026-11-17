-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- Square borders on floating windows (LSP hover/diagnostics, snacks pickers,
-- notifications and inputs, blink completion, mason all follow this).
vim.o.winborder = "single"
