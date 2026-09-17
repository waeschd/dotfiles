local opts = { silent = true }
--local opts = { noremap = true, silent = true }

-- Visual line movement and indent behavior
opts.desc = "Move visual selection down one line"
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)

opts.desc = "Move visual selection up one line"
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)

opts.desc = "Shift left and keep selection"
vim.keymap.set("v", "<", "<gv", opts)

opts.desc = "Shift right and keep selection"
vim.keymap.set("v", ">", ">gv", opts)

-- Scrolling and search
opts.desc = "Next search result centered"
vim.keymap.set("n", "n", "nzzzv", opts)

opts.desc = "Previous search result centered"
vim.keymap.set("n", "N", "Nzzzv", opts)

-- Clipboard / deletion
opts.desc = "Paste over selection without yanking"
vim.keymap.set("v", "p", '"_dp', opts)

opts.desc = "Delete without saving to registers"
vim.keymap.set({ "n", "v" }, "d", [["_d]], opts)

-- Window navigation
opts.desc = "Move to left split"
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)

opts.desc = "Move to below split"
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)

opts.desc = "Move to above split"
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)

opts.desc = "Move to right split"
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Insert and terminal controls
opts.desc = "Move cursor right in insert mode"
vim.keymap.set("i", "<C-l>", "<Right>", opts)

opts.desc = "Move cursor left in insert mode"
vim.keymap.set("i", "<C-h>", "<Left>", opts)

opts.desc = "Move cursor up in insert mode"
vim.keymap.set("i", "<C-k>", "<Up>", opts)

opts.desc = "Move cursor down in insert mode"
vim.keymap.set("i", "<C-j>", "<Down>", opts)

opts.desc = "Insert new line"
vim.keymap.set("i", "<C-a>", "<NL>", opts)

opts.desc = "Exit terminal insert mode"
vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", opts)

-- Buffer management
opts.desc = "Close current buffer"
vim.keymap.set("n", "<leader>x", function()
  local function is_buffer_visible_in_other_window(bufnr)
    local count = 0
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == bufnr then
        count = count + 1
        if count > 1 then
          return true
        end
      end
    end
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()

  -- If buffer is visible in another window, just switch to next buffer
  if is_buffer_visible_in_other_window(bufnr) then
    vim.notify("Buffer is openend in another window!")
    return
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

  if has_breakpoints(bufnr) then
    local answer = vim.fn.input("Breakpoints found in buffer. Still want to close it? (y/N): ")
    if answer == "" then
      return
    end

    if answer:lower() == "y" or answer:lower() == "yes" then
      vim.cmd('bnext')
      vim.api.nvim_buf_delete(bufnr, {})
    end
  else
    vim.cmd('bnext')
    vim.api.nvim_buf_delete(bufnr, {})
  end
end, opts)

opts.desc = "Go to next buffer"
vim.keymap.set("n", "<Tab>", "<cmd>bn<CR>", opts)

opts.desc = "Go to previous buffe"
vim.keymap.set("n", "<S-Tab>", "<cmd>bp<CR>", opts)

vim.keymap.set({"i","s"}, "<Tab>", function()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local before_cursor = line:sub(1, col)

  -- Only tabs (or empty) before cursor
  if before_cursor:match("^[\t]*$") then
    return "\t"
  else
    return string.rep(" ", vim.bo.tabstop - (col % vim.bo.tabstop))
  end
end, { expr = true, desc = "Tab indent, Space align" })

-- Split window management
opts.desc = "Split window vertically"
vim.keymap.set("n", "<leader>sv", "<C-w>v", opts)

opts.desc = "Split window horizontally"
vim.keymap.set("n", "<leader>sh", "<C-w>s", opts)

opts.desc = "Make split windows equal size"
vim.keymap.set("n", "<leader>se", "<C-w>=", opts)

opts.desc = "Close current split"
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", opts)

opts.desc = "Increase window width"
vim.keymap.set("n", "<M-.>", ":vertical resize +5<CR>", opts)

opts.desc = "Decrease window width"
vim.keymap.set("n", "<M-,>", ":vertical resize -5<CR>", opts)

-- Commentary
opts.remap = true
opts.desc = "Toggle comment line"
vim.keymap.set("n", "<leader>cc", "gcc", opts)

opts.desc = "Toggle comment selection"
vim.keymap.set("v", "<leader>cc", "gc", opts)
opts.remap = false

-- List chars
vim.keymap.set("n", "<leader>cw", function()
  local lc = vim.opt.listchars:get()

  if lc.tab == "  " then
    vim.opt.listchars = {
      trail = "•",
      -- tab = " -➜",
      tab = "➜  ",
      space = "•",
      nbsp = "+",
      eol = "$",
    }
    Snacks.indent.disable()
  else
    vim.opt.listchars = {
      trail = "•",
      tab = "  ",
      space = " ",
    }
    Snacks.indent.enable()
  end
end, { desc = "Toggle whitespace visibility", silent = true })

