return {
  -- slime (REPL integration)
  {
    "jpalardy/vim-slime",
    config = function()
      vim.g.slime_target = "tmux"
      vim.g.slime_default_config = { socket_name = "default", target_pane = "2" }
      vim.g.slime_bracketed_paste = 1
    end,
  },
}
