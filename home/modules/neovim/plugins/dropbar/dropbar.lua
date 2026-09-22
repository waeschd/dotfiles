require("dropbar").setup({
  bar = {
    enable = function(buf, win, _)
      buf = vim._resolve_bufnr(buf)

      -- Bail on an already-gone buffer/window, special windows
      -- (popups/command-line/etc.), windows that already have their own
      -- winbar set, and help buffers
      if
        not vim.api.nvim_buf_is_valid(buf)
        or not vim.api.nvim_win_is_valid(win)
        or vim.fn.win_gettype(win) ~= ""
        or vim.wo[win].winbar ~= ""
        or vim.bo[buf].ft == "help"
      then
        return false
      end

      -- Skip very large files (>1MB) -- parsing/symbol lookup gets too slow
      local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
      if stat and stat.size > 1024 * 1024 then
        return false
      end

      -- Skip terminal buffers
      if vim.bo[buf].bt == "terminal" then
        return false
      end

      -- Only show the bar where it can actually show something: markdown
      -- (dropbar has its own heading-based path for these), a working
      -- treesitter parser, or an LSP client that supports document symbols
      return vim.bo[buf].ft == "markdown"
        or pcall(vim.treesitter.get_parser, buf)
        or not vim.tbl_isempty(vim.lsp.get_clients({
          bufnr = buf,
          method = "textDocument/documentSymbol",
        }))
    end,
  },
})
local dropbar_api = require("dropbar.api")

vim.keymap.set(
  "n",
  "<Leader>dp",
  dropbar_api.pick,
  { desc = "(Dropbar) Pick symbols in winbar", noremap = true, silent = true }
)
