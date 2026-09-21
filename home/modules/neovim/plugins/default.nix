{ pkgs, lib, ... }:
[
]
++ (import ./colorscheme/colorscheme.nix { inherit pkgs; })
++ (import ./lsp/lsp.nix { inherit pkgs lib; })
++ (import ./git/git.nix { inherit pkgs lib; })
++ (import ./treesitter/treesitter.nix { inherit pkgs; })
++ (import ./which-key/which-key.nix { inherit pkgs; })
++ (import ./virt-column/virt-column.nix { inherit pkgs; })
++ (import ./undotree/undotree.nix { inherit pkgs; })
