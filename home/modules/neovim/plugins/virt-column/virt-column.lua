require("virt-column").setup({
  char = "│",
  virtcolumn = "121",
})

vim.api.nvim_create_user_command("VirtCol", function(opts)
  require("virt-column").setup({
    virtcolumn = opts.args,
    char = "│",
  })
end, { nargs = 1 })
