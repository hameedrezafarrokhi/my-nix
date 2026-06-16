{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.zwm;
  zwm = pkgs.callPackage ./zwm.nix { };

in

{

  options = {
    services.xserver.windowManager.zwm = {
      enable = mkEnableOption "zwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before zwm is started.
        '';
      };
      package = mkPackageOption pkgs "zwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "zwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "zwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        [ ! -f "$HOME/.config/zwm/zwm.conf" ] && cp ${zwm}/share/zwm/zwm.conf $HOME/.config/zwm/
        ${zwm}/bin/zwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.zwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = zwm;
    };

  };

}
