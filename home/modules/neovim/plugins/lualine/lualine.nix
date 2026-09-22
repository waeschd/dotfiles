{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.lualine-nvim;
    type = "lua";
    config = builtins.readFile ./lualine.lua;
  }
]
