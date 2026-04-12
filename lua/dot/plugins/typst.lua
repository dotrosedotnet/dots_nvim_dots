local typst_job = nil

vim.api.nvim_create_autocmd("FileType", {
	pattern = "typst",
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local opts = { buffer = buf, silent = true }

		local function get_pdf()
			return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":r") .. ".pdf"
		end

		vim.keymap.set("n", "<leader>tc", function()
			local file = vim.api.nvim_buf_get_name(buf)
			vim.fn.jobstart({ "typst", "compile", file })
		end, vim.tbl_extend("force", opts, { desc = "Typst compile" }))

		vim.keymap.set("n", "<leader>tw", function()
			if typst_job then
				return
			end
			local file = vim.api.nvim_buf_get_name(buf)
			typst_job = vim.fn.jobstart({ "typst", "watch", file })
			vim.fn.jobstart({ "zathura", get_pdf() })
		end, vim.tbl_extend("force", opts, { desc = "Typst watch + preview" }))

		vim.keymap.set("n", "<leader>tq", function()
			if typst_job then
				vim.fn.jobstop(typst_job)
				typst_job = nil
			end
		end, vim.tbl_extend("force", opts, { desc = "Typst stop watch" }))
	end,
})

return {}
