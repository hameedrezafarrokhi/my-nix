{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "mango" config.my.window-managers) {

  programs.mango = {
    enable = true;
   #package = self.packages.${pkgs.system}.mango;
  };

};}
