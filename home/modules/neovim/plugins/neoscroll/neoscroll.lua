require("neoscroll").setup({
  mappings = { "<C-u>", "<C-d>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
})

local opts = { silent = true }
opts.desc = "(Neoscroll) Scroll and center view"
vim.keymap.set({ "n", "v", "x" }, "<A-j>", function()
  require("neoscroll").scroll(1, { move_cursor = true, duration = 300 })
  require("neoscroll").zz({ half_win_duration = 300 })
end, opts)
vim.keymap.set({ "n", "v", "x" }, "<A-k>", function()
  require("neoscroll").scroll(-1, { move_cursor = true, duration = 300 })
  require("neoscroll").zz({ half_win_duration = 300 })
end, opts)

-- Scroll bindings
opts.desc = "(Neoscroll) Scroll down"
vim.keymap.set({ "n", "v", "x" }, "<C-d>", function()
  require("neoscroll").scroll(0.25, { move_cursor = true, duration = 200 })
end, opts)

opts.desc = "(Neoscroll) Scroll up"
vim.keymap.set({ "n", "v", "x" }, "<C-u>", function()
  require("neoscroll").scroll(-0.25, { move_cursor = true, duration = 200 })
end, opts)

-- Mouse scroll bindings
opts.desc = "(Neoscroll) Scroll down with mouse wheel"
vim.keymap.set({ "n", "v", "x" }, "<ScrollWheelDown>", function()
  require("neoscroll").scroll(10, { move_cursor = false, duration = 150 })
end, opts)

opts.desc = "(Neoscroll) Scroll up with mouse wheel"
vim.keymap.set({ "n", "v", "x" }, "<ScrollWheelUp>", function()
  require("neoscroll").scroll(-10, { move_cursor = false, duration = 150 })
end, opts)
