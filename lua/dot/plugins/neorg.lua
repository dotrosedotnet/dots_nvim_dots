return {
	{
		"vhyrro/luarocks.nvim",
		priority = 1000,
		config = true,
	},
	{
		"nvim-neorg/neorg",
		--dependencies = { "luarocks.nvim" },
		dependencies = {
			"luarocks.nvim",
			"plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			{ "pysan3/neorg-templates", dependencies = { "L3MON4D3/LuaSnip" } },
		},
		lazy = false,
		version = "*",
		-- default_workspace = "General",
		config = function()
			require("neorg").setup({
				load = {
					["core.defaults"] = {}, -- Loads default behaviour
					["core.concealer"] = {}, -- Adds pretty icons to your documents
					["core.dirman"] = { -- Manages Neorg workspaces
						config = {
							workspaces = {
								general = "~/notes/general",
								exercise = "~/notes/exercise",
								food = "~/notes/food",
								practice = "~/notes/practice",
							},
							default_workspace = "general",
						},
					},
					["core.integrations.treesitter"] = {},
					["external.templates"] = {
						config = {
							templates_dir = vim.fn.stdpath("config") .. "/templates/norg",
							-- default_subcommand = "add", -- or "fload", "load"
							-- keywords = { -- Add your own keywords.
							--   EXAMPLE_KEYWORD = function ()
							--     return require("luasnip").insert_node(1, "default text blah blah")
							--   end,
							-- },
							-- snippets_overwrite = {},
							keywords = { -- Add your own keywords.
								JTIME = function()
									local time = os.date("%I:%M %p")
									local cleanTime = time:match("0*(.+)")
									return require("luasnip").insert_node(1, cleanTime)
								end,
							},
						},
					},
				},
			})
		end,
	},
}
