local snippets_path = vim.fn.stdpath("config") .. "/luasnippets/supercollider.lua"

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

describe("supercollider snippets", function()
	local regular, autosnippets
	local original_get_node

	before_each(function()
		regular, autosnippets = dofile(snippets_path)
		original_get_node = vim.treesitter.get_node
	end)

	after_each(function()
		vim.treesitter.get_node = original_get_node
	end)

	local function in_code()
		vim.treesitter.get_node = function()
			return mock_node_chain({ "identifier", "function_call", "source_file" })
		end
	end

	local function in_string()
		vim.treesitter.get_node = function()
			return mock_node_chain({ "string", "source_file" })
		end
	end

	local function in_comment()
		vim.treesitter.get_node = function()
			return mock_node_chain({ "line_comment", "source_file" })
		end
	end

	local function in_symbol()
		vim.treesitter.get_node = function()
			return mock_node_chain({ "symbol", "source_file" })
		end
	end

	local representative_triggers = { "sd", "ndef", "pdef", "pb", "sin", "saw", "rlpf", "env", "perc", "splay" }

	describe("inventory", function()
		it("registers all 18 expected triggers", function()
			local expected = {
				"sd",
				"ndef",
				"pdef",
				"pb",
				"sin",
				"saw",
				"pulse",
				"lfn",
				"lfsaw",
				"dust",
				"env",
				"perc",
				"lpf",
				"rlpf",
				"bpf",
				"splay",
				"lag",
				"decay",
			}
			for _, trig in ipairs(expected) do
				assert.is_not_nil(find_snippet(autosnippets, trig), "missing trigger: " .. trig)
			end
			assert.are.equal(#expected, #autosnippets)
		end)

		it("regular list is empty", function()
			assert.are.equal(0, #regular)
		end)
	end)

	describe("in_sc_code guard", function()
		for _, trig in ipairs(representative_triggers) do
			it("expands `" .. trig .. "` in code", function()
				in_code()
				local snip = find_snippet(autosnippets, trig)
				local params = snip:resolveExpandParams(trig, trig, {})
				assert.is_not_nil(params)
			end)

			it("does NOT expand `" .. trig .. "` inside a string", function()
				in_string()
				local snip = find_snippet(autosnippets, trig)
				local params = snip:resolveExpandParams(trig, trig, {})
				assert.is_nil(params)
			end)

			it("does NOT expand `" .. trig .. "` inside a line comment", function()
				in_comment()
				local snip = find_snippet(autosnippets, trig)
				local params = snip:resolveExpandParams(trig, trig, {})
				assert.is_nil(params)
			end)

			it("does NOT expand `" .. trig .. "` inside a symbol", function()
				in_symbol()
				local snip = find_snippet(autosnippets, trig)
				local params = snip:resolveExpandParams(trig, trig, {})
				assert.is_nil(params)
			end)
		end
	end)
end)

describe("dot.luasnip.helpers in_sc_code", function()
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

	it("is true at top level of code", function()
		vim.treesitter.get_node = function()
			return mock_node_chain({ "identifier", "source_file" })
		end
		assert.is_true(helpers.in_sc_code())
	end)

	it("is true deep inside a function body", function()
		vim.treesitter.get_node = function()
			return mock_node_chain({
				"identifier",
				"function_call",
				"function_block",
				"function_definition",
				"source_file",
			})
		end
		assert.is_true(helpers.in_sc_code())
	end)

	it("is false inside a string literal", function()
		vim.treesitter.get_node = function()
			return mock_node_chain({ "string", "source_file" })
		end
		assert.is_false(helpers.in_sc_code())
	end)

	it("is false inside a symbol literal", function()
		vim.treesitter.get_node = function()
			return mock_node_chain({ "symbol", "source_file" })
		end
		assert.is_false(helpers.in_sc_code())
	end)

	it("is false inside a line comment", function()
		vim.treesitter.get_node = function()
			return mock_node_chain({ "line_comment", "source_file" })
		end
		assert.is_false(helpers.in_sc_code())
	end)

	it("is false inside a block comment", function()
		vim.treesitter.get_node = function()
			return mock_node_chain({ "block_comment", "source_file" })
		end
		assert.is_false(helpers.in_sc_code())
	end)

	it("is false when string is an ancestor (not just current node)", function()
		vim.treesitter.get_node = function()
			return mock_node_chain({ "string_content", "string", "source_file" })
		end
		assert.is_false(helpers.in_sc_code())
	end)

	it("is true when no node at cursor (defaults open, not closed)", function()
		vim.treesitter.get_node = function()
			return nil
		end
		assert.is_true(helpers.in_sc_code())
	end)
end)
