{ config, pkgs, lib, ... }:

let

  btop-app = pkgs.writeShellScriptBin "btop-app" ''
    kitty --name btop-app --class btop-app sh -c 'btop'
  '';

in

{ config = lib.mkIf (config.my.apps.btop.enable) {

  programs.btop = {
    enable = true;
    package = pkgs.btop;
   #settings = {};
   #extraConfig = '' '';
   #themes = {};
  };

  home.packages = [
    btop-app
  ];

};}
