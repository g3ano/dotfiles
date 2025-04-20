local M = {
	"numToStr/Comment.nvim",
	event = { "BufRead", "BufNewFile" },
	keys = { { "gc", mode = { "n", "v" } }, { "gb", mode = { "n", "v" } } },
}

function M.config()
	local setup = {
		padding = true,
		sticky = true,
		ignore = "^$",
		mappings = {
			basic = true,
			extra = true,
		},
		toggler = {
			line = "gcc",
			block = "gbc",
		},
		opleader = {
			line = "gc",
			block = "gb",
		},
		extra = {
			above = "gcO",
			below = "gco",
			eol = "gcA",
		},
	}

	local status_ok, nvim_comment = pcall(require, "Comment")
	if not status_ok then
		return
	end
	nvim_comment.setup(setup)
end

return M
