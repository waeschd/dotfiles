{ pkgs, ... }:
let
  mkPlugin = path: import path { inherit pkgs; };
in
builtins.concatMap mkPlugin [
  ./colorscheme/colorscheme.nix
  ./lsp/lsp.nix
  ./git/git.nix
  ./treesitter/treesitter.nix
  ./which-key/which-key.nix
  ./virt-column/virt-column.nix
  ./undotree/undotree.nix
  ./nvim-surround/nvim-surround.nix
  ./autoclose/autoclose.nix
  ./neoscroll/neoscroll.nix
  ./trouble/trouble.nix
  ./dropbar/dropbar.nix
  ./lualine/lualine.nix
  ./nvim-cokeline/nvim-cokeline.nix
  ./toggleterm/toggleterm.nix
  ./oil/oil.nix
  ./noice/noice.nix
  ./markview/markview.nix
  ./snacks/snacks.nix
  ./auto-session/auto-session.nix
  ./dap/dap.nix
]
