{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.display-manager == "lightdm") {

  services.xserver.enable = true;

  services.xserver.displayManager.lightdm = {

    enable = true;
    autoLogin.timeout = 0;
   #extraSeatDefaults = '' '';
   #extraConfig = '' '';
   #background = ; # background image or color to use.

    greeter = {
      enable = true;
     #package = ;
     #name = "";
    };

   #greeters = {
   #  gtk = { };
   #  tiny = { };
   #  mini = { };
   #  lomiri = { };
   #  slick = { };
   #  enso = { };
   #  pantheon = { };
   #  mobile = { };
   #};

  };

};}
