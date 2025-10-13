{ config, pkgs, lib, ... }:

let

  cfg = config.my.backup;

in

{

  options.my.backup = {

    rsync.enable = lib.mkEnableOption "enable rsync tools";

  };

  config = lib.mkIf cfg.rsync.enable {

    environment.systemPackages = [

      pkgs.timeshift                     ##System files backup
      pkgs.grsync

    ];


  };

}
