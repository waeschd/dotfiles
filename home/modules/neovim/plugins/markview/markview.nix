{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.markview-nvim;
    type = "lua";
    config = builtins.readFile ./markview.lua;
  }
]
