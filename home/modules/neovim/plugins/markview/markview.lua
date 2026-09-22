require("markview").setup({
  preview = {
    filetypes = { "markdown", "codecompanion" },
    ignore_buftypes = {},
    icon_provider = "devicons",
  },
  markdown = {
    headings = {
      shift_width = 2,
      org_indent = true,
      org_shift_width = 2,
    },
  },
})
