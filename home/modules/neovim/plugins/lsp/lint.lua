-- nvim-lint just runs the linter and calls vim.diagnostic.set() directly, so
-- results show up through the same diagnostics UI (signs, virtual text,
-- Trouble) as any LSP server -- but it needs an explicit autocmd to
-- actually trigger a run, see below.
local lint = require("lint")

lint.linters_by_ft = {
  python = { "mypy" },
  markdown = { "markdownlint" },
  c = { "cpplint" },
  cpp = { "cpplint" },
}

lint.linters.cpplint.args = {
  "--linelength=120",
  "--filter=" .. table.concat({
    "-whitespace/tab", -- Permitting the use of tab characters for indentation.
    "-legal/copyright", -- Removing the requirement for a legal/copyright header at the top of files.
    "-build/header_guard", -- Allowing non-standard or custom naming conventions for #ifndef header guards.
    "-whitespace/braces", -- Permitting the placement of opening braces on a new line (Allman/C# style).
    "-whitespace/indent", -- Allowing indentation depths other than the default two-space requirement.
    "-build/include_order", -- Permitting #include statements to be ordered non-alphabetically.
  }, ","),
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  desc = "Run nvim-lint for the current buffer's filetype",
  callback = function()
    lint.try_lint()
  end,
})
