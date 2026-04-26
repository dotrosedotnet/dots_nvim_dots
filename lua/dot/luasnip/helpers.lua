local M = {}

local MATH_NODES = {
	displayed_equation = true,
	inline_formula = true,
	math_environment = true,
}

function M.in_mathzone()
	local node = vim.treesitter.get_node()
	while node do
		local t = node:type()
		if t == "text_mode" then
			return false
		elseif MATH_NODES[t] then
			return true
		end
		node = node:parent()
	end
	return false
end

local SC_NON_CODE_NODES = {
	string = true,
	symbol = true,
	line_comment = true,
	block_comment = true,
}

function M.in_sc_code()
	local node = vim.treesitter.get_node()
	while node do
		if SC_NON_CODE_NODES[node:type()] then
			return false
		end
		node = node:parent()
	end
	return true
end

return M
