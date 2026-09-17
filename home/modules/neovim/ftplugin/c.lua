local opt = vim.opt_local

opt.tabstop     = 8     -- Number of visual spaces per TAB character
opt.softtabstop = 8     -- Number of spaces a <Tab> counts for while editing
opt.shiftwidth  = 8     -- Number of spaces to use for each step of (auto)indent
opt.expandtab   = false -- Use actual TAB characters (not spaces) when indenting
opt.autoindent  = true  -- Copy indentation from the current line when starting a new one
opt.smartindent = true  -- Automatically insert extra indentation in certain contexts
opt.cindent     = true  -- C-syntax-aware indenting (braces, case labels, preprocessor,
                         -- continuation lines) -- takes precedence over smartindent for C
