{ pkgs, ... }:
[
  # Bare dependency: which-key require()s it directly for file-icon lookups,
  # no config of its own.
  pkgs.vimPlugins.nvim-web-devicons

  {
    plugin = pkgs.vimPlugins.which-key-nvim;
    type = "lua";
    config = builtins.readFile ./which-key.lua;
  }
]
