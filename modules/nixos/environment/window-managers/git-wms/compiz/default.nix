{ config, pkgs, lib, mypkgs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.compiz;
  compiz = pkgs.callPackage ./compiz.nix {
    python3 = pkgs.python311; python3Packages = pkgs.python311Packages;
  };

in

{

  options = {
    services.xserver.windowManager.compiz = {
      enable = mkEnableOption "compiz";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before compiz is started.
        '';
      };
      package = mkPackageOption pkgs "compiz" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "compiz" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "compiz";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${compiz}/bin/compiz &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.compiz = {
      enable = true;
      extraSessionCommands = '' '';
      package = compiz;
    };

  };

}
