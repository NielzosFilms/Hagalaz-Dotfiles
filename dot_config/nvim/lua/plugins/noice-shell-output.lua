-- Neovim 0.12 tags :!cmd output as "shell_out"/"shell_err" messages, which
-- noice doesn't route anywhere visible. Show them in a split (close with q).
local shell_filter = { event = "msg_show", kind = { "shell_out", "shell_err" } }

return {
	"folke/noice.nvim",
	opts = function(_, opts)
		opts.routes = opts.routes or {}
		table.insert(opts.routes, 1, {
			view = "split",
			filter = shell_filter,
		})

		-- The split shows every routed message, so clear the previous command's
		-- output before a new :!cmd runs; otherwise results pile up.
		vim.api.nvim_create_autocmd("CmdlineLeave", {
			group = vim.api.nvim_create_augroup("noice_shell_output", { clear = true }),
			callback = function()
				if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline():match("^%s*!") then
					for _, route in ipairs(require("noice.message.router")._routes or {}) do
						if vim.deep_equal(route.filter, shell_filter) then
							route.view:clear()
						end
					end
				end
			end,
		})
	end,
}
