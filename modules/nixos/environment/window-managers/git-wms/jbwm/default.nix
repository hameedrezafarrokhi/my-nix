{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.jbwm;
  jbwm = pkgs.callPackage ./jbwm.nix {
   #conf = ''
   #  // jbwm - Minimalist Window Manager for X
   #  // Copyright 2008-2020, Alisa Bedard <alisabedard@gmail.com>
   #  // Copyright 1999-2015, Ciaran Anscomb <evilwm@6809.org.uk>
   #  // See README for license and other details.
   #  #ifndef JBWM_CONFIG_H
   #  #define JBWM_CONFIG_H
   #  #include <X11/X.h> // for keymasks
   #  /* Note:  Also, adjust the values in JBWMDefaults.h as necessary.  */
   #  #define JBWM_TERM "${config.my.default.terminal}"
   #  /* Default fonts */
   #  #ifdef JBWM_USE_XFT
   #  #define JBWM_FONT "Sans:size=9:aspect=1.2"
   #  #else//!JBWM_USE_XFT
   #  #define JBWM_FONT "fixed"
   #  #endif//JBWM_USE_XFT
   #  /* Default colors */
   #  #ifndef USE_OLD_THEME
   #  //#define JBWM_FG "#bbf"
   #  #define JBWM_FG "white"
   #  #define JBWM_FC "green1"
   #  #define JBWM_BG "black"
   #  #define JBWM_CLOSE "red"
   #  #define JBWM_RESIZE "blue"
   #  #define JBWM_SHADE "#yellow"
   #  #define JBWM_STICK "#magenta"
   #  #define JBWM_NAME "jbwm"
   #  #else//USE_OLD_THEME
   #  #define JBWM_FG "#bad0ff"
   #  #define JBWM_FC "#00ff2f"
   #  #define JBWM_BG "#3b4352"
   #  #define JBWM_CLOSE "#ff2600"
   #  #define JBWM_RESIZE "#00a1ff"
   #  #define JBWM_SHADE "#ffe200"
   #  #define JBWM_STICK "#5bf662"
   #  #define JBWM_NAME "jbwm"
   #  #endif//!USE_OLD_THEME
   #  /* Compile-time defaults of an integer type shall be stored here.  */
   #  enum {
   #    JBWM_KEYMASK_GRAB = Mod1Mask | ControlMask,
   #    JBWM_KEYMASK_MOD = ShiftMask,
   #    JBWM_SNAP = 10,
   #    JBWM_RESIZE_INCREMENT = 20,
   #    JBWM_NUMBER_OF_DESKTOPS = 255
   #  };
   #  #endif//JBWM_CONFIG_H
   #'';

    keys = ''
      // Copyright 2020, Alisa Bedard
      #ifndef JBWM_JBWMKEYS_H
      #define JBWM_JBWMKEYS_H
      #include <X11/keysym.h>
      enum JBWMKeys {
        JBWM_KEY_0 = XK_0,
        JBWM_KEY_1 = XK_1,
        JBWM_KEY_2 = XK_2,
        JBWM_KEY_3 = XK_3,
        JBWM_KEY_4 = XK_4,
        JBWM_KEY_5 = XK_5,
        JBWM_KEY_6 = XK_6,
        JBWM_KEY_7 = XK_7,
        JBWM_KEY_8 = XK_8,
        JBWM_KEY_9 = XK_9,
        JBWM_KEY_KILL = XK_c,
        JBWM_KEY_ALTLOWER = XK_minus,
        JBWM_KEY_VDESK_NEXT_ROW = XK_Page_Up,
        JBWM_KEY_VDESK_PREV_ROW = XK_Page_Down,
        JBWM_KEY_DOWN = XK_j,
        JBWM_KEY_DOWN_UP = XK_J,
        JBWM_KEY_FS = XK_a,
        JBWM_KEY_INFO = XK_F5,
        JBWM_KEY_LEFT = XK_h,
        JBWM_KEY_LEFT_UP = XK_H,
        JBWM_KEY_LOWER = XK_Down,
        JBWM_KEY_MAX = XK_Return,
        JBWM_KEY_MAX_H = XK_g,
        JBWM_KEY_MAX_V = XK_G,
        JBWM_KEY_MOVE = XK_m,
        JBWM_KEY_NEW = XK_space,
        JBWM_KEY_NEXT = XK_Tab,
        JBWM_KEY_NEXTDESK = XK_Right,
        JBWM_KEY_PREVDESK = XK_Left,
        JBWM_KEY_QUIT = XK_Escape,
        JBWM_KEY_RAISE = XK_Up,
        JBWM_KEY_RIGHT = XK_l,
        JBWM_KEY_RIGHT_UP = XK_L,
        JBWM_KEY_SHADE = XK_d,
        JBWM_KEY_STICK = XK_grave,
        JBWM_KEY_UP = XK_k,
        JBWM_KEY_UP_UP = XK_K,
      };
      #include "key_combos.h"
      #endif//!JBWM_JBWMKEYS_H
    '';

   #client = ''
   #  // Copyright 2020, Alisa Bedard <alisabedard@gmail.com>
   #  #ifndef JBWM_JBWMCLIENTOPTIONS_H
   #  #define JBWM_JBWMCLIENTOPTIONS_H
   #  #include <stdbool.h>
   #  #include <stdint.h>
   #  struct JBWMClientOptions {
   #    uint8_t border : 8;
   #    bool fullscreen : 1;
   #    bool max_horz : 1;
   #    bool max_vert : 1;
   #    bool no_close : 1;
   #    bool no_max : 1;
   #    bool no_shade : 1;
   #    bool no_move : 1;
   #    bool no_resize : 1;
   #    bool no_title_bar : 1;
   #    bool remove : 1;
   #    bool shaded : 1;
   #    bool shaped : 1;
   #    bool sticky : 1;
   #    bool tearoff : 1;
   #  };
   #  #endif//!JBWM_JBWMCLIENTOPTIONS_H
   #'';

   #titlebar = ''
   #  // Copyright 2020, Alisa Bedard
   #  #ifndef JBWM_JBWMCLIENTTITLEBAR_H
   #  #define JBWM_JBWMCLIENTTITLEBAR_H
   #  #include <X11/X.h>
   #  struct JBWMClientTitleBar {
   #    Window win, close, resize, shade, stick;
   #  };
   #  #endif//!JBWM_JBWMCLIENTTITLEBAR_H
   #'';
  };

in

{

  options = {
    services.xserver.windowManager.jbwm = {
      enable = mkEnableOption "jbwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before jbwm is started.
        '';
      };
      package = mkPackageOption pkgs "jbwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "jbwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "jbwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        #${jbwm}/bin/jbwm -1 mod4 -2 mod1 &
        ${jbwm}/bin/jbwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    environment.sessionVariables = {
      "JBWM_FC" = "red";
      "JBWM_FG" = "white";
      "JBWM_BG" = "black";
      "JBWM_CLOSE" = "red";
      "JBWM_SHADE" = "green";
      "JBWM_Resize" = "Yellow";
      "JBWM_FONT" = "Comic Sans MS, 10";
      "JBWM_TERM" = "${config.my.default.terminal}";
    };

    services.xserver.windowManager.jbwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = jbwm;
    };

  };

}
