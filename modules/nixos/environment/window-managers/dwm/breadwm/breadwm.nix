{ config, pkgs, lib, inputs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.bread-wm;
  bread-wm = pkgs.callPackage ./bread-wm.nix { inputs = inputs; };

in

{

  options = {
    services.xserver.windowManager.bread-wm = {
      enable = mkEnableOption "bread-wm";
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

  config = lib.mkIf (builtins.elem "bread-wm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "bread-wm";
      start = ''
        dwmblocks &
        export _JAVA_AWT_WM_NONREPARENTING=1

        xsetroot -cursor_name left_ptr &

        ${bread-wm}/bin/dwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      cfg.package
      bread-wm
      pkgs.xsetroot
      pkgs.dwmblocks
    ];

    services.xserver.windowManager.bread-wm = {

      enable = true;
     #extraSessionCommands = '' '';
      package = bread-wm;

    };

  };

}
