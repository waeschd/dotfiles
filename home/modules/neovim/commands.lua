vim.api.nvim_create_user_command("FindMacro", function(opts)
  local macro = opts.args
  vim.fn.execute('silent! rg --type=c "^\\s*#\\s*define\\s*\\<' .. macro .. '\\>" | copen')
end, { nargs = 1 })

vim.api.nvim_create_user_command("BufOnly", function()
  vim.cmd("%bd|e#|bd#")
end, {})
