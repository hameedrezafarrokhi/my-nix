{ pkgs, lib, config, inputs, ...}:

{ config = lib.mkIf (builtins.elem "ags" config.my.bar-shell.shells) {

  home.packages = [

  ];

};}
