local M = {
	"Mofiqul/vscode.nvim",
	lazy = false,
	priority = 1000,
}

M.name = "vscode"

M.config = function()
	local c = require("vscode.colors").get_colors()

	require("vscode").setup({
		transparent = false,
		italic_comments = false,
		disable_nvimtree_bg = true,
		color_overrides = {
			vscPopupBack = c.vscBack,
		},
		group_overrides = {
			cursor = {
				fg = c.vscCursorDarkDark,
				bg = c.vscLightRed,
				bold = true,
			},
			NeoTreeGitConflict = {
				fg = c.vscOrange,
				bold = false,
				italic = false,
			},
			NeoTreeRootName = {
				bold = true,
			},
			MatchParen = {
				bg = c.vscNone,
				fg = c.vscLightRed,
				bold = true,
			},
			CursorLineNr = {
				bg = c.vscCursorDarkDark,
			},
			FlashLabel = {
				bg = c.vscDiffRedDark,
			},
		},
	})
	require("vscode").load()

	local status_ok, _ = pcall(vim.cmd.colorscheme, M.name)
	if not status_ok then
		return
	end
end

return M
