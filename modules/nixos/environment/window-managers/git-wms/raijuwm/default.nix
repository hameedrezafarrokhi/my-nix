{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.raijuwm;
  raijuwm = pkgs.callPackage ./raijuwm.nix { };

in

{

  options = {
    services.xserver.windowManager.raijuwm = {
      enable = mkEnableOption "raijuwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before raijuwm is started.
        '';
      };
      package = mkPackageOption pkgs "raijuwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "raijuwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "raijuwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${raijuwm}/bin/raijuwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.raijuwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = raijuwm;
    };

  };

}
