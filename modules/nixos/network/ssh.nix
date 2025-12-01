{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (config.my.network.ssh.enable) {

  services.gnome.gcr-ssh-agent = {
    enable = true;
    package = pkgs.gcr_4;
  };

  services.sshd.enable = true;

  services.openssh = {
    enable = true;
    package = config.programs.ssh.package;
    openFirewall = true;
    startWhenNeeded = false;
    allowSFTP = true;
   #sftpServerExecutable = "internal-sftp";
   #sftpFlags = [ ];
    settings = {
      X11Forwarding = false;
      UsePAM = true;
      UseDns = false;
      StrictModes = true;
      PrintMotd = true;
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = true;
     #Macs = [ ];
     #KexAlgorithms = [ ];
      KbdInteractiveAuthentication = true;
      LogLevel = "INFO";
      GatewayPorts = "no";
     #AllowUsers = [ ];
     #AllowGroups = [ ];
     #DenyUsers = [ ];
     #DenyGroups = [ ];
     #Ciphers = [ ];
     #AuthorizedPrincipalsFile = "none";
    };
   #ports = [ 22 ];
   #moduliFile = "";
   #listenAddresses = [  # THIS IS AN EXAMPLE
   #  {
   #    addr = "192.168.3.1";
   #    port = 22;
   #  }
   #  {
   #    addr = "0.0.0.0";
   #    port = 64022;
   #  }
   #];
    knownHosts = {
      "yewk4an5.repo.borgbase.com" = {
       #hostNames = [ ‹name› ] ++ config.services.openssh.knownHosts.<name>.extraHostNames;
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMS3185JdDy7ffnr0nLWqVy8FaAQeVh1QYUSiNpW5ESq";
       #publicKeyFile = null;
       #extraHostNames = [ ];
       #certAuthority = false;
      };
    };
   #hostKeys = [ ];
   #extraConfig = '' '';
   #banner = null;
    authorizedKeysInHomedir = true;
   #authorizedKeysFiles = [ ];
   #authorizedKeysCommandUser = "nobody";
   #authorizedKeysCommand = "none";
  };

  programs.ssh = {
    package = pkgs.openssh;
    systemd-ssh-proxy = {
      enable = true;
    };
    pubkeyAcceptedKeyTypes = [
      "ssh-ed25519"
      "ssh-rsa"
    ];
    hostKeyAlgorithms = [
      "ssh-ed25519"
      "ssh-rsa"
    ];
   #startAgent = true;
    setXAuthLocation = true;
   #macs = [ ];
   #ciphers = [ ];
   #agentPKCS11Whitelist = "";
   #knownHostsFiles = [ ];
    knownHosts = {
      "yewk4an5.repo.borgbase.com" = {
       #hostNames = [ ‹name› ] ++ config.services.openssh.knownHosts.<name>.extraHostNames;
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMS3185JdDy7ffnr0nLWqVy8FaAQeVh1QYUSiNpW5ESq";
       #publicKeyFile = null;
       #extraHostNames = [ ];
       #certAuthority = false;
      };
    };
   #kexAlgorithms = [ ];
    forwardX11 = true;
   #extraConfig = '' '';
    enableAskPassword = config.services.xserver.enable;
    askPassword = lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass"; # seahorse or ksshaskpass or x11-ssh-askpass or lxqt.lxqt-openssh-askpass
    agentTimeout = null;
  };

  users.users.${admin}.openssh = {
    authorizedKeys = {
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMS3185JdDy7ffnr0nLWqVy8FaAQeVh1QYUSiNpW5ESq yewk4an5.repo.borgbase.com"
      ];
     #keyFiles = [ ];
    };
   #authorizedPrincipals = [ ];
  };

};}
