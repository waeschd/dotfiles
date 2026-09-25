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

      # ---- snacks.nvim ---- (picker.files/grep shell out to `rg`; it's on
      # the interactive shell's PATH via the user profile, but not
      # guaranteed to be on Neovim's PATH depending on how it's launched)
      ripgrep

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

      # ---- snacks.nvim ---- (dashboard's git-status terminal panel shells
      # out to these for its ASCII-art clock)
      figlet
      lolcat

      # ---- nvim-dap ---- (gdb + lldb-dap adapter binaries; rust-gdb ships
      # alongside the rustc package above)
      gdb
      lldb
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
  # `~/.config/nvim/after/ftplugin/<filetype>.lua` whenever that filetype is set
  xdg.configFile = {
    "nvim/after/ftplugin".source = ./ftplugin;

    # Project-starter files
    "nvim/templates".source = ./templates;
  };
}
