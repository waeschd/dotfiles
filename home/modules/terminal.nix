{ pkgs, ... }:

{
  # ------------------------ Kitty ------------------------- #
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;

    font = {
      name = "Maple Mono NL NF";
      size = 12;
    };

    themeFile = "OneDark-Pro";

    settings = {
      shell = "fish";

      window_border_width = "0";
      window_margin_width = "0";
      window_padding_width = "0";

      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";

      cursor_blink_interval = "0.5";
      cursor_stop_blinking_after = "1";

      scrollback_lines = "2000";
      wheel_scroll_min_lines = "1";
      enable_audio_bell = "no";
      background_opacity = "1";
      dynamic_background_opacity = "yes";

      selection_foreground = "none";
      selection_background = "none";

      confirm_os_window_close = 2;
    };

    keybindings = {
      "f11" = "toggle_fullscreen";
    };
  };
}
