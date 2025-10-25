{ config, pkgs, lib, ... }:

let

  cfg = config.my.tasks;

in

{

  options.my.tasks.enable = lib.mkEnableOption "enable automated taks";

  config = lib.mkIf (config.my.tasks.enable) {

    services = {

      cron = {
        enable = true;
       #mailto = null; # Email address to which job output will be mailed
       #cronFiles = [ ];
       #systemCronJobs = [ ];
      };

    };

  };

}
