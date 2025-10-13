{ config, pkgs, lib, ... }:

let

  cfg = config.my.security.pam;

in

{

  options.my.security.pam.enable = lib.mkEnableOption "enable pam";

  config = lib.mkIf cfg.enable {

    security.pam.services = {
      login = {
        enable = true;
        name = "login";
        kwallet = {
          enable = true;
         #package = pkgs.kdePackages.kwallet-pam;
          forceRun = true;
        };
        gnupg.enable = true;
        enableGnomeKeyring = true;
      };
     #greetd = { };
     #su = { };
      sshd = {
        enable = true;
        name = "sshd";
        kwallet = {
          enable = true;
         #package = pkgs.kdePackages.kwallet-pam;
          forceRun = true;
        };
        gnupg.enable = true;
        enableGnomeKeyring = true;
      };
    };

  };

}
