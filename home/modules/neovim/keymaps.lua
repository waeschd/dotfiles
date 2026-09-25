local opts = { silent = true }
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

opts.desc = "Change without saving to registers"
vim.keymap.set({ "n", "v" }, "c", [["_c]], opts)

opts.desc = "Delete to end of line without saving to registers"
vim.keymap.set({ "n", "v" }, "D", [["_D]], opts)

opts.desc = "Change to end of line without saving to registers"
vim.keymap.set({ "n", "v" }, "C", [["_C]], opts)

opts.desc = "Change line without saving to registers"
vim.keymap.set({ "n", "v" }, "S", [["_S]], opts)

opts.desc = "Delete char before cursor without saving to registers"
vim.keymap.set({ "n", "v" }, "X", [["_X]], opts)

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

opts.desc = "Move cursor down in insert mode"
vim.keymap.set("i", "<C-j>", "<Down>", opts)

opts.desc = "Exit terminal insert mode"
vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", opts)

-- Neovim collapses them back into one key and <Tab>'s mapping wins for both
-- (see :h CTRL-I) -- this keeps <C-i> on its default jumplist-forward action.
opts.desc = "Jump to newer cursor position"
vim.keymap.set("n", "<C-i>", "<C-i>", opts)

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
vim.keymap.set("n", "<leader>cc", "gcc", { silent = true, remap = true, desc = "Toggle comment line" })
vim.keymap.set("v", "<leader>cc", "gc", { silent = true, remap = true, desc = "Toggle comment selection" })

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


opts.desc = "(LSP) Go to definition"
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

opts.desc = "(LSP) Go to declaration"
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

opts.desc = "(LSP) Code action"
vim.keymap.set("n", "<leader>lca", vim.lsp.buf.code_action, opts)

opts.desc = "(LSP) Rename"
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)

opts.desc = "(LSP) Toggle inlay hints"
vim.keymap.set("n", "<leader>lh", function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), { bufnr })
end, opts)

-- Diagnostics
opts.desc = "(Diagnostics) Toggle virtual lines"
vim.keymap.set("n", "<leader>dvl", function()
  local current = vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = not current })
end, opts)

opts.desc = "(Diagnostics) Toggle virtual text"
vim.keymap.set("n", "<leader>dvi", function()
  local current = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not current })
end, opts)


opts.desc = "Go to file under cursor"
vim.keymap.set("n", "gf", function()
  vim.cmd("vertical wincmd f")
end, opts)

opts.desc = "Go to file:line under cursor"
vim.keymap.set("n", "gF", function()
  vim.cmd("vertical wincmd F")
end, opts)
