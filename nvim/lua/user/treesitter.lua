local M = {
	"nvim-treesitter/nvim-treesitter",
	event = "BufReadPost",
}

function M.config()
	local configs = require("nvim-treesitter.configs")

	configs.setup({
		ensure_installed = {
			"lua",
			"markdown",
			"markdown_inline",
			"bash",
			"python",
			"javascript",
			"html",
			"typescript",
			"php",
			"json",
			"jsonc",
		},
		ignore_install = {},
		sync_install = false,
		highlight = {
			enable = not vim.g.vscode,
			disable = function(lang, buf)
				local max_filesize = 100 * 1024 -- 100 KB
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					return true
				end
			end,
		},
		autopairs = {
			enable = true,
		},
		indent = { enable = true, disable = { "python", "css" } },
		fold = {
			enable = true,
		},
		matchup = {
			enable = true,
			disable = { "c", "ruby" },
		},
	})
end

return M
