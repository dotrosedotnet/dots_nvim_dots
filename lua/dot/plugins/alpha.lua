return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Set Header
    -- -- Font options
    -- -- -- DOS\ Rebel
    -- -- -- Kban
    -- -- -- Nancyj-Fancy
    -- -- -- NScript
    -- -- -- Roman
    dashboard.section.header.val = {
      "  ██████   █████                   █████   █████  ███                  ",
      " ░░██████ ░░███                   ░░███   ░░███  ░░░                   ",
      "  ░███░███ ░███   ██████   ██████  ░███    ░███  ████  █████████████   ",
      "  ░███░░███░███  ███░░███ ███░░███ ░███    ░███ ░░███ ░░███░░███░░███  ",
      "  ░███ ░░██████ ░███████ ░███ ░███ ░░███   ███   ░███  ░███ ░███ ░███  ",
      "  ░███  ░░█████ ░███░░░  ░███ ░███  ░░░█████░    ░███  ░███ ░███ ░███  ",
      "  █████  ░░█████░░██████ ░░██████     ░░███      █████ █████░███ █████ ",
      " ░░░░░    ░░░░░  ░░░░░░   ░░░░░░       ░░░      ░░░░░ ░░░░░ ░░░ ░░░░░  ",
      "                                                                       ",
    }

    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button("n", "New File", "<cmd>ene<CR>"),
      dashboard.button("e", "File Explorer", "<cmd>NvimTreeToggle<CR>"),
      dashboard.button("f", "Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("/", "Find Word", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("s", "PWD Session", "<cmd>SessionRestore<CR>"),
      dashboard.button("q", "Quit", "<cmd>qa<CR>"),
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
