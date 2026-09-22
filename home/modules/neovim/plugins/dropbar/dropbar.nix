{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.dropbar-nvim;
    type = "lua";
    config = builtins.readFile ./dropbar.lua;
  }
]
