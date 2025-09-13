return {
	"akinsho/bufferline.nvim",
	enabled = false, -- Disabled to test tabby.nvim
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	config = function()
		-- Load the miniBase16 configuration to get the current Stylix colors
		local ok, miniBase16Config = pcall(require, "dot.plugins.miniBase16")
		local colors = {}

		if ok and miniBase16Config.opts then
			-- Get the palette from the miniBase16 config
			local opts = type(miniBase16Config.opts) == "function" and miniBase16Config.opts() or miniBase16Config.opts
			colors = opts.palette or {}
		else
			-- Fallback colors if loading fails
			colors = {
				base00 = "#282a36", -- Default Background
				base01 = "#363447", -- Lighter Background (Used for status bars)
				base02 = "#44475a", -- Selection Background
				base03 = "#6272a4", -- Comments, Invisibles, Line Highlighting
				base04 = "#9ea8c7", -- Dark Foreground (Used for status bars)
				base05 = "#f8f8f2", -- Default Foreground
				base06 = "#f0f1f4", -- Light Foreground (Not often used)
				base07 = "#ffffff", -- Light Background (Not often used)
				base08 = "#ff5555", -- Variables, XML Tags, Markup Link Text, etc
				base09 = "#ffb86c", -- Integers, Boolean, Constants, etc
				base0A = "#f1fa8c", -- Classes, Markup Bold, Search Text Background
				base0B = "#50fa7b", -- Strings, Inherited Class, Markup Code, Diff Inserted
				base0C = "#8be9fd", -- Support, Regex, Escape Characters, Markup Quotes
				base0D = "#80bfff", -- Functions, Methods, Headings, Diff Changed
				base0E = "#ff79c6", -- Keywords, Storage, Selector, Diff Deleted
				base0F = "#bd93f9", -- Deprecated, Opening/Closing Embedded Language Tags
			}
		end

		-- Setup bufferline with basic config
		require("bufferline").setup({
			options = {
				mode = "tabs",
				separator_style = "slant",
				themable = true, -- Allow external highlight overrides
			},
		})

		-- Force set the highlight groups directly after setup
		-- This ensures our colors are applied regardless of bufferline's internal processing
		vim.api.nvim_set_hl(0, "BufferLineFill", { bg = colors.base01 })
		vim.api.nvim_set_hl(0, "BufferLineBackground", { bg = colors.base02, fg = colors.base04 })
		vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { bg = colors.base01, fg = colors.base05 })
		vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { bg = colors.base00, fg = colors.base06, bold = true })

		-- Separator highlights
		vim.api.nvim_set_hl(0, "BufferLineSeparator", { fg = colors.base01, bg = colors.base02 })
		vim.api.nvim_set_hl(0, "BufferLineSeparatorVisible", { fg = colors.base01, bg = colors.base00 })
		vim.api.nvim_set_hl(0, "BufferLineSeparatorSelected", { fg = colors.base01, bg = colors.base00 })

		-- Tab specific highlights
		vim.api.nvim_set_hl(0, "BufferLineTab", { bg = colors.base01, fg = colors.base04 })
		vim.api.nvim_set_hl(0, "BufferLineTabVisible", { bg = colors.base01, fg = colors.base04 })
		vim.api.nvim_set_hl(0, "BufferLineTabSelected", { bg = colors.base02, fg = colors.base06, bold = true })
		vim.api.nvim_set_hl(0, "BufferLineTabSeparator", { fg = colors.base01, bg = colors.base00 })
		vim.api.nvim_set_hl(0, "BufferLineTabSeparatorSelected", { fg = colors.base02, bg = colors.base00 })

		-- Missing highlight groups that we haven't targeted yet
		vim.api.nvim_set_hl(0, "BufferLineBuffer", { bg = colors.base02, fg = colors.base04 }) -- IMPORTANT: Icons inherit from this
		vim.api.nvim_set_hl(0, "BufferLineTabClose", { bg = colors.base02, fg = colors.base04 })
		vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { bg = colors.base02, fg = colors.base0D })
		vim.api.nvim_set_hl(0, "BufferLineIndicatorVisible", { bg = colors.base02, fg = colors.base03 })
		vim.api.nvim_set_hl(0, "BufferLineModified", { bg = colors.base01, fg = colors.base0A })
		vim.api.nvim_set_hl(0, "BufferLineModifiedVisible", { bg = colors.base01, fg = colors.base0A })
		vim.api.nvim_set_hl(0, "BufferLineModifiedSelected", { bg = colors.base00, fg = colors.base0A })

		-- Double-loading workaround for icon backgrounds
		-- This ensures parent highlights exist before icon highlights are created
		vim.defer_fn(function()
			-- Clear the icon highlight cache to force recreation
			local highlights = require("bufferline.highlights")
			if highlights.reset_icon_hl_cache then
				highlights.reset_icon_hl_cache()
			end
			
			-- Re-setup bufferline with the same config
			-- This recreates icon highlights with proper parent backgrounds
			require("bufferline").setup({
				options = {
					mode = "tabs",
					separator_style = "slant",
					themable = true,
				},
			})
		end, 50) -- 50ms delay to ensure initial highlights are set
	end,
}
