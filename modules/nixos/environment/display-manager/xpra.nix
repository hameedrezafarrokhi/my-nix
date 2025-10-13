{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.remoteDesktop.xpra.enable) {

  services.xserver.enable = true;

  services.xserver.displayManager.xpra = {

    enable = true;
    desktop = null;      # "gnome-shell"
    auth = "pam";        # "password:value=mysecret"
    bindTcp = "127.0.0.1:10000";
    pulseaudio = true;
    extraOptions = [ ];

  };

};}
