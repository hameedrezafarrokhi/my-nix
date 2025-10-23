{ config, lib, pkgs, ... }:

{

  options.my.rices-shells = lib.mkOption {

     type = lib.types.listOf (lib.types.enum [

       "hyprland-uwsm" "hyprland-noctalia" "hyprland-caelestia" "hyprland-dms" "hyprland-ax" "hyprland-ashell" "hyprland-exo"
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
    ./mango
    ./i3
    ./spectrwm
    ./herbstluftwm
    ./fluxbox
    ./xmonad
    ./awesome
    ./qtile
    ./bspwm
    ./dwm
    ./uwsm
    ./x11

  ];

}
