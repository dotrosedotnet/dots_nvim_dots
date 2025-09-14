return {
	"nanozuki/tabby.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- Load the miniBase16 configuration to get the current colors
		local config_path = vim.fn.stdpath("config") .. "/lua/dot/plugins/miniBase16.lua"
		local colors = {}

		-- Try to load colors from miniBase16
		local ok, err = pcall(function()
			-- Use dofile to avoid module caching issues
			local miniBase16Config = dofile(config_path)
			-- Get the palette from the config (handle both function and table forms)
			local opts = miniBase16Config.opts or miniBase16Config.config or miniBase16Config
			local config = type(opts) == "function" and opts() or opts
			colors = config.palette or {}
		end)

		-- Fallback colors if loading fails
		if not ok or not next(colors) then
			colors = {
				base00 = "#322931", -- Default Background
				base01 = "#322931", -- Lighter Background (status bars)
				base02 = "#797379", -- Selection Background
				base03 = "#898388", -- Comments, Invisibles
				base04 = "#999498", -- Dark Foreground (status bars)
				base05 = "#a9a4a8", -- Default Foreground
				base06 = "#b9b5b8", -- Light Foreground
				base07 = "#ffffff", -- Light Background
				base08 = "#dd464c", -- Variables, XML Tags
				base09 = "#fdcc59", -- Integers, Boolean
				base0A = "#989498", -- Classes, Markup Bold
				base0B = "#8fc13e", -- Strings, Inherited Class
				base0C = "#149b93", -- Support, Regex
				base0D = "#1290bf", -- Functions, Methods
				base0E = "#c85e7c", -- Keywords, Storage
				base0F = "#6e2326", -- Deprecated
			}
		end

		-- Define tabby theme using base16 colors
		local theme = {
			fill = { bg = colors.base02, fg = colors.base04 }, -- Background fill
			head = { bg = colors.base02, fg = colors.base07 }, -- Start section
			current_tab = { bg = colors.base01, fg = colors.base06, style = "bold" }, -- Active tab
			tab = { bg = colors.base04, fg = colors.base01 }, -- Inactive tabs
			win = { bg = colors.base02, fg = colors.base04 }, -- Windows
			tail = { bg = colors.base02, fg = colors.base05 }, -- End section
		}

		-- Setup tabby with custom line renderer
		require("tabby").setup({
			line = function(line)
				return {
					{
						{ "  ", hl = theme.head },
						line.sep("", theme.head, theme.fill),
					},
					line.tabs().foreach(function(tab)
						local hl = tab.is_current() and theme.current_tab or theme.tab
						return {
							line.sep("", hl, theme.fill),
							tab.is_current() and "" or "",
							" ",
							tab.number(),
							": ",
							tab.name(),
							" ",
							tab.close_btn(""),
							line.sep("", hl, theme.fill),
							hl = hl,
							margin = " ",
						}
					end),
					line.spacer(),
					{
						line.sep("", theme.tail, theme.fill),
						{ "  ", hl = theme.tail },
					},
					hl = theme.fill,
				}
			end,
		})

		-- Ensure tabline is always visible
		vim.o.showtabline = 2
	end,
}