-- LSP
opts.desc = "(LSP) Format selection"
vim.keymap.set("v", "<leader>lf", function()
  require("conform").format({ async = true, range = true, timeout_ms = 2000, lsp_format = "fallback" })
end, opts)

opts.desc = "(LSP) Format buffer"
vim.keymap.set("n", "<leader>lf", function()
  require("conform").format({
    async = true,
    timeout_ms = 2000,
    lsp_format = "fallback",
  })
end, opts)

opts.desc = "(LSP) Hover code info"
vim.keymap.set("n", "<leader>lci", function () vim.lsp.buf.hover() end, opts)

local lsp_jump_stack = {}

local function push_current_position()
  local buf = vim.api.nvim_get_current_buf()
  local pos = vim.api.nvim_win_get_cursor(0)

  table.insert(lsp_jump_stack, {
    buf = buf,
    lnum = pos[1],
    col = pos[2],
  })
end

local function get_encoding()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  return (clients[1] and clients[1].offset_encoding) or "utf-16"
end

local function smart_lsp_jump(jump_fn, method)
  local params = vim.lsp.util.make_position_params(0, get_encoding())

  vim.lsp.buf_request(0, method, params, function(err, result, ctx, config)
    if err or not result or vim.tbl_isempty(result) then
      return
    end

    -- Only push if a real jump will happen
    push_current_position()

    -- Call the original function to perform the jump
    -- (it will work now because result exists)
    jump_fn()

    -- Give the jump time to complete before centering
    vim.defer_fn(function()
      vim.cmd('normal! zz')
    end, 50)
  end)
end

vim.keymap.set("n", "gd", function()
  smart_lsp_jump(vim.lsp.buf.definition, "textDocument/definition")
end)

vim.keymap.set("n", "gD", function()
  smart_lsp_jump(vim.lsp.buf.declaration, "textDocument/declaration")
end)

local function smart_return()
  if #lsp_jump_stack == 0 then
    return
  end

  local target = table.remove(lsp_jump_stack)

  local current_buf = vim.api.nvim_get_current_buf()

  -- Switch to the target buffer if it's valid
  if vim.api.nvim_buf_is_valid(target.buf) then
    vim.api.nvim_set_current_buf(target.buf)
    vim.api.nvim_win_set_cursor(0, { target.lnum, target.col })
  end

  -- Only delete the previous buffer if it's not the target
  -- AND the buffer is NOT open in any other window
  if current_buf ~= target.buf and vim.api.nvim_buf_is_valid(current_buf) then
    local windows = vim.api.nvim_list_wins()
    local buf_open_elsewhere = false

    for _, win in ipairs(windows) do
      if vim.api.nvim_win_get_buf(win) == current_buf then
        buf_open_elsewhere = true
        break
      end
    end

    if not buf_open_elsewhere then
      vim.api.nvim_buf_delete(current_buf, { force = false })
    end
  end
end

opts.desc = "(LSP) Go back and close buffer"
vim.keymap.set("n", "<C-t>", function()
  smart_return()
end, opts)

opts.desc = "(LSP) Code action"
vim.keymap.set("n", "<leader>lca", vim.lsp.buf.code_action, opts)

opts.desc = "(LSP) Rename"
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)

opts.desc = "(LSP) Toggle inlay hints"
if vim.lsp.inlay_hint then
  vim.keymap.set("n", "<leader>lh", function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), { bufnr })
  end, opts)
end

-- Diagnostics
opts.desc = "(Diagnostics) Toggle virtual text"
vim.keymap.set("n", "<leader>dv", function()
  local current = vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = not current })
end, opts)


opts.desc = "Go to file under cursor"
vim.keymap.set("n", "gf", function()
  vim.cmd("vertical wincmd f")
end, opts)

opts.desc = "Go to file:line under cursor"
vim.keymap.set("n", "gF", function()
  vim.cmd("vertical wincmd F")
end, opts)

opts.desc = "Yank with line numbers"
local function yank_with_line_numbers()
  vim.cmd('noau normal! "vy')
  local text = vim.fn.getreg("v")
  local start_line = vim.fn.line("v")

  local lines = vim.split(text, "\n")
  local numbered_lines = {}

  for i, line in ipairs(lines) do
    -- If the last line is empty, skip it
    if i == #lines and line == "" then
      break
    end

    local current_line_num = start_line + i - 1
    table.insert(numbered_lines, string.format("%d  %s", i, line))
  end

  local final_text = table.concat(numbered_lines, "\n")
  vim.fn.setreg("+", final_text)
  vim.fn.setreg('"', final_text)
end
vim.keymap.set("v", "<leader>yc", yank_with_line_numbers, opts)
