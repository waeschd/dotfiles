{ pkgs, ... }:
with pkgs.vimPlugins;
[
  # ---- bare deps (no config of their own) ----
  nvim-dap-virtual-text
  lazydev-nvim
  overseer-nvim

  # ---- nvim-dap ----
  {
    plugin = nvim-dap;
    type = "lua";
    config = builtins.readFile ./dap.lua;
  }
]
