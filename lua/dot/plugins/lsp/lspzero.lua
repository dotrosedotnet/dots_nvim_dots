return {
	"VonHeikemen/lsp-zero.nvim",
	-- branch = '',
	dependencies = {
		"hrsh7th/nvim-cmp",
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
	},
	config = function()
		local lsp_zero = require("lsp-zero")
		local MY_FQBN = "arduino:avr:uno"

		lsp_zero.on_attach(function(client, bufnr)
			-- see :help lsp-zero-keybindings
			-- to learn the available actions
			lsp_zero.default_keymaps({ buffer = bufnr })
		end)

		require("lspconfig").lua_ls.setup({})
		require("lspconfig").clojure_lsp.setup({})
		require("lspconfig").pyright.setup({})
		require("lspconfig").arduino_language_server.setup({
			cmd = {
				"arduino-language-server",
				"-cli-config",
				"/Users/dot/Library/Arduino15/arduino-cli.yaml",
				"-fqbn",
				MY_FQBN,
			},
		})
		require("lspconfig").clangd.setup({})
		require("lspconfig").beancount.setup({})
		require("lspconfig").jqls.setup({})
		require("lspconfig").marksman.setup({})
		require("lspconfig").vimls.setup({})
		require("lspconfig").nixd.setup({})
		-- require("lspconfig").nil.setup({})
		require("lspconfig").dockerls.setup({})
		require("lspconfig").docker_compose_language_service.setup({})
		require("lspconfig").intelephense.setup({})
		require("lspconfig").html.setup({})
		require("lspconfig").cssls.setup({})
		require("lspconfig").eslint.setup({})
		require("lspconfig").jsonls.setup({})
		require("lspconfig").bashls.setup({})
		require("lspconfig").jdtls.setup({})
	end,
}
