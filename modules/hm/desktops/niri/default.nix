{ config, pkgs, lib, ... }:

let

  cfg = config.my.niri;

in

{

  options.my.niri.enable = lib.mkEnableOption "niri";

  config = lib.mkIf cfg.enable {

   #services = {
   #  polkit-gnome = {
   #    enable = true;
   #    package = pkgs.polkit_gnome;
   #  };
   #};

    programs.niriswitcher = {

      enable = true;
      package = pkgs.niriswitcher;
     #style = ; # Path or '' extra css ''
      settings = {
        keys = {
          modifier = "Alt";
          switch = {
            next = "Tab";
            prev = "Shift+Tab";
          };
        };
        center_on_focus = true;
        appearance = {
          system_theme = "dark";
          icon_size = 64;
        };
      };

    };

  };

  imports = [

    ./niri-dms.nix
    ./niri-noctalia.nix

  ];

}
