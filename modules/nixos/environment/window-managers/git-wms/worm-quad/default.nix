{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.worm-quad;
  worm-quad = pkgs.callPackage ./worm-quad.nix {
    conf = ''
 /* config.h for worm.c */

#ifndef CONFIG_H
#define CONFIG_H

#define DESKTOPS        10  /* Must edit DESKTOPCHANGE keys to suit */
#define MOD4            Mod4Mask  /* windows key */
#define MOD1            Mod1Mask  /* alt key */
#define OUTPUT_INFO     0  /* 0=Don't 1=Output info (for bipolarbar) */
#define PANEL_HEIGHT    30
#define SHOW_PANEL      0  /* 0=Don't 1=Have the panel shown at startup */
#define BORDER_WIDTH    3
#define SPLIT_LIMIT     250 /* minimum distance from the edge the split point can be */

/* Colors */
#define FOCUS           "#664422" // dkorange
#define UNFOCUS         "#004050" // blueish
#define SWAP_COLOUR     "#CF420A" // red/orangeish

const char* dmenucmd[]         = {"dmenu_run","-i","-nb","#664422","-nf","white",NULL};
const char* terminalcmd[]      = {"alacritty",NULL};
const char* browsercmd[]       = {"firefox",NULL};

#define DESKTOPCHANGE(K,N) \
    {  MOD4,             K,        change_desktop, {.i = N}}, \
    {  MOD4|ShiftMask,   K,        move_to_desktop, {.i = N}},

static key keys[] = {
    /* MOD               KEY            FUNCTION           ARGS */
    /* Window Management */
    {  MOD4,             XK_Left,       rotate_win_hor,    {.i = -1}},
    {  MOD4,             XK_Right,      rotate_win_hor,    {.i = 1}},
    {  MOD4,             XK_Up,         rotate_win_ver,    {.i = -1}},
    {  MOD4,             XK_Down,       rotate_win_ver,    {.i = 1}},
    {  MOD4,             XK_f,          toggle_fullscreen, {NULL}},
    {  MOD4|ShiftMask,   XK_Left,       move_swap_hor,     {.i = -1}},
    {  MOD4|ShiftMask,   XK_Right,      move_swap_hor,     {.i = 1}},
    {  MOD4|ShiftMask,   XK_Up,         move_swap_ver,     {.i = -1}},
    {  MOD4|ShiftMask,   XK_Down,       move_swap_ver,     {.i = 1}},
    {  MOD4|ShiftMask,   XK_Return,     perform_swap,      {NULL}},
    {  MOD4|MOD1,        XK_Left,       move_split_hor,    {.i = -10}},
    {  MOD4|MOD1,        XK_Right,      move_split_hor,    {.i = 10}},
    {  MOD4|MOD1,        XK_Up,         move_split_ver,    {.i = -10}},
    {  MOD4|MOD1,        XK_Down,       move_split_ver,    {.i = 10}},
    {  MOD4|MOD1,        XK_Return,     center_split,      {NULL}},

    /* Desktop Management */
    {  MOD1,             XK_Right,      rotate_desktop,    {.i = 1}},
    {  MOD1,             XK_Left,       rotate_desktop,    {.i = -1}},
    {  MOD1,             XK_Tab,        last_desktop,      {NULL}},
    {  MOD1,             XK_Up,         toggle_panel,      {NULL}},
       DESKTOPCHANGE(    XK_1,                             0)
       DESKTOPCHANGE(    XK_2,                             1)
       DESKTOPCHANGE(    XK_3,                             2)
       DESKTOPCHANGE(    XK_4,                             3)
       DESKTOPCHANGE(    XK_5,                             4)
       DESKTOPCHANGE(    XK_6,                             5)
       DESKTOPCHANGE(    XK_7,                             6)
       DESKTOPCHANGE(    XK_8,                             7)
       DESKTOPCHANGE(    XK_9,                             8)
       DESKTOPCHANGE(    XK_0,                             9)

    /* Other */
    {  MOD4,             XK_space,      spawn,             {.com = dmenucmd}},
    {  MOD4,             XK_Return,     spawn,             {.com = terminalcmd}},
    {  MOD4|ControlMask, XK_q,          quit,              {NULL}},
    {  MOD4,             XK_Delete,     kill_client,       {NULL}}
};

#endif

    '';
  };

in

{

  options = {
    services.xserver.windowManager.worm-quad = {
      enable = mkEnableOption "worm-quad";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before worm-quad is started.
        '';
      };
      package = mkPackageOption pkgs "worm-quad" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "worm-quad" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "worm-quad";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${worm-quad}/bin/worm-quad &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.worm-quad = {
      enable = true;
      extraSessionCommands = '' '';
      package = worm-quad;
    };

  };

}
