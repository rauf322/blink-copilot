local M = {}

---@class Config
M.options = {
	max_completions = 3,
	max_attempts = 4,
}

---Merge the user options with the default options
---@param user_opts Config
function M.init(user_opts)
	M.options = vim.tbl_deep_extend("force", M.options, user_opts)
end

return M
