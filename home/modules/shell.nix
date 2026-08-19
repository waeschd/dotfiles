{ pkgs, ... }:

{
  # ------------------------ Shell ------------------------- #
  programs.fish = {
    enable = true;

    # Disable greeting (was: set fish_greeting)
    # and run macchina on interactive start (was: status is-interactive block)
    interactiveShellInit = ''
      set fish_greeting
      fastfetch 
    '';

    # ------------------------ Abbreviations ------------------------------ #
    shellAbbrs = {
      cd_uni           = "cd ~/Nextcloud/01.Universitaet/02.Master_Informatik";
      cd_configs       = "cd ~/Nextcloud/02.PC/05.configs";
      cd_masterprojekt = "cd ~/Nextcloud/01.Universitaet/02.Master_Informatik/04.Semester/01.Masterprojekt";
      cd_masterarbeit  = "cd ~/Nextcloud/01.Universitaet/02.Master_Informatik/05.Semester/02.Masterarbeit";
      cd_hiwi          = "cd ~/Nextcloud/01.Universitaet/03.HiWi/";
    };

    # ------------------------ Aliases ------------------------------------ #
    shellAliases = {
      clear_all = "history -c && clear";

      spvg = "valgrind --tool=memcheck --leak-check=yes --show-reachable=yes --track-origins=yes --num-callers=20 --track-fds=yes --trace-children=yes";

      ls      = "eza --icons -1 --group-directories-first -s name --git";
      ls_size = "eza --icons -1 --total-size --group-directories-first -s name --git";

      cat = "bat";
      cp  = "cp -i";
      mv  = "mv -i";

      update_deb       = "sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && flatpak update -y && flatpak uninstall --unused -y && cargo install-update -a";
      update_cargo_bin = "cargo install-update -a";

      copy_clipboard  = "xclip -selection clipboard";
      paste_clipboard = "xclip -selection clipboard -o";

      measure_write_speed = "dd if=/dev/zero of=/tmp/speedTest.txt bs=1MiB count=4096";
      measure_read_speed  = "dd if=/tmp/speedTest.txt of=/dev/null bs=1MiB count=4096";

      wake_man  = "ssh ad66egev@i4lab1.cs.fau.de wake faui49man1";
      wake_jenk = "ssh ad66egev@i4lab1.cs.fau.de wake faui49jenkins2";
    };

    # ------------------------ Functions ----------------------------------- #
    functions = {
      convert_mp3_to_mp4 = {
        description = "Convert <input.mp3> to output.mp4 with Blue Image.";
        body = ''
          ffmpeg -f lavfi -i color=c=blue:s=1280x720 -i $argv[1] -shortest -fflags +shortest output.mp4
        '';
      };

      convert_md_to_pdf_eisvogel = {
        description = "Convert <input.md> to output.pdf with the Eisvogel Template.";
        body = ''
          pandoc $argv[1] -o output.pdf --pdf-engine=xelatex --template eisvogel --listings -N
        '';
      };

      clean_cropped_pdf = {
        description = "Clean <input.pdf>; written to cleaned.pdf";
        body = ''
          ocrmypdf --skip-text --remove-background --clean-final --continue-on-soft-render-error $argv[1] cleaned.pdf
        '';
      };

      compress_pdf = {
        description = "Compress <input.pdf>; written to compressed.pdf";
        body = ''
          qpdf --object-streams=generate $argv[1] compressed.pdf
        '';
      };

      uncompress_pdf = {
        description = "Uncompress <input.pdf>; written to uncompressed.pdf";
        body = ''
          qpdf --qdf --object-streams=disable $argv[1] uncompressed.pdf
        '';
      };

      start_ydotoold = {
        description = "Start ydotool daemon";
        body = ''
          sudo -b ydotoold \
                    --socket-path="$HOME/.ydotool_socket" \
                    --socket-own="$(id -u):$(id -g)"
        '';
      };

      find_macro = {
        description = "Find definition of a C macro";
        body = ''
          grep -r --include="*.[ch]" "^\s*#\s*define\s*\<$argv[1]\>" ./
        '';
      };

      convert_image_to_pdf = {
        description = "Convert image to PDF with selectable text and high-res images";
        body = ''
          if test (count $argv) -lt 1
              echo "Usage: convert_image_to_pdf <inputfile> [dpi]"
              return 1
          end

          set input $argv[1]
          set dpi 2400
          if test (count $argv) -ge 2
              set dpi $argv[2]
          end

          set base (basename $input)
          set base_noext (string replace -r '\.[^.]*$' "" $base)

          inkscape "$input" --export-type=pdf --export-filename="$base_noext.pdf" --export-dpi=$dpi
        '';
      };

      reduce_pdf_size = {
        description = "Reduce size of <input.pdf>; written to reduced.pdf";
        body = ''
          gs -sDEVICE=pdfwrite \
            -dCompatibilityLevel=1.4 \
            -dPDFSETTINGS=/prepress \
            -dNOPAUSE -dBATCH -dQUIET \
            -sOutputFile=reduced.pdf $argv[1]
        '';
      };

      wakeup_wol = {
        description = "Issue a magic packet to the device with a nic with the specified MAC address";
        body = ''
          sudo ether-wake 70:85:c2:a5:53:b9
        '';
      };

      do_backup = {
        description = "Do a backup from <src> to <dst>";
        body = ''
          if test (count $argv) -lt 1
              echo "Usage: do_backup <src> <dst>"
              return 1
          end

          rsync -azu --progress $argv[1] $argv[2]
        '';
      };

      patch_font = {
        description = "Patch a font with NerdFonts.";
        body = ''
          fontforge -script nerd-fonts/font-patcher -c $argv[1] -out patched_font
        '';
      };

      # Git wrapper function
      git.body = ''
        if test "$argv[1]" = "status"
          command git status -s $argv[2..-1]
        else if test "$argv[1]" = "clean"
          command git clean -i -fd $argv[2..-1]
        else if test "$argv[1]" = "sdiff"
          set -e argv[1]
          env GIT_EXTERNAL_DIFF=difft command git diff $argv
        else
          command git $argv
        end
      '';
    };
  };


  programs.bash = {
    enable = true;
  };

  #< ------------------------ Shell ------------------------- #

  # ------------------------ Prompt / History ------------------------------ #
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = false;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = false;

    settings = {
      format = " [](fg:c1)$container$directory[](fg:c1) [](fg:#303030)$git_branch$git_status$git_state$git_metrics$nodejs$dotnet$python$java$c$rust$cmd_duration$time[](fg:c4)$fill[](fg:#ffffff)$os[](fg:#ffffff bg:c1)$username$hostname[ ](fg:c1)$line_break$character";  

      right_format = "";

      palette = "main";
      # add_newline = true;

      palettes.main = {
        c1 = "#004480"; # blue light
        c2 = "#002240"; # blue dark
        c3 = "#c6e7ff"; # blue extra light
        c4 = "#303030"; # gray
        c5 = "#808080"; # gray light
      };

      os = {
        format = "[$symbol ](fg:#000000 bg:#ffffff)";
        disabled = false;
        symbols = {
	  Alpine = "";
          Amazon = "";
          Android = "";
          Arch = "";
          CentOS = "";
          Debian = "";
          EndeavourOS = "";
          Fedora = "";
          FreeBSD = "";
          Garuda = "";
          Gentoo = "";
          Linux = "";
          Macos = "";
          Manjaro = "";
          Mariner = "";
          Mint = "";
          NetBSD = "";
          NixOS = "";
          OpenBSD = ""; # ""
          OpenCloudOS = "☁️";
          openEuler = "";
          openSUSE = "";
          OracleLinux = "⊂⊃";
          Pop = ""; # ""
          Raspbian = "";
          Redhat = "";
          RedHatEnterprise = "";
          Solus = ""; # " "
          SUSE = "";
          Ubuntu = "";
          Unknown = "";
          Windows = "";
        };
      };

      container = {
        format = ''[\[ $name\] ](fg:#ffffff bg:c1)'';
      };

      directory = {
        format = "[󱉭  \$path ](fg:#ffffff bg:c1)";
        truncation_length = 2;
      };

      git_branch = {
        format = "[ 󰘬 \$branch ](fg:#ffffff bg:c4)";
      };

      git_state = {
        format = ''[\($state( $progress_current of $progress_total)\)]($style) '';
      };

      git_metrics = {
        added_style = "bold blue";
        format = "[+\$added](\$added_style)/[-\$deleted](\$deleted_style) ";
      };

      git_status = {
        format = "[\$all_status\$ahead_behind](fg:#ffffff bg:c4)";
        ahead = "⇡ \${count}";
        behind = "⇣ \${count}";
        staged = "[+\$count](fg:green bg:c4) ";
        deleted = "";
        renamed = "";
        stashed = "[](fg:cyan bg:c4) ";
        untracked = "[?\$count](fg:blue bg:c4) ";
        modified = "[!\$count](fg:yellow bg:c4) ";
        conflicted = "[═](fg:yellow bg:c4) ";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        up_to_date = " ";
      };

      nodejs = {
        format = "[ \$symbol\$version ](fg:#ffffff bg:c4)";
      };

      dotnet = {
        format = "[ \$symbol\$tfm ](fg:#ffffff bg:c4)";
        symbol = " .NET ";
      };

      python = {
        format = "[ \$symbol\$version ](fg:#ffffff bg:c4)";
        symbol = " ";
      };

      rust = {
        format = "[ \$symbol\$version ](fg:#ffffff bg:c4)";
        symbol = " ";
      };

      java = {
        format = "[ \$symbol\$version ](fg:#ffffff bg:c4)";
        symbol = " ";
      };

      c = {
        format = "[ \$symbol\$version ](fg:#ffffff bg:c4)";
        symbol = " ";
      };

      fill = {
        symbol = " ";
      };

      cmd_duration = {
        min_time = 1000;
        format = "[ \$duration ](fg:#ffffff bg:c4 bold)";
        show_milliseconds = true;
      };

      shell = {
        format = "[  \$indicator ](c5 bg:c4)";
        unknown_indicator = "shell";
        powershell_indicator = "powershell";
        fish_indicator = "fish";
        disabled = false;
      };

      time = {
        disabled = false;
        format = "[ \$time ](fg:#ffffff bg:c4)";
        time_format = "󰦖 %H:%M";
      };

      username = {
        format = "[  \$user ](fg:#ffffff bg:c1)";
        show_always = true;
      };

      hostname = {
        format = "[   \$hostname ](fg:#ffffff bg:c1)";
      };

      character = {
        format = "\$symbol ";
        success_symbol = "  [ ](fg:#32cd32) [󱞩](fg:#ffa500)\$fill";
        error_symbol = "  [ ](fg:#dc143c) [󱞩](fg:#ffa500)\$fill";
      };
    };
  };
  #< ------------------------ Prompt / History ------------------------------ #

  # ------------------------ Environment Variables ------------------------- #
  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
    SUDO_EDITOR = "/usr/bin/nvim";
    EDITOR = "/usr/bin/nvim";
    GIT_EDITOR = "nvim -f";
    TERM = "xterm-256color";
  };

  home.sessionPath = [
    "$HOME/Nextcloud/01.Universitaet/02.Master_Informatik/04.Semester/01.Masterprojekt/fauccc"
  ];

  # ------------------------ Terminal MUX ------------------------- #
  programs.zellij = {
    enable = true;
    # enableFishIntegration = false; # auto-start a Zellij session when you open a new shell
    # exitShellOnExit = true;   # closes the terminal when you exit zellij
    # attachExistingSession = true;  # attach to existing session instead of creating new one
  };
}
