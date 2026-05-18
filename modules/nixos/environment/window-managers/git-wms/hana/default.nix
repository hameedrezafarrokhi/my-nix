{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.hana;
  hana = pkgs.callPackage ./hana.nix { };

in

{

  options = {
    services.xserver.windowManager.hana = {
      enable = mkEnableOption "hana";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before hana is started.
        '';
      };
      package = mkPackageOption pkgs "hana" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "hana" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "hana";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${hana}/bin/hana &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.hana = {
      enable = true;
      extraSessionCommands = '' '';
      package = hana;
    };

  };

}
