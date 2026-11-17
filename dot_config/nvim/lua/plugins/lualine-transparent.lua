-- Let the status line show the terminal background, like the rest of the
-- editor. Lualine's auto theme paints its middle sections a solid colour, so
-- they are cleared on each theme it builds, which it does again on every
-- colorscheme change. The mode and position sections keep their colours.
--
-- A colorscheme can recolour the mode section by defining LualineMode<Mode>
-- highlight groups (LualineModeNormal, LualineModeInsert, ...): bg is the
-- mode block, fg its text. The Hagalaz theme's neovim.lua does this; themes
-- without them keep lualine's own colours.
return {
	"nvim-lualine/lualine.nvim",
	opts = function(_, opts)
		local function hex(n)
			return n and string.format("#%06x", n)
		end

		opts.options = opts.options or {}
		opts.options.theme = function()
			local theme = require("lualine.utils.loader").load_theme("auto")
			for mode, sections in pairs(theme) do
				local hl = vim.api.nvim_get_hl(0, { name = "LualineMode" .. (mode:gsub("^%l", string.upper)), link = false })
				if hl.bg then
					sections.a = vim.tbl_extend("force", sections.a or {}, { bg = hex(hl.bg), fg = hex(hl.fg) })
					sections.b = vim.tbl_extend("force", sections.b or {}, { fg = hex(hl.bg) })
				end
				for _, section in ipairs({ "b", "c" }) do
					if sections[section] then
						sections[section].bg = "None"
					end
				end
			end
			return theme
		end

		-- No clock in the status line.
		opts.sections = opts.sections or {}
		opts.sections.lualine_z = {}
	end,
}
