{ config, pkgs, lib, ... }:

let

  cfg = config.my.security.pam;

in

{

  options.my.security.pam.enable = lib.mkEnableOption "enable pam";

  config = lib.mkIf cfg.enable {

    security.pam.services = {

      login = {
        enable = true;
        name = "login";
       #kwallet = {          # Causes Brave to take a long time to load on first boot
       #  enable = true;
       # #package = pkgs.kdePackages.kwallet-pam;
       #  forceRun = true;
       #};
        gnupg.enable = true;
        enableGnomeKeyring = true;
      };

     #greetd = { };
     #su = { };

      sshd = {
        enable = true;
        name = "sshd";
       #kwallet = {
       #  enable = true;
       # #package = pkgs.kdePackages.kwallet-pam;
       #  forceRun = true;
       #};
        gnupg.enable = true;
        enableGnomeKeyring = true;
      };

      i3lock.enable = true;
      i3lock-color.enable = true;
      xlock.enable = true;
      xscreensaver.enable = true;
      betterlockscreen.enable = true;
      xremap-x-lock-sleep.enable = true;
      x-lock-sleep.enable = true;

    };

  };

}
