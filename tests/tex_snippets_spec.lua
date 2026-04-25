local snippets_path = vim.fn.stdpath("config") .. "/luasnippets/tex.lua"

local function find_snippet(snippets, trigger)
	for _, snip in ipairs(snippets) do
		if snip.trigger == trigger then
			return snip
		end
	end
	return nil
end

describe("tex snippets", function()
	local snippets

	before_each(function()
		-- dofile re-reads the file fresh each test; no package.loaded cache to bust.
		snippets = dofile(snippets_path)
	end)

	describe(";trivial", function()
		it("is defined", function()
			assert.is_not_nil(find_snippet(snippets, ";trivial"))
		end)

		it("expands to 'IT WORKS'", function()
			local snip = find_snippet(snippets, ";trivial")
			assert.same({ "IT WORKS" }, snip.nodes[1].static_text)
		end)
	end)
end)
