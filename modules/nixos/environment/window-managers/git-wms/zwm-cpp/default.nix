{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.zwm-cpp;
  zwm-cpp = pkgs.callPackage ./zwm-cpp.nix { };

in

{

  options = {
    services.xserver.windowManager.zwm-cpp = {
      enable = mkEnableOption "zwm-cpp";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before zwm-cpp is started.
        '';
      };
      package = mkPackageOption pkgs "zwm-cpp" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "zwm-cpp" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "zwm-cpp";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}

        ${zwm-cpp}/bin/zwm-cpp &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.zwm-cpp = {
      enable = true;
      extraSessionCommands = '' '';
      package = zwm-cpp;
    };

  };

}
