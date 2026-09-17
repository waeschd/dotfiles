{ pkgs, lib, ... }:
with pkgs.vimPlugins;
[
  # ---- nvim-lspconfig ----
  {
    plugin = nvim-lspconfig;
    type = "lua";
    config = builtins.readFile ./lspconfig.lua;
  }

  # ---- nvim-cmp + its source plugins (bare deps, no config of their own) ----
  cmp-nvim-lsp
  cmp-buffer
  cmp-path
  cmp-cmdline
  cmp_luasnip
  luasnip
  lspkind-nvim
  {
    plugin = nvim-cmp;
    type = "lua";
    config = builtins.readFile ./cmp.lua;
  }

  # ---- conform.nvim (formatting) ----
  {
    plugin = conform-nvim;
    type = "lua";
    config = builtins.readFile ./conform.lua;
  }

  # ---- nvim-lint (linting) ----
  {
    plugin = nvim-lint;
    type = "lua";
    config = builtins.readFile ./lint.lua;
  }
]
