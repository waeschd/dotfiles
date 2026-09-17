local opt = vim.opt_local

opt.softtabstop = 2     -- Number of spaces a <Tab> counts for while editing
opt.tabstop     = 2     -- Number of visual spaces per TAB character
opt.shiftwidth  = 2     -- Number of spaces to use for each step of (auto)indent
opt.expandtab   = true  -- Use Spaces instead of <TAB> when indenting
opt.autoindent  = true  -- Copy indentation from the current line when starting a new one
opt.smartindent = true  -- Automatically insert extra indentation in certain contexts
