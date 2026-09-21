require("trouble").setup({
  modes = {
    -- diagnostics = { auto_open = true },
    symbols = {
      win = { size = 40 },
      format = "{kind_icon} {symbol.name}",
    },
  },
  auto_close = true,
  max_items = 1000,
})

local opts = { silent = true }

opts.desc = "(Trouble) Diagnostics"
vim.keymap.set("n", "<leader>tD", "<cmd>Trouble diagnostics toggle<cr>", opts)

opts.desc = "(Trouble) Buffer Diagnostics"
vim.keymap.set("n", "<leader>td", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", opts)

opts.desc = "(Trouble) Symbols"
vim.keymap.set("n", "<leader>ts", "<cmd>Trouble symbols toggle focus=false<cr>", opts)

opts.desc = "(Trouble) LSP Definitions / references / ..."
vim.keymap.set("n", "<leader>tl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", opts)

opts.desc = "(Trouble) Location List"
vim.keymap.set("n", "<leader>tL", "<cmd>Trouble loclist toggle<cr>", opts)

opts.desc = "(Trouble) Quickfix List"
vim.keymap.set("n", "<leader>tQ", "<cmd>Trouble qflist toggle<cr>", opts)
