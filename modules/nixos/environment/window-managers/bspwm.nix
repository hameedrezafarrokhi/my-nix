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

  environment.systemPackages = [
   #pkgs.bsp-layout
   #(pkgs.callPackage ./bsp-tabbed.nix { })
  ];

    # ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.su}/bin/su m --command='systemctl --user start bspwm-reload.service'"
  services.udev.extraRules = ''
    ACTION=="add|remove", SUBSYSTEM=="drm", RUN+="${pkgs.systemd}/bin/systemctl --user start bspwm-reload.service"
  '';

};}
