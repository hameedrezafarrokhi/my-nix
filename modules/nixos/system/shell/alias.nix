{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (config.my.shell.alias.enable) {

  environment = {
    shells = [ pkgs.bash pkgs.fish pkgs.zsh ];
    shellAliases = config.home-manager.users.${admin}.home.shellAliases;
  };

};}
