return {
	"davidgranstrom/scnvim",
	-- Patch upstream crash in SCNvimDoc.sc:278 (bare String where Array required;
	-- breaks exportDocMapJson on classes with IMPLEMENTORCLASS, e.g. Document).
	-- The trailing commit keeps the working tree clean so :Lazy update doesn't
	-- refuse to pull. grep will fail loudly if upstream ever changes the line.
	-- Removable once upstream merges a fix.
	build = table.concat({
		"sed -i 's|inheritance.add(implKlass.name.asString);|inheritance.add([implKlass.name.asString]);|' scide_scnvim/Classes/SCNvimDoc/SCNvimDoc.sc",
		"grep -qF 'inheritance.add([implKlass.name.asString])' scide_scnvim/Classes/SCNvimDoc/SCNvimDoc.sc",
		"git diff --quiet scide_scnvim/Classes/SCNvimDoc/SCNvimDoc.sc || git -c user.email=lazy@local -c user.name=lazy-build -c commit.gpgsign=false commit -q --no-verify -m 'local: implKlass array-wrap' scide_scnvim/Classes/SCNvimDoc/SCNvimDoc.sc",
	}, " && "),
	config = function()
		local scnvim = require("scnvim")
		local map = scnvim.map
		local map_expr = scnvim.map_expr

		scnvim.setup({
			keymaps = {
				["<M-e>"] = map("editor.send_line", { "i", "n" }),
				["<C-e>"] = {
					map("editor.send_block", { "i", "n" }),
					map("editor.send_selection", "x"),
				},
				-- ["<CR>"] = map("postwin.toggle"),
				["<M-CR>"] = map("postwin.toggle", "i"),
				["<M-L>"] = map("postwin.clear", { "n", "i" }),
				["<C-k>"] = map("signature.show", { "n", "i" }),
				["<F12>"] = map("sclang.hard_stop", { "n", "x", "i" }),
				["<leader>st"] = map("sclang.start"),
				["<leader>sk"] = map("sclang.recompile"),
				["<F1>"] = map_expr("s.boot"),
				["<F2>"] = map_expr("s.meter"),
			},
			editor = {
				highlight = {
					color = "IncSearch",
				},
			},
			postwin = {
				horizontal = true,
				size = 10,
				float = {
					enabled = false,
				},
			},
			documentation = {
				cmd = vim.fn.exepath("pandoc"),
				horizontal = false,
				direction = "right",
			},
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "help.supercollider",
			desc = "scnvim: <CR> opens help for word under cursor",
			callback = function(args)
				vim.keymap.set("n", "<CR>", function()
					require("scnvim.help").open_help_for(vim.fn.expand("<cword>"))
				end, { buffer = args.buf, desc = "Open help for <cword>" })
			end,
		})
	end,
}
