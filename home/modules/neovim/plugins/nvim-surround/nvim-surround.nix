{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.nvim-surround;
    type = "lua";
    config = builtins.readFile ./nvim-surround.lua;
  }
]
