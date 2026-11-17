-- Square corners on the which-key menu (<leader>). LazyVim's "helix" preset
-- hard-codes a rounded border, so it ignores vim.o.winborder.
return {
	"folke/which-key.nvim",
	opts = {
		win = { border = "single" },
	},
}
