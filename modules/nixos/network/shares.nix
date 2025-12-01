{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.network.shares.enable) {

  services = {

   #dleyna.enable = true;

   #samba = {
   #  enable = true;
   #  package = pkgs.samba4Full;  # lots of overrides
   #  smbd = {
   #    enable = true;
   #   #extraArgs = [ ];
   #  };
   #  winbindd = {
   #    enable = true;
   #   #extraArgs = [ ];
   #  };
   #  usershares = {
   #    enable = true;
   #    group = "samba";
   #  };
   #  nmbd = {
   #    enable = true;
   #   #extraArgs = [ ];
   #  };
   #  nsswins = true;
   #  openFirewall = true;
   #
   # #settings = {  # default:
   # #  global = {
   # #    "invalid users" = [
   # #      "root"
   # #    ];
   # #    "passwd program" = "/run/wrappers/bin/passwd %u";
   # #    security = "user";
   # #  };
   # #};
   #
   #};
   #samba-wsdd = {  # for NAS devices
   #  enable = true;
   # #workgroup = null;
   #  openFirewall = true;
   # #listen = "/run/wsdd/wsdd.sock";
   # #interface = null;
   # #hostname = null;
   # #hoplimit = null;
   # #extraOptions = [ "--shortlog" ];
   # #domain = null;
   # #discovery = false;
   #};

  };

};}
