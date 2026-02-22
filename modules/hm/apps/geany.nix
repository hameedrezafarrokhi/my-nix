{ config, pkgs, lib, ... }:

let

  geany-plugs = pkgs.callPackage ../../nixos/myPackages/geany-plugins.nix { enableAllPlugins = true; };

in

{ config = lib.mkIf (config.my.apps.geany.enable) {

  home.packages = [
    geany-plugs
    pkgs.geany-with-vte
    pkgs.bash-language-server
  ];

  xdg.configFile = {
    geany-plugins = {
      source = "${geany-plugs}/lib/geany/geany";
      target = "geany/plugin-packages";
      recursive = true;
    };
  };

};}
