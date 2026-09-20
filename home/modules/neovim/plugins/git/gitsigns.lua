require("gitsigns").setup({
  signcolumn = false,
  numhl = true,

  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")

    local function map(mode, key, action, opts)
      local opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, key, action, opts)
    end

    local opts = {}
    --------- Navigation ---------
    -- Hunk
    opts.desc = "(GitSigns) Jump to next hunk"
    map("n", "<leader>ghn", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, opts)

    opts.desc = "(GitSigns) Jump to prev hunk"
    map("n", "<leader>ghp", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, opts)

    --------- Actions -----------
    -- Hunk
    opts.desc = "(GitSigns) Stage hunk"
    map("n", "<leader>ghs", gitsigns.stage_hunk, opts)

    opts.desc = "(GitSigns) Reset hunk"
    map("n", "<leader>ghr", gitsigns.reset_hunk, opts)

    opts.desc = "(GitSigns) Preview hunk inline"
    map("n", "<leader>ghi", gitsigns.preview_hunk_inline, opts)

    opts.desc = "(GitSigns) Stage hunk"
    map("v", "<leader>ghs", function()
      gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, opts)

    opts.desc = "(GitSigns) Reset hunk"
    map("v", "<leader>ghr", function()
      gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, opts)

    -- Buffer
    opts.desc = "(GitSigns) Stage buffer"
    map("n", "<leader>gbs", gitsigns.stage_buffer, opts)

    opts.desc = "(GitSigns) Reset buffer"
    map("n", "<leader>gbr", gitsigns.reset_buffer, opts)

    opts.desc = "(GitSigns) Blame buffer"
    map("n", "<leader>gbb", gitsigns.blame, opts)

    -- QuickFix list
    opts.desc = "(GitSigns) Send (global) hunks to QuickFix list"
    map("n", "<leader>ghQ", function()
      gitsigns.setqflist("all")
    end, opts)

    opts.desc = "(GitSigns) Send (buffer) hunks to QuickFix list"
    map("n", "<leader>ghq", gitsigns.setqflist, opts)

    -- Text object
    map({ "n", "v" }, "ghv", gitsigns.select_hunk)
  end,
})
