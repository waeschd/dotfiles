{ config, pkgs, lib, ...}:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Sebastian Russer";
        email = "sebastian.russer@fau.de";
      };
      aliases = {
        word-diff = "diff --word-diff=color -b";
	pr = "pull --rebase";
      };
      core = {
        editor = "nvim";
	page = "diffnav";
      };
      init.defaultBranch = "main";
      pull.rebase = false;
      interactive.diffFilter = "diffnav --color-only";
      diffnav.side-by-side = true;
      merge.conflictStyle = "zdiff3";
    };
  };
}
