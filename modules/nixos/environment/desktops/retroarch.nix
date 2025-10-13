{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "retroarch" config.my.desktops) {

################################################### OG SESSION

  services.xserver.desktopManager.retroarch = {
    enable = true;
    package = pkgs.retroarch;
   #extraArgs = [ ];
  };

################################################### MY SESSION

 #services.xserver.desktopManager.session = [
 #  {
 #    name = "RetroArch";
 #    start = ''
 #      ${pkgs.retroarch}/bin/retroarch -f ${escapeShellArgs services.xserver.desktopManager.extraArgs} &
 #      waitPID=$!
 #    '';
 #  }
 #];

 #services.displayManager.sessionPackages = [
 #
 #  (pkgs.writeTextFile {
 #    name = "retroarch";
 #    text = ''
 #      [Desktop Entry]
 #      Name=RetroArch (env)
 #      Comment=RetroArch with envs
 #      Exec=${pkgs.retroarch}/bin/retroarch -f ${lib.escapeShellArgs config.services.xserver.desktopManager.retroarch.extraArgs}
 #      Type=Application
 #    '';
 #    destination = "/share/xsessions/retroarch.desktop";
 #    derivationArgs = {
 #      passthru.providedSessions = [ "retroarch" ];
 #    };
 #  })
 #
 #];

 #environment.systemPackages = [ pkgs.retroarch ];

};}
