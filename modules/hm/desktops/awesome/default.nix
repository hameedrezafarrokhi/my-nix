{ config, pkgs, lib, inputs, ... }:

let

  cfg = config.my.awesome;

in

{

  options.my.awesome.enable = lib.mkEnableOption "awesome";

  config = lib.mkIf cfg.enable {

    xsession.windowManager.awesome = {

      enable = true;
      package = pkgs.awesome;
      luaModules = [ pkgs.luaPackages.vicious pkgs.luaPackages.awesome-wm-widgets ];
      noArgb = false;

    };

    xdg.configFile = {

      awesome-conf = {
        target = "awesome/";
        source = ./awesome;
      };

    };

  };

}
