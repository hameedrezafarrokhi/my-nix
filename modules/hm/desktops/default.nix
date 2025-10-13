{ config, lib, pkgs, ... }:

{

  options.my.rices-shells = lib.mkOption {

     type = lib.types.listOf (lib.types.enum [

       "hyprland-uwsm" "hyprland-noctalia" "hyprland-caelestia" "hyprland-dms" "hyprland-ax"
       "niri-uwsm" "niri-noctalia" "niri-dms"

      ]);
     default = [ ];
  };

  imports = [

    ./kde
    ./cinnamon
    ./mate
    ./gnome
    ./xfce
    ./hypr
    ./niri
    ./sway
    ./river
    ./wayfire
    ./labwc
    ./i3
    ./spectrwm
    ./herbstluftwm
    ./fluxbox
    ./xmonad
    ./awesome
    ./bspwm
    ./dwm
    ./uwsm
    ./x11

  ];

}
