return {
  {
    "Olical/conjure",
    -- ft = { "clojure", "fennel", "python" }, -- etc
    ft = { "clojure" },
    lazy = true,
    init = function()
      -- Set configuration options here
      vim.g["conjure#debug"] = true
    end,

    -- [Optional] cmp-conjure for cmp
    dependencies = { "PaterJason/cmp-conjure" },
  },
		{
			"PaterJason/cmp-conjure",
      lazy = true;
			config = function()
				local cmp = require("cmp")
				local config = cmp.get_config()
        table.insert(config.sources, { name = "conjure" })
				return cmp.setup(config)
			end,
		},
}
