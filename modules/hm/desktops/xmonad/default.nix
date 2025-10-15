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

       #haskellPackages.xmonad-eval                      # WARNING BROKEN
       #haskellPackages.xmonad-vanessa                   # WARNING BROKEN
       #haskellPackages.xmonad-wallpaper                 # WARNING BROKEN
       #haskellPackages.xmonad-screenshot                # WARNING BROKEN
       #haskellPackages.xmonad-windownames               # WARNING BROKEN
       #haskellPackages.xmonad-entryhelper               # WARNING BROKEN
       #haskellPackages.xmonad-contrib-gpl               # WARNING BROKEN
       #haskellPackages.xmonad-bluetilebranch            # WARNING BROKEN
       #haskellPackages.xmonad-contrib-bluetilebranch    # WARNING BROKEN
       #haskellPackages.TaskMonad                        # WARNING BROKEN
       #haskellPackages.ixmonad                          # WARNING BROKEN
      ];

     #libFiles = { };
     #config = ;


    };

    programs.xmobar = {

      enable = true;
      package = pkgs.haskellPackages.xmobar;

     #extraConfig = '' '';

    };

    home.packages = [

      pkgs.xmonadctl
      pkgs.xmonad-log
     #pkgs.xmonad_log_applet                             # WARNING BROKEN

    ];

    xdg.configFile = {

      xmonad-conf = {
        target = "xmonad/";
        source = "${inputs.dot-collection}/xmonad/shahab-xmonad-dots/xmonad/";
      };

    };

  };

}
