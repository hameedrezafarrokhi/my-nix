{ config, pkgs, lib, ... }:

let

  cfg = config.my.window-managers;

in

{

  options.my.window-managers = lib.mkOption {

     type = lib.types.listOf (lib.types.enum [

       "hyprland" "niri"
       "sway" "qtile" "dwl"
       "labwc" "river" "wayfire"
       "miracle-wm" "miriway"

       "icewm" "fluxbox" "openbox" "windowlab" "windowmaker"
       "i3" "spectrwm" "herbstluftwm" "dk"
       "dwm" "chadwm" "drew-wm" "titus-wm" "bread-wm"
       "xmonad" "awesome" "bspwm"
       "exwm" "wmderland" "ragnarwm" "notion" "pekwm" "mlvwm"
       "fvwm2" "fvwm3" "leftwm" "berry" "hypr" "sawfish"
       "twm" "jwm" "ratpoison" "e16"

      ]);
     default = [ ];

  };

  options.my.rices-shells = lib.mkOption {

     type = lib.types.listOf (lib.types.enum [

       "hyprland-uwsm" "hyprland-noctalia" "hyprland-caelestia" "hyprland-dms" "hyprland-ax"
       "niri-uwsm" "niri-noctalia" "niri-dms"

      ]);
     default = [ ];

  };

  imports = [

    ./hyprland.nix
    ./niri.nix
    ./dwm.nix
    ./dwm/chadwm/chadwm.nix
    ./dwm/drewwm/drewwm.nix
    ./dwm/tituswm/tituswm.nix
    ./dwm/breadwm/breadwm.nix
    ./dwl.nix
    ./xmonad.nix
    ./awesome.nix
    ./bspwm.nix
    ./xmonad.nix
    ./i3.nix
    ./dk.nix
    ./qtile.nix
    ./spectrwm.nix
    ./herbstluftwm.nix
    ./sway.nix
    ./miracle-wm.nix
    ./miriway.nix
    ./river.nix
    ./wayfire.nix
    ./fluxbox.nix
    ./openbox.nix
    ./windowlab.nix
    ./windowmaker.nix
    ./icewm.nix
    ./labwc.nix
    ./exwm.nix
    ./wmderland.nix
    ./ragnarwm.nix
    ./notion.nix
    ./pekwm.nix
    ./sawfish.nix
    ./mlvwm.nix
    ./fvwm2.nix
    ./fvwm3.nix
    ./berry.nix
    ./hypr.nix
    ./twm.nix
    ./jwm.nix
    ./ratpoison.nix
    ./leftwm.nix
    ./e16.nix

    ./rices-shells/hyprland-noctalia.nix
    ./rices-shells/hyprland-caelestia.nix
    ./rices-shells/hyprland-uwsm.nix
    ./rices-shells/hyprland-dms.nix
    ./rices-shells/hyprland-ax.nix
    ./rices-shells/niri-noctalia.nix
    ./rices-shells/niri-dms.nix

  ];

}
