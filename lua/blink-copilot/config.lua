local M = {}

---@class Config
---@field max_completions integer Maximum number of completions to show
---@field max_attempts? integer Maximum number of attempts to fetch completions
---@field kind string Specifies the type of completion item to display
M.options = {
	max_completions = 3,
	kind = "Copilot",
	debounce = 200, ---@type integer | false
	auto_refresh = {
		backward = true,
		forward = true,
	},
}

---Merge the user options with the default options
---@param user_opts Config
function M.init(user_opts)
	M.options = vim.tbl_deep_extend("force", M.options, user_opts)
end

return M
