{ pkgs, ... }:
let
  # cppdbg's OpenDebugAD7 binary, straight from the actual VS Code C/C++
  # extension package -- nix-managed and reproducible, no Mason/runtime
  # download needed.
  opendebugad7 =
    "${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7";
in
[
  # ---- bare deps (no config of their own) ----
  pkgs.vimPlugins.nvim-dap-virtual-text
  pkgs.vimPlugins.lazydev-nvim
  pkgs.vimPlugins.overseer-nvim

  # ---- nvim-dap ----
  {
    plugin = pkgs.vimPlugins.nvim-dap;
    type = "lua";
    config = ''
      vim.g.opendebugad7_path = "${opendebugad7}"
    '' + builtins.readFile ./dap.lua;
  }

  # ---- nvim-dap-view ----
  {
    plugin = pkgs.vimPlugins.nvim-dap-view;
    type = "lua";
    config = builtins.readFile ./dap-view.lua;
  }
]
