{ pkgs, lib, ... }:
[
  {
    plugin = pkgs.vimPlugins.which-key-nvim;
    type = "lua";
    config = builtins.readFile ./which-key.lua;
  }
]
++ (import ./colorscheme/colorscheme.nix { inherit pkgs; })
++ (import ./lsp/lsp.nix { inherit pkgs lib; })
++ (import ./git/git.nix { inherit pkgs lib; })
