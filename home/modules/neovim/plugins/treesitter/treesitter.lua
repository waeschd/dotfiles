require("nvim-treesitter").setup({
  -- Parsers are installed declaratively via nix (see treesitter.nix), not at
  -- runtime -- auto_install would try to fetch/compile into the read-only
  -- Nix store and fail.
  auto_install = false,
})

-- The "main" branch dropped setup()'s highlight/indent options -- Neovim's
-- own highlighter and this plugin's indentexpr are opt-in per buffer now.
-- See github.com/nvim-treesitter/nvim-treesitter#highlighting.
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local has_parser = pcall(vim.treesitter.start)
    if has_parser then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "Grey" })
    vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = true, sp = "Grey" })
  end,
})

require("treesitter-context").setup({})
