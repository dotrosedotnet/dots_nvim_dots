return {
	"davidgranstrom/scnvim",
	-- Two upstream crashes patched locally:
	--   1. SCNvimDoc.sc:278 — bare String where Array required; breaks
	--      exportDocMapJson on classes with IMPLEMENTORCLASS (e.g. Document).
	--   2. help.lua render_help_file — no nil-guard on getHelpUri callback;
	--      crashes when navigating to a class with no renderable help.
	-- The trailing commit keeps the working tree clean so :Lazy update doesn't
	-- refuse to pull. greps will fail loudly if upstream ever changes the lines.
	-- Removable once upstream merges fixes.
	build = function(plugin)
		local cmd = table.concat({
			"sed -i 's|inheritance.add(implKlass.name.asString);|inheritance.add([implKlass.name.asString]);|' scide_scnvim/Classes/SCNvimDoc/SCNvimDoc.sc",
			"grep -qF 'inheritance.add([implKlass.name.asString])' scide_scnvim/Classes/SCNvimDoc/SCNvimDoc.sc",
			"grep -qF 'if not input_path then return end' lua/scnvim/help.lua || sed -i '/local basename = input_path:gsub/i\\    if not input_path then return end' lua/scnvim/help.lua",
			"grep -qF 'if not input_path then return end' lua/scnvim/help.lua",
			"git diff --quiet scide_scnvim/Classes/SCNvimDoc/SCNvimDoc.sc lua/scnvim/help.lua || git -c user.email=lazy@local -c user.name=lazy-build -c commit.gpgsign=false commit -q --no-verify -m 'local: scnvim patches' scide_scnvim/Classes/SCNvimDoc/SCNvimDoc.sc lua/scnvim/help.lua",
		}, " && ")
		local out = vim.fn.system({ "sh", "-c", "cd " .. vim.fn.shellescape(plugin.dir) .. " && " .. cmd })
		if vim.v.shell_error ~= 0 then
			error("[scnvim build] failed (exit " .. vim.v.shell_error .. "):\n" .. out)
		end
	end,
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
				["<leader>sh"] = map(function() vim.cmd("SCNvimExt fzf-sc.fuzz help") end),
				["<leader>sR"] = map(function()
					vim.notify("[scnvim] Rendering full help corpus...", vim.log.levels.INFO)
					require("scnvim.help").render_all(vim.schedule_wrap(function()
						vim.notify("[scnvim] Help corpus rendered.", vim.log.levels.INFO)
					end))
				end),
				["<leader>s/"] = map(function()
					local help_dir = vim.fn.expand("~/.local/share/SuperCollider/Help")
					local fzf = require("fzf-lua")
					fzf.live_grep({
						cwd = help_dir,
						prompt = "Help> ",
						rg_opts = "--glob '*.txt' --column --line-number --no-heading --color=always --smart-case --max-columns=4096",
						actions = {
							["default"] = function(selected, opts)
								if not selected or not selected[1] then
									return
								end
								local entry = fzf.path.entry_to_file(selected[1], opts)
								if not entry or not entry.path then
									return
								end
								require("scnvim.help").on_open(nil, entry.path)
								local lines = vim.api.nvim_buf_line_count(0)
								local line = math.min(tonumber(entry.line) or 1, lines)
								if line > 0 then
									vim.api.nvim_win_set_cursor(0, { line, 0 })
								end
							end,
						},
					})
				end),
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
				-- Override the inherited 'help' iskeyword (which includes .,(,) etc.)
				-- so <cword> picks up just identifiers like `new` or `Pbind`.
				vim.bo[args.buf].iskeyword = "a-z,A-Z,48-57,_"
				vim.keymap.set("n", "<CR>", function()
					require("scnvim.help").open_help_for(vim.fn.expand("<cword>"))
				end, { buffer = args.buf, desc = "Open help for <cword>" })
			end,
		})

		-- Method-lookup quickfix: open below the help split (not below the postwin)
		-- and close it once the user picks an entry.
		local help = require("scnvim.help")
		help.on_select:replace(function(err, results)
			if err then
				vim.notify("[scnvim] " .. tostring(err), vim.log.levels.ERROR)
				return
			end
			if not results or #results == 0 then
				return
			end

			local group = vim.api.nvim_create_augroup("scnvim_qf_conceal", { clear = true })
			vim.api.nvim_create_autocmd("BufWinEnter", {
				group = group,
				pattern = "quickfix",
				callback = function()
					vim.cmd([[syntax match SCNvimConcealResults /^.*Help\/\|.txt\||.*|\|/ conceal]])
					vim.opt_local.conceallevel = 2
					vim.opt_local.concealcursor = "nvic"
				end,
			})

			vim.fn.setqflist(results)
			vim.cmd("belowright copen 10")

			vim.keymap.set("n", "<CR>", function()
				local idx = vim.api.nvim_win_get_cursor(0)[1]
				local item = vim.fn.getqflist()[idx]
				vim.cmd("cclose")
				if not item then
					return
				end
				local uri = vim.fn.bufname(item.bufnr)
				if vim.uv.fs_stat(uri) then
					help.on_open(nil, uri, item.text)
				else
					help.open_help_for(vim.fn.fnamemodify(uri, ":t:r"))
				end
			end, { buffer = true, desc = "scnvim: open & close QF" })
		end)
	end,
}
