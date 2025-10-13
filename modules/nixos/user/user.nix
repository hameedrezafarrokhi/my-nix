{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.user.enable) {

  users = {
    mutableUsers = true;                       # passwd to change pass
    allowNoPasswordLogin = false;
    defaultUserHome = "/home";
    defaultUserShell = pkgs.${config.my.shell.default};
    motd = "            Hello, Smile pls :)";
   #motdFile = "";

   #groups = {};                               # groups to add like "hackers" "students"...
   #extraGroups = {};                          # same as above
   #extraUsers = {}; # same as users

  };

  services.accounts-daemon.enable = true;

};}
