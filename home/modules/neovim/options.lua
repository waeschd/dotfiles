-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Show hidden characters: trailing spaces, tabs, etc.
vim.opt.listchars = {
  trail = "•",
  tab = "  ",
}
vim.opt.list = true -- Enable display of the above list characters

-- Split window behavior
vim.opt.splitright = true -- New vertical splits open to the right
vim.opt.splitbelow = true -- New horizontal splits open below

-- Line numbers
vim.opt.number = true         -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers (current line stays absolute)

-- File backups and persistence
vim.opt.swapfile = false -- Disable swap files
vim.opt.backup = false   -- Disable backup files (filename~)
vim.opt.undofile = true  -- Save undo history across sessions

-- Information to save and restore for sessions
vim.opt.sessionoptions = {
  "buffers",
  "tabpages",
  "globals",
  "blank",
  "curdir",
  "folds",
  "help",
  "winsize",
  "winpos",
  "terminal",
  "localoptions",
}

-- Show live substitution preview in a split window
vim.opt.inccommand = "split"

-- Better colors and UI appearance
vim.opt.termguicolors = true -- Enable 24-bit color support in terminal
vim.opt.signcolumn = "yes"   -- Always show the sign column (for git/lsp indicators)

-- Backspace behavior
vim.opt.backspace = { "start", "eol", "indent" } -- Allow backspacing over indentation, line breaks, and insert start

-- Clipboard integration
vim.opt.clipboard:append("unnamedplus") -- Use system clipboard for all yank, delete, and paste operations

-- Search highlighting
vim.opt.hlsearch = true -- Highlight all search results as you type

-- Jumplist: jumping from the middle discards newer entries instead of
-- appending, so CTRL-O/CTRL-I behave like a stack rather than a flat log
vim.opt.jumpoptions = "stack"

-- Default text settings --
vim.opt.tabstop = 2        -- Number of visual spaces per TAB character
vim.opt.softtabstop = 2    -- Number of spaces a <Tab> counts for while editing
vim.opt.shiftwidth = 2     -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true   -- Use Spaces instead of <TAB> when indenting
vim.opt.wrap = true        -- Enable line wrapping (long lines wrap to next line)
vim.opt.sidescroll = 1     -- Scroll character by character (smoother)
vim.opt.copyindent = true  -- Copy indentation from the current line when starting a new one

vim.opt.ignorecase = true -- Ignore case when searching
vim.opt.smartcase = true  -- Override ignorecase when the search pattern has an uppercase letter

-- Move statusline to the bottom
vim.opt.cmdheight = 0

-- Disable default search count
vim.opt.shortmess:append("S")

-- Diagnostics
local signs = {
  Error = "󰅚 ",
  Warn = "󰀪 ",
  Hint = "󰌶 ",
  Info = "󰋽 ",
}

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = signs.Error,
      [vim.diagnostic.severity.WARN] = signs.Warn,
      [vim.diagnostic.severity.HINT] = signs.Hint,
      [vim.diagnostic.severity.INFO] = signs.Info,
    },
  },
  virtual_lines = false, -- Disable inline virtual-line diagnostics (signs are used instead)
})

vim.opt.mousemoveevent = true -- Enable mouse-move events (e.g. for hover-based UI)
