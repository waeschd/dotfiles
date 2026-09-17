vim.lsp.enable({
  "clangd",
  "rust_analyzer",
  "lua_ls",
  "eslint",
  "basedpyright",
  "harper_ls",
  "jsonls",
})

-- Harper adjustments
local harper_ft = vim.lsp.config["harper_ls"].filetypes
table.insert(harper_ft, "text")
vim.lsp.config("harper_ls", {
  filetypes = harper_ft,
  settings = {
    ["harper-ls"] = {
      diagnosticSeverity = "information",
      isolateEnglish = true,
      maxFileLength = 2 * 1024 * 1024,
      excludePatterns = {
        "**_de.md",
        "*tagebuch.md",
      },
    },
  },
})
