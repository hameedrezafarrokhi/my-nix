{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.mcwm;
  mcwm = pkgs.callPackage ./mcwm.nix {
    conf = ''
      /* User configurable stuff. */

      /*
       * Move this many pixels when moving or resizing with keyboard unless
       * the window has hints saying otherwise.
       */
      #define MOVE_STEP 10

      /*
       * Use this modifier combined with other keys to control wm from
       * keyboard. Default is Mod4, which on my keyboard is the Alt key but
       * is usually the Windows key on more normal keyboard layouts.
       */
      #define MODKEY XCB_MOD_MASK_4

      /* Extra modifier for resizing. Default is Shift. */
      #define SHIFTMOD XCB_MOD_MASK_SHIFT

      /*
       * Modifier key to use with mouse buttons. Default Mod1, Meta on my
       * keyboard.
       */
      #define MOUSEMODKEY XCB_MOD_MASK_4

      /*
       * Start this program when pressing MODKEY + USERKEY_TERMINAL. Needs
       * to be in $PATH.
       *
       * Change to "xterm" if you're feeling conservative.
       *
       * Can be set from command line with "-t program".
       */
      #define TERMINAL "${config.my.default.terminal}"

      /*
       * Do we allow windows to be iconified? Set to true if you want this
       * behaviour to be default. Can also be set by calling mcwm with -i.
       */
      #define ALLOWICONS true

      /*
       * Start these programs when pressing MOUSEMODKEY and mouse buttons on
       * root window.
       */
      #define MOUSE1 ""
      #define MOUSE2 ""
      #define MOUSE3 "mcmenu"

      /*
       * Default colour on border for focused windows. Can be set from
       * command line with "-f colour".
       */
      #define FOCUSCOL "cyan"

      /* Ditto for unfocused. Use "-u colour". */
      #define UNFOCUSCOL "grey40"

      /* Ditto for fixed windows. Use "-x colour". */
      #define FIXEDCOL "red"

      /* Default width of border window, in pixels. Used unless -b width. */
      #define BORDERWIDTH 4

      /* Default snap margin in pixels. Used unless -s width. */
      #define SNAPMARGIN 0

      /*
       * Keysym codes for window operations. Look in X11/keysymdefs.h for
       * actual symbols. Use XK_VoidSymbol to disable a function.
       */
      #define USERKEY_FIX 		XK_grave
      #define USERKEY_MOVE_LEFT 	XK_Left
      #define USERKEY_MOVE_DOWN 	XK_Down
      #define USERKEY_MOVE_UP 	XK_Up
      #define USERKEY_MOVE_RIGHT 	XK_Right
      #define USERKEY_MAXVERT 	XK_V
      #define USERKEY_RAISE 		XK_S
      #define USERKEY_TERMINAL 	XK_T
      #define USERKEY_MAX 		XK_Return
      #define USERKEY_CHANGE 		XK_Tab
      #define USERKEY_BACKCHANGE	XK_VoidSymbol
      #define USERKEY_WS1		XK_1
      #define USERKEY_WS2		XK_2
      #define USERKEY_WS3		XK_3
      #define USERKEY_WS4		XK_4
      #define USERKEY_WS5		XK_5
      #define USERKEY_WS6		XK_6
      #define USERKEY_WS7		XK_7
      #define USERKEY_WS8		XK_8
      #define USERKEY_WS9		XK_9
      #define USERKEY_WS10		XK_0
      #define USERKEY_PREVWS          XK_bracketleft
      #define USERKEY_NEXTWS          XK_bracketright
      #define USERKEY_TOPLEFT         XK_H
      #define USERKEY_TOPRIGHT        XK_L
      #define USERKEY_BOTLEFT         XK_J
      #define USERKEY_BOTRIGHT        XK_K
      #define USERKEY_DELETE          XK_C
      #define USERKEY_PREVSCREEN      XK_comma
      #define USERKEY_NEXTSCREEN      XK_period
      #define USERKEY_ICONIFY         XK_D
    '';



  };

in

{

  options = {
    services.xserver.windowManager.mcwm = {
      enable = mkEnableOption "mcwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before mcwm is started.
        '';
      };
      package = mkPackageOption pkgs "mcwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "mcwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "mcwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${mcwm}/bin/mcwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.mcwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = mcwm;
    };

  };

}
