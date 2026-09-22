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
++ (import ./nvim-surround/nvim-surround.nix { inherit pkgs; })
++ (import ./autoclose/autoclose.nix { inherit pkgs; })
++ (import ./neoscroll/neoscroll.nix { inherit pkgs; })
++ (import ./trouble/trouble.nix { inherit pkgs; })
++ (import ./dropbar/dropbar.nix { inherit pkgs; })
++ (import ./lualine/lualine.nix { inherit pkgs; })
++ (import ./nvim-cokeline/nvim-cokeline.nix { inherit pkgs; })
