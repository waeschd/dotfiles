{ pkgs, ... }:
[
  # Parsers are baked in via nix instead of nvim-treesitter's runtime
  # :TSUpdate/install() (source config used the latter, but that needs
  # network + a compiler against a read-only Nix store, so it can't work
  # here). "html_tags" from the source config doesn't exist as a grammar --
  # dropped.
  {
    plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [
      bash
      c
      cpp
      html
      fish
      rust
      javascript
      nix
      zig
      latex
      markdown
      markdown_inline
      typst
      yaml
    ]);
    type = "lua";
    config = builtins.readFile ./treesitter.lua;
  }

  pkgs.vimPlugins.nvim-treesitter-context
]
