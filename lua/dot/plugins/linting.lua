return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			python = { "pylint" },
			sh = { "shellcheck" },
			bash = { "shellcheck" },
			zsh = { "shellcheck" },
			dockerfile = { "hadolint" },
			markdown = { "markdownlint" },
			json = { "jsonlint" },
			yaml = { "yamllint" },
			lua = { "luacheck" },
		}

		-- Create autocommand for linting
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
			group = lint_augroup,
			callback = function()
				-- Only lint if the buffer is attached to an LSP client
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				if #clients > 0 then
					lint.try_lint()
				end
			end,
		})

		-- Manual lint trigger
		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })

		-- Show linter name in status
		vim.keymap.set("n", "<leader>li", function()
			local linters = lint.get_running()
			if #linters == 0 then
				vim.notify("No linters running", vim.log.levels.INFO)
			else
				vim.notify("Running linters: " .. table.concat(linters, ", "), vim.log.levels.INFO)
			end
		end, { desc = "Show running linters" })
	end,
}
