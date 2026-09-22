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
