-- Per-window buffer list: each window remembers, in a fixed order, only the
-- buffers that have actually been displayed in it -- unlike :bnext/:bprevious,
-- which cycle through every listed buffer in the whole session.
local group = vim.api.nvim_create_augroup("WindowLocalBuffers", { clear = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = group,
  callback = function(args)
    local win = vim.api.nvim_get_current_win()
    local list = vim.w[win].buf_history or {}

    for _, buf in ipairs(list) do
      if buf == args.buf then
        return
      end
    end

    table.insert(list, args.buf)
    vim.w[win].buf_history = list
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

local function is_referenced_by_any_window(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
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
  for i, buf in ipairs(list) do
    if buf == bufnr then
      table.remove(list, i)
      break
    end
  end
  vim.w[win].buf_history = list

  if #list > 0 then
    vim.cmd.buffer(list[#list])
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
