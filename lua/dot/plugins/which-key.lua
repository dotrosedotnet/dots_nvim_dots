return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	-- opts = {
	--   -- your configuration comes here
	--   -- or you can leave it empty for defaults
	-- },
	config = function(_, opts)
		require("which-key").setup(opts)
		local present, wk = pcall(require, "which-key")
		if not present then
			return
		end
		wk.add({
			{
				"<leader>",
				group = {
					e = { name = "Explorer" },
					f = { name = "Find" },
					s = { name = "Splits" },
					t = { name = "Tabs" },
					w = { name = "Sessions" },
					x = { name = "Diagnostics" },
				},
			},
			{ "<localleader>j", name = "+Journal" },
			{ "<localleader>jp", "<cmd>Neorg journal yesterday<CR>", desc = "<- Yesterday" },
			{ "<localleader>jn", "<cmd>Neorg journal tomorrow<CR>", desc = "-> Tomorrow" },
			{ "<localleader>jt", "<cmd>Neorg journal today<CR>", desc = "↓Today" },
			{ "<leader>n", name = "+Neorg" },
			{ "<leader>nw", name = "+Workspaces" },
			{ "<leader>nwe", "<cmd>Neorg workspace exercise<cr>", desc = "Exercise" },
			{ "<leader>nwf", "<cmd>Neorg workspace food<cr>", desc = "Food" },
			{ "<leader>nwp", "<cmd>Neorg workspace practice<cr>", desc = "Practice" },
			{ "<leader>nwg", "<cmd>Neorg workspace general<cr>", desc = "General" },
			{ "<leader>nj", name = "+Journal" },
			{ "<leader>nje", "<cmd>Neorg workspace exercise <CR><cmd> Neorg journal today<cr>", desc = "Exercise" },
			{ "<leader>njf", "<cmd>Neorg workspace food <CR><cmd> Neorg journal today<cr>", desc = "Food" },
			{ "<leader>njp", "<cmd>Neorg workspace practice <CR><cmd> Neorg journal today<cr>", desc = "Practice" },
			{ "<leader>njg", "<cmd>Neorg workspace general <CR><cmd> Neorg journal today<cr>", desc = "General" },
		})
		-- Add the key mappings only for Markdown files in a zk notebook.
		if require("zk.util").notebook_root(vim.fn.expand("%:p")) ~= nil then
			local function map(...)
				vim.api.nvim_buf_set_keymap(0, ...)
			end
			local opts = { noremap = true, silent = false }

			-- Open the link under the caret.
			map("n", "<CR>", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)

			-- Create a new note after asking for its title.
			-- This overrides the global `<leader>zn` mapping to create the note in the same directory as the current buffer.
			map(
				"n",
				"<leader>zn",
				"<Cmd>ZkNew { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>",
				opts
			)
			-- Create a new note in the same directory as the current buffer, using the current selection for title.
			map("v", "<leader>znt", ":'<,'>ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<CR>", opts)
			-- Create a new note in the same directory as the current buffer, using the current selection for note content and asking for its title.
			map(
				"v",
				"<leader>znc",
				":'<,'>ZkNewFromContentSelection { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>",
				opts
			)

			-- Open notes linking to the current buffer.
			map("n", "<leader>zb", "<Cmd>ZkBacklinks<CR>", opts)
			-- Alternative for backlinks using pure LSP and showing the source context.
			--map('n', '<leader>zb', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
			-- Open notes linked by the current buffer.
			map("n", "<leader>zl", "<Cmd>ZkLinks<CR>", opts)

			-- Preview a linked note.
			map("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
			-- Open the code actions for a visual selection.
			map("v", "<leader>za", ":'<,'>lua vim.lsp.buf.range_code_action()<CR>", opts)
		end
	end,
	setup = function()
		require("core.utils").load_mappings("whichkey")
	end,
}
-- -- EXAMPLE FROM DOCS
-- local wk = require("which-key")
-- wk.add({
--   { "<leader>f", group = "file" }, -- group
--   { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
--   { "<leader>fb", function() print("hello") end, desc = "Foobar" },
--   { "<leader>fn", desc = "New File" },
--   { "<leader>f1", hidden = true }, -- hide this keymap
--   { "<leader>w", proxy = "<c-w>", group = "windows" }, -- proxy to window mappings
--   { "<leader>b", group = "buffers", expand = function()
--       return require("which-key.extras").expand.buf()
--     end
--   },
--   {
--     -- Nested mappings are allowed and can be added in any order
--     -- Most attributes can be inherited or overridden on any level
--     -- There's no limit to the depth of nesting
--     mode = { "n", "v" }, -- NORMAL and VISUAL mode
--     { "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
--     { "<leader>w", "<cmd>w<cr>", desc = "Write" },
--   }
-- })
