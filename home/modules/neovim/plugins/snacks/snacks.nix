{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.snacks-nvim;
    type = "lua";
    config = builtins.readFile ./snacks.lua;
  }
]
