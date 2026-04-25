local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmta = require("luasnip.extras.fmt").fmta

local helpers = require("dot.luasnip.helpers")

local function cap(n)
	return f(function(_, snip)
		return snip.captures[n]
	end)
end

local regular = {
	s(";trivial", t("IT WORKS")),
}

local autosnippets = {
	s(
		{ trig = "//", condition = helpers.in_mathzone },
		fmta("\\frac{<>}{<>}", { i(1), i(2) })
	),
	s(
		{
			trig = "([%a])(%d)",
			regTrig = true,
			wordTrig = false,
			condition = helpers.in_mathzone,
		},
		fmta("<>_<>", { cap(1), cap(2) })
	),
	s(
		{
			trig = "([%a])_(%d%d)",
			regTrig = true,
			wordTrig = false,
			condition = helpers.in_mathzone,
		},
		fmta("<>_{<>}", { cap(1), cap(2) })
	),
}

return regular, autosnippets
