{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.swww.enable) {

  services.swww = {
    enable = true;
    package = pkgs.swww;
    extraArgs = [ ];
  };

 #systemd.user.services.swww = {
 #  Service = {
 #    ExecStart = lib.mkForce "${lib.getExe (config.services.swww.package)} ${lib.escapeShellArgs config.services.swww.extraArgs} img /home/hrf/Pictures/Wallpapers/catppuccin-astro-macchiato/macchiato-hald8-background.png2.png";
 #  };
 #};

};}
