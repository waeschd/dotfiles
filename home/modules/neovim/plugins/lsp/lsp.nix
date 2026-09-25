{ pkgs, ... }:
[
  # ---- nvim-lspconfig ----
  {
    plugin = pkgs.vimPlugins.nvim-lspconfig;
    type = "lua";
    config = builtins.readFile ./lspconfig.lua;
  }

  # ---- nvim-cmp + its source plugins (bare deps, no config of their own) ----
  pkgs.vimPlugins.cmp-nvim-lsp
  pkgs.vimPlugins.cmp-buffer
  pkgs.vimPlugins.cmp-path
  pkgs.vimPlugins.cmp-cmdline
  pkgs.vimPlugins.cmp_luasnip
  pkgs.vimPlugins.luasnip
  pkgs.vimPlugins.lspkind-nvim
  {
    plugin = pkgs.vimPlugins.nvim-cmp;
    type = "lua";
    config = builtins.readFile ./cmp.lua;
  }

  # ---- conform.nvim (formatting) ----
  {
    plugin = pkgs.vimPlugins.conform-nvim;
    type = "lua";
    config = builtins.readFile ./conform.lua;
  }

  # ---- nvim-lint (linting) ----
  {
    plugin = pkgs.vimPlugins.nvim-lint;
    type = "lua";
    config = builtins.readFile ./lint.lua;
  }
]
