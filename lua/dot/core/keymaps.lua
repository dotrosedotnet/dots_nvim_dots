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

-- colorscheme reload function
local function reload_colorscheme()
	local ok, err = pcall(function()
		-- Clear the bytecode cache for miniBase16
		local cache_pattern = vim.fn.expand("~/.cache/nvim/luac/*miniBase16*")
		vim.fn.system("rm -f " .. cache_pattern .. " 2>/dev/null")
		
		-- Use dofile to load the config file directly since it has a dot in the filename
		local config_path = vim.fn.stdpath("config") .. "/lua/dot/plugins/miniBase16.lua"
		local config_module = dofile(config_path)
		-- Check for opts (can be function or table) or config
		local opts = config_module.opts or config_module.config or config_module
		-- If opts is a function, call it to get the actual config
		local config = type(opts) == "function" and opts() or opts
		require("mini.base16").setup(config)
	end)

	if ok then
		print("✓ miniBase16 reloaded successfully")
	else
		print("✗ Error reloading miniBase16: " .. tostring(err))
	end
end

-- make function globally accessible
_G.reload_colorscheme = reload_colorscheme

-- colorscheme reload keymap and command
keymap.set("n", "<leader>rc", reload_colorscheme, { desc = "Reload colorscheme" })

-- create user command
vim.api.nvim_create_user_command("ReloadColorscheme", reload_colorscheme, {
	desc = "Reload miniBase16 colorscheme",
})

-- Reload bufferline function
local function reload_bufferline()
	local ok, err = pcall(function()
		-- Clear any cached configuration
		package.loaded["dot.plugins.bufferline"] = nil
		
		-- Re-run the config function from our bufferline setup
		local bufferline_config = require("dot.plugins.bufferline")
		if bufferline_config.config then
			bufferline_config.config()
		end
	end)
	
	if ok then
		print("✓ Bufferline reloaded with custom highlights")
	else
		print("✗ Error reloading bufferline: " .. tostring(err))
	end
end

-- Make function globally accessible
_G.reload_bufferline = reload_bufferline

-- Bufferline reload keymap
keymap.set("n", "<leader>rb", reload_bufferline, { desc = "Reload bufferline" })
