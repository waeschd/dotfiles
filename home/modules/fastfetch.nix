{ config, pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;

    settings = {
    # Logo configuration
      logo = {
        source = "~/.config/fastfetch/fast-images/hypr.png";
        type = "kitty";
        height = 22;
        padding = {
          top = 7;
        };
      };

      # Display settings
      display = {
        separator = " ➜ ";
      };

      # Modules configuration
      modules = [
        { type = "break"; }
        { type = "break"; }

        {
          type = "custom";
          format = "\u001b[90m  \u001b[31m  \u001b[32m  \u001b[33m  \u001b[34m  \u001b[35m  \u001b[36m  \u001b[37m ";
        }
        { type = "break"; }

        {
          type = "title";
          keyWidth = 8;
        }
        {
          type = "custom";
          format = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
        }
        { type = "break"; }

        # OS, Kernel, Packages, Shell
        {
          type = "os";
          key = " OS   ";
          keyColor = "31";
        }
        {
          type = "kernel";
          key = " ├   ";
          keyColor = "31";
        }
        {
          type = "packages";
          format = "{} (pacman)";
          key = " ├   ";
          keyColor = "31";
        }
        {
          type = "shell";
          key = " └   ";
          keyColor = "31";
        }
        { type = "break"; }

        # WM, WM Theme, Icons, Cursor, Terminal, Terminal Font
        {
          type = "wm";
          key = " WM   ";
          keyColor = "32";
        }
        {
          type = "wmtheme";
          key = " ├ 󰉼  ";
          keyColor = "32";
        }
        {
          type = "icons";
          key = " ├ 󰀻  ";
          keyColor = "32";
        }
        {
          type = "cursor";
          key = " ├   ";
          keyColor = "32";
        }
        {
          type = "terminal";
          key = " ├   ";
          keyColor = "32";
        }
        {
          type = "terminalfont";
          key = " └   ";
          keyColor = "32";
        }
        { type = "break"; }

        # Host, CPU, GPU, Memory, Swap, Disk, Monitor
        {
          type = "host";
          format = "{5} {1} ({2})";
          key = " PC   ";
          keyColor = "33";
        }
        {
          type = "cpu";
          format = "{1} ({3}) @ {7}";
          key = " ├   ";
          keyColor = "33";
        }
        {
          type = "gpu";
          format = "{1} {2} @ {12}";
          key = " ├ 󰢮  ";
          keyColor = "33";
        }
        {
          type = "memory";
          key = " ├   ";
          keyColor = "33";
        }
        {
          type = "swap";
          key = " ├ 󰓡  ";
          keyColor = "33";
        }
        {
          type = "disk";
          key = " ├ 󰋊  ";
          keyColor = "33";
        }
        {
          type = "monitor";
          key = " └   ";
          keyColor = "33";
        }
        { type = "break"; }

        # Uptime, Datetime, Command (Install Age)
        {
          type = "uptime";
          key = " UP   ";
          keyColor = "34";
        }
        {
          type = "datetime";
          format = "{1}-{3}-{11}";
          key = " ├   ";
          keyColor = "34";
        }
        {
          type = "command";
          key = " └   ";
          keyColor = "34";
          text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
        }
        { type = "break"; }

        # Command (Splash Screen)
        {
          type = "command";
          key = " SH   ";
          keyColor = "34";
          text = "splash=$(hyprctl splash);echo $splash";
        }
        {
          type = "custom";
          format = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
        }
        { type = "break"; }

        # Colored separators
        {
          type = "custom";
          format = "\u001b[90m  \u001b[31m  \u001b[32m  \u001b[33m  \u001b[34m  \u001b[35m  \u001b[36m  \u001b[37m ";
        }
        { type = "break"; }
        { type = "break"; }
      ];
    };
  };
}
