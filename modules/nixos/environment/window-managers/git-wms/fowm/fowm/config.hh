#ifndef CONFIG_HH
#define CONFIG_HH

#include <X11/Xlib.h>

#ifdef USE_XFT
#include <X11/Xft/Xft.h>
#endif

#include "misc.hh"

#define NUM_BUTTONS 5

#define NUM_STYLES 6

#define STYLE_NONE	0
#define STYLE_NO_TITLE	1
#define STYLE_NO_BORDER	2
#define STYLE_NORMAL	3
#define STYLE_INFO	4
#define STYLE_MENU	5

#define STYLE_BORDER	1
#define STYLE_TITLEBAR	2
#define STYLE_UTIL	4

#define NUM_BTN_ACT 10

struct cfg_rect
{
	int left, top, right, bottom;
};

struct cfg_border
{
	cfg_rect position;
	ulong bg_color[4];
	Pixmap pixmap[4];
	uint act_idx;
	uint num_col;
};

struct cfg_titlebar : cfg_border
{
#ifdef USE_XFT
	XftColor fg_color[4];
#else
	ulong fg_color[4];
#endif
	cfg_rect title;
	cfg_border * borders;
	uint num_borders;
};

struct cfg_util : cfg_border
{
#ifdef USE_XFT
	XftColor fg_color[4];
#else
	ulong fg_color[4];
#endif
	uint left, right, height, baseline;
	uint arrow_width;
	uint arrow_height;
	Pixmap arrow[2];
};

struct cfg_style
{
	uint top, left, right, bottom;
	cfg_border * borders;
	uint num_borders;
	union
	{
		cfg_titlebar titlebar;
		cfg_util util;
	};
};

class action;

struct cfg_actions
{
	action * act[NUM_BUTTONS];
};

struct cfg_key
{
	uint key;
	uint mod;
	action * act;
};

struct cfg_menu;

struct cfg_menu_item
{
	char * name;
	union
	{
		action * act;
		cfg_menu * menu;
	};
};

namespace config
{
	extern char * confdir;
	extern size_t dirlen; // strlen(confdir)

#ifdef USE_XFT
	extern XftFont * font;
#else
	extern XFontStruct * font;
#endif
	extern Cursor cursor;
	extern cfg_style style[NUM_STYLES];
	extern cfg_actions button_press[NUM_BTN_ACT];
	extern cfg_actions button_release[NUM_BTN_ACT];
	extern cfg_key * keys;
	extern uint num_keys;
	extern uint modifier;
	extern uint mod_act;
	extern uint max_menu_width;
	extern uint snap_dist[5];
	extern uint workspaces;

	void init(const char *);
	void read(const char *);
	void fini();
}

#endif
