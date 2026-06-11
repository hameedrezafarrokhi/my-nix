{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.awww.enable) {

  services.awww = {
    enable = true;
    package = pkgs.awww;
    extraArgs = [ ];
  };

 #systemd.user.services.awww = {
 #  Service = {
 #    ExecStart = lib.mkForce "${lib.getExe (config.services.awww.package)} ${lib.escapeShellArgs config.services.awww.extraArgs} img /home/hrf/Pictures/Wallpapers/background.png";
 #  };
 #};

};}
