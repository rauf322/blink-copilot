local source = require("blink-copilot.source")
local config = require("blink-copilot.config")

local M = {}

---Create a new instance of the completion provider
---@param opts Config
function M.new(opts)
	local src = source:new(opts)

	vim.api.nvim_create_autocmd({ "LspAttach" }, {
		callback = function()
			src:detect_lsp_client()
		end,
	})

	return src
end

---Setup the plugin with the given options
---@param user_opts Config
function M.setup(user_opts)
	config.init(user_opts)
end

return M
