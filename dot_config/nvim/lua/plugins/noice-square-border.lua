-- Square corners on noice's popups (its defaults are rounded) and a border on
-- LSP hover docs, which noice shows without one. Colours come from the
-- colorscheme (NoiceCmdlinePopupBorder*, FloatBorder, ...).
return {
	"folke/noice.nvim",
	opts = {
		views = {
			popup = { border = { style = "single" } },
			cmdline_popup = { border = { style = "single" } },
			cmdline_input = { border = { style = "single" } },
			confirm = { border = { style = "single" } },
			popupmenu = { border = { style = "single", padding = { 0, 1 } } },
			hover = { border = { style = "single", padding = { 0, 1 } } },
		},
	},
}
