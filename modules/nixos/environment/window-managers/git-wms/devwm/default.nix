{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.devwm;
  devwm = pkgs.callPackage ./devwm.nix {
    conf = ''
#ifndef CONFIG_H
#define CONFIG_H

// Mod (Mod1 == alt) and master size
#define MOD1             Mod1Mask
#define MOD4             Mod4Mask
#define MASTER_SIZE     0.5

// Borders
#define BORDER_WIDTH    2
#define FOCUS           "rgb:ff/49/00"
#define UNFOCUS         "rgb:88/88/88"

#define VIEW_VERTICAL_STACK     0
#define VIEW_HORIZONTAL_STACK   1
#define VIEW_SINGLE             2

const char* urxvtcmd[] = {"urxvtc","-fade","30","-bg","black","-fg","white","-fadecolor","white",NULL};

// Avoid multiple paste
#define DESKTOPCHANGE(K,N) \
    {  MOD4,             K,                          change_desktop, {.i = N}}, \
    {  MOD4|ShiftMask,   K,                          client_to_desktop, {.i = N}},

// Shortcuts
static struct key keys[] = {
    {  MOD4,             XK_h,                       decrease,       {NULL}},
    {  MOD4,             XK_l,                       increase,       {NULL}},
    {  MOD4,             XK_w,                       kill_client,    {NULL}},
    {  MOD4,             XK_bracketleft,             next_win,       {NULL}},
    {  MOD4,             XK_Tab,                     next_win,       {NULL}},
    {  MOD4,             XK_bracketright,            prev_win,       {NULL}},
    {  MOD4,             XK_j,                       prev_win,       {NULL}},
    {  MOD4,             XK_k,                       next_win,       {NULL}},
    {  MOD4|ShiftMask,   XK_j,                       move_up,        {NULL}},
    {  MOD4|ShiftMask,   XK_k,                       move_down,      {NULL}},
    {  MOD4,             XK_Return,                  swap_master,    {NULL}},
    {  MOD4|ShiftMask,   XK_Return,                  switch_mode,    {.i = VIEW_SINGLE}},
    {  MOD4,             XK_space,                   switch_mode,    {NULL}},
    {  MOD4,             XK_d,                       spawn,          {.com = urxvtcmd}},
    {  MOD4,             XK_Right,                   next_desktop,   {NULL}},
    {  MOD4,             XK_Left,                    prev_desktop,   {NULL}},
       DESKTOPCHANGE(   XK_1,                                       0)
       DESKTOPCHANGE(   XK_2,                                       1)
       DESKTOPCHANGE(   XK_3,                                       2)
       DESKTOPCHANGE(   XK_4,                                       3)
       DESKTOPCHANGE(   XK_5,                                       4)
    {  MOD1|ControlMask, XK_q,                       quit,           {NULL}}
};

#endif

    '';
  };

in

{

  options = {
    services.xserver.windowManager.devwm = {
      enable = mkEnableOption "devwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before devwm is started.
        '';
      };
      package = mkPackageOption pkgs "devwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "devwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "devwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${devwm}/bin/devwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.devwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = devwm;
    };

  };

}
