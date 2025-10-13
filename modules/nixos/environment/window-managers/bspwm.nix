{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "bspwm" config.my.window-managers) {

  services.xserver.windowManager.bspwm = {
    enable = true;
    package = pkgs.bspwm;
   #configFile = "${pkgs.bspwm}/share/doc/bspwm/examples/bspwmrc";
    sxhkd = {
      package = pkgs.sxhkd;
     #configFile = "${pkgs.bspwm}/share/doc/bspwm/examples/sxhkdrc";
    };
  };

  environment.systemPackages = [ pkgs.bsp-layout ];

};}
