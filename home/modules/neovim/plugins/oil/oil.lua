require("oil").setup({
  columns = {
    "icon",
    "permissions",
    "size",
    --"mtime",
  },
  confirmation = {
    border = "rounded",
    win_options = {
      winhighlight = "Normal:OilConfigWindow,FloatBorder:OilConfigBorder",
    },
  },
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "(Oil) Open parent directory", silent = true })
