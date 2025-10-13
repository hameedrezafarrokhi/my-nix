{ config, pkgs, lib, nix-path, mypkgs, admin, ... }:

{ config = lib.mkIf (builtins.elem "fish" config.my.shell.shells) {

  programs.fish = {

    enable = true;
    package = pkgs.fish;
    generateCompletions = true;

    vendor = {
      completions.enable = true;
      config.enable = true;
      functions.enable = true;
    };

   #useBabelfish = false;

   #promptInit = "";

   #shellInit = '' '';

   #loginShellInit = "";

   #interactiveShellInit = config.home-manager.users.${admin}.programs.fish.interactiveShellInit;

    shellAliases = config.home-manager.users.${admin}.programs.fish.shellAliases;

    shellAbbrs = config.home-manager.users.${admin}.programs.fish.shellAbbrs;

  };

};}
