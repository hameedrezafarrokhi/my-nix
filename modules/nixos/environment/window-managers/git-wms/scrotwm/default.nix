{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.scrotwm;
  scrotwm = pkgs.callPackage ./scrotwm.nix { };
  scrotbar = pkgs.writeShellScriptBin "scrotbar" ''
    ${builtins.readFile ./baraction.sh}
  '';

in

{

  options = {
    services.xserver.windowManager.scrotwm = {
      enable = mkEnableOption "scrotwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before scrotwm is started.
        '';
      };
      package = mkPackageOption pkgs "scrotwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "scrotwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "scrotwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${scrotwm}/bin/scrotwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package scrotbar ];

    services.xserver.windowManager.scrotwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = scrotwm;
    };

  };

}
