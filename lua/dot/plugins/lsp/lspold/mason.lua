return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "→",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			ensure_installed = {
        -- "awk_ls",
				"arduino_language_server",
				"cssls",
				"bashls",
				"beancount",
				"clangd",
				"cmake",
				"clojure_lsp",
				"html",
				"jsonls",
				"jdtls",
				"tsserver",
				"jqls",
				"texlab",
				"lua_ls",
				"autotools_ls",
				"marksman",
				"mutt_ls",
        -- "ocamllsp",
        "nil_ls",
				"pyright",
				"taplo",
				"vimls",
        "dockerls",
        "docker_compose_language_service",
			},
		})
		mason_tool_installer.setup({
			ensure_installed = {
				"clj-kondo",
				"prettier",
				"stylua",
				"isort",
				"black",
				"pylint",
				"eslint_d",
				"intelephense",
			},
		})
	end,
}
