local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

local helpers = require("dot.luasnip.helpers")

local regular = {
	s(";trivial", t("IT WORKS")),
}

local autosnippets = {
	s(
		{ trig = "//", condition = helpers.in_mathzone },
		fmta("\\frac{<>}{<>}", { i(1), i(2) })
	),
}

return regular, autosnippets
