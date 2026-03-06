return {
	"dimfeld/section-wordcount.nvim",
	ft = { "markdown", "asciidoc", "norg" },
	config = function()
		require("section-wordcount").setup({
			highlight = "String",
			virt_text_pos = "eol",
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				require("section-wordcount").wordcounter({})
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "norg",
			callback = function()
				require("section-wordcount").wordcounter({ header_char = "*" })
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "asciidoc",
			callback = function()
				require("section-wordcount").wordcounter({ header_char = "=" })
			end,
		})
	end,
}
