{ config, pkgs, lib, nix-path, ... }:

{ config = lib.mkIf (builtins.elem "nu" config.my.shells) {

  home.packages = [ ];

  programs.nushell = {
    enable = true;
    package = pkgs.nushell;
    plugins = [ ];

    settings = {
      show_banner = false;
    };

   #shellAliases = { };

   #configDir = ;
   #configFile = {
   #  source = ;
   #  text = '' '';
   #};
   #extraConfig = '' '';

   #environmentVariables = { };
   #envFile = {
   #  source = ;
   #  text = '' '';
   #};
   #extraEnv = '' '';

   #loginFile = {
   #  source = ;
   #  text = '' '';
   #};
   #extraLogin = '' '';

  };

};}
