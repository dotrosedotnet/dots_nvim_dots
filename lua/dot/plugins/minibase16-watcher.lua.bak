-- Auto-reload miniBase16 colorscheme when the file changes
-- Watches for NixOS updates to the theme file and applies them immediately

return {
	-- Use the current config directory as the plugin location
	-- This tells lazy.nvim this is a local plugin, not a remote one
	dir = vim.fn.stdpath("config"),
	name = "minibase16-watcher",
	lazy = false, -- Load immediately after miniBase16
	priority = 90, -- Lower priority than miniBase16 (which should be high)
	config = function()
		local uv = vim.loop or vim.uv
		local config_path = vim.fn.stdpath("config") .. "/lua/dot/plugins/miniBase16.lua"
		
		-- Check if file exists
		if vim.fn.filereadable(config_path) ~= 1 then
			return -- No file to watch
		end
		
		local watcher = nil
		local debounce_timer = nil
		
		-- Reload function (based on keymaps.lua implementation)
		local function reload_minibase16()
			local ok, err = pcall(function()
				-- Clear the bytecode cache for this file
				local cache_pattern = vim.fn.expand("~/.cache/nvim/luac/*miniBase16*")
				vim.fn.system("rm -f " .. cache_pattern .. " 2>/dev/null")
				
				local config_module = dofile(config_path)
				-- Check for opts (can be function or table) or config
				local opts = config_module.opts or config_module.config or config_module
				-- If opts is a function, call it to get the actual config
				local config = type(opts) == "function" and opts() or opts
				require("mini.base16").setup(config)
			end)
			
			if not ok and err then
				vim.notify("miniBase16 reload error: " .. tostring(err), vim.log.levels.ERROR)
			end
			-- Silent on success - no interruption
		end
		
		-- Watch function - watch parent directory to catch symlink updates
		local function watch_file()
			if watcher then
				watcher:stop()
			end
			
			-- Watch the parent directory instead of the file itself
			local parent_dir = vim.fn.fnamemodify(config_path, ":h")
			local filename = vim.fn.fnamemodify(config_path, ":t")
			
			watcher = uv.new_fs_event()
			watcher:start(parent_dir, {}, vim.schedule_wrap(function(err, fname, events)
				if err then return end
				
				-- Only react to changes to our specific file
				if fname ~= filename then return end
				
				-- Debounce rapid changes
				if debounce_timer then
					debounce_timer:stop()
					debounce_timer:close()
				end
				
				debounce_timer = uv.new_timer()
				debounce_timer:start(100, 0, vim.schedule_wrap(function()
					reload_minibase16()
					debounce_timer:close()
					debounce_timer = nil
					-- Restart watcher (handles file replacement by NixOS)
					watch_file()
				end))
			end))
		end
		
		-- Start watching
		watch_file()
		
		-- Cleanup on exit
		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				if watcher then watcher:stop() end
				if debounce_timer then 
					debounce_timer:stop()
					debounce_timer:close()
				end
			end,
			desc = "Clean up miniBase16 file watcher"
		})
	end
}