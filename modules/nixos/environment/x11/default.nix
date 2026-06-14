{ config, lib, pkgs, admin, ... }:

let

  cfg = config.my.x11;

in

{

  options.my.x11.enable = lib.mkEnableOption "x11 settings";

  config = lib.mkIf cfg.enable {

    services.xserver.enable = true;

    services.xserver = {

      displayManager = {

        startx = {
          enable = true;
          generateScript = true;
         #extraCommands = '' '';
        };

      };

      updateDbusEnvironment = true;

      autoRepeatInterval = config.home-manager.users.${admin}.my.x11.xrate;
      autoRepeatDelay = config.home-manager.users.${admin}.my.x11.xdelay;

     #defaultDepth = 0; # Default colour depth. example 8

     #display = 0; # Display number for the X server.

      exportConfiguration = true;

     #excludePackages = [ pkgs.xterm ];

     #enableTearFree = false;

     #enableTCP = false;

     #enableCtrlAltBackspace = false; # to forcefully kill X.

     #dpi = ; # Int

     #config = lib.mkAfter '' '';

     #extraConfig = '' '';

     #extraDisplaySettings = " ";

     #filesSection = '' '';

     #fontPath = " ";

     #imwheel = {
     #  enable
     #  extraOptions
     #  rules
     #};

      inputClassSections = [

       # Example:
       #''
       #  Identifier      "Trackpoint Wheel Emulation"
       #  MatchProduct    "ThinkPad USB Keyboard with TrackPoint"
       #  Option          "EmulateWheel"          "true"
       #  Option          "EmulateWheelButton"    "2"
       #  Option          "Emulate3Buttons"       "false"
       #''

        ''
          Identifier      "system-keyboard"
          MatchIsKeyboard "on"
          Option          "AutoRepeat" "${toString config.services.xserver.autoRepeatDelay} ${toString config.services.xserver.autoRepeatInterval}"
        ''

      ];

     #logFile = "/dev/null";

    };

    environment.systemPackages = [

      pkgs.xsetroot

      pkgs.wayback-x11
     #pkgs.i3status             ##i3 status bar
     #pkgs.i3lock               ##i3 screenlock
     #pkgs.i3blocks             ##i3 blocks for status bar
     #pkgs.picom                ##i3/dwm main compositor
      pkgs.feh                  ##i3/dwm theming background
     #pkgs.dunst                ##i3/dwm notification daemon
     #pkgs.lxappearance         ##i3/dwm theming client

      (pkgs.dmenu.override {
        patches = [
          (pkgs.fetchurl {
            url = "https://tools.suckless.org/dmenu/patches/xresources/dmenu-xresources-4.9.diff";
            sha256 = "sha256-dbiE4myVnzlmdhEOteC3S97EOxy5QklQ8IzGQeb7Y9Y=";
          })
        ];
      })

      pkgs.rofi                 ##i3/dwm app launcher menu (alternative)
      pkgs.xclip                ## Clipboard_manager
     #pkgs.variety              ## Wallpaper_manager
     #pkgs.plank                ## Dock
      pkgs.networkmanagerapplet #Network manager applet for bar
      pkgs.playerctl
     #pkgs.upower

     #pkgs.xmenu

      (pkgs.callPackage ../../myPackages/xdg-xmenu.nix { })
     #(pkgs.callPackage ../../myPackages/xfiles.nix { })
      (pkgs.callPackage ../../myPackages/xclickroot.nix { })
      (pkgs.callPackage ../../myPackages/xwww.nix { })

    ];

    programs = {
      i3lock = {
        enable = true;
        u2fSupport = true;
        package = pkgs.i3lock-color; # pkgs.i3lock-fancy-rapid; # pkgs.i3lock;
      };
    };

    security.wrappers.xscreensaver-auth = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.xscreensaver}/libexec/xscreensaver/xscreensaver-auth";
    };

    security.wrappers.i3lock-color = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.i3lock-color}/bin/i3lock-color";
    };

    security.wrappers.betterlockscreen = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.betterlockscreen}/bin/betterlockscreen";
    };

  };

}
