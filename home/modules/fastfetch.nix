{ config, pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        type = "auto";
	source = "NixOS";
      };

      display = {
        separator = " ";
      };

      modules = [
        { type = "custom";   key = "╭───────────╮"; }
        { type = "title";    key = "│  user    │"; format = "{user-name}"; }
        { type = "title";    key = "│ 󰇅 hname   │"; format = "{host-name}"; }
        { type = "uptime";   key = "│ 󰅐 uptime  │"; }
        { type = "os";       key = "│  distro  │"; }
        { type = "kernel";   key = "│  kernel  │"; }
        { type = "wm";       key = "│  wm      │"; }
        { type = "terminal"; key = "│  term    │"; }
        { type = "shell";    key = "│  shell   │"; }
        { type = "cpu";      key = "│ 󰍛 cpu     │"; showPeCoreCount = true; }
        { type = "disk";     key = "│ 󰉉 disk    │"; folders = [ "/" ]; }
        { type = "memory";   key = "│  memory  │"; }
        { type = "custom";   key = "├───────────┤"; }
        { type = "host";     key = "│ PC        │"; format = "{5} {1} ({2})"; }
        { type = "gpu";      key = "│ ├ 󰢮 gpu   │"; format = "{1} {2} @ {12}"; }
        { type = "swap";     key = "│ ├ 󰓡 swap  │"; }
        { type = "monitor";  key = "│ ├  disp  │"; format = "{1} px @ {2} Hz - {3} mm ({4} inches, {5} pp)"; }
        { type = "command";  key = "│ └  dtime │";
          text = ''
            birth_install=$(stat -c %W /);
            current=$(date +%s);
            time_progression=$((current - birth_install));
            days_difference=$((time_progression / 86400));
            echo $days_difference days
          '';
        }
        { type = "colors";   key = "│  colors  │"; symbol = "circle"; }
        { type = "custom";   key = "╰───────────╯"; }
      ];
    };
  };
}
