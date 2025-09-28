vim.cmd("let g:netrw_liststyle = 3")

-- Disable Neovim's markdown recommended style (which sets tabstop=4)
vim.g.markdown_recommended_style = 0

local opt = vim.opt

opt.relativenumber = true
opt.number = true

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- opt.wrap = true
opt.linebreak = true
-- opt.columns = 100

opt.ignorecase = true
opt.smartcase = true --mixed case -> sen

opt.cursorline = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.backspace = "indent,eol,start"

opt.clipboard:append("unnamedplus")

opt.splitright = true
opt.splitbelow = true

opt.conceallevel = 3

opt.textwidth = 80

-- auto-reload colorscheme on startup
-- DISABLED: This causes duplicate color loading since mini.base16 already loads on startup
-- vim.api.nvim_create_autocmd("VimEnter", {
-- 	callback = function()
-- 		-- small delay to ensure all plugins are loaded
-- 		vim.defer_fn(function()
-- 			if _G.reload_colorscheme then
-- 				_G.reload_colorscheme()
-- 			end
-- 		end, 100)
-- 	end,
-- 	desc = "Auto-reload colorscheme on startup",
-- })
