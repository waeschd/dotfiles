{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.onedark-nvim;
    type = "lua";
    config = builtins.readFile ./colorscheme.lua;
  }

  pkgs.vimPlugins.github-nvim-theme # shares config file
  pkgs.vimPlugins.bamboo-nvim
]
