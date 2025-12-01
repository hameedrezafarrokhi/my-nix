{ config, pkgs, lib, ... }:

let

  cfg = config.my.ssh;

in

{

  options.my.ssh.enable =  lib.mkEnableOption "ssh";

  config = lib.mkIf cfg.enable {

    programs.ssh = {
      enable = true;
      package = null;
      enableDefaultConfig = false;

     #extraConfig = '' '';
     #extraOptionOverrides = { };
     #includes = [ ];

      matchBlocks = {       # very comlex :))

        "*" = {
          compression = false;
          controlMaster = "no"; # one of "yes", "no", "ask", "auto", "autoask"
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "yes";  # "2h"
          forwardAgent = true;
          hashKnownHosts = false;
          serverAliveCountMax = 3;
          userKnownHostsFile = "~/.ssh/known_hosts";
          addKeysToAgent = "yes";
        };

      };
    };

    services = {
      ssh-agent = {
        enable = true;
        package = pkgs.openssh;
      };
      ssh-tpm-agent = {
        enable = false;
        package = pkgs.ssh-tpm-agent;
        keyDir = null;
      };
    };

  };

}
