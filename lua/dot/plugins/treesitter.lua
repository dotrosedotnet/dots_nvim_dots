return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		require("nvim-treesitter").setup()

		require("nvim-treesitter.install").install({
			"arduino",
			"bash",
			"beancount",
			"bibtex",
			"c",
			"clojure",
			"cmake",
			"css",
			"csv",
			"diff",
			"dockerfile",
			"forth",
			"git_config",
			"gitcommit",
			"gitignore",
			"go",
			"gpg",
			"html",
			"http",
			"ini",
			"java",
			"javascript",
			"jq",
			"json",
			"latex",
			"lua",
			"luadoc",
			"make",
			"markdown",
			"markdown_inline",
			"muttrc",
			"norg",
			"ocaml",
			"passwd",
			"python",
			"regex",
			"ssh_config",
			"supercollider",
			"tmux",
			"toml",
			"typst",
			"vim",
			"vimdoc",
			"yaml",
		})

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		require("nvim-ts-autotag").setup()
	end,
}
