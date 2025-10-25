{ config, pkgs, lib, ... }:

let

  cfg = config.my.search;

in

{

  options.my.search.enable = lib.mkEnableOption "enable search stuff";

  config = lib.mkIf (config.my.search.enable) {

    services = {

      locate = {
        enable = true;
        package = pkgs.plocate;
        interval = "never";      # run updatedb manually
       #extraFlags = ;           # Extra flags to pass to updatedb
        prunePaths = [
         "/tmp"
         "/var/tmp"
         "/var/cache"
         "/var/lock"
         "/var/run"
         "/var/spool"
         "/nix/store"
         "/nix/var/log/nix"
        ];
        pruneNames = [ ".bzr" ".cache" ".git" ".hg" ".svn" ];
       #pruneFS = ;
       #pruneBindMounts = ;
        output = "/var/cache/locatedb";
      };

    };

  };

}
