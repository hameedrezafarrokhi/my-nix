{ config, lib, pkgs, ... }:

let

  cfg = config.my.dconf;

in

{

  options.my.dconf.enable = lib.mkEnableOption "enable dconf settings";

  config = lib.mkIf cfg.enable {

    programs.dconf = {
      enable = true;
     #profiles = { };
     #packages = [ ];
    };

  };

}
