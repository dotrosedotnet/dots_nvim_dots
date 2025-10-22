vim.g.mapleader = " "

local keymap = vim.keymap

-- keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

--increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- splits
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- tabs
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Next Tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Previous Tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- zk
local opts = { noremap = true, silent = false }

-- Create a new note after asking for its title.
keymap.set("n", "<leader>zn", "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>", opts)

-- Open notes.
keymap.set("n", "<leader>zo", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", opts)
-- Open notes associated with the selected tags.
keymap.set("n", "<leader>zt", "<Cmd>ZkTags<CR>", opts)

-- Search for the notes matching a given query.
keymap.set("n", "<leader>zf", "<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<CR>", opts)
-- Search for the notes matching the current visual selection.
keymap.set("v", "<leader>zf", ":'<,'>ZkMatch<CR>", opts)

-- diagnostics
keymap.set("n", "<leader>yd", function()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local line_num = cursor_pos[1] - 1 -- Convert to 0-indexed
	local diagnostics = vim.diagnostic.get(0, { lnum = line_num })

	if #diagnostics == 0 then
		vim.notify("No diagnostics on current line", vim.log.levels.INFO)
		return
	end

	local severity_map = {
		[vim.diagnostic.severity.ERROR] = "ERROR",
		[vim.diagnostic.severity.WARN] = "WARN",
		[vim.diagnostic.severity.INFO] = "INFO",
		[vim.diagnostic.severity.HINT] = "HINT",
	}

	local lines = {}
	for _, diag in ipairs(diagnostics) do
		local severity = severity_map[diag.severity] or "UNKNOWN"
		local source = diag.source or ""
		local text
		if source ~= "" then
			text = string.format("[%s:%s] %s", severity, source, diag.message)
		else
			text = string.format("[%s] %s", severity, diag.message)
		end
		table.insert(lines, text)
	end

	local content = table.concat(lines, "\n")
	vim.fn.setreg("+", content)
	vim.notify("Copied diagnostic(s) to clipboard", vim.log.levels.INFO)
end, { desc = "Yank (copy) diagnostics on current line" })

-- colorscheme reload function
-- MOVED TO NIXOS CONFIG: The reload command is now managed by tintedNvim.nix
-- which generates ~/.config/nvim/lua/dot/plugins/tinted-reload.lua
-- This ensures the reload command always matches the NixOS-managed colors
