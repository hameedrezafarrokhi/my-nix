{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.hogewm;
  xremap-hogewm = pkgs.writeShellScriptBin "xremap-hogewm" ''
    sleep 7
    xremap --watch --mouse .config/xremap/xremap.yaml
  '';
  hogewm = pkgs.callPackage ./hogewm.nix { };

in

{

  options = {
    services.xserver.windowManager.hogewm = {
      enable = mkEnableOption "hogewm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before hogewm is started.
        '';
      };
      package = mkPackageOption pkgs "hogewm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "hogewm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "hogewm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${hogewm}/bin/hogewm &
        waitPID=$!
        ${config.my.default.terminal} &
        ${hogewm}/bin/eternal_sleep
      '';
    };

    environment.systemPackages = [ cfg.package xremap-hogewm ];

    services.xserver.windowManager.hogewm = {
      enable = true;
      extraSessionCommands = ''
        systemctl --user stop numlockx.service
        numlockx off
        pkill numlockx
        systemctl --user stop xremap.service
        pkill xremap
        sleep 2
        xmodmap ${hogewm}/home/.Xmodmap
        setxkbmap -option ctrl:nocaps
        #xremap-hogewm &
      '';
      package = hogewm;
    };

  };

}
