{ config, pkgs, lib, inputs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.pd-wm;
  pd-wm = pkgs.callPackage ./pd-wm.nix { inputs = inputs; };

in

{

  options = {
    services.xserver.windowManager.pd-wm = {
      enable = mkEnableOption "pd-wm";
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

  config = lib.mkIf (builtins.elem "pd-wm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "pd-wm";
      start = ''
        systemctl --user stop dwm-status.service

        xsetroot -cursor_name left_ptr &

        export _JAVA_AWT_WM_NONREPARENTING=1
        ${pd-wm}/bin/dwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      cfg.package
      pd-wm
      pkgs.xorg.xsetroot
    ];

    services.xserver.windowManager.pd-wm = {

      enable = true;
     #extraSessionCommands = '' '';
      package = pd-wm;

    };

  };

}
