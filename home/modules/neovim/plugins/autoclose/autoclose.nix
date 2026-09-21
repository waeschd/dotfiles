{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.autoclose-nvim;
    type = "lua";
    config = builtins.readFile ./autoclose.lua;
  }
]
