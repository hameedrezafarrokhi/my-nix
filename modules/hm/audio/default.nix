{ config, pkgs, lib, ... }:

let

  cfg = config.my.audio;

in

{

  options.my.audio.enable = lib.mkEnableOption "audio stuff";

  config = lib.mkIf cfg.enable {

    services.playerctld = {
      enable = true;
      package = pkgs.playerctl;
    };

    home.packages = [

      pkgs.pamixer

    ];

  };

}
