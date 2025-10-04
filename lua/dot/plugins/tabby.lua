return {
	"nanozuki/tabby.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local devicons = require("nvim-web-devicons")

		-- Create a function to get colors dynamically
		local function get_colors()
			-- Get colors from highlight groups set by Stylix
			local function get_hl_color(group, attr)
				local hl = vim.api.nvim_get_hl(0, { name = group })
				if attr == "fg" then
					return hl.fg and string.format("#%06x", hl.fg) or nil
				elseif attr == "bg" then
					return hl.bg and string.format("#%06x", hl.bg) or nil
				end
			end

			-- Extract colors from the highlight groups
			return {
				base00 = get_hl_color("Normal", "bg") or "#252a2f",
				base01 = get_hl_color("CursorLine", "bg") or "#43474c",
				base02 = get_hl_color("StatusLine", "bg") or "#616568",
				base03 = get_hl_color("Comment", "fg") or "#7f8285",
				base04 = get_hl_color("StatusLineNC", "fg") or "#9ea0a2",
				base05 = get_hl_color("Normal", "fg") or "#bcbdc0",
				base06 = get_hl_color("Normal", "fg") or "#dadadd",
				base07 = get_hl_color("NormalFloat", "fg") or "#f7f8f8",
				base08 = get_hl_color("Error", "fg") or "#ed5d86",
				base09 = get_hl_color("Number", "fg") or "#f59762",
				base0A = get_hl_color("Type", "fg") or "#eb824d",
				base0B = get_hl_color("String", "fg") or "#20c290",
				base0C = get_hl_color("Special", "fg") or "#02efef",
				base0D = get_hl_color("Function", "fg") or "#4080d0",
				base0E = get_hl_color("Keyword", "fg") or "#a070d0",
				base0F = get_hl_color("Delimiter", "fg") or "#eb0000",
			}
		end

		-- Create theme from colors
		local function build_theme(colors)
			return {
				fill = { bg = colors.base02, fg = colors.base09 }, -- Background fill
				head = { bg = colors.base02, fg = colors.base07 }, -- Start section
				current_tab = { bg = colors.base03, fg = colors.base0C, style = "bold" }, -- Active tab
				tab = { bg = colors.base00, fg = colors.base03 }, -- Inactive tabs
				win = { bg = colors.base02, fg = colors.base05 }, -- Windows
				tail = { bg = colors.base02, fg = colors.base05 }, -- End section
			}
		end

		local colors = get_colors()
		local theme = build_theme(colors)

		-- Setup tabby with custom line renderer and rounded separators
		require("tabby").setup({
			line = function(line)
				return {
					{ "  ", hl = theme.head },
					line.tabs().foreach(function(tab)
						local hl = tab.is_current() and theme.current_tab or theme.tab
						local win = tab.current_win()
						local buf = win and win.buf()
						return {
							line.sep("", hl, theme.fill),
							tab.is_current() and "" or "",
							" ",
							tab.number(),
							": ",
							buf and buf.file_icon() or "",
							tab.name(),
							" ",
							tab.close_btn(""),
							line.sep("", hl, theme.fill),
							hl = hl,
							margin = " ",
						}
					end),
					line.spacer(),
					{ "  ", hl = theme.tail },
					hl = theme.fill,
				}
			end,
		})

		-- Ensure tabline is always visible
		vim.o.showtabline = 2

		-- Refresh tabby when colorscheme changes
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				-- Get updated colors and rebuild theme
				local new_colors = get_colors()
				theme = build_theme(new_colors)

				-- Force redraw of tabline
				vim.cmd("redrawtabline")
			end,
			desc = "Update tabby colors when colorscheme changes",
		})
	end,
}
