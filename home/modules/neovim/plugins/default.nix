{ pkgs, lib, ... }:
[
]
++ (import ./colorscheme/colorscheme.nix { inherit pkgs; })
++ (import ./lsp/lsp.nix { inherit pkgs lib; })
++ (import ./git/git.nix { inherit pkgs lib; })
