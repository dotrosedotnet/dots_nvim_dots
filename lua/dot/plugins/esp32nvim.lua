return {
	"Aietes/esp32.nvim",
	dependencies = { "folke/snacks.nvim" },
	lazy = false,  -- Load immediately, don't wait for ft
	config = function()
		require("esp32").setup({
			build_dir = "build.clang",  -- Required: tells esp32.nvim where compile_commands.json is
		})
	end,
}
