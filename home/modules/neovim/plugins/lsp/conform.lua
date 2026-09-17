-- conform.nvim registers itself as a formatting provider that
-- `vim.lsp.buf.format()`/keymaps.lua's <leader>lf can fall back to, so
-- filetypes with no formatter listed below (e.g. Rust) still format via
-- their attached LSP server.
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    python = { "black" },
    markdown = { "markdownlint" },
    c = { "clang-format" },
    cpp = { "clang-format" },
  },

  formatters = {
    stylua = {
      prepend_args = {
        "--indent-type", "Spaces",
        "--indent-width", "2",
        "--column-width", "120",
      },
    },
  },
})
