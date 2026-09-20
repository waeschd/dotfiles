{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.virt-column-nvim;
    type = "lua";
    config = builtins.readFile ./virt-column.lua;
  }
]
