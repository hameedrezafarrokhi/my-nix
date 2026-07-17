{ config, pkgs, lib, mypkgs, nix-path, ... }:

{ config = lib.mkIf (builtins.elem "dash" config.my.shells) {

  home.packages = [ pkgs.dash ];

};}
