{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.zoxide.enable) {

  programs.zoxide = {

    enable = true;
    package = pkgs.zoxide;

    enableZshIntegration = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;

    options = [

     #"--no-cmd"
     #"--cmd z"
     #"--hook"

    ];

  };

  home.sessionVariables = {

   #"_ZO_DATA_DIR" = "$XDG_DATA_HOME";
    "_ZO_ECHO" = 1;
    "_ZO_MAXAGE" = 10000;
   #"_ZO_FZF_OPTS" = " ";
    "_ZO_EXCLUDE_DIRS" = "/etc/nixos:/nix/store/*";
   #"_ZO_RESOLVE_SYMLINKS" = 1; # Resolves Symlinks Before Adding to Database

  };

};}
