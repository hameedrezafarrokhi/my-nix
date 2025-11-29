{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.pay-respects.enable) {

  programs.pay-respects = {

    enable = true;
    package = pkgs.pay-respects;
    enableBashIntegration = false;
    enableFishIntegration = true;
    enableZshIntegration = true;
    options = [
      "--alias"
      "huh"
    ];

  };

};}
