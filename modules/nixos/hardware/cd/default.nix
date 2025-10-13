{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.cd;

in

{

  options.my.hardware.cd.enable = lib.mkEnableOption "enable cd-dvd stuff";

  config = lib.mkIf cfg.enable {

    programs.cdemu = {
      enable = true;
      gui = true;
      group = "cdrom";
      image-analyzer = true;
    };

  };

}
