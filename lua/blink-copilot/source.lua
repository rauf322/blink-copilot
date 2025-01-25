local util = require("blink-copilot.util")
local config = require("blink-copilot.config")

local M = {}

---The constructor for the completion provider
---@param opts Config
function M:new(opts)
	self:detect_lsp_client()
	self:reset()

	local source_config = vim.tbl_deep_extend("force", config.options, opts)
	source_config.max_attempts = source_config.max_attempts or source_config.max_completions + 1

	-- Register the new kind if it doesn't exist
	local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
	if not CompletionItemKind[source_config.kind] then
		local kind_idx = #CompletionItemKind + 1
		CompletionItemKind[kind_idx] = source_config.kind
		CompletionItemKind[source_config.kind] = kind_idx
	end

	return setmetatable({
		config = source_config,
		kind_idx = CompletionItemKind[source_config.kind],
	}, { __index = self })
end

---Detect the LSP client
function M:detect_lsp_client()
	if self.client and not self.client.is_stopped() then
		return
	end

	local copilot_lua_clients = vim.lsp.get_clients({ name = "copilot" })
	local copilot_vim_clients = vim.lsp.get_clients({ name = "GitHub Copilot" })
	self.client = copilot_lua_clients and copilot_lua_clients[1] or copilot_vim_clients and copilot_vim_clients[1]
end

---Reset the context
function M:reset()
	util.cancel_request(self.client, self.context and self.context.first_req_id)
	util.cancel_request(self.client, self.context and self.context.cycling_req_id)

	---@class CompletionContext
	self.context = {
		cache = {},
		completions = {},
		target = nil,
		first_req_id = nil,
		cycling_req_id = nil,
	}
end

---Add new completions to the context
---@param items blink.cmp.CompletionItem[]
function M:add_new_completions(items)
	local new_completions = {}

	for _, item in ipairs(items) do
		if #self.context.completions < config.options.max_completions then
			if not self.context.cache[item.label] then
				self.context.cache[item.label] = true
				table.insert(self.context.completions, item)
				table.insert(new_completions, item)
			end
		end
	end

	return new_completions
end

---Implement the get_completions method of the completion provider
---@param ctx blink.cmp.Context
---@param resolve fun(self: blink.cmp.CompletionResponse): nil
function M:get_completions(ctx, resolve)
	if not self.client then
		return
	end

	local current_state = {
		bufnr = ctx.bufnr,
		id = ctx.id,
		line = ctx.cursor[0],
		col = ctx.cursor[1],
	}

	if vim.deep_equal(current_state, self.context.target) then
		resolve({
			is_incomplete_forward = false,
			is_incomplete_backward = false,
			items = self.context.completions,
		})
		return
	end

	self:reset()

	coroutine.wrap(function()
		local co = coroutine.running()
		local lsp_params = util.get_lsp_params()

		---@type lsp.Handler
		local function handle_lsp_response(err, response)
			if not err and response and response.items then
				coroutine.resume(co, response.items)
			end
		end

		---@param is_initial_request boolean
		local function send_completion_request(is_initial_request)
			local request_success, request_id =
				util.get_completions_from_lsp(self.client, lsp_params, handle_lsp_response)

			if request_success then
				if is_initial_request then
					self.context.first_req_id = request_id
				else
					self.context.cycling_req_id = request_id
				end
			end
			return request_success
		end

		local function process_and_resolve_items()
			local lsp_items = coroutine.yield()
			local blink_items = util.lsp_completion_items_to_blink_items(lsp_items, self.kind_idx)
			local added_items = self:add_new_completions(blink_items)

			resolve({
				is_incomplete_forward = false,
				is_incomplete_backward = false,
				items = added_items,
			})
		end

		-- Get the first completions
		if send_completion_request(true) then
			process_and_resolve_items()
			self.context.first_req_id = nil
			self.context.target = current_state
		end

		-- Attempt to get more completions
		lsp_params = util.to_cycling_lsp_params(lsp_params)
		local attempts_made = 0
		while #self.context.completions < self.config.max_completions and attempts_made < self.config.max_attempts do
			attempts_made = attempts_made + 1
			if send_completion_request(false) then
				process_and_resolve_items()
				self.context.cycling_req_id = nil
			end
		end
	end)()
end

return M
