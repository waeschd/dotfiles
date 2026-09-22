-- Per-window buffer list: each window remembers, in a fixed order, only the
-- buffers that have actually been displayed in it -- unlike :bnext/:bprevious,
-- which cycle through every listed buffer in the whole session.
--
-- Note on window-groups.nvim (a similar-looking plugin checked as a
-- reference): it enforces single-ownership -- a buffer can only ever be
-- shown in one window at a time, and it forcibly reverts/redirects focus if
-- you try to open the same buffer in a second window. We explicitly want
-- the opposite (the same buffer visible in several windows, each tracking
-- it independently), so that mechanism isn't reusable here. We did borrow
-- its floating-window exclusion and its "land on the positional neighbor,
-- not just the last buffer" close behavior below.
local group = vim.api.nvim_create_augroup("WindowLocalBuffers", { clear = true })

-- Never track unlisted/special buffers (quickfix, terminal, help, a
-- plugin's own UI panel, ...) -- only real file/scratch buffers belong in
-- a window's cycle history.
local function is_eligible_buf(buf)
  return vim.bo[buf].buflisted and vim.bo[buf].buftype == ""
end

local function is_floating(win)
  return vim.api.nvim_win_get_config(win).relative ~= ""
end

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = group,
  callback = function()
    vim.schedule(function()
      local win = vim.api.nvim_get_current_win()
      if not vim.api.nvim_win_is_valid(win) or is_floating(win) then
        return
      end

      local buf = vim.api.nvim_get_current_buf()
      if not is_eligible_buf(buf) then
        return
      end

      local list = vim.w[win].buf_history or {}

      for _, b in ipairs(list) do
        if b == buf then
          return
        end
      end

      table.insert(list, buf)
      vim.w[win].buf_history = list

      -- cokeline (or any other tabline reading WinBufList()) already redrew
      -- synchronously for the very event that got us here, i.e. *before*
      -- this scheduled callback ran -- so it rendered against the stale
      -- pre-update list. Force one more redraw now that the list is current.
      pcall(vim.cmd, "redrawtabline")
    end)
  end,
})

-- Deleted/wiped buffers are only pruned lazily, from whichever window's list
-- notices them going stale -- not eagerly from every window on BufDelete.
local function get_win_list(win)
  local list = vim.w[win].buf_history or {}
  local pruned = {}
  for _, buf in ipairs(list) do
    if vim.api.nvim_buf_is_valid(buf) then
      table.insert(pruned, buf)
    end
  end
  if #pruned ~= #list then
    vim.w[win].buf_history = pruned
  end
  return pruned
end

local function cycle(step)
  local win = vim.api.nvim_get_current_win()
  local list = get_win_list(win)
  if #list <= 1 then
    return
  end

  local current = vim.api.nvim_get_current_buf()
  local idx = 1
  for i, buf in ipairs(list) do
    if buf == current then
      idx = i
      break
    end
  end

  vim.cmd.buffer(list[((idx - 1 + step) % #list) + 1])
end

function _G.WinBufNext()
  cycle(1)
end

function _G.WinBufPrev()
  cycle(-1)
end

-- Public getter for other plugins (e.g. a bufferline) that want to show
-- only the current window's own buffer list instead of every buffer.
function _G.WinBufList()
  return get_win_list(vim.api.nvim_get_current_win())
end

-- Checks both the tracked history (a window that *has shown* this buffer
-- before) and what's currently on screen (belt-and-suspenders: never delete
-- a buffer some window is actually displaying right now, even if that
-- window's history missed recording it for some other untracked reason).
local function is_referenced_by_any_window(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return true
    end
    for _, buf in ipairs(vim.w[win].buf_history or {}) do
      if buf == bufnr then
        return true
      end
    end
  end
  return false
end

local function has_breakpoints(bufnr)
  local ok, dap = pcall(require, "dap.breakpoints")

  if not ok or not dap then
    return false
  end

  local breakpoints = dap.get(bufnr)
  for _, bp_list in pairs(breakpoints) do
    if #bp_list > 0 then
      return true
    end
  end
  return false
end

-- Closes the current buffer for this window's own list only: if another
-- window still has it in its list (even if not currently displaying it),
-- the underlying buffer is left loaded for that window to come back to.
function _G.WinBufClose()
  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()

  if has_breakpoints(bufnr) then
    local answer = vim.fn.input("Breakpoints found in buffer. Still want to close it? (y/N): ")
    if answer:lower() ~= "y" and answer:lower() ~= "yes" then
      return
    end
  end

  local list = get_win_list(win)
  local removed_idx
  for i, buf in ipairs(list) do
    if buf == bufnr then
      table.remove(list, i)
      removed_idx = i
      break
    end
  end
  vim.w[win].buf_history = list

  if #list > 0 then
    -- Land on the buffer that took the closed one's place in the list
    -- (or the new last one, if it was at the end) rather than always
    -- jumping to the oldest/last-opened buffer.
    vim.cmd.buffer(list[math.min(removed_idx or #list, #list)])
  else
    vim.cmd("enew")
  end

  if not is_referenced_by_any_window(bufnr) then
    vim.api.nvim_buf_delete(bufnr, {})
  end
end

local opts = { silent = true }

opts.desc = "Close current buffer (this window's list only)"
vim.keymap.set("n", "<leader>x", WinBufClose, opts)

opts.desc = "Go to next buffer in this window"
vim.keymap.set("n", "<Tab>", WinBufNext, opts)

opts.desc = "Go to previous buffer in this window"
vim.keymap.set("n", "<S-Tab>", WinBufPrev, opts)
