return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- Core dependencies
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },

		-- SchemaStore for JSON/YAML schemas
		require("dot.plugins.lsp.schemastore"),

		-- UI enhancements
		require("dot.plugins.lsp.lsp-utils"), -- Trouble.nvim
		require("dot.plugins.lsp.lsp-info"),  -- Fidget.nvim
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		-- Enhanced capabilities from nvim-cmp
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Diagnostic configuration
		vim.diagnostic.config({
			virtual_text = {
				prefix = "●",
				spacing = 4,
			},
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		-- Diagnostic signs
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Border for hover and signature help
		local border = {
			{ "╭", "FloatBorder" },
			{ "─", "FloatBorder" },
			{ "╮", "FloatBorder" },
			{ "│", "FloatBorder" },
			{ "╯", "FloatBorder" },
			{ "─", "FloatBorder" },
			{ "╰", "FloatBorder" },
			{ "│", "FloatBorder" },
		}

		local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or border
			return orig_util_open_floating_preview(contents, syntax, opts, ...)
		end

		-- Global on_attach function
		local on_attach = function(client, bufnr)
			local opts = { buffer = bufnr, silent = true }
			local keymap = vim.keymap

			-- Navigation
			opts.desc = "Show LSP references"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

			-- Code actions and refactoring
			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

			-- Diagnostics
			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

			opts.desc = "Go to previous diagnostic"
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

			opts.desc = "Go to next diagnostic"
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

			-- Documentation
			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", vim.lsp.buf.hover, opts)

			opts.desc = "Show signature help"
			keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, opts)

			-- Workspace
			opts.desc = "Add workspace folder"
			keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)

			opts.desc = "Remove workspace folder"
			keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)

			opts.desc = "List workspace folders"
			keymap.set("n", "<leader>wl", function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end, opts)

			-- Restart
			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

			-- Enable inlay hints if supported
			if client.server_capabilities.inlayHintProvider then
				vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				opts.desc = "Toggle inlay hints"
				keymap.set("n", "<leader>ih", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
				end, opts)
			end
		end

		-- Configure and enable specific servers
		-- Lua
		vim.lsp.config("lua_ls", {
			cmd = { "/etc/profiles/per-user/dot/bin/lua-language-server" },
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = vim.list_extend(
							vim.api.nvim_get_runtime_file("", true),
							{
								vim.fn.expand("$VIMRUNTIME/lua"),
								vim.fn.stdpath("config") .. "/lua",
							}
						),
						checkThirdParty = false,
					},
					telemetry = {
						enable = false,
					},
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})
		vim.lsp.enable("lua_ls")

		-- Python
		vim.lsp.config("pyright", {
			cmd = { "pyright" },
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						diagnosticMode = "openFilesOnly",
						useLibraryCodeForTypes = true,
						typeCheckingMode = "basic",
					},
				},
			},
		})
		vim.lsp.enable("pyright")

		-- Arduino
		local arduino_cmd
		local fqbn = "arduino:avr:uno"
		local cli_config = vim.fn.expand("~/Library/Arduino15/arduino-cli.yaml")
		if vim.fn.has("mac") == 1 and vim.fn.filereadable(cli_config) == 1 then
			arduino_cmd = {
				"arduino-language-server",
				"-cli-config",
				cli_config,
				"-fqbn",
				fqbn,
			}
		else
			arduino_cmd = {
				"arduino-language-server",
				"-fqbn",
				fqbn,
			}
		end
		vim.lsp.config("arduino_language_server", {
			capabilities = capabilities,
			on_attach = on_attach,
			cmd = arduino_cmd,
		})
		vim.lsp.enable("arduino_language_server")

		-- C/C++
		vim.lsp.config("clangd", {
			capabilities = vim.tbl_deep_extend("force", capabilities, {
				offsetEncoding = { "utf-16" },
			}),
			on_attach = on_attach,
			cmd = {
				"/etc/profiles/per-user/dot/bin/clangd",
				"--background-index",
				"--clang-tidy",
				"--header-insertion=iwyu",
				"--completion-style=detailed",
				"--function-arg-placeholders",
				"--fallback-style=llvm",
			},
		})
		vim.lsp.enable("clangd")

		-- Nix
		vim.lsp.config("nixd", {
			cmd = { "nixd" },
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				nixd = {
					nixpkgs = {
						expr = "import <nixpkgs> { }",
					},
					formatting = {
						command = { "nixpkgs-fmt" },
					},
				},
			},
		})
		vim.lsp.enable("nixd")

		-- JSON with schemas
		vim.lsp.config("jsonls", {
			cmd = { "vscode-json-language-server", "--stdio" },
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
					validate = { enable = true },
				},
			},
		})
		vim.lsp.enable("jsonls")

		-- TypeScript/JavaScript
		vim.lsp.config("ts_ls", {
			cmd = { "typescript-language-server", "--stdio" },
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		})
		vim.lsp.enable("ts_ls")

		-- YAML with schemas
		vim.lsp.config("yamlls", {
			cmd = { "yaml-language-server", "--stdio" },
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				yaml = {
					schemaStore = {
						enable = false,
						url = "",
					},
					schemas = require("schemastore").yaml.schemas(),
				},
			},
		})
		vim.lsp.enable("yamlls")

		-- Simple servers with explicit commands
		local simple_servers = {
			{ name = "clojure_lsp", cmd = { "clojure-lsp" } },
			{ name = "beancount", cmd = { "beancount-language-server" } },
			{ name = "jqls", cmd = { "jq-lsp" } },
			{ name = "marksman", cmd = { "marksman" } },
			{ name = "vimls", cmd = { "vim-language-server", "--stdio" } },
			{ name = "dockerls", cmd = { "docker-langserver", "--stdio" } },
			{ name = "docker_compose_language_service", cmd = { "docker-compose-langserver", "--stdio" } },
			{ name = "intelephense", cmd = { "intelephense", "--stdio" } },
			{ name = "html", cmd = { "vscode-html-language-server", "--stdio" } },
			{ name = "cssls", cmd = { "vscode-css-language-server", "--stdio" } },
			{ name = "eslint", cmd = { "vscode-eslint-language-server", "--stdio" } },
			{ name = "bashls", cmd = { "bash-language-server", "start" } },
			{ name = "jdtls", cmd = { "jdtls" } },
			{ name = "hls", cmd = { "haskell-language-server", "--lsp" } },
		}

		for _, server in ipairs(simple_servers) do
			vim.lsp.config(server.name, {
				cmd = server.cmd,
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.enable(server.name)
		end
	end,
}