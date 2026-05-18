{ config, pkgs, lib, inputs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.chadwm;
  chadwm = pkgs.callPackage ./chad-wm.nix { inputs = inputs; };

in

{

  options = {
    services.xserver.windowManager.chadwm = {
      enable = mkEnableOption "chadwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before dwm is started.
        '';
      };
      package = mkPackageOption pkgs "dwm" {
        example = ''
          pkgs.dwm.overrideAttrs (oldAttrs: rec {
            patches = [
              (super.fetchpatch {
                url = "https://dwm.suckless.org/patches/steam/dwm-steam-6.2.diff";
                sha256 = "sha256-f3lffBjz7+0Khyn9c9orzReoLTqBb/9gVGshYARGdVc=";
              })
            ];
          })
        '';
      };
    };
  };

  ###### implementation

  config = lib.mkIf (builtins.elem "chadwm" config.my.window-managers) {

    #while type chadwm >/dev/null; do chadwm && continue || break; done
    #xrdb merge ~/.Xresources
    #xbacklight -set 10 &
    #xset r rate 200 50 &
    #picom &

    services.xserver.windowManager.session = singleton {
      name = "chadwm";
      start = ''

        dash ${inputs.chadwm}/scripts/bar.sh &

        ${cfg.extraSessionCommands}

        export _JAVA_AWT_WM_NONREPARENTING=1

        xsetroot -cursor_name left_ptr &

        ${chadwm}/bin/chadwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      cfg.package
      chadwm
      pkgs.dash
      pkgs.xsetroot
    ];

    services.xserver.windowManager.chadwm = {

      enable = true;
     #extraSessionCommands = '' '';
      package = chadwm;

    };

  };

}
