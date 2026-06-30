{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.xwm;
  xwm = pkgs.callPackage ./xwm.nix {
    conf = ''
/* See "license" file for copyright and license details. */

/* Appearance. */
static const unsigned int borderpx  = 1 ; /* Border pixel of windows. */
static const int showbar = 1;  /* 0 means no bar.  */
static const int topbar = 1; /* 0 means bottom bar. */
static const char *fonts[]  = { "Consolas:size=10" } ;
static const char col_gray[] = "#888888" ;
static const char col_white[] = "#FFFFFF" ;
static const char col_black[] = "#000000" ;
static const char *colors[][3] = {
	/* Foreground, background, border. */
	[SchemeSel] = { col_black, col_white, col_white},
	[SchemeNorm]  = { col_white, col_black,  col_gray},
} ;

/* Tagging. */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" } ;

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* Class, instance, title, tags mask, is floating, monitor */
} ;

/* Layout(s). */
static const float mfact     = 0.55 ; /* Factor of master area size [0.05..0.95]. */
static const int nmaster     = 1 ; /* Number of clients in master area. */
static const int resizehints = 1 ; /* 1 means respect size hints in tiled resizals. */

/* Layouts on the tags you get when start WM. */
static const SetupLayout setup_layouts[9] = {
	/* Layout, mfact, nmaster. */
	{LayoutTile,  0.55, 1}, /* 1. */
	{LayoutTile,  0.55, 1}, /* 2. */
	{LayoutTile,  0.55, 1}, /* 3. */
	{LayoutTile,  0.55, 1}, /* 4. */
	{LayoutTile,  0.55, 1}, /* 5. */
	{LayoutTile,  0.55, 1}, /* 6. */
	{LayoutTile,  0.55, 1}, /* 7. */
	{LayoutTile,  0.55, 1}, /* 8. */
	{LayoutTile,  0.55, 1}, /* 9. */
} ;

static const Layout layouts[] = {
	/* Standard is ALWAYS floating. */
	/* Symbol, arrange function. */
	[LayoutFloating] = { "[F]", floating}, /* Floating layout. */
	[LayoutTile] = { "[T]", tile }, /* Tiled layout. */
	[LayoutMonocle] = { "[M]", monocle }, /* Maximized layout. */
	[LayoutSplit] = {"[S]", split},  /* Split layout. */
	[LayoutRootwin] = {"[R]", rootwin},
} ;

/* Key definitions. */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY, KEY, view, {.ui = 1 << TAG} }, /* Change view to this tag. */ \
	{ MODKEY|ControlMask, KEY, toggleview,     {.ui = 1 << TAG} }, /* Add this tag to current view. */\
	{ MODKEY|ShiftMask, KEY, tag, {.ui = 1 << TAG} }, /* Move current window to this tag. */\
	{ MODKEY|ControlMask|ShiftMask, KEY,  toggletag, {.ui = 1 << TAG} } /* Link current wiwond to this tag. */

static char menumon[] = "0" ;
/* Easier CMD assigning. $1 in scripts is current monitor. */
#define SHCMD(cmd) { "rc", "-l", "-c", cmd, menumon, NULL }/*)*/

#define XRESOURCES "$home/lib/xresources"
#define XRESOURCES_MERGE "test -r " XRESOURCES " && xrdb -merge " XRESOURCES

#define XMODMAP "$home/lib/xmodmap"
#define XMODMAP_MERGE " test -r " XMODMAP " && xmodmap "XMODMAP
/* Setting of window manager name which let you change the title in right up corner. */
#define SETWMNAME(str) "out = `{echo -n "str"} ; xsetroot -name $\"out"

/* Keyboard. */
#define SET_KB_LT "setxkbmap -model pc105 -keycodes evdev"
/* It's made to escape using Compose key in games and stuff. */
#define CLEAR_KB_LT SET_KB_LT " -option"

/* Native map for your language. */
#define NATIVE_KB_MAP "ru"

/* Option. */
#define KB_OPTION "grp:alt_space_toggle,caps:escape,ctrl:swap_lalt_lctl,ctrl:swap_ralt_rctl"
#define KB_DVORAK_COMPOSE_OPTION "compose:ralt"

/* Dvorak. */
#define DVORAK_KB_LT "-layout us," NATIVE_KB_MAP " -variant dvorak, -option " KB_OPTION "," KB_DVORAK_COMPOSE_OPTION
#define SET_DVORAK_KB_LT SET_KB_LT " " DVORAK_KB_LT

/* Programmer dvorak. */
#define DVP_KB_LT "-layout us," NATIVE_KB_MAP" -variant dvp, -option "KB_OPTION
#define SET_DVP_KB_LT SET_KB_LT " " DVP_KB_LT

