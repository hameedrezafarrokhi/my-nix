{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.catwm-ahmadinne;
  catwm-ahmadinne = pkgs.callPackage ./catwm-ahmadinne.nix {
    conf = ''

      #ifndef CONFIG_H
      #define CONFIG_H

      #define MOD             Mod4Mask
      #define MASTER_SIZE     0.5
      #define PANEL_HEIGHT    20
      #define BORDER_WIDTH    4
      #define ATTACH_ASIDE    0 /* 0=TRUE, 1=New window is master */
      #define DEFAULT_MODE    2 /* 0 = Horizontal, 1 = Fullscreen, 2 = Vertical */
      #define SMART_BORDER	0 /* 0=TRUE, 1=FALSE */
      #define WINDOW_GAPS     6

      // Colors
      #define FOCUS           "#1f1f28"
      #define UNFOCUS         "#f2ecbc"
      #define FULLSCREEN	"#c84053"

      const char* dmenucmd[] = {"rofi","-show","drun","-theme",".config/rofi/themes/main.rasi",NULL};
      const char* urxvtcmd[] = {"${config.my.default.terminal}",NULL};
      const char* lockcmd[]  = {"x-lock",NULL};
      const char* next[]     = {"playerctl","next",NULL};
      const char* prev[]     = {"playerctl","previous",NULL};
      const char* toggle[]   = {"ncmpcpp","play-pause",NULL };
      const char* voldown[]  = {"pamixer","-ud","5",NULL};
      const char* volup[]    = {"pamixer","-ui","5",NULL};
      const char* brsrcmd[]  = {"${config.my.default.browser-alt-name}",NULL};
      const char* filecmd[]  = {"${config.my.default.file-alt}",NULL};
      const char* hintcmd[]  = {"hints",NULL};
      const char* clipcmd[]  = {"copyq","menu",NULL};

      // for reboot and shutdown
      const char* rebootcmd[]     = {"sudo","reboot",NULL};
      const char* shutdowncmd[]   = {"sudo","shutdown","-h","now",NULL};

      // Avoid multiple paste
      #define DESKTOPCHANGE(K,N) \
          {  MOD,                K,                         change_desktop, {.i = N}}, \
          {  MOD|ShiftMask,      K,                         client_to_desktop, {.i = N}},
      // Shortcuts
      static struct key keys[] = {
          // MOD                  KEY                         FUNCTION           ARGS
          {  MOD|ShiftMask,      XK_Up,                      increase,          {NULL}},
          {  MOD|ShiftMask,      XK_Down,                    decrease,          {NULL}},
          {  MOD,                XK_c,                       kill_client,       {NULL}},
          {  MOD,                XK_Right,                   next_win,          {NULL}},
          {  MOD,                XK_Tab,                     next_win,          {NULL}},
          {  Mod1Mask|ShiftMask, XK_Tab,                     prev_win,          {NULL}},
          {  MOD,                XK_k,                       prev_win,          {NULL}},
          {  Mod1Mask|ShiftMask, XK_l,                       spawn,             {.com = lockcmd}},
          {  0,                  XF86XK_AudioNext,           spawn,             {.com = next}},
          {  0,                  XF86XK_AudioPrev,           spawn,             {.com = prev}},
          {  0,                  XF86XK_AudioPlay,           spawn,             {.com = toggle}},
          {  0,                  XF86XK_AudioLowerVolume,    spawn,             {.com = voldown}},
          {  0,                  XF86XK_AudioRaiseVolume,    spawn,             {.com = volup}},
          {  MOD,                XK_space,                   spawn,             {.com = dmenucmd}},
          {  MOD,                XK_b,                       spawn,             {.com = brsrcmd}},
          {  MOD,                XK_e,                       spawn,             {.com = filecmd}},
          {  MOD|ShiftMask,	   XK_Return,                  spawn,             {.com = urxvtcmd}},
          {  MOD,		         XK_v,			       spawn,	        {.com = clipcmd}},
          {  MOD,		         XK_semicolon,		       spawn,	        {.com = hintcmd}},
      // Others
          {  MOD,                XK_Up,                      move_up,           {NULL}},
          {  MOD,                XK_Down,                    move_down,         {NULL}},
          {  MOD|ShiftMask,      XK_s,                       swap_master,       {NULL}},
          {  MOD,   		   XK_s,                       focus_master,      {NULL}},
          {  MOD,   		   XK_Return,                  toggle_fullscreen, {NULL}},
          {  MOD|ControlMask,    XK_1,                       switch_vertical,   {NULL}},
          {  MOD|ControlMask,    XK_2,                       switch_horizontal, {NULL}},
          {  Mod1Mask|ShiftMask, XK_e,                       catkill,           {NULL}},
      //    {  MOD|ControlMask,   XK_r,                       spawn,          {.com = rebootcmd}},
      //    {  MOD|ControlMask,   XK_s,                       spawn,          {.com = shutdowncmd}},
             DESKTOPCHANGE(      XK_1,                                       0)
             DESKTOPCHANGE(      XK_2,                                       1)
             DESKTOPCHANGE(      XK_3,                                       2)
             DESKTOPCHANGE(      XK_4,                                       3)
             DESKTOPCHANGE(      XK_5,                                       4)
             DESKTOPCHANGE(      XK_6,                                       5)
             DESKTOPCHANGE(      XK_7,                                       6)
             DESKTOPCHANGE(      XK_8,                                       7)
             DESKTOPCHANGE(      XK_9,                                       8)
             DESKTOPCHANGE(      XK_0,                                       9)
      };

      #endif

    '';
  };

in

{

  options = {
    services.xserver.windowManager.catwm-ahmadinne = {
      enable = mkEnableOption "catwm-ahmadinne";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before catwm-ahmadinne is started.
        '';
      };
      package = mkPackageOption pkgs "catwm-ahmadinne" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "catwm-ahmadinne" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "catwm-ahmadinne";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${catwm-ahmadinne}/bin/catwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      cfg.package
      pkgs.dzen2
    ];

    services.xserver.windowManager.catwm-ahmadinne = {
      enable = true;
      extraSessionCommands = '' '';
      package = catwm-ahmadinne;
    };

  };

}
