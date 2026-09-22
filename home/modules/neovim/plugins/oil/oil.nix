{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.oil-nvim;
    type = "lua";
    config = builtins.readFile ./oil.lua;
  }
]
