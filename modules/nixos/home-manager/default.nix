{ config, pkgs, lib, ... }:

let

  cfg = config.my.home-manager;

in

{

  options.my.home-manager.enable = lib.mkEnableOption "home-manager nixos top-level options";

  config = lib.mkIf cfg.enable {

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };

  };

}
