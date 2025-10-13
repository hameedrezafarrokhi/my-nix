{ config, lib, pkgs, mypkgs, admin, ... }:

{

  nix = {
    extraOptions = ''experimental-features = nix-command flakes'';
    package = pkgs.nix;
   #nixPath = [ ];
   #registry = { };
   #substituters = [ ];
   #trustedPublicKeys = [ ];
  };

# nixpkgs = {      # Declared In Flake! (only for non-flake systems)
#   config = {
#     allowUnfree=true;
#   };
#  #overlays = { };
# };

  time.timeZone = "Asia/Tehran";

  environment.packages = with pkgs; [
    nano
    neovim
    nh
    git
    yazi
    vim
  ];

  environment = {
    motd = "Hello, Smile pls :^)";
    etcBackupExtension = ".bak";
   #binSh = "/path/to/bin/sh";
   #usrBinEnv = "/path/to/usr/bin/env";
   #etc = { };
   #sessionVariables = { };
   #extraOutputsToInstall = [ ];
  };

  android-integration = {
    am.enable = true;
    termux-open.enable = true;
    termux-open-url.enable = true;
    termux-reload-settings.enable = true;
    termux-setup-storage.enable = true;
    termux-wake-lock.enable = true;
    termux-wake-unlock.enable = true;
    unsupported.enable = true;
    xdg-open.enable = true;
  };

  build = {
    activation = { };
    activationAfter = { };
    activationBefore = { };
    extraProotOptions = [ ];
  };

  networking = {
   #hosts = {     # example
   #  "127.0.0.1" = [ "foo.bar.baz" ];
   #  "192.168.0.2" = [ "fileserver.local" "nameserver.local" ];
   #};
   #extraHosts = "";
   #hostFiles = [  ];
  };

# user = {                    # Is Set By Nix-On-Droid Automatically
#  #userName = admin;
#   gid = "$(id -g)";
#   uid = "$(id -u)";
#   group = "nix-on-droid";
#  #home = /path/to/home/directory;
#  #shell = ${pkgs.bashInteractive}/bin/bash;
# };

  home-manager = {

    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    config = {
     #imports = [ ./hm ];
      home = {
       #username = admin;
       #homeDirectory = "/home/${admin}";
      };
    };
  };

  terminal = {
    font = "${pkgs.terminus_font_ttf}/share/fonts/truetype/TerminusTTF.ttf";
    colors = {
      background = "#1D2231";
      foreground = "#FFFFFF";
      cursor     = "#F4DBD6";
      color0     = "#494D64";
      color1     = "#ED8796";
      color2     = "#A6DA95";
      color3     = "#EED49F";
      color4     = "#8AADF4";
      color5     = "#F5BDE6";
      color6     = "#8BD5CA";
      color7     = "#B8C0E0";
      color8     = "#5B6078";
      color9     = "#ED8796";
      color10    = "#A6DA95";
      color11    = "#EED49F";
      color12    = "#8AADF4";
      color13    = "#F5BDE6";
      color14    = "#8BD5CA";
      color15    = "#B8C0E0";
    };
  };

}
