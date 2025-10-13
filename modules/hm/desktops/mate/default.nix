{ config, pkgs, lib, ... }:

let

  cfg = config.my.mate;

in

{

  options.my.mate.enable = lib.mkEnableOption "mate";

  config = lib.mkIf cfg.enable {

    dconf.settings = {

     #"org/mate/desktop/accessibility/keyboard" = {
     #  bouncekeys-beep-reject = true;
     #  bouncekeys-delay = 300;
     #  bouncekeys-enable = false;
     #  enable = false;
     #  feature-state-change-beep = false;
     #  mousekeys-accel-time = 1200;
     #  mousekeys-enable = false;
     #  mousekeys-init-delay = 160;
     #  mousekeys-max-speed = 750;
     #  slowkeys-beep-accept = true;
     #  slowkeys-beep-press = true;
     #  slowkeys-beep-reject = false;
     #  slowkeys-delay = 300;
     #  slowkeys-enable = false;
     #  stickykeys-enable = false;
     #  stickykeys-latch-to-lock = true;
     #  stickykeys-modifier-beep = true;
     #  stickykeys-two-key-off = true;
     #  timeout = 120;
     #  timeout-enable = false;
     #  togglekeys-enable = false;
     #};

     #"org/mate/desktop/background" = {
     #  color-shading-type = "vertical-gradient";
     #  picture-filename = "";
     #  picture-options = "wallpaper";
     #  primary-color = "rgb(88,145,188)";
     #  secondary-color = "rgb(60,143,37)";
     #};

      "org/mate/marco/global-keybindings" = {
        panel-main-menu = "<Alt><Mod4>space";
        panel-run-dialog = "<Mod4>space";
        switch-to-workspace-1 = "<Mod4>1";
        switch-to-workspace-2 = "<Mod4>2";
        switch-to-workspace-3 = "<Mod4>3";
        switch-to-workspace-4 = "<Mod4>4";
      };

      "org/mate/desktop/peripherals/keyboard" = {
        numlock-state = "on";
      };

     #"org/mate/panel/general" = {
     #  history-mate-run = [ "kitty" ];
     #  object-id-list = [ "menu-bar" "notification-area" "clock" "show-desktop" "window-list" "workspace-switcher" ];
     #  toplevel-id-list = [ "top" "bottom" ];
     #};

     #"org/mate/panel/objects/clock" = {
     #  applet-iid = "ClockAppletFactory::ClockApplet";
     #  locked = true;
     #  object-type = "applet";
     #  panel-right-stick = true;
     #  position = 0;
     #  toplevel-id = "top";
     #};

     #"org/mate/panel/objects/menu-bar" = {
     #  locked = true;
     #  object-type = "menu-bar";
     #  position = 0;
     #  toplevel-id = "top";
     #};

     #"org/mate/panel/objects/notification-area" = {
     #  applet-iid = "NotificationAreaAppletFactory::NotificationArea";
     #  locked = true;
     #  object-type = "applet";
     #  panel-right-stick = true;
     #  position = 10;
     #  toplevel-id = "top";
     #};

     #"org/mate/panel/objects/show-desktop" = {
     #  applet-iid = "WnckletFactory::ShowDesktopApplet";
     #  locked = true;
     #  object-type = "applet";
     #  position = 0;
     #  toplevel-id = "bottom";
     #};

     #"org/mate/panel/objects/window-list" = {
     #  applet-iid = "WnckletFactory::WindowListApplet";
     #  locked = true;
     #  object-type = "applet";
     #  position = 20;
     #  toplevel-id = "bottom";
     #};

     #"org/mate/panel/objects/workspace-switcher" = {
     #  applet-iid = "WnckletFactory::WorkspaceSwitcherApplet";
     #  locked = true;
     #  object-type = "applet";
     #  panel-right-stick = true;
     #  position = 0;
     #  toplevel-id = "bottom";
     #};

     #"org/mate/panel/toplevels/bottom" = {
     #  expand = true;
     #  orientation = "bottom";
     #  screen = 0;
     #  size = 24;
     #  y = 743;
     #  y-bottom = 0;
     #};

     #"org/mate/panel/toplevels/top" = {
     #  expand = true;
     #  orientation = "top";
     #  screen = 0;
     #  size = 24;
     #};

     #"org/mate/search-tool" = {
     #  default-window-height = 357;
     #  default-window-maximized = false;
     #  default-window-width = 554;
     #  look-in-folder = "/home/hrf";
     #};

     #"org/mate/search-tool/select" = {
     #  contains-the-text = true;
     #};

     #"org/mate/settings-daemon/plugins/media-keys" = {
     #  search = "disabled";
     #};

     #"org/mate/system-monitor" = {
     #  current-tab = 2;
     #  maximized = false;
     #  window-state = mkTuple [ 700 563 50 50 ];
     #};

     #"org/mate/system-monitor/disktreenew" = {
     #  col-7-width = 300;
     #};

     #"org/mate/system-monitor/proctree" = {
     #  col-26-width = 133;
     #};



    };

  };

}
