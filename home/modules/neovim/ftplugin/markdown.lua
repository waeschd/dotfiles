local opt = vim.opt_local

opt.tabstop     = 2     -- Number of visual spaces per TAB character
opt.softtabstop = 2     -- Number of spaces a <Tab> counts for while editing
opt.shiftwidth  = 2     -- Number of spaces to use for each step of (auto)indent
opt.expandtab   = true  -- Use Spaces instead of <TAB> when indenting
opt.autoindent  = true  -- Copy indentation from the current line when starting a new one
opt.smartindent = false -- Off: it treats lines starting with "#" as C preprocessor
                         -- directives and un-indents them, which mangles Markdown headings

opt.wrap      = true -- Soft-wrap long lines (prose, unlike code, wants this)
opt.linebreak = true -- Wrap at word boundaries instead of mid-word

opt.spell     = true    -- Spell-check prose
opt.spelllang = "en,de" -- Matches the en/de mix harper_ls is configured for
