{ config, pkgs, lib, ...}:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Sebastian Russer";
        email = "sebastian.russer@fau.de";
      };
      alias = {
        word-diff = "diff --word-diff=color -b";
        pr = "pull --rebase";
      };
      core = {
        editor = "nvim";
      };
      init.defaultBranch = "main";
      pull.rebase = false;
      merge.conflictStyle = "zdiff3";
    };
  };

  # delta is a stdout colorizer (not a full-screen program like diffnav), so
  # it embeds cleanly both as the CLI's pager and inside lazygit's own diff
  # panel below.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      side-by-side = true;
      wrap-max-lines = "unlimited";
    };
  };

  programs.lazygit = {
    enable = true;
    settings.git = {
      autoFetch = false;
      pagers = [
        { pager = "delta --side-by-side --paging=never"; }
      ];
    };
  };
}
