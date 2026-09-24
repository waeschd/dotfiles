{ pkgs, ... }:
with pkgs.vimPlugins;
let
  # cppdbg's OpenDebugAD7 binary, straight from the actual VS Code C/C++
  # extension package -- nix-managed and reproducible, no Mason/runtime
  # download needed.
  opendebugad7 =
    "${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7";
in
[
  # ---- bare deps (no config of their own) ----
  nvim-dap-virtual-text
  lazydev-nvim
  overseer-nvim

  # ---- nvim-dap ----
  {
    plugin = nvim-dap;
    type = "lua";
    config = ''
      vim.g.opendebugad7_path = "${opendebugad7}"
    '' + builtins.readFile ./dap.lua;
  }

  # ---- nvim-dap-view ----
  {
    plugin = nvim-dap-view;
    type = "lua";
    config = builtins.readFile ./dap-view.lua;
  }
]
