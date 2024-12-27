return {
	"zk-org/zk-nvim",
	config = function()
		-- local lspconfig = require('lspconfig')
		-- local configs = require("lspconfig/configs")

		require("zk").setup({
			picker = "fzf",

			lsp = {
				-- `config` is passed to `vim.lsp.start_client(config)`
				config = {
					cmd = { "zk", "lsp" },
					name = "zk",
					-- on_attach = ...
					-- etc, see `:h vim.lsp.start_client()`
				},

				-- automatically attach buffers in a zk notebook that match the given filetypes
				auto_attach = {
					enabled = true,
					filetypes = { "markdown" },
				},
			},
		})

		vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
			pattern = { "/home/dot/.local/share/zk/*.md" },
			callback = function()
				vim.cmd("$")
				vim.cmd("startinsert")
			end,
		})
	end,
}
