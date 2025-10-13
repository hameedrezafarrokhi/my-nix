{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "enlightenment" config.my.desktops) {

  services.xserver.desktopManager.enlightenment.enable = true;
  environment.enlightenment.excludePackages = [ ];

  systemd.user.services = {
    efreet.unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=Enlightenment";
    ethumb.unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=Enlightenment";
  };

};}
