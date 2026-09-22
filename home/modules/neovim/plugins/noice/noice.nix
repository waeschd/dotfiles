{ pkgs, ... }:
[
  # noice's popupmenu/hover views are built on nui.nvim; nvim-notify is a
  # bare dependency it can route messages through (unused here since
  # notify.enabled = false in noice.lua, but still required at require()-time).
  pkgs.vimPlugins.nui-nvim
  pkgs.vimPlugins.nvim-notify

  {
    plugin = pkgs.vimPlugins.noice-nvim;
    type = "lua";
    config = builtins.readFile ./noice.lua;
  }
]
