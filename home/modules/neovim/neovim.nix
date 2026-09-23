{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    # Tools nvim itself needs on PATH: LSP servers, formatters, linters.
    extraPackages = with pkgs; [
      # vim.lsp's file watcher (workspace/didChangeWatchedFiles) uses real
      # inotify watches via `inotifywait` when it's on PATH, falling back to
      # a much slower manual directory-polling backend otherwise.
      inotify-tools

      # ---- Git ---- (lazygit.nvim shells out to the `lazygit` TUI)
      lazygit

      # ---- Treesitter ---- (nvim-treesitter's healthcheck/query tooling
      # wants the `tree-sitter` CLI on PATH; parsers themselves are still
      # baked in via nix, not compiled by this at runtime)
      tree-sitter

      # ---- C/C++ ---- (clangd LSP + clang-format formatter + cpplint linter)
      clang-tools
      cpplint

      # ---- Rust ---- (rust_analyzer LSP; rustc/cargo are also needed by
      # rust_analyzer itself, e.g. to resolve its sysroot -- not just for
      # actually compiling anything)
      rust-analyzer
      rustc
      cargo

      # ---- Lua ---- (lua_ls LSP + stylua formatter)
      lua-language-server
      stylua

      # ---- Web/JSON ---- (eslint + jsonls LSPs, prettier formatter)
      vscode-langservers-extracted
      prettier

      # ---- English prose ---- (harper_ls LSP)
      harper

      # ---- Python ---- (basedpyright LSP, black formatter, mypy diagnostics)
      basedpyright
      black
      mypy

      # ---- Markdown ---- (markdownlint formatter + diagnostics)
      markdownlint-cli

      # ---- Bash ---- (bashls LSP; it shells out to shellcheck for
      # diagnostics and shfmt for formatting when they're on PATH)
      bash-language-server
      shellcheck
      shfmt
    ];

    plugins = import ./plugins { inherit pkgs lib; };

    initLua = ''
      ${builtins.readFile ./options.lua}
      ${builtins.readFile ./win-buffers.lua}
      ${builtins.readFile ./keymaps.lua}
      ${builtins.readFile ./autocmds.lua}
      ${builtins.readFile ./commands.lua}
    '';
  };

  # Neovim's native ftplugin loading auto-sources
  # `~/.config/nvim/after/ftplugin/<filetype>.lua` whenever that filetype is
  # set, so these just need to land in place.
  xdg.configFile = {
    "nvim/after/ftplugin/c.lua".source        = ./ftplugin/c.lua;
    "nvim/after/ftplugin/lua.lua".source      = ./ftplugin/lua.lua;
    "nvim/after/ftplugin/markdown.lua".source = ./ftplugin/markdown.lua;

    # Project-starter files (clang-format/editorconfig/markdownlint configs)
    # copied by hand into a new project -- not read by Neovim itself.
    "nvim/templates/c/.clang-format".source        = ./templates/c/.clang-format;
    "nvim/templates/c/.editorconfig".source        = ./templates/c/.editorconfig;
    "nvim/templates/md/.markdownlint.yaml".source  = ./templates/md/.markdownlint.yaml;
  };
}
