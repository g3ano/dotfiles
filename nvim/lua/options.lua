local options = {
	backup = false,
	clipboard = "unnamedplus",
	fileencoding = "utf-8",
	hlsearch = true,
	ignorecase = true,
	mouse = "a",
	smartcase = true,
	smartindent = true,
	swapfile = false,
	termguicolors = true,
	timeout = true,
	timeoutlen = 500,
	undofile = true,
	updatetime = 300,
	writebackup = false,
	number = true,
	relativenumber = true,
	ruler = false,
	numberwidth = 2,
	wrap = true,
	spelllang = "en",
	tabstop = 4,
	shiftwidth = 4,
	softtabstop = 4,
	expandtab = true,
	autoindent = true,
	backspace = "indent,eol,start",
	linespace = 1,
	autowriteall = true,
}

for k, v in pairs(options) do
	vim.opt[k] = v
end


