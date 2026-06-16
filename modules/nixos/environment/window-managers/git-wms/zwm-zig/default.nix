{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.zwm-zig;
  zwm-zig = pkgs.callPackage ./zwm-zig.nix { };

in

{

  options = {
    services.xserver.windowManager.zwm-zig = {
      enable = mkEnableOption "zwm-zig";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before zwm-zig is started.
        '';
      };
      package = mkPackageOption pkgs "zwm-zig" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "zwm-zig" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "zwm-zig";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${zwm-zig}/bin/zwm-zig &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.zwm-zig = {
      enable = true;
      extraSessionCommands = '' '';
      package = zwm-zig;
    };

  };

}
