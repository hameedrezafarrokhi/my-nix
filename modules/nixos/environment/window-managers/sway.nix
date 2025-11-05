{ config, pkgs, lib, admin, ... }:

let

  swayfx-conf = toString ../../../hm/desktops/sway/config;
  swayfx-package = pkgs.swayfx.override {
    isNixOS = false;
    enableXWayland = true;
    extraSessionCommands = config.home-manager.users.${admin}.wayland.windowManager.sway.extraSessionCommands;
    extraOptions = config.home-manager.users.${admin}.wayland.windowManager.sway.extraOptions;
    withBaseWrapper = true;
    withGtkWrapper = true;
  };

  SwayFx = pkgs.writeShellScriptBin "SwayFx" ''
    XDG_CURRENT_DESKTOP=sway ${swayfx-package}/bin/sway --config ${swayfx-conf} --unsupported-gpu
  '';

in

{ config = lib.mkIf (builtins.elem "sway" config.my.window-managers) {

  programs.sway = {
    enable = true;
    package = pkgs.sway;
    xwayland.enable = true;
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
    extraPackages = with pkgs; [
      brightnessctl
      foot
      grim
      pulseaudio
      swayidle
      swaylock
      wmenu
    ];
    extraOptions = config.home-manager.users.${admin}.wayland.windowManager.sway.extraOptions;
   #extraSessionCommands = '' '';
  };

  services.displayManager.sessionPackages = [
    (pkgs.writeTextFile {
      name = "SwayFx";
      text = ''
        [Desktop Entry]
        Name=SwayFx
        Comment=SwayFx
        Exec=${SwayFx}/bin/SwayFx
        TryExec=${SwayFx}/bin/SwayFx
        Type=Application
        DesktopNames=sway
      '';
      destination = "/share/wayland-sessions/SwayFx.desktop";
    } // { providedSessions = [ "SwayFx" ]; })
  ];

 #programs.uwsm = {
 #  enable = true;
 #  waylandCompositors = {
 #    SwayFx = {
 #      prettyName = "SwayFx";
 #      comment = "Sway but with eye candy (UWSM)";
 #      binPath = "${SwayFx}/bin/SwayFx";
 #    };
 #  };
 #};

  environment.systemPackages = [ SwayFx ];

};}
