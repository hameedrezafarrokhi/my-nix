{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.torba;
  torba = pkgs.callPackage ./torba.nix { };
  torba-bar = pkgs.writeShellScriptBin "torba-bar" ''
    ${builtins.readFile ./baraction.sh}
  '';

in

{

  options = {
    services.xserver.windowManager.torba = {
      enable = mkEnableOption "torba";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before torba is started.
        '';
      };
      package = mkPackageOption pkgs "torba" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "torba" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "torba";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${torba}/bin/torba &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package torba-bar ];

    services.xserver.windowManager.torba = {
      enable = true;
      extraSessionCommands = '' '';
      package = torba;
    };

  };

}
