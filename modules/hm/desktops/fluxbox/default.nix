{ config, pkgs, lib, ... }:

let

  cfg = config.my.fluxbox;

in

{

  options.my.fluxbox.enable = lib.mkEnableOption "fluxbox";

  config = lib.mkIf cfg.enable {

    xsession.windowManager.fluxbox = {

      enable = true;
      package = pkgs.fluxbox;

     #extraCommandLineArgs = [ ];

     #slitlist = '' '';
     #apps = '' '';
     #menu = '' '';
     #windowmenu = '' '';
     #keys = '' '';
     #init = '' '';

    };

  };

}
