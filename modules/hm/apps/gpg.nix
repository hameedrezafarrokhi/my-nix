{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.gpg.enable) {

  programs.gpg = {
    enable = true;
    package = pkgs.gnupg;
    homedir = "${config.home.homeDirectory}/.gnupg";
    mutableKeys = true;
    mutableTrust = true;
   #publicKeys = [ { source = ./pubkeys.txt; } ];
   #scdaemonSettings = { };
   #settings = { };
  };

  services.gpg-agent = {
    enable = true;
    pinentry = {
      package = pkgs.pinentry-qt; # pkgs.pinentry-all
     #program = pinentry-qt;
    };
    enableExtraSocket = true;
    enableScDaemon = true;
    enableSshSupport = true;
    verbose = false;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    grabKeyboardAndMouse = true;
    defaultCacheTtl = null;
    maxCacheTtl = null;
    defaultCacheTtlSsh = null;
    maxCacheTtlSsh = null;
    noAllowExternalCache = false;
   #sshKeys = [ ];
   #extraConfig = '' '';
  };

  home.packages = [ pkgs.gcr ];

};}
