{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "dash" config.my.shell.shells) {

  environment.systemPackages = [ pkgs.dash ];

};}
