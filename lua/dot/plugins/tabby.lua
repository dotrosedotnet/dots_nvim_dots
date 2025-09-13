return {
	"nanozuki/tabby.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- Use simple preset for testing
		require('tabby').setup({
			preset = 'tab_only',
		})
		
		-- Ensure tabline is always visible
		vim.o.showtabline = 2
	end,
}