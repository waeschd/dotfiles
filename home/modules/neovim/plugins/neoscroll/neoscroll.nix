{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.neoscroll-nvim;
    type = "lua";
    config = builtins.readFile ./neoscroll.lua;
  }
]
