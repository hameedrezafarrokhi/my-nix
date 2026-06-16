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
       "mango"

       "icewm" "fluxbox" "openbox" "windowlab" "windowmaker"
       "i3" "spectrwm" "herbstluftwm" "dk"
       "dwm" "chadwm" "drew-wm" "titus-wm"
       "xmonad" "awesome" "bspwm"
       "exwm" "wmderland" "ragnarwm" "notion" "pekwm" "mlvwm"
       "fvwm2" "fvwm3" "leftwm" "berry" "hypr" "sawfish"
       "twm" "jwm" "ratpoison" "e16"
       "tinywm" "2bwm" "windowchef" "evilwm" "lwm" "wmfs"
       "afterstep" "nimdow" "shod" "smallwm" "katriawm" "wmii"
       "hackedbox" "mwm" "cwm" "stumpwm" "clfswm" "matchbox"

       "oxwm"

       "ragnar" "hana" "suswm" "chibiwm" "custard" "monsterwm" "monsterwm-xcb"
       "catwm-og" "catwm-djmasde" "catwm-ahmadinne" "sara" "dminiwm" "eowm"
       "moody" "meowwm" "meow" "sexywm" "mmwm" "coma" "fluorite" "moonwm"
       "pwm" "philoswm" "devoidwm"
       "frankenwm" "echinus" "howm" "zwm-c" "zwm" "zwm-zig" "zwm-zig2" "zwm-cpp"

       "sowm" "aphelia" "mcwm" "jbwm" "qvwm" "ewm" "safwm"
       "aewmpp" "clarawm" "simplewm" "sophy" "fowm" "xswm"
       "sewm" "fxwm" "cygnus" "rwm" "hogewm" "biscuitwm" "xpywm"
       "superiorxwm" "barigui" "iguassu" "vswm" "verysmallwm" "verystupidwm"


      ]);
     default = [ ];

  };

  options.my.rices-shells = lib.mkOption {

     type = lib.types.listOf (lib.types.enum [

       "hyprland-uwsm"
       "hyprland-noctalia"
       "hyprland-caelestia"
       "hyprland-dms"
       "hyprland-ashell"
       "hyprland-exo"
       "hyprland-ambxst"
      #"hyprland-ax"

       "niri-uwsm"
       "niri-noctalia"
       "niri-dms"

      ]);
     default = [ ];

  };

  imports = [

   #./hyprland.nix
    ./niri.nix

    ./dwm.nix
   #./dwm/chadwm
   #./dwm/drewwm
   #./dwm/tituswm
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
   #./mango.nix

    ./tinywm.nix
    ./2bwm.nix
    ./windowchef.nix
    ./evilwm.nix
    ./lwm.nix
    ./wmfs.nix
    ./afterstep.nix
    ./nimdow.nix
    ./shod.nix
    ./smallwm.nix
    ./katriawm.nix
    ./wmii.nix
    ./hackedbox.nix
    ./mwm.nix
    ./cwm.nix
    ./stumpwm.nix
    ./clfswm.nix
    ./matchbox.nix

    ./oxwm.nix

   #./rices-shells/hyprland-noctalia.nix
   #./rices-shells/hyprland-caelestia.nix
   #./rices-shells/hyprland-uwsm.nix
   #./rices-shells/hyprland-dms.nix
   #./rices-shells/hyprland-ambxst.nix
   #./rices-shells/hyprland-ax.nix
   #./rices-shells/hyprland-ashell.nix
   #./rices-shells/hyprland-exo.nix

   #./rices-shells/niri-noctalia.nix
   #./rices-shells/niri-dms.nix

    ./git-wms/ragnar
    ./git-wms/hana
    ./git-wms/swm-sus
    ./git-wms/chibiwm
    ./git-wms/custard
    ./git-wms/catwm/catwm-og
    ./git-wms/catwm/catwm-djmasde
    ./git-wms/catwm/catwm-ahmadinne
    ./git-wms/catwm/dminiwm
    ./git-wms/catwm/sara
    ./git-wms/catwm/eowm
    ./git-wms/monsterwm
    ./git-wms/monsterwm-xcb
    ./git-wms/moody
    ./git-wms/meow
    ./git-wms/meowwm
    ./git-wms/sexywm
    ./git-wms/mmwm
    ./git-wms/coma
    ./git-wms/fluorite
    ./git-wms/moonwm
    ./git-wms/devoidwm
    ./git-wms/pwm
    ./git-wms/philoswm
    ./git-wms/frankenwm
    ./git-wms/echinus
    ./git-wms/howm
    ./git-wms/zwm-c
    ./git-wms/zwm
    ./git-wms/zwm-zig
    ./git-wms/zwm-zig2
    ./git-wms/zwm-cpp

    ./git-wms/sowm
    ./git-wms/aphelia
    ./git-wms/mcwm
    ./git-wms/jbwm
    ./git-wms/qvwm
    ./git-wms/ewm
    ./git-wms/safwm
    ./git-wms/aewmpp
    ./git-wms/clarawm
    ./git-wms/swm-simple
    ./git-wms/sophy
    ./git-wms/fowm
    ./git-wms/sewm
    ./git-wms/cygnus
    ./git-wms/fxwm
    ./git-wms/rwm
    ./git-wms/hogewm
    ./git-wms/superiorxwm
    ./git-wms/barigui
    ./git-wms/iguassu
    ./git-wms/vswm
    ./git-wms/verysmallwm
    ./git-wms/verystupidwm
    ./git-wms/biscuitwm
    ./git-wms/xpywm
    ./git-wms/xswm



  ];

}
