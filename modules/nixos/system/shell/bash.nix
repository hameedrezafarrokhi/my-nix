{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (builtins.elem "bash" config.my.shell.shells) {

  programs.bash = {

   #interactiveShellInit = builtins.readFile ./.bashrc;

    completion = {
      enable = true;
      package = pkgs.bash-completion;
    };

    enableLsColors = true;
   #lsColorsFile = ${pkgs.dircolors-solarized}/ansi-dark;

   #undistractMe = {
   #  enable = true;
   #  playSound = false;
   #  timeout = 30;
   #};

    vteIntegration = true;

   #blesh.enable = true;

   #shellInit = "";
   #loginShellInit = "";

    shellAliases = config.home-manager.users.${admin}.programs.bash.shellAliases;

  };

};}
