local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

-- load lazy
require("lazy").setup("user", {
	install = { colorscheme = { require("user.colorscheme").name } },
	defaults = { lazy = true, version = "57cce98dfdb2f2dd05a0567d89811e6d0505e13b" },
	ui = { wrap = "true", border = "rounded" },
	change_detection = { enabled = true, notify = false },
	debug = false,
	performance = {
		rtp = {
			disabled_plugins = {
				-- "gzip", -- Plugin for editing compressed files.
				-- "matchit", -- What is it?
				--  "matchparen", -- Plugin for showing matching parens
				--  "netrwPlugin", -- Handles file transfers and remote directory listing across a network
				--  "tarPlugin", -- Plugin for browsing tar files
				--  "tohtml", -- Converting a syntax highlighted file to HTML
				--  "tutor", -- Teaching?
				--  "zipPlugin", -- Handles browsing zipfiles
			},
		},
	},
})
