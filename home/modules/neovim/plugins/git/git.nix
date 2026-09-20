{ pkgs, lib, ... }:
with pkgs.vimPlugins;
[
  # ---- gitsigns.nvim ----
  {
    plugin = gitsigns-nvim;
    type = "lua";
    config = builtins.readFile ./gitsigns.lua;
  }

  # ---- lazygit.nvim (needs the `lazygit` TUI itself on PATH) ----
  plenary-nvim
  {
    plugin = lazygit-nvim;
    type = "lua";
    config = builtins.readFile ./lazygit.lua;
  }
]
