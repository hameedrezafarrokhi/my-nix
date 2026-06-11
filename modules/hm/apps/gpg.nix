{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.gpg.enable) {


  sshAuthSock = {
    enable = true;
    systemd.socketProviderUnit = lib.mkForce "gpg-agent-ssh.socket";
    initialization = {
      bash = lib.mkForce ''
        unset SSH_AGENT_PID
        if [ "''${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
          export SSH_AUTH_SOCK="$(${config.programs.gpg.package}/bin/gpgconf --list-dirs agent-ssh-socket)"
        fi
      '';
      fish = lib.mkForce ''
        set -e SSH_AGENT_PID

        begin
          set -l gnupg_val 0
          if set -q gnupg_SSH_AUTH_SOCK_by
            set gnupg_val $gnupg_SSH_AUTH_SOCK_by
          end

          if test $gnupg_val -ne %self
            set -x SSH_AUTH_SOCK (${config.programs.gpg.package}/bin/gpgconf --list-dirs agent-ssh-socket)
          end
        end
      '';
      nushell = lib.mkForce ''
        $env.SSH_AUTH_SOCK = $"(${config.programs.gpg.package}/bin/gpgconf --list-dirs agent-ssh-socket)"
      '';
    };
  };

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
