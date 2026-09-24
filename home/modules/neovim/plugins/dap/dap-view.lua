require("dap-view").setup({
  -- Open when a session starts, close when all sessions finish
  auto_toggle = true,
})

vim.keymap.set("n", "<Leader>duo", function()
  require("dap-view").open()
end, { desc = "(Debug UI) Open UI", silent = true })

vim.keymap.set("n", "<Leader>duc", function()
  require("dap-view").close()
end, { desc = "(Debug UI) Close UI", silent = true })

vim.keymap.set("n", "<Leader>dut", function()
  require("dap-view").toggle()
end, { desc = "(Debug UI) Toggle UI", silent = true })

vim.keymap.set("n", "<Leader>dw", function()
  vim.ui.input({ prompt = "DAP Watch > " }, function(expr)
    if not expr or expr == "" then
      return
    end
    require("dap-view").add_expr(expr)
  end)
end, { desc = "DAP add watch (prompt)" })

vim.keymap.set("v", "<Leader>dw", function()
  vim.cmd('noau normal! "vy')
  local text = vim.fn.getreg("v")
  text = text:gsub("\n", " ")
  require("dap-view").add_expr(text)
end, { desc = "DAP add watch (visual selection)" })
