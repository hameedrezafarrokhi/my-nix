{ config, pkgs, lib, ... }:

let

  cfg = config.my.spectrwm;

in

{

  options.my.spectrwm.enable = lib.mkEnableOption "spectrwm";

  config = lib.mkIf cfg.enable {

    xsession.windowManager.spectrwm = {

      enable = true;
      package = pkgs.spectrwm;

      programs = {
        term = config.my.default.terminal;
        search = "rofi -show drun";
      };

      quirks = {
        blueman = "FLOAT";
      };

      bindings = {
        quit = "Alt+Ctrl+Shift+e";
        restart = "Alt+Shift+r";
      };

      unbindings = [
        "MOD+e"
      ];

      settings = {
        modkey = "Mod4";
        workspace_limit = 7;
      };

    };

  };

}
