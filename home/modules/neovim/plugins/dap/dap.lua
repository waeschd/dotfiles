require("lazydev").setup({})
require("overseer").setup()

local dap = require("dap")

-- Dap Virtual Text
require("nvim-dap-virtual-text").setup({
  all_references = true,
  virt_text_pos = "eol",
})

-- Adapters
dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap" },
}

-- cppdbg (Microsoft's OpenDebugAD7/MIEngine, from the VS Code C/C++
-- extension, wired in via nix -- see dap.nix). Unlike native GDB-DAP
-- above, this wraps gdb/lldb via the MI protocol, which is what gives
-- you the `,x`/`,b` watch format specifiers and friendlier `display`
-- handling -- neither of those are part of DAP or GDB itself.
dap.adapters.cppdbg = {
  type = "executable",
  command = vim.g.opendebugad7_path,
}

dap.adapters["lldb-dap"] = {
  type = "executable",
  command = "lldb-dap",
}

dap.adapters["rust-gdb"] = {
  type = "executable",
  command = "rust-gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
}

-- GDB's DAP mode has no "run these commands after attach" field, so
-- `autorun` in a launch.json config isn't real GDB DAP syntax -- it's
-- just an extra key nvim-dap leaves untouched on `session.config`. Once
-- the adapter reports it's initialized, replay each command through the
-- REPL ourselves (GDB evaluates `repl`-context requests as CLI commands).
dap.listeners.after.event_initialized["autorun"] = function(session)
  for _, cmd in ipairs(session.config.autorun or {}) do
    if session.config.type == "cppdbg" then
      dap.repl.execute("-exec " .. cmd)
    else
      dap.repl.execute(cmd)
    end
  end
end

-- repl_execute helper
local function repl_execute(text)
  local session = dap.session()
  if session then
    if session.config.type == "cppdbg" then
      dap.repl.execute("-exec " .. text)
    else
      dap.repl.execute(text)
    end
  end
end

-- Actions
vim.keymap.set({ "n", "i" }, "<F5>", function()
  dap.continue()
end, { desc = "(Debug) Continue", silent = true })

vim.keymap.set({ "n" }, "<leader>dsd", function()
  local session = dap.session()
  if session then
    if session.config.type == "cppdbg" then
      dap.repl.execute("-exec detach")
    else
      dap.disconnect()
    end
  end
end, { desc = "(Debug) Detach", silent = true })

vim.keymap.set({ "n" }, "<leader>dst", function()
  dap.terminate()
end, { desc = "(Debug) Terminate", silent = true })

vim.keymap.set({ "n", "i" }, "<F6>", function()
  dap.pause()
end, { desc = "(Debug) Pause", silent = true })

vim.keymap.set({ "n", "i" }, "<F10>", function()
  dap.step_over()
end, { desc = "(Debug) Step over", silent = true })

vim.keymap.set({ "n", "i" }, "<F11>", function()
  dap.step_into()
end, { desc = "(Debug) Step into", silent = true })

vim.keymap.set({ "n", "i" }, "<F12>", function()
  dap.step_out()
end, { desc = "(Debug) Step out", silent = true })

vim.keymap.set({ "n" }, "<Leader>dr", function()
  vim.ui.input({ prompt = "Debug command to execute: " }, function(text)
    if text then
      repl_execute(text)
    end
  end)
end, { desc = "(Debug) Execute debugger command", silent = true })

vim.keymap.set("n", "<leader>de", function()
  vim.ui.input({ prompt = "DAP Eval > " }, function(expr)
    if not expr or expr == "" then
      return
    end
    dap.repl.execute(expr)
  end)
end, { desc = "DAP eval expression" })

vim.keymap.set("v", "<leader>de", function()
  vim.cmd('noau normal! "vy')
  local text = vim.fn.getreg("v")
  text = text:gsub("\n", " ")
  dap.repl.execute(text)
end, { desc = "DAP eval visual selection" })

-- Breakpoints/Logpoints
vim.keymap.set("n", "<Leader>dbb", function()
  dap.toggle_breakpoint()
end, { desc = "(Debug) Toggle breakpoint", silent = true })

vim.keymap.set("n", "<Leader>dbc", function()
  local condition = vim.fn.input("Breakpoint condition: ")
  local hit_condition = vim.fn.input("Hits before stop: ", "1")
  local log_message = vim.fn.input("Log Message:")

  dap.toggle_breakpoint(condition, hit_condition, log_message)
end, { desc = "(Debug) Toggle conditional breakpoint", silent = true })

vim.keymap.set("n", "<Leader>dbn", function()
  dap.clear_breakpoints()
end, { desc = "(Debug) Clear all breakpoints", silent = true })

-- Widgets (built into nvim-dap core, no dap-ui needed)
vim.keymap.set({ "n", "v" }, "<Leader>duh", function()
  require("dap.ui.widgets").hover()
end, { desc = "(Debug UI) Hover", silent = true })

vim.keymap.set({ "n", "v" }, "<Leader>dup", function()
  require("dap.ui.widgets").preview()
end, { desc = "(Debug UI) Preview", silent = true })

-- Step over/in/out
vim.keymap.set("n", "<Down>", function()
  dap.step_over()
  vim.cmd("normal! zz")
end, { noremap = true, silent = true, desc = "(Debug) Step Over" })

vim.keymap.set("n", "<Right>", function()
  dap.step_into()
  vim.cmd("normal! zz")
end, { noremap = true, silent = true, desc = "(Debug) Step Into" })

vim.keymap.set("n", "<Left>", function()
  dap.step_out()
  vim.cmd("normal! zz")
end, { noremap = true, silent = true, desc = "(Debug) Step Out" })

-- Backtrace
vim.keymap.set("n", "<S-Down>", function()
  dap.up()
end, { desc = "(Debug) Up one frame", silent = true })

vim.keymap.set("n", "<S-Up>", function()
  dap.down()
end, { desc = "(Debug) Down one frame", silent = true })

-- Highlights and Icons
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapUIStop" })
vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DapUIStop" })
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DapUIStop" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DapUIScope" })

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "DapStoppedBg", { bg = "#604918" })
  end,
})
vim.fn.sign_define("DapStopped", { text = "", texthl = "@variable.parameter.vimdoc", linehl = "DapStoppedBg" })
