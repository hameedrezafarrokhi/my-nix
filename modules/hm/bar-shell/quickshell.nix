{ config, pkgs, lib, inputs, system, ... }:

let

  aetheris-shell = pkgs.callPackage ./qs-rices/aetheris-shell.nix { };
  aevum-shell = pkgs.callPackage ./qs-rices/aevum-shell.nix { };

in

{ config = lib.mkIf (builtins.elem "quickshell" config.my.bar-shell.shells) {

  programs.quickshell = {
    enable = true;
   #package = inputs.quickshell.packages.${system}.default;
   #package = lib.mkForce inputs.quickshell.packages.${system}.default; # pkgs.quickshell;
    package = pkgs.quickshell;
    systemd = {
      enable = lib.mkForce false;
      target = "hyprland-session.target"; # default: config.wayland.systemd.target (without quotes)
    };
    activeConfig = lib.mkForce "noctalia-shell";
  };

  home.packages = [
    aetheris-shell
    aevum-shell
  ];

};}
