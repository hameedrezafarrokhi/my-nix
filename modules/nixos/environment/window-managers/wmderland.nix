{ config, pkgs, lib, mypkgs, ... }:

with lib;

let
  cfg = config.services.xserver.my-windowManager.wmderland;
in

{
  options.services.xserver.my-windowManager.wmderland = {
    enable = mkEnableOption "wmderland";

    extraSessionCommands = mkOption {
      default = "";
      type = types.lines;
      description = ''
        Shell commands executed just before wmderland is started.
      '';
    };

    extraPackages = mkOption {
      type = with types; listOf package;
      default = [
        pkgs.rofi
        pkgs.dunst
        mypkgs.old-stable.light
        pkgs.hsetroot
        pkgs.feh
        pkgs.rxvt-unicode
      ];
      defaultText = literalExpression ''
        [
          pkgs.rofi
          pkgs.dunst
          mypkgs.old-stable.light
          pkgs.hsetroot
          pkgs.feh
          pkgs.rxvt-unicode
        ]
      '';
      description = ''
        Extra packages to be installed system wide.
      '';
    };

  };

  config = lib.mkIf (builtins.elem "wmderland" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "wmderland";
      start = ''
        ${cfg.extraSessionCommands}

        ${pkgs.wmderland}/bin/wmderland &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      pkgs.wmderland
      pkgs.wmderlandc
    ]
    ++ cfg.extraPackages;

    services.xserver.my-windowManager.wmderland = {

      enable = true;
     #extraSessionCommands = '' '';
     #extraPackages = [ ];

    };

  };

}
