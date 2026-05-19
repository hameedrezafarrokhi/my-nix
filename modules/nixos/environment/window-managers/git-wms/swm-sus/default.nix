{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.suswm;
  suswm = pkgs.callPackage ./swm.nix {
    conf = ''
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY, view,        {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY, toggleview,  {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY, tag,         {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY, toggletag,   {.ui = 1 << TAG} },

static const unsigned int borderpx    = 4;
static const unsigned int gappx       = 6;
static const unsigned int snap        = 16;
static const int          attachbottom = 1;
static const int          focusonopen  = 1;
static const float        mfact        = 0.5;
static const int          nmaster      = 1;

static const char col_nborder[] = "#1e1e1e";
static const char col_sborder[] = "#7c9e7e";
static const char col_uborder[] = "#c47f50";

static const char *tags[] = { "1","2","3","4","5","6","7","8","9" };

static const L layouts[] = {
	{ tile    },
	{ NULL    },
	{ monocle },
};

static const char *termcmd[]  = { "${config.my.default.terminal}", NULL };
static const char *dmenucmd[] = { "dmenu_run", NULL };

static const K keys[] = {
	{ MODKEY,              XK_Return, spawn,       {.v = termcmd  } },
	{ MODKEY,              XK_d,      spawn,       {.v = dmenucmd } },
	{ MODKEY,              XK_c,      killclient,  {0} },
	{ Mod1Mask|ShiftMask,  XK_e,      quit,        {0} },
	{ MODKEY,              XK_Right,  focusstack,  {.i = +1} },
	{ Mod1Mask,            XK_Tab,    focusstack,  {.i = +1} },
	{ MODKEY,              XK_Left,   focusstack,  {.i = -1} },
	{ Mod1Mask|ShiftMask,  XK_Tab,    focusstack,  {.i = -1} },
	{ MODKEY,              XK_equal,  incnmaster,  {.i = +1} },
	{ MODKEY|ShiftMask,    XK_equal,  incnmaster,  {.i = -1} },
	{ MODKEY|ShiftMask,    XK_Down,   setmfact,    {.f = -0.05} },
	{ MODKEY|ShiftMask,    XK_Up,     setmfact,    {.f = +0.05} },
	{ MODKEY|ShiftMask,    XK_Return, zoom,        {0} },
	{ MODKEY,              XK_Tab,    view,        {0} },
	{ MODKEY|ControlMask,  XK_1,      setlayout,   {.v = &layouts[0]} },
	{ MODKEY|ControlMask,  XK_2,      setlayout,   {.v = &layouts[2]} },
	{ MODKEY|ControlMask,  XK_3,      setlayout,   {.v = &layouts[1]} },
	{ MODKEY,              XK_Return, tglfs,       {0} },
	{ MODKEY|ShiftMask,    XK_f,      tglfl,       {0} },
	{ MODKEY,              XK_0,      view,        {.ui = ~0} },
	{ MODKEY|ShiftMask,    XK_0,      tag,         {.ui = ~0} },
	TAGKEYS(XK_1,0) TAGKEYS(XK_2,1) TAGKEYS(XK_3,2)
	TAGKEYS(XK_4,3) TAGKEYS(XK_5,4) TAGKEYS(XK_6,5)
	TAGKEYS(XK_7,6) TAGKEYS(XK_8,7) TAGKEYS(XK_9,8)
};

static const B buttons[] = {
	{ ClkClientWin, MODKEY, Button1, mv,    {0} },
	{ ClkClientWin, MODKEY, Button2, tglfl, {0} },
	{ ClkClientWin, MODKEY, Button3, rz,    {0} },
};
    '';
  };

in

{

  options = {
    services.xserver.windowManager.suswm = {
      enable = mkEnableOption "suswm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before suswm is started.
        '';
      };
      package = mkPackageOption pkgs "suswm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "suswm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "suswm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${suswm}/usr/local/bin/swm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.suswm = {
      enable = true;
      extraSessionCommands = '' '';
      package = suswm;
    };

  };

}