/* Qwerty. */
#define QWERTY_KB_LT "-layout us," NATIVE_KB_MAP " -option "KB_OPTION
#define SET_QWERTY_KB_LT CLEAR_KB_LT ";" SET_KB_LT " " QWERTY_KB_LT

/* Native layout. */
#define NATIVE_KB_LT "-layout " NATIVE_KB_MAP ",us -variant ,dvorak -option " KB_OPTION
#define SET_NATIVE_KB_LT SET_KB_LT " " NATIVE_KB_LT

/* Keyboard options. */
#define KB_REPEAT_RATE "60"
#define KB_REPEAT_DELAY "300"
#define SET_KB_OPTIONS "xset r rate " KB_REPEAT_DELAY " " KB_REPEAT_RATE

/* Xsetroot. */
#define XSETROOT "xsetroot"
#define XSETROOT_SOLID_GRAY XSETROOT " -solid '#333333'"

/* It is called on "xwm" start. */
static char *rccmd[] = SHCMD( SETWMNAME("Hello, master `{whoami}") ";" \
	SET_DVORAK_KB_LT ";" \
	SET_KB_OPTIONS ";" \
	XRESOURCES_MERGE ";"\
	XSETROOT_SOLID_GRAY ";"
	"if( which VBoxClient-all ) VBoxClient-all & ;") ;

/* Spawners. */
static char *runcmd[] = SHCMD(
	"eval `{goblin echo -d '\n'"
	/* Standard programs. */
	" firefox"
	" chromium"
	" gimp"
	" mypaint"
	" olive-editor"
	" cadence"
	" catia"
	" carla"
	" pavucontrol"
	" telegram"
	"| xmen -m $1 -p $prompt}"
) ; /* Menu run. */
static char *lockcmd[] = {"xlck", 0} ;
static char *outruncmd[] = SHCMD(SETWMNAME("`{ eval `{echo -n | xmen -m $1 -p $prompt } }")) ; /* Set WM name to output of command. */
static char *termcmd[] = SHCMD("xmux -txmux $PERSONAL_SHELL") ; /* Fancy terminal run. */
static char *stermcmd[] = SHCMD("xtrm $PERSONAL_SHELL") ; /* Simpler terminal to run. */
static char *plumbcmd[] = SHCMD("url=`{eval echo `{xsel}} ; exec  xplumb $\"url") ;

/* Keyboard layouts. */
static const char *dvorakkbdcmd[] = SHCMD(SETWMNAME("dvorak") ";" SET_DVORAK_KB_LT ";" );
static const char *dvpkbdcmd[] = SHCMD(SETWMNAME("dvp") ";" SET_DVP_KB_LT ";" ) ;
static const char *natkbdcmd[] = SHCMD(SETWMNAME("native")";" SET_NATIVE_KB_LT ";" ) ;
static const char *qwertykbdcmd[] = SHCMD(SETWMNAME("qwerty")";" SET_QWERTY_KB_LT ";" ) ;

