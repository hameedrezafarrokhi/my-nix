{ config, pkgs, lib, ... }:

{

  options.my.display-manager = lib.mkOption {

     type = lib.types.nullOr (lib.types.enum [

       "sddm"
       "lightdm"
       "cosmic-greeter"
       "gdm"

       "ly"
       "lemurs"

       "autologin"

     ]);
     default = null;

  };

  options.my.tty = {

    startx.enable = lib.mkEnableOption "startx";
    sx.enable =  lib.mkEnableOption "sx";

  };

  options.my.remoteDesktop = {

    xpra.enable = lib.mkEnableOption "xpra";
    vnc.enable =  lib.mkEnableOption "vnc";

  };

  options.my.defaultSession = lib.mkOption {
    type = lib.types.nullOr (lib.types.str);
    default = null;
  };

  imports = [

    ./sddm.nix
    ./sx.nix
    ./startx.nix
    ./gdm.nix
    ./lightdm.nix
    ./ly.nix
    ./cosmic-greeter.nix
    ./autologin.nix
    ./lemurs.nix
    ./xpra.nix
    ./vnc.nix

  ];

  config = {

    services.displayManager.defaultSession = lib.mkForce config.my.defaultSession;

  };

}
