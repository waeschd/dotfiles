{ pkgs, ... }:
[
  # ---- gitsigns.nvim ----
  {
    plugin = pkgs.vimPlugins.gitsigns-nvim;
    type = "lua";
    config = builtins.readFile ./gitsigns.lua;
  }

  # ---- lazygit.nvim (needs the `lazygit` TUI itself on PATH) ----
  pkgs.vimPlugins.plenary-nvim
  {
    plugin = pkgs.vimPlugins.lazygit-nvim;
    type = "lua";
    config = builtins.readFile ./lazygit.lua;
  }
]
