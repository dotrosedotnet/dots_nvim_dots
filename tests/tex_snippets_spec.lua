local snippets_path = vim.fn.stdpath("config") .. "/luasnippets/tex.lua"

local function find_snippet(snippets, trigger)
	for _, snip in ipairs(snippets) do
		if snip.trigger == trigger then
			return snip
		end
	end
	return nil
end

-- Build a mock node chain from innermost to outermost.
-- types[1] is the cursor node, types[#types] is the root.
local function mock_node_chain(types)
	local function build(idx)
		if idx > #types then
			return nil
		end
		local parent = build(idx + 1)
		return {
			type = function()
				return types[idx]
			end,
			parent = function()
				return parent
			end,
		}
	end
	return build(1)
end

describe("tex snippets", function()
	local snippets

	before_each(function()
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

	describe("//", function()
		local original_get_node

		before_each(function()
			original_get_node = vim.treesitter.get_node
		end)

		after_each(function()
			vim.treesitter.get_node = original_get_node
		end)

		it("is defined", function()
			assert.is_not_nil(find_snippet(snippets, "//"))
		end)

		it("expands when cursor is inside displayed_equation", function()
			vim.treesitter.get_node = function()
				return mock_node_chain({ "operator", "text", "displayed_equation", "source_file" })
			end
			local snip = find_snippet(snippets, "//")
			local params = snip:resolveExpandParams("//", "//", {})
			assert.is_not_nil(params)
		end)

		it("does NOT expand in plain prose", function()
			vim.treesitter.get_node = function()
				return mock_node_chain({ "text", "source_file" })
			end
			local snip = find_snippet(snippets, "//")
			local params = snip:resolveExpandParams("//", "//", {})
			assert.is_nil(params)
		end)
	end)
end)

describe("dot.luasnip.helpers", function()
	local helpers
	local original_get_node

	before_each(function()
		package.loaded["dot.luasnip.helpers"] = nil
		helpers = require("dot.luasnip.helpers")
		original_get_node = vim.treesitter.get_node
	end)

	after_each(function()
		vim.treesitter.get_node = original_get_node
	end)

	describe("in_mathzone", function()
		it("is true inside displayed_equation (\\[..\\])", function()
			vim.treesitter.get_node = function()
				return mock_node_chain({ "word", "text", "displayed_equation", "source_file" })
			end
			assert.is_true(helpers.in_mathzone())
		end)

		it("is true inside inline_formula ($..$ or \\(..\\))", function()
			vim.treesitter.get_node = function()
				return mock_node_chain({ "inline_formula", "source_file" })
			end
			assert.is_true(helpers.in_mathzone())
		end)

		it("is true inside math_environment (equation, align)", function()
			vim.treesitter.get_node = function()
				return mock_node_chain({ "word", "text", "math_environment", "source_file" })
			end
			assert.is_true(helpers.in_mathzone())
		end)

		it("is false in plain prose", function()
			vim.treesitter.get_node = function()
				return mock_node_chain({ "text", "source_file" })
			end
			assert.is_false(helpers.in_mathzone())
		end)

		it("is false inside \\text{} within math (text_mode beats math ancestor)", function()
			vim.treesitter.get_node = function()
				return mock_node_chain({
					"word",
					"text",
					"curly_group",
					"text_mode",
					"displayed_equation",
					"source_file",
				})
			end
			assert.is_false(helpers.in_mathzone())
		end)

		it("is false when no node is at cursor", function()
			vim.treesitter.get_node = function()
				return nil
			end
			assert.is_false(helpers.in_mathzone())
		end)
	end)
end)
