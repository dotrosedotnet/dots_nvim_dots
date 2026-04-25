local lazy_root = vim.fn.stdpath("data") .. "/lazy"

vim.opt.rtp:append(vim.fn.stdpath("config"))
vim.opt.rtp:append(lazy_root .. "/plenary.nvim")
vim.opt.rtp:append(lazy_root .. "/LuaSnip")

vim.cmd("runtime plugin/plenary.vim")
