{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.rofi.enable) {

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
   #finalPackage = ;
    plugins = with pkgs; [

      rofimoji
      rofi-vpn
      rofi-top
      rofi-systemd
      rofi-screenshot
      rofi-power-menu
      rofi-network-manager
      rofi-nerdy
      rofi-mpd
      rofi-menugen
      rofi-games
      rofi-file-browser
      rofi-emoji
      rofi-calc
      rofi-bluetooth
      rofi-blezz
      rofi-pass-wayland
      rofi-pass
      rofi-obsidian
      rofi-rbw-x11
      rofi-rbw-wayland
      rofi-rbw
      rofi-pulse-select

    ];

    modes = [
      "drun"
     #"run"
     #"emoji"
     #"ssh"
     #"window"
     #"windowcd"
     #"combi"
     #"keys"
     #"filebrowser"
     #"calc"
     #"top"
     #"blezz"
     #"games"
     #"nerdy"
     #"file-browser-extended"
     #"recursivebrowser"
     #{
     #  name = "top";
     #  path = lib.getExe pkgs.rofi-top;
     #}
    ];
    cycle = true;
    terminal = "${lib.getExe pkgs.${config.my.default.terminal}}";

    location = "center"; # "bottom", "bottom-left", "bottom-right", "center", "left", "right", "top", "top-left" ....
   #yoffset = 0;
   #xoffset = 0;

   #pass = {
   #  stores = ;
   #  package = ;
   #  extraConfig = ;
   #  enable = ;
   #};

   #configPath = ;
   #extraConfig = '' '';

  };

};}
