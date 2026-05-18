{ config, pkgs, lib, inputs, mypkgs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.titus-wm;
  titus-wm = pkgs.callPackage ./titus-wm.nix { inputs = inputs; };

in

{

  options = {
    services.xserver.windowManager.titus-wm = {
      enable = mkEnableOption "titus-wm";
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

  config = lib.mkIf (builtins.elem "titus-wm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "titus-wm";
      start = ''
        polybar main -c "${titus-wm}/polybar/themes/minimal/config.ini" &
        export _JAVA_AWT_WM_NONREPARENTING=1

        xsetroot -cursor_name left_ptr &

        ${titus-wm}/bin/dwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      cfg.package
      titus-wm
      pkgs.xsetroot
    ];

    services.xserver.windowManager.titus-wm = {

      enable = true;
     #extraSessionCommands = '' '';
      package = titus-wm;

    };

  };

}
