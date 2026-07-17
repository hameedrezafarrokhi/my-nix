{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.nora;
  nora = pkgs.callPackage ./nora.nix { };

in

{

  options = {
    services.xserver.windowManager.nora = {
      enable = mkEnableOption "nora";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before nora is started.
        '';
      };
      package = mkPackageOption pkgs "nora" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "nora" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "nora";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${nora}/bin/nora &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.nora = {
      enable = true;
      extraSessionCommands = '' '';
      package = nora;
    };

  };

}
