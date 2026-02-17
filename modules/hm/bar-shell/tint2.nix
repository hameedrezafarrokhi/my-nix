{ config, pkgs, lib, mypkgs, inputs, ... }:

{ config = lib.mkIf (builtins.elem "tint2" config.my.bar-shell.shells) {

  programs.tint2 = {
    enable = true;
    package = mypkgs.stable.tint2;
   #extraConfig = '' '';
  };

};}
