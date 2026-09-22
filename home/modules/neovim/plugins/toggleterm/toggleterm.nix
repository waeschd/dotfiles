{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.toggleterm-nvim;
    type = "lua";
    config = builtins.readFile ./toggleterm.lua;
  }
]
