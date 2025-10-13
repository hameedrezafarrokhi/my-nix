{ config, pkgs, lib, inputs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.my-dwm;

in

{

  ###### interface

  options = {
    services.xserver.windowManager.my-dwm = {
      enable = mkEnableOption "dwm";
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

  config = lib.mkIf (builtins.elem "dwm" config.my.window-managers) {

  ###### implementation

    services.xserver.windowManager.my-dwm = {

      enable = true;
     #extraSessionCommands = '' '';
      package = pkgs.dwm;
    };

    services.xserver.windowManager.session = singleton {
      name = "dwm";
      start = ''
        ${cfg.extraSessionCommands}

        export _JAVA_AWT_WM_NONREPARENTING=1
        ${cfg.package}/bin/dwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

  };


}