static Key keys[] = {
	/* Modifier, key, function, argument. */
	/* Program spawners. */
	{ MODKEY|ShiftMask, XK_Return, spawn, {.v = termcmd} }, /* Terminal. */
	{ MODKEY|ShiftMask, XK_t, spawn, {.v = stermcmd} }, /* Text buffer terminal. */
	{ MODKEY|ShiftMask, XK_r, spawn, {.v = runcmd} }, /* Run CMD. (dmenu most the time) */
	{ MODKEY|ShiftMask, XK_c, spawn, {.v = outruncmd} }, /* Run CMD and set it's output to WMname. */
	{ MODKEY|ShiftMask, XK_p, spawn, {.v = plumbcmd} }, /* Plumber. */

	/* Clients stuff and input. (The most often used) */
	{ MODKEY, XK_a, spawn, {.v = qwertykbdcmd} }, /* Qwerty. */
	{ MODKEY, XK_Tab, spawn, {.v = dvorakkbdcmd} }, /* Dvorak. */
	{ MODKEY, XK_BackSpace, spawn, {.v = natkbdcmd} }, /* Alternative. */
	{ MODKEY, XK_Return, spawn, {.v = dvpkbdcmd} }, /* Dvorak programmer. */
	{ MODKEY, XK_x, killcurclient, {0} }, /* Close current window. */
	{ MODKEY,  XK_b, togglebar, {0} }, /* Toggle bar with tags and other. */
	{ MODKEY, XK_j, focusstack, {.i = +1, .b=1 } }, /* Change focus via keyboard(Next). */
	{ MODKEY, XK_k, focusstack, {.i = -1, .b=1 } }, /* Change focus via keyboard(Previous). */
	{ MODKEY, XK_i, incnmaster, {.i = +1 } }, /* Increase size of window table stack. */
	{ MODKEY,  XK_u, incnmaster, {.i = 0 } }, /* Set nmaster to standard value. */
	{ MODKEY,  XK_d, incnmaster, {.i = -1 } }, /* Decrease size of window table stack. */
	{ MODKEY, XK_h, setmfact, {.f = -0.05} }, /* Decrease master window size. */
	{ MODKEY, XK_l, setmfact, {.f = +0.05} }, /* Increase master window size. */

	{ MODKEY|ControlMask, XK_h, scrolldeskhorizontal, {.i = +300, .b = 0} }, /* Scrolling desktop. */
	{ MODKEY|ControlMask, XK_l, scrolldeskhorizontal, {.i = -300, .b = 0} },
	{ MODKEY|ControlMask, XK_k, scrolldeskvertical, {.i = +300, .b = 0} },
	{ MODKEY|ControlMask, XK_j, scrolldeskvertical, {.i = -300, .b = 0} },
	{ MODKEY, XK_r, zoom, {0} }, /* Current choosen window master. */
	{ MODKEY, XK_t, setlayout, {.v = &layouts[LayoutTile]} }, /* Tile layout. */
	{ MODKEY, XK_s, setlayout, {.v = &layouts[LayoutSplit]}}, /* Split layout. */
	{ MODKEY, XK_f, setlayout, {.v = &layouts[LayoutFloating]} }, /* Floating layout. */
	{ MODKEY, XK_m, setlayout, {.v = &layouts[LayoutMonocle]} }, /* Maximized layout. */
	{ MODKEY, XK_w, setlayout, {.v = &layouts[LayoutRootwin]} }, /* Layout with one window in mid. */
	{ MODKEY|ShiftMask, XK_space,  setlayout, {0} },  /* Toggle layout. */
	{ MODKEY, XK_space,  togglefree, {0} },  /* Change between floated and unfloated statement. */
	{ MODKEY|ShiftMask, XK_f,  togglefullscreen, {0} },
	{ MODKEY, XK_0, view, {.ui = ~0 } },  /* Toggle all tags. */
	{ MODKEY|ShiftMask, XK_0, tag,  {.ui = ~0 } }, /* Move window to the next tag. */

	/* Monitor things. */
	{ MODKEY, XK_comma,  focusmon, {.i = -1 } },
	{ MODKEY, XK_period, focusmon, {.i = +1 } },
	{ MODKEY|ShiftMask, XK_comma,  tagmon, {.i = -1 } },
	{ MODKEY|ShiftMask, XK_period, tagmon, {.i = +1 } },

	/* Tags. */
	{ MODKEY, XK_p, viewnext, {.i = -1} },
	{ MODKEY, XK_n, viewnext, {.i = +1} },
	TAGKEYS(XK_1, 0),
	TAGKEYS(XK_2, 1),
	TAGKEYS(XK_3, 2),
	TAGKEYS(XK_4, 3),
	TAGKEYS(XK_5, 4),
	TAGKEYS(XK_6, 5),
	TAGKEYS(XK_7, 6),
	TAGKEYS(XK_8, 7),
	TAGKEYS(XK_9, 8),

	/* DWM hotkeys(It's rarely used, so it takes the most effort to use). */
	{ MODKEY|ControlMask|ShiftMask, XK_l, spawn, {.v = lockcmd} },
	{ MODKEY|ControlMask|ShiftMask, XK_Escape, quit, {0} }, /* Quit window manager. */
	{ MODKEY|ControlMask|ShiftMask, XK_r, quit, {.i = 1 } }, /* Restart window manager. */
} ;
/* Button definitions. */
/* Click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin. */
static Button buttons[] = {
	/* Click, event mask, button, function, argument. */
	/* Layouts. */
	{ ClkLtSymbol, 0, Button1, setlayout, {0}}, /* Toggle layout. */
	{ ClkLtSymbol, 0, Button4, nextlayout,  {.i = -1}}, /* Changing layouts by mouse wheel. */
	{ ClkLtSymbol, 0, Button5, nextlayout,  {.i = +1}},
	{ ClkLtSymbol, 0, Button2, togglefree, {0} }, /* Toggle floating layout on current window. */
	{ ClkLtSymbol, 0, Button3, zoom, {0} },

	/* Master window. */
	{ ClkStatusText, 0, Button1, setmfact, {.f = -0.05} } ,/* Decrease master window size. */
	{ ClkStatusText, 0, Button5, setmfact, {.f = -0.01} },
	{ ClkStatusText, 0, Button3,setmfact, {.f = +0.05} } , /* Increase master window size. */
	{ ClkStatusText, 0, Button4, setmfact, {.f = +0.01} },
	{ ClkRootWin, MODKEY|ShiftMask, Button4, setmfact, {.f = +0.01} },
	{ ClkRootWin, MODKEY|ShiftMask, Button5, setmfact, {.f = -0.01} },
	{ ClkClientWin, MODKEY|ShiftMask, Button4, setmfact, {.f = +0.01} },
	{ ClkClientWin, MODKEY|ShiftMask, Button5, setmfact, {.f = -0.01} },
	{ ClkRootWin, MODKEY|ControlMask, Button4, setmfact, {.f = +0.05} },
	{ ClkRootWin, MODKEY|ControlMask, Button5, setmfact, {.f = -0.05} },
	{ ClkClientWin, MODKEY|ControlMask, Button4, setmfact, {.f = +0.05} },
	{ ClkClientWin, MODKEY|ControlMask, Button5, setmfact, {.f = -0.05} },

	/* Scrolling desktop. */
	{ ClkStatusText, 0, Button1, scrolldeskhorizontal, {.i = +300, .b = 0} },
	{ ClkStatusText, 0, Button3, scrolldeskhorizontal, {.i = -300, .b = 0} },
	{ ClkStatusText, 0, Button5, scrolldeskvertical, {.i = -100, .b = 0} },
	{ ClkStatusText, 0, Button4, scrolldeskvertical, {.i = +100, .b = 0} },
	{ ClkRootWin, MODKEY|ShiftMask, Button4, scrolldeskhorizontal, {.i = +100, .b = 0} },
	{ ClkRootWin, MODKEY|ShiftMask, Button5, scrolldeskhorizontal, {.i = -100, .b = 0} },
	{ ClkRootWin, MODKEY|ControlMask, Button5, scrolldeskvertical, {.i = -100, .b = 0} },
	{ ClkRootWin, MODKEY|ControlMask, Button4, scrolldeskvertical, {.i = +100, .b = 0} },
	{ ClkClientWin, MODKEY|ShiftMask, Button4, scrolldeskhorizontal, {.i = +100, .b = 0} },
	{ ClkClientWin, MODKEY|ShiftMask, Button5, scrolldeskhorizontal, {.i = -100, .b = 0} },
	{ ClkClientWin, MODKEY|ControlMask, Button5, scrolldeskvertical, {.i = -100, .b = 0} },
	{ ClkClientWin, MODKEY|ControlMask, Button4, scrolldeskvertical, {.i = +100, .b = 0} },

	/* Changing focus. */
	{ ClkWinTitle, 0, Button4, focusstack, {.i = +1, .b=0 } },
	{ ClkWinTitle, 0, Button5, focusstack, {.i = -1, .b=0 } },

	/* Calling terminals. */
	{ ClkRootWin, 0, Button2, quit, {.i = 1 } },
	{ ClkStatusText, 0, Button2, spawn, {.v = stermcmd } },

	/* Moving window by mouse. */
	{ ClkClientWin, MODKEY, Button1, movemouse, {0} },
	{ ClkWinTitle, 0, Button1, moveclick, {0} },
	/* Close current window. */
	{ ClkClientWin, MODKEY|ShiftMask, Button2, killcurclient, {0}  },
	{ ClkWinTitle, 0, Button2, killclick, {0}  },

	/* Up window on the stack of view. */
	{ ClkClientWin, MODKEY, Button4, raisefocused, {0} },

	/* Low window on the stack of view. */
	{ ClkClientWin, MODKEY, Button5, lowerfocused, {0} },

	/* Resizing by mouse. */
	{ ClkClientWin, MODKEY, Button3, resizemouse, {0} },
	{ ClkWinTitle, 0, Button3, resizeclick, {0} },

	/* In tiled mode choose current window as master. */
	{ ClkClientWin, MODKEY|ControlMask, Button2, zoom, {0} },

	/* Tags. */
	{ ClkTagBar, 0, Button1, view, {0} },
	{ ClkTagBar, 0, Button3, toggleview, {0} },
	{ ClkTagBar, 0, Button2, tag, {0} },
	{ ClkTagBar, MODKEY, Button2, toggletag, {0} },
	{ ClkTagBar, 0, Button4, viewnext, {.i = +1} },
	{ ClkTagBar, 0, Button5, viewnext, {.i = -1} },
} ;
/* Sides definition. Calls functions when touches borders of screens resizing or moving windows. */
/* Sides can be SideNo, SideRight, SideLeft, SideUp, SideDown. */
static Side sides[] = {
	{SideRight, scrolldeskhorizontal, {.i = -500, .b = 1} },
	{SideLeft, scrolldeskhorizontal, {.i = +500, .b = 1} },
	{SideUp, scrolldeskvertical, {.i = +500, .b = 1} },
	{SideDown, scrolldeskvertical, {.i = -500, .b = 1} },
} ;


    '';
  };

in

{

  options = {
    services.xserver.windowManager.xwm = {
      enable = mkEnableOption "xwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before xwm is started.
        '';
      };
      package = mkPackageOption pkgs "xwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "xwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "xwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${xwm}/bin/xwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.xwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = xwm;
    };

  };

}
