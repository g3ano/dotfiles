local M = {
	"kylechui/nvim-surround",
	version = "*",
	event = "VeryLazy",
}

M.config = function()
	local status_ok, nvim_surround = pcall(require, "nvim-surround")
	if not status_ok then
		return
	end
	nvim_surround.setup()
end

return M
