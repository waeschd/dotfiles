{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.trouble-nvim;
    type = "lua";
    config = builtins.readFile ./trouble.lua;
  }
]
