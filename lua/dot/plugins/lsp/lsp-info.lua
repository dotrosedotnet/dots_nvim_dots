return {
	"j-hui/fidget.nvim",
	event = "LspAttach",
	opts = {
		-- Options for the notification subsystem
		notification = {
			poll_rate = 10,
			filter = vim.log.levels.INFO,
			history_size = 128,
			override_vim_notify = false,
			view = {
				stack_upwards = true,
				icon_separator = " ",
				group_separator = "---",
				group_separator_hl = "Comment",
			},
			window = {
				normal_hl = "Comment",
				winblend = 100,
				border = "none",
				zindex = 45,
				max_width = 0,
				max_height = 0,
				x_padding = 1,
				y_padding = 0,
				align = "bottom",
				relative = "editor",
			},
		},
		-- Options for the progress subsystem
		progress = {
			poll_rate = 0,
			suppress_on_insert = false,
			ignore_done_already = false,
			ignore_empty_message = false,
			clear_on_detach = function(client_id)
				local client = vim.lsp.get_client_by_id(client_id)
				return client and client.name or nil
			end,
			notification_group = function(msg)
				return msg.lsp_client.name
			end,
			ignore = {},
			display = {
				render_limit = 16,
				done_ttl = 3,
				done_icon = "✔",
				done_style = "Constant",
				progress_ttl = math.huge,
				progress_icon = { pattern = "dots", period = 1 },
				progress_style = "WarningMsg",
				group_style = "Title",
				icon_style = "Question",
				priority = 30,
				skip_history = true,
				format_annote = function(msg)
					return msg.title
				end,
				format_group_name = function(group)
					return tostring(group)
				end,
			},
		},
	},
}