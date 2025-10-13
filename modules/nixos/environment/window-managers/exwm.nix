{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "exwm" config.my.window-managers) {

  services.xserver.windowManager.exwm = {

    enable = true;
    package = pkgs.emacs;
    loadScript = "(require 'exwm)";
   #extraPackages = epkgs: [
   #  epkgs.emms
   #  epkgs.magit
   #  epkgs.proofgeneral
   #];

  };

};}
