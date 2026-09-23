local auto_session = require("auto-session")

-- auto-session's own save/restore messages print the raw absolute path
-- (e.g. "Saved session: /home/seru/Projects/foo"), with no option to
-- abbreviate it. Suppress that built-in message and print our own with the
-- home directory literally substituted out, using whatever path was
-- actually being saved/restored (the given session_name if one was passed,
-- since that's not necessarily the cwd, falling back to cwd otherwise).
local function display_path(session_name)
  local path = (session_name and session_name ~= "") and session_name or vim.fn.getcwd()
  local home = vim.env.HOME
  if home and home ~= "" then
    path = path:gsub(vim.pesc(home), "~")
  end
  return path
end

local orig_save_session = auto_session.save_session
auto_session.save_session = function(session_name, opts)
  opts = opts or {}
  local show = opts.show_message == nil or opts.show_message
  opts.show_message = false
  local ok = orig_save_session(session_name, opts)
  if ok and show then
    vim.notify("Saved session: " .. display_path(session_name))
  end
  return ok
end

local orig_restore_session = auto_session.restore_session
auto_session.restore_session = function(session_name, opts)
  opts = opts or {}
  local show = opts.show_message == nil or opts.show_message
  opts.show_message = false
  local ok = orig_restore_session(session_name, opts)
  if ok and show then
    vim.notify("Restored session: " .. display_path(session_name))
  end
  return ok
end

auto_session.setup({
  bypass_save_filetypes = { "alpha", "dashboard", "snacks_dashboard" },
  auto_create = false,
  save_extra_data = function(_)
    local extra_data = {}

    local ok, breakpoints = pcall(require, "dap.breakpoints")
    if ok and breakpoints then
      local bps = {}
      local breakpoints_by_buf = breakpoints.get()
      for buf, buf_bps in pairs(breakpoints_by_buf) do
        bps[vim.api.nvim_buf_get_name(buf)] = buf_bps
      end
      if not vim.tbl_isempty(bps) then
        extra_data.breakpoints = bps
      end
    end

    local win_histories = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local list = vim.w[win].buf_history
      if list and #list > 0 then
        local paths = {}
        for _, buf in ipairs(list) do
          if vim.api.nvim_buf_is_valid(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            if name ~= "" then
              table.insert(paths, name)
            end
          end
        end
        if #paths > 0 then
          local tabnr, winnr = unpack(vim.fn.win_id2tabwin(win))
          win_histories[tabnr .. ":" .. winnr] = paths
        end
      end
    end
    if not vim.tbl_isempty(win_histories) then
      extra_data.win_histories = win_histories
    end

    if vim.tbl_isempty(extra_data) then
      return
    end
    return vim.fn.json_encode(extra_data)
  end,

  restore_extra_data = function(_, extra_data)
    local function get_buffer_number(fpath)
      local bufnr = vim.fn.bufnr(fpath, true)
      -- Load the file if it wasn't loaded by the session
      if vim.fn.bufloaded(bufnr) == 0 then
        vim.api.nvim_buf_call(bufnr, vim.cmd.edit)
      end
      return bufnr
    end

    local json = vim.fn.json_decode(extra_data)

    if json.breakpoints then
      local ok, breakpoints = pcall(require, "dap.breakpoints")

      if ok and breakpoints then
        vim.notify("restoring breakpoints")
        for buf_name, buf_bps in pairs(json.breakpoints) do
          for _, bp in pairs(buf_bps) do
            local line = bp.line
            local opts = {
              condition = bp.condition,
              log_message = bp.logMessage,
              hit_condition = bp.hitCondition,
            }
            local buf = get_buffer_number(buf_name)
            breakpoints.set(opts, buf, line)
          end
        end
      end
    end

    if json.win_histories then
      for key, paths in pairs(json.win_histories) do
        local tabnr, winnr = key:match("^(%d+):(%d+)$")
        local win = vim.fn.win_getid(tonumber(winnr), tonumber(tabnr))
        if win ~= 0 then
          local bufnrs = {}
          for _, path in ipairs(paths) do
            table.insert(bufnrs, get_buffer_number(path))
          end
          vim.w[win].buf_history = bufnrs
        end
      end
    end
  end,
})
