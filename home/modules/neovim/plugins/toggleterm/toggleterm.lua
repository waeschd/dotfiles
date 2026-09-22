require("toggleterm").setup({
  open_mapping = [[<a-t>]],
  direction = "horizontal",
  persist_mode = true,
  shade_terminals = false,
  float_opts = {
    border = "curved",
  },
  winbar = {
    enabled = true,
    name_formatter = function(term)
      return "" .. "#" .. term.id
    end,
  },
})

-- floating terminal
local Terminal = require("toggleterm.terminal").Terminal

local float_term = Terminal:new({
  direction = "float",
  float_opts = { border = "curved" },
})

function _G.toggle_float_term()
  float_term:toggle()
end

vim.keymap.set({ "n", "t" }, "<A-f>", function()
  _G.toggle_float_term()
end, { noremap = true, silent = true })

-- Cycle between open terminals (toggleterm has no built-in "next/prev
-- terminal" mapping -- it only identifies terminals by number).
local function current_term_id()
  if vim.bo.buftype == "terminal" then
    return vim.b.toggle_number
  end
end

local function cycle_term(step)
  local toggleterm = require("toggleterm.terminal")
  local terms = toggleterm.get_all()

  if not terms or vim.tbl_isempty(terms) then
    vim.notify("No ToggleTerm terminals available", vim.log.levels.WARN)
    return
  end

  local ids = {}
  for _, term in ipairs(terms) do
    if term.id ~= nil then
      table.insert(ids, term.id)
    end
  end
  table.sort(ids)

  local current = current_term_id()
  local idx = 1
  if current then
    for i, id in ipairs(ids) do
      if id == current then
        idx = i
        break
      end
    end
  end

  local next_id = ids[((idx - 1 + step) % #ids) + 1]
  if next_id == current then
    return
  end

  local current_term = current and toggleterm.get(current)
  if current_term then
    current_term:close()
  end
  toggleterm.get(next_id):open()
end

vim.keymap.set({ "n", "t" }, "<A-]>", function()
  cycle_term(1)
end, { noremap = true, silent = true, desc = "Next ToggleTerm terminal" })

vim.keymap.set({ "n", "t" }, "<A-[>", function()
  cycle_term(-1)
end, { noremap = true, silent = true, desc = "Previous ToggleTerm terminal" })

-- Send visual selection to terminal
local last_term_id = nil

vim.keymap.set("v", "<leader>st", function()
  local toggleterm = require("toggleterm.terminal")
  local terms = toggleterm.get_all()

  if not terms or vim.tbl_isempty(terms) then
    vim.notify("No ToggleTerm terminals available", vim.log.levels.WARN)
    return
  end

  -- Collect valid terminal IDs
  local term_ids = {}
  for _, term in ipairs(terms) do
    if term.id ~= nil then
      table.insert(term_ids, term.id)
    end
  end

  if vim.tbl_isempty(term_ids) then
    vim.notify("No valid ToggleTerm IDs found", vim.log.levels.ERROR)
    return
  end

  -- Single terminal → send directly
  if #term_ids == 1 then
    last_term_id = term_ids[1]
    vim.cmd("ToggleTermSendVisualSelection " .. last_term_id)
    return
  end

  -- Explicit, readable default selection logic
  local default_id
  if last_term_id ~= nil and vim.tbl_contains(term_ids, last_term_id) then
    default_id = last_term_id
  else
    default_id = term_ids[1]
  end

  vim.ui.input({
    prompt = "Send to terminal #: ",
    default = tostring(default_id),
  }, function(input)
    if not input then
      return
    end

    local term_id = tonumber(input)
    if term_id == nil or not vim.tbl_contains(term_ids, term_id) then
      vim.notify("Invalid terminal number", vim.log.levels.ERROR)
      return
    end

    last_term_id = term_id
    vim.cmd("ToggleTermSendVisualSelection " .. term_id)
  end)
end, { desc = "(ToggleTerm) Send visual selection to terminal" })
