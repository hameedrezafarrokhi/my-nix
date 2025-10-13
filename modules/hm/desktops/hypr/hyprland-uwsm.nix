{ config, pkgs, lib, ... }:

let


in

{ config = lib.mkIf (builtins.elem "hyprland-uwsm" config.my.rices-shells) {



};}
