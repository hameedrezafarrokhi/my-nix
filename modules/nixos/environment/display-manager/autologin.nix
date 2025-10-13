{ config, pkgs, lib, myStuff, ... }:

{ config = lib.mkIf (config.my.display-manager == "autologin") {

  services.xserver.enable = true;

  services.displayManager = {
    autoLogin = {
      enable = true;
      user = myStuff.myUser;
    };
  };

};}
