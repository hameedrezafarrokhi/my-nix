{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.hardware.ram-tmp.nohang.enable) {

  services.nohang = {

    package = pkgs.nohang;

    enable = true;

    configPath = "desktop"; # one of "basic", "desktop" or absolute path

  };

};}
