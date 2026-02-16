{ config, pkgs, lib, inputs, system, ... }:

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

};}
