{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (builtins.elem "xmonad" config.my.window-managers) {

  services.xserver.windowManager.xmonad = {

    enable = true;
    enableContribAndExtras = true;
    haskellPackages = pkgs.haskellPackages;

    xmonadCliArgs = [ ];
    ghcArgs = [ ];

    extraPackages = config.home-manager.users.${admin}.xsession.windowManager.xmonad.extraPackages;
    enableConfiguredRecompile = true;

   #config = ;

  };

  environment.systemPackages = [

    pkgs.xmonadctl
    pkgs.xmonad-log
   #pkgs.xmonad_log_applet

  ];

};}
