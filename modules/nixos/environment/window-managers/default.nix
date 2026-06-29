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
       "wingo" "worm" "worm-quad" "dowm" "plwm" "rubywm"
       "hadlock" "wtftw" "minyaty" "hsdwm" "calavera" "oxwm-r"
       "sswm" "gar" "unknowwm" "kopiwm" "critwm" "ferriswm"
       "karuiwm" "cupidwm" "devwm" "glitch" "heawm" "octopus"
       "gowm" "pointblank" "vxwm" "torba" "scrotwm" "cocowm"
       "mxswm" "crubwm" "voxwm" "sweetwm" "page" "cluless"
       "rustile" "poorwm" "neowm" "ltwm" "dael" "derpy-wm"
       "troodon" "miawm" "irwm" "customwm" "ttwm" "2am-qwm"
       "oxidewm" "subtle-rs" "tatami" "gridwm" "fensterchef"
       "rondo" "pywm" "qtwm" "dash" "ferawm" "boringwm" "dxwm"
       "sirenwm" "seiwm" "yggdrasilwm" "fleon" "absent" "nwm"
       "chamferwm" "legacywm" "lwm-c" "ywm" "minimalwm" "pgwm"
       "rdwm" "rustwm" "bond-wm" "fyrwm" "nyxwm" "foxwm"

       "bouncy-window-manager" "bouncy-wm" "bounce-wm" "bouncywm"
       "bouncywm-ruby" "bouncewm-kacper" "bouncewm" "stressfulwm"

       "oxwm"

       "ragnar" "hana" "suswm" "chibiwm" "custard" "monsterwm" "monsterwm-xcb"
       "catwm-og" "catwm-djmasde" "catwm-ahmadinne" "sara" "dminiwm" "eowm"
       "moody" "meowwm" "meow" "sexywm" "mmwm" "coma" "fluorite" "moonwm"
       "marswm" "pwm" "philoswm" "devoidwm"
       "frankenwm" "echinus" "howm" "zwm-c" "zwm" "zwm-zig" "zwm-zig2" "zwm-cpp"

       "compiz" "compiz-reloaded" "sowm" "aphelia" "mcwm" "jbwm" "qvwm" "ewm" "safwm"
       "aewmpp" "clarawm" "simplewm" "sophy" "fowm" "xswm"
       "sewm" "fxwm" "cygnus" "rwm" "hogewm" "biscuitwm" "xpywm"
       "superiorxwm" "barigui" "iguassu" "vswm" "verysmallwm" "verystupidwm"
       "vtwm" "progman" "karmen" "windwm" "larswm" "9wm" "ctwm" "blackbox"
       "goomwwm" "wmx" "flwm" "adwm" "emwm" "eggwm" "uwm" "notewm" "dfpwm"
       "nimwin" "stevewm" "nyxwm-float" "waimea" "mitewm-go" "mitewm" "qpwm"
       "wm0" "xmt" "makron" "window_manager" "amiwb" "slacker" "mswm" "fwwm"
       "NsCDE" "fluid-wm" "srwm" "moksha"


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
    ./git-wms/wingo
    ./git-wms/worm
    ./git-wms/dowm
    ./git-wms/plwm
    ./git-wms/rubywm
    ./git-wms/hadlock
    ./git-wms/wtftw
    ./git-wms/minyaty
    ./git-wms/hsdwm
    ./git-wms/calavera
    ./git-wms/oxwm-r
    ./git-wms/sswm
    ./git-wms/gar
    ./git-wms/unknowwm
    ./git-wms/kopiwm
    ./git-wms/critwm
    ./git-wms/ferriswm
    ./git-wms/karuiwm
    ./git-wms/cupidwm
    ./git-wms/devwm
    ./git-wms/glitch
    ./git-wms/heawm
    ./git-wms/octopus
    ./git-wms/gowm
    ./git-wms/pointblank
    ./git-wms/vxwm
    ./git-wms/torba
    ./git-wms/scrotwm
    ./git-wms/cocowm
    ./git-wms/mxswm
    ./git-wms/crubwm
    ./git-wms/voxwm
    ./git-wms/sweetwm
    ./git-wms/page
    ./git-wms/cluless
    ./git-wms/rustile
    ./git-wms/poorwm
    ./git-wms/neowm
    ./git-wms/ltwm
    ./git-wms/dael
    ./git-wms/derpy-wm
    ./git-wms/troodon
    ./git-wms/miawm
    ./git-wms/irwm
    ./git-wms/customwm
    ./git-wms/ttwm
    ./git-wms/2am-qwm
    ./git-wms/oxidewm
    ./git-wms/subtle-rs
    ./git-wms/tatami
    ./git-wms/gridwm
    ./git-wms/fensterchef
    ./git-wms/rondo
    ./git-wms/pywm
    ./git-wms/qtwm
    ./git-wms/dash
    ./git-wms/ferawm
    ./git-wms/boringwm
    ./git-wms/dxwm
    ./git-wms/sirenwm
    ./git-wms/seiwm
    ./git-wms/yggdrasilwm
    ./git-wms/fleon
    ./git-wms/absent
    ./git-wms/chamferwm
    ./git-wms/legacywm
    ./git-wms/lwm-c
    ./git-wms/ywm
    ./git-wms/minimalwm
    ./git-wms/pgwm
    ./git-wms/nwm
    ./git-wms/rdwm
    ./git-wms/rustwm
    ./git-wms/bond-wm
    ./git-wms/fyrwm
    ./git-wms/nyxwm
    ./git-wms/fluid-wm


    ./git-wms/bouncy-window-manager
    ./git-wms/bouncy-wm
    ./git-wms/bounce-wm
    ./git-wms/bouncywm
    ./git-wms/bouncywm-ruby
    ./git-wms/bouncewm-kacper
    ./git-wms/bouncewm
    ./git-wms/stressfulwm


    ./git-wms/compiz
    ./git-wms/compiz-reloaded
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
    ./git-wms/vtwm
    ./git-wms/progman
    ./git-wms/karmen
    ./git-wms/windwm
    ./git-wms/9wm
    ./git-wms/larswm
    ./git-wms/ctwm
    ./git-wms/blackbox
    ./git-wms/goomwwm
    ./git-wms/wmx
    ./git-wms/flwm
    ./git-wms/adwm
    ./git-wms/emwm
    ./git-wms/eggwm
    ./git-wms/uwm
    ./git-wms/marswm
    ./git-wms/worm-quad
    ./git-wms/notewm
    ./git-wms/dfpwm
    ./git-wms/nimwin
    ./git-wms/stevewm
    ./git-wms/nyxwm-float
    ./git-wms/waimea
    ./git-wms/mitewm-go
    ./git-wms/mitewm
    ./git-wms/qpwm
    ./git-wms/wm0
    ./git-wms/xmt
    ./git-wms/makron
    ./git-wms/window_manager
    ./git-wms/amiwb
    ./git-wms/slacker
    ./git-wms/mswm
    ./git-wms/foxwm
    ./git-wms/fwwm
    ./git-wms/NsCDE
    ./git-wms/srwm
    ./git-wms/moksha


  ];

}
