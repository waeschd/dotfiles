{ pkgs, ... }:
[
  {
    plugin = pkgs.vimPlugins.auto-session;
    type = "lua";
    config = builtins.readFile ./auto-session.lua;
  }
]
