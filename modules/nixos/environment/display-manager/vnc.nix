{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.remoteDesktop.vnc.enable) {

  programs.turbovnc.ensureHeadlessSoftwareOpenGL = true;

};}
