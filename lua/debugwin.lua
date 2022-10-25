local namespace = vim.api.nvim_create_namespace("debugwin")

local ctx = {
	buf_nr = nil,
	buf_name = "debugwin://DebugBuffer",
	win_id = nil,
}

--- Buffer -------------------------------------------------------------------------------------------------------------

local function valid_buf(buf_nr)
	local _, buf_name = pcall(vim.api.nvim_buf_get_name, buf_nr)
	return buf_name == ctx.buf_name
end

local function find_last_buf()
	local buf_nrs = vim.tbl_filter(valid_buf, vim.api.nvim_list_bufs())
	return #buf_nrs > 1 and math.max(unpack(buf_nrs)) or buf_nrs[1]
end

local function create_buf()
	local buf_nr = vim.api.nvim_create_buf(false, true)
	pcall(vim.api.nvim_buf_set_name, buf_nr, ctx.buf_name)
	return buf_nr
end

--- Window -------------------------------------------------------------------------------------------------------------

local function valid_win(win_id)
	if type(win_id) == "number" and vim.api.nvim_win_is_valid(win_id) then
		return valid_buf(vim.api.nvim_win_get_buf(win_id))
	end
end

local function find_last_win()
	local win_ids = vim.tbl_filter(valid_win, vim.api.nvim_list_wins())
	return #win_ids > 1 and math.max(unpack(win_ids)) or win_ids[1]
end

local function create_win(buf_nr)
	local win_conf = {
		anchor = "NE",
		border = "single",
		focusable = true,
		relative = "editor",
		---
		width = vim.o.columns,
		height = vim.o.cmdwinheight,
		row = vim.o.lines,
		col = vim.o.columns,
	}

	local win_id = vim.api.nvim_open_win(buf_nr, false, win_conf)
	vim.api.nvim_win_set_hl_ns(win_id, namespace)
	vim.api.nvim_win_set_option(win_id, "winblend", 20)
	vim.api.nvim_win_set_option(win_id, "winhighlight", "NormalFloat:Normal")

	return win_id
end

--- Exported -----------------------------------------------------------------------------------------------------------

local M = {}

function M.show(content, insert_date)
	content = vim.deepcopy(content)
	if type(content) == "nil" then
		content = vim.api.nvim_cmd({ cmd = "messages" }, { output = true })
		content = vim.split(content, "\n")
	elseif type(content) == "string" then
		content = vim.split(content, "\n")
	elseif type(content) ~= "table" then
		return
	end

	if insert_date == true then
		table.insert(content, 1, ("----- %s -----"):format(os.date("%H:%M:%S")))
	end

	content = vim.tbl_map(function(val)
		return string.format("%s", type(val) == "table" and vim.inspect(val) or val)
	end, content)

	local last_buf_nr = find_last_buf()
	ctx.buf_nr = last_buf_nr and last_buf_nr or create_buf()

	local last_win_id = find_last_win()
	ctx.win_id = last_win_id and last_win_id or create_win(ctx.buf_nr)

	vim.api.nvim_buf_set_lines(ctx.buf_nr, 0, -1, false, content)

	vim.api.nvim_win_call(ctx.win_id, function()
		vim.cmd.wincmd("J")
		vim.cmd.normal("gg")
	end)

end

function M.focus()
	if valid_win(ctx.win_id) then
		vim.api.nvim_set_current_win(ctx.win_id)
		vim.cmd.normal("gg")
	end
end

function M.close()
	if valid_buf(ctx.buf_nr) then
		vim.api.nvim_buf_delete(ctx.buf_nr, { force = true })
	end
end

return M
