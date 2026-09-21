require("autoclose").setup({
  keys = {
    ["'"] = { escape = true, close = false, pair = "''", disabled_filetypes = { "grug-far" } },
    ["("] = { close = true, pair = "()", disabled_filetypes = { "grug-far" } },
  },
})
