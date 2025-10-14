{ inputs, config, pkgs, lib, ... }:

let


in

{ imports = [

   #inputs.ax-shell.homeManagerModules.default
    ./ax-exec.nix

  ];

  config = lib.mkIf (builtins.elem "hyprland-ax" config.my.rices-shells) {

 #nixpkgs.overlays = [ inputs.ax-shell.overlays.default ];

 #nixpkgs.overlays = [
 #  (final: prev:
 #    let
 #      hasAxSend = inputs.ax-shell.packages ? ${prev.system} && inputs.ax-shell.packages.${prev.system} ? inputs.ax-send;
 #    in
 #    if hasAxSend then inputs.ax-shell.overlays.default else (final_: prev_: {}))
 #];


#nixpkgs.overlays = [
#  (final: prev:
#    let
#      sys = prev.system;
#    in
#      inputs.ax-shell.packages.${sys} or {}
#  )
#];


  programs.ax-shell = {
    enable = true;
  # package = pkgs.ax-shell;
  #
  # configDir = "${config.xdg.configHome}/ax-shell";
  #
  # currentWallpaperPath = "/home/hrf/Pictures/Wallpapers/1background.png";
  ##faceIconPath = ;
  # hyprlandColorsConfPath = "/nix/store/3wq3w61g2vzcz7f9xb0qz03s4ll060k5-catppuccin-hyprland-0-unstable-2024-06-19/macchiato.conf";
  #
  # autostart = {
  #   enable = false;
  #   logPath = "${config.xdg.stateHome}/ax-shell/main.log";
  # };
  #
  ##matugen = {
  ##  settings = { };
  ##  extraSettings = { };
  ##};
  #
  #
  # settings = {
  #   # --- General ---
  #   terminalCommand = "kitty -e";
  #   wallpapersDir = "${config.home.homeDirectory}/Pictures/Wallpapers";
  #
  #   cornersVisible = true;
  #   datetime12hFormat = false;
  #
  #   dashboard = {
  #     components = {
  #       widgets = true;
  #       pins = true;
  #       kanban = true;
  #       wallpapers = true;
  #       mixer = true;
	 #};
  #   };
  #
  #
  #   # --- Cursor ---
  #  #cursor = {
  #  #  package = pkgs.oreo-cursors-plus;
  #  #  name = "oreo_black_cursors";
  #  #  size = 24;
  #  #};
  #
  #   # --- Bar & Dock ---
  #   bar = {
  #     position = "Top"; # "Top", "Bottom", "Left", "Right"
  #     theme = "Pills";  # "Pills", "Dense", "Edge"
  #     centered = true;
  #     workspace = {
  #       showNumber = true;
  #       useChineseNumerals = false;
  #       hideSpecial = true;
  #     };
  #     metrics.disks = [ "/" ];
  #     components = {
  #       button_apps = true;
  #       systray = true;
  #       control = true;
  #       network = true;
  #       button_tools = true;
  #       sysprofiles = true;
  #       button_overview = true;
  #       ws_container = true;
  #       battery = true;
  #       metrics = true;
  #       language = true;
  #       date_time = true;
  #       button_power = true;
  #     };
  #   };
  #
  #   dock = {
  #     enable = true; # Disable the dock
  #     alwaysOccluded = false;
  #     iconSize = 28;
  #     theme = "Pills";
  #   };
  #
  #   panel = {
  #     theme = "Notch"; # "Notch", "Panel"
  #     position = "Center";
  #   };
  #
  #   notifications = {
  #     position = "Top";
  #     limitedAppsHistory = [ "Spotify" ];
  #     historyIgnoredApps = [ "Hyprshot" ];
  #   };
  #
  #   metrics = {
  #     main = {
  #       cpu = true;
  #       ram = true;
  #       disk = true;
  #       gpu = true;
  #     };
  #     small = {
  #       cpu = true;
  #       ram = true;
  #       disk = true;
  #       gpu = true;
  #     };
  #   };
  #
  #   defaultFaceIcon = "${config.programs.ax-shell.package}/share/ax-shell/assets/default.png";
  #
  #
  #   # --- Keybindings ---
  #   keybindings = {   # ADD to Hypr Manually
  #     launcher = { prefix = "SUPER"; suffix = "SPACE"; };
  #     restart = { prefix = "SUPER ALT"; suffix = "B"; };
  #     axmsg = { prefix = "SUPER"; suffix = "A"; };
  #     dash = { prefix = "SUPER"; suffix = "D"; };
  #     bluetooth = { prefix = "SUPER"; suffix = "B"; };
  #     pins = { prefix = "SUPER"; suffix = "Q"; };
  #     kanban = { prefix = "SUPER"; suffix = "N"; };
  #    #launcher = { prefix = "SUPER"; suffix = "R"; };
  #     tmux = { prefix = "SUPER"; suffix = "T"; };
  #     cliphist = { prefix = "SUPER"; suffix = "V"; };
  #     toolbox = { prefix = "SUPER"; suffix = "S"; };
  #     overview = { prefix = "SUPER"; suffix = "TAB"; };
  #     wallpapers = { prefix = "SUPER"; suffix = "COMMA"; };
  #     randwall = { prefix = "SUPER SHIFT"; suffix = "COMMA"; };
  #     mixer = { prefix = "SUPER"; suffix = "M"; };
  #     emoji = { prefix = "SUPER"; suffix = "PERIOD"; };
  #     power = { prefix = "SUPER"; suffix = "ESCAPE"; };
  #     caffeine = { prefix = "SUPER SHIFT"; suffix = "M"; };
  #     restart_inspector = { prefix = "SUPER CTRL ALT"; suffix = "B"; };
  #   };
  #
  #  #hyprlandBinds = [ ];
  #  #hyprlandExecOnce = [ ];
  #
  # };

  };

 #home.packages = [ pkgs.ax-send ];

};}
