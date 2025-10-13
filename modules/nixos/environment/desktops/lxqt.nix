{ config, pkgs, lib, utils, ... }:

{ config = lib.mkIf (builtins.elem "lxqt" config.my.desktops) {

########################################### LXQT OG

  services.xserver.desktopManager.lxqt = {
    enable = true;
    extraPackages = with pkgs; [ xscreensaver ];
  };

  environment.lxqt.excludePackages = [ ];

  xdg.portal.lxqt = {
    enable = true;
    styles = [
      pkgs.libsForQt5.qtstyleplugin-kvantum
     #pkgs.breeze-qt5
      pkgs.libsForQt5.qtcurve
    ];
  };

############################################ LXQT CLONE


 #services.xserver.desktopManager.session = lib.singleton {
 #  name = "lxqt";
 #  bgSupport = true;
 #  start = ''
 #
 #    export XDG_CONFIG_DIRS=$XDG_CONFIG_DIRS''${XDG_CONFIG_DIRS:+:}${config.system.path}/share
 #
 #    exec ${pkgs.lxqt.lxqt-session}/bin/startlxqt
 #  '';
 #};

 #environment.systemPackages =
 #  pkgs.lxqt.preRequisitePackages
 #  ++ pkgs.lxqt.corePackages
 #  ++ (utils.removePackagesByName pkgs.lxqt.optionalPackages config.environment.lxqt.excludePackages)
 #  ++ [ pkgs.xscreensaver ]
 #  ;
 #
 #environment.pathsToLink = [ "/share" ];
 #programs.gnupg.agent.pinentryPackage = lib.mkDefault pkgs.pinentry-qt;
 #services.gvfs.enable = true;
 #services.upower.enable = config.powerManagement.enable;
 #services.libinput.enable = lib.mkDefault true;
 #xdg.portal.config.lxqt.default = lib.mkDefault [
 #  "lxqt"
 #  "gtk"
 #];

################################################ LXQT SESSION

 #services.displayManager.sessionPackages = [
 #
 # #pkgs.lxqt.lxqt-session
 #
 #  (pkgs.writeTextFile {
 #    name = "lxqt-env";
 #    text = ''
 #      [Desktop Entry]
 #      Name=Lxqt (env)
 #      Comment=Lxqt Desktop with envs
 #      Exec=startlxqt
 #      TryExec=lxqt-session
 #      Type=Application
 #    '';
 #    destination = "/share/xsessions/lxqt-env.desktop";
 #    derivationArgs = {
 #      passthru.providedSessions = [ "lxqt-env" ];
 #    };
 #  })
 #
 #];

};}
