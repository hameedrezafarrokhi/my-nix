{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.keepass.enable) {

  programs = {

    keepassxc = {
      enable = true;
      package = pkgs.keepassxc;
      autostart = false;

      settings = {
        Browser = {
          Enabled = true;
        };
        GUI = {
          AdvancedSettings = true;
          ApplicationTheme = "dark";
         #CompactMode = true;
          HidePasswords = true;
        };
        SSHAgent = {
          Enabled = true;
        };
      };

    };

   #git-credential-keepassxc = {
   #  enable = true;
   #
   #  package = pkgs.git-credential-keepassxc.override {
   #    withNotification = true;
   #    withYubikey = false;
   #    withStrictCaller = false;
   #    withAll = false;
   #  };
   #
   #  groups = [
   #    "Git"
   #  ];
   #
   #  hosts = [
   #    "https://github.com"
   #  ];
   #
   #};

  };

};}
