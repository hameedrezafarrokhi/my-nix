{ config, pkgs, lib, nix-path, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.sexywm;
  sxbar = pkgs.callPackage ./sxbar.nix { };
  sexywm = pkgs.callPackage ./sxwm.nix {
    patches = [
       # Master branch patches
     #./sxwm/patches/directional-gaps-pbadeer.patch
     #./sxwm/patches/option-mirror-layout-palsmo.patch
     #./sxwm/patches/single-window-gaps-dragonchicken.patch
    ];
  };

in

{

  options = {
    services.xserver.windowManager.sexywm = {
      enable = mkEnableOption "sexywm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before sexywm is started.
        '';
      };
      package = mkPackageOption pkgs "sexywm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "sexywm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "sexywm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${sexywm}/bin/sexywm &
        waitPID=$!
      '';
    };

    # -c ${nix-path}/modules/nixos/environment/window-managers/git-wms/sexywm/sxwmrc

    environment.systemPackages = [ cfg.package sxbar ];

    services.xserver.windowManager.sexywm = {
      enable = true;
      extraSessionCommands = ''
        systemctl --user stop numlockx.service
        numlockx off
        pkill numlockx
      '';
      package = sexywm;
    };

  };

}
