{ config, pkgs, lib, ... }:

{

  options.my.hardware.touchegg= {

    enable = lib.mkEnableOption "enable x11 touch support with touchegg (from elementaryos)";

  };

  config = (lib.mkMerge [

    (lib.mkIf (config.my.hardware.touchegg.enable) { services.touchegg.enable = true; services.touchegg.package = pkgs.touchegg;})
    (lib.mkIf (!config.my.hardware.touchegg.enable) { services.touchegg.enable = lib.mkForce false;})

  ])

  ;

}
