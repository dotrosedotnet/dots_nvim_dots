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

return M
