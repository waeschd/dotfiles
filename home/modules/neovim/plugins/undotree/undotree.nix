{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.undotree;
    type = "lua";
    config = builtins.readFile ./undotree.lua;
  }
]
