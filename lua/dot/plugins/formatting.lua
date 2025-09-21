return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				vue = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier", "markdownlint-cli2" },
				["markdown.mdx"] = { "prettier" },
				graphql = { "prettier" },
				handlebars = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
				fish = { "shfmt" },
				nix = { "nixpkgs-fmt" },
				java = { "google-java-format" },
				go = { "goimports", "gofmt" },
				rust = { "rustfmt", lsp_format = "fallback" },
				toml = { "taplo" },
				-- Use injected formatter for code blocks in markdown, etc.
				["_"] = { "trim_whitespace" },
			},
			format_on_save = function(bufnr)
				-- Disable with a global or buffer-local variable
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				-- Disable for certain filetypes
				local ignore_filetypes = { "sql", "proto" }
				if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
					return
				end
				return {
					timeout_ms = 2000,
					lsp_format = "fallback",
					async = false,
				}
			end,
			-- Log level
			log_level = vim.log.levels.ERROR,
			-- Notify on format errors
			notify_on_error = true,
		})

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				-- FormatDisable! will disable formatting just for this buffer
				vim.b.disable_autoformat = true
			else
				vim.g.disable_autoformat = true
			end
		end, {
			desc = "Disable autoformat-on-save",
			bang = true,
		})
		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, {
			desc = "Re-enable autoformat-on-save",
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
