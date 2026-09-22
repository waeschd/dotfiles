{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.nvim-cokeline;
    type = "lua";
    config = builtins.readFile ./nvim-cokeline.lua;
  }
]
