{ config, pkgs, lib, inputs, ... }:

let

  cfg = config.my.xmonad;

in

{

  options.my.xmonad.enable = lib.mkEnableOption "xmonad";

  config = lib.mkIf cfg.enable {

    xsession.windowManager.xmonad = {

      enable = true;
      enableContribAndExtras = true;
      haskellPackages = pkgs.haskellPackages;

      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
        haskellPackages.monad-logger
        haskellPackages.DescriptiveKeys
        haskellPackages.xmonad-dbus
        haskellPackages.xmonad-utils
        haskellPackages.xmonad-volume
        haskellPackages.xmonad-extras
        haskellPackages.xmonad-spotify
        haskellPackages.xmonad-contrib

       #haskellPackages.xmonad-eval                     # WARNING BROKEN
       #haskellPackages.xmonad-vanessa
       #haskellPackages.xmonad-wallpaper
       #haskellPackages.xmonad-screenshot
       #haskellPackages.xmonad-windownames
       #haskellPackages.xmonad-entryhelper
       #haskellPackages.xmonad-contrib-gpl
       #haskellPackages.xmonad-bluetilebranch
       #haskellPackages.xmonad-contrib-bluetilebranch
       #haskellPackages.TaskMonad
       #haskellPackages.ixmonad
      ];

     #libFiles = { };
     #config = ;


    };

    programs.xmobar = {

      enable = true;
      package = pkgs.haskellPackages.xmobar;

     #extraConfig = '' '';

    };

    home.packages = with pkgs; [

       xmonadctl
       xmonad-log
      #xmonad_log_applet

    ];

    xdg.configFile = {

      xmonad-conf = {
        target = "xmonad/";
        source = "${inputs.dot-collection}/xmonad/shahab-xmonad-dots/xmonad/";
      };

    };

  };

}
