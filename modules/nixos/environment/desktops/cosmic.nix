{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "cosmic" config.my.desktops) {

   services.desktopManager.cosmic = {
     enable = true;
     xwayland.enable = true;
     showExcludedPkgsWarning = true;
    #excludePackages = [ ];
   };

   environment.systemPackages = [

     pkgs.cosmic-reader
     pkgs.cosmic-ext-ctl
     pkgs.cosmic-protocols
     pkgs.cosmic-ext-tweaks
     pkgs.cosmic-ext-calculator
     pkgs.quick-webapps
     pkgs.examine
     pkgs.tasks
     pkgs.oboete

   ];

};}
