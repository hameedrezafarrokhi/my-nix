{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.echinus;
  echinus = pkgs.callPackage ./echinus.nix {
    patches = [
      ./fix-incompatible-pointer-types.patch
    ];
  };

in

{

  options = {
    services.xserver.windowManager.echinus = {
      enable = mkEnableOption "echinus";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before echinus is started.
        '';
      };
      package = mkPackageOption pkgs "echinus" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "echinus" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "echinus";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${echinus}/bin/echinus &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      cfg.package
     #(pkgs.callPackage ./iriq.nix { })
     #(pkgs.callPackage ./ourico.nix { })
    ];

    services.xserver.windowManager.echinus = {
      enable = true;
      extraSessionCommands = '' '';
      package = echinus;
    };

  };

}
