{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "nu" config.my.shell.shells) {

  environment.systemPackages = [ pkgs.nushell ];

};}
