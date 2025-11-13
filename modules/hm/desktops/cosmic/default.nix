{ config, pkgs, lib, ... }:

let

  cfg = config.my.cosmic;

in

{

  options.my.cosmic.enable = lib.mkEnableOption "cosmic";

  config = lib.mkIf cfg.enable {    # HUNDREDS OF OPTIONS

    wayland.desktopManager.cosmic = {
      enable = false;
    };

  };

}
