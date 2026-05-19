#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <pwd.h>
#include <alloca.h>

#include "pixmap.hh"
#include "cursor.hh"
#include "action.hh"
#include "screen.hh"
#include "config.hh"

#define DEFAULT_PATH "/.fowm"
#define MAX_ARGS 8

char * config::confdir = nullptr;
size_t config::dirlen = 0;

#ifdef USE_XFT
XftFont * config::font = nullptr;
#else
XFontStruct * config::font = nullptr;
#endif
Cursor config::cursor = None;
cfg_style config::style[NUM_STYLES] = {};
cfg_actions config::button_press[NUM_BTN_ACT] = {};
cfg_actions config::button_release[NUM_BTN_ACT] = {};
cfg_key * config::keys = nullptr;
uint config::num_keys = 0;
uint config::modifier = 0;
uint config::mod_act = 0;
uint config::max_menu_width = 0;
uint config::snap_dist[5] = {};
uint config::workspaces = 1;

namespace
{

typedef bool (*run_fn)(uint, char **);

struct command
{
	const char * name;
	run_fn run;
};

bool to_color(const char * str, ulong * ret)
{
	XColor xc;
	if (XAllocNamedColor(dpy, screen->colormap(), str, &xc, &xc))
	{
		*ret = xc.pixel;
		return true;
	}
	return false;
}

struct modifier
{
	const char * name;
	uint mask;
};

const modifier modifiers[] =
{
	{ "Shift", ShiftMask },
	{ "Lock", LockMask },
	{ "Control", ControlMask },
	{ "Mod1", Mod1Mask },
	{ "Mod2", Mod2Mask },
	{ "Mod3", Mod3Mask },
	{ "Mod4", Mod4Mask },
	{ "Mod5", Mod5Mask }
};

bool to_modifier(const char * str, uint * ret)
{
	for (const modifier & mod : modifiers)
	{
		if (str_eq(mod.name, str))
		{
			*ret = mod.mask;
			return true;
		}
	}

	return false;
}

#ifdef USE_XFT
XftFont * xft_font_open(const char * name, uint size)
{
	FcPattern * pat = FcNameParse(str_cast(name));
	if (pat)
	{
		FcPatternAddDouble(pat, FC_PIXEL_SIZE, size);
		FcResult res;
		FcPattern * match = XftFontMatch(dpy, screen->number(), pat, &res);
		FcPatternDestroy(pat);
		if (match)
		{
			XftFont * font = XftFontOpenPattern(dpy, match);
			FcPatternDestroy(match);
			return font;
		}
	}

	return nullptr;
}
#endif

bool cmd_include(uint argc, char ** argv)
{
	if (argc != 2) return false;

	config::read(argv[1]);

	return true;
}

bool cmd_font(uint argc, char ** argv)
{
#ifdef USE_XFT
	if (argc != 3) return false;

	uint size;
	if (!to_uint(argv[2], &size))
		return false;
	if (!size) return false;

	XftFont * font = xft_font_open(argv[1], size);
	if (!font) return false;

	if (config::font)
		XftFontClose(dpy, font);
	config::font = font;

	return true;
#else
	if (argc != 2) return false;

	XFontStruct * font = XLoadQueryFont(dpy, argv[1]);
	if (!font) return false;

	if (config::font)
		XFreeFont(dpy, config::font);
	config::font = font;

	return true;
#endif
}

bool cmd_cursor(uint argc, char ** argv)
{
	if (argc != 2) return false;

	Cursor cur = cursor::load(argv[1]);
	if (!cur) return false;

	if (config::cursor)
		XFreeCursor(dpy, config::cursor);

	config::cursor = cur;
	return true;
}

bool cmd_cursor_color(uint argc, char ** argv)
{
	if (argc != 3) return false;
	if (!config::cursor) return false;

	XColor fg, bg;
	Colormap cmap = screen->colormap();
	if (!XParseColor(dpy, cmap, argv[1], &fg))
		return false;
	if (!XParseColor(dpy, cmap, argv[2], &bg))
		return false;

	XRecolorCursor(dpy, config::cursor, &fg, &bg);
	return true;
}

bool cmd_snap_dist(uint argc, char ** argv)
{
	if (argc < 2 || argc > 6) return false;

	if (!to_uint(argv[1], config::snap_dist))
		return false;

	if (argc < 3)
	{
		config::snap_dist[1] = config::snap_dist[0];
		config::snap_dist[2] = config::snap_dist[0];
		config::snap_dist[3] = config::snap_dist[0];
		config::snap_dist[4] = config::snap_dist[0];
		return true;
	}

	if (!to_uint(argv[2], config::snap_dist + 1))
		return false;

	if (argc < 4)
	{
		config::snap_dist[2] = config::snap_dist[0];
		config::snap_dist[3] = config::snap_dist[1];
		config::snap_dist[4] = 0;
		return true;
	}

	if (!to_uint(argv[3], config::snap_dist + 2))
		return false;

	if (argc < 5)
	{
		config::snap_dist[4] = config::snap_dist[2];
		config::snap_dist[2] = config::snap_dist[0];
		config::snap_dist[3] = config::snap_dist[1];
		return true;
	}

	if (!to_uint(argv[4], config::snap_dist + 3))
		return false;

	if (argc < 6)
	{
		config::snap_dist[4] = 0;
		return true;
	}

	if (!to_uint(argv[5], config::snap_dist + 4))
		return false;

	return true;
}

bool cmd_workspaces(uint argc, char ** argv)
{
	if (argc != 2) return false;

	uint ws;
	if (!to_uint(argv[1], &ws))
		return false;

	if (ws < 1) return false;

	config::workspaces = ws;
	return true;
}

uchar c_style = STYLE_NORMAL;

bool cmd_style(uint argc, char ** argv)
{
	if (argc != 2) return false;

	if (str_eq(argv[1], "Normal"))
	{
		c_style = STYLE_NORMAL;
		return true;
	}

	if (str_eq(argv[1], "NoBorder"))
	{
		c_style = STYLE_NO_BORDER;
		return true;
	}

	if (str_eq(argv[1], "NoTitle"))
	{
		c_style = STYLE_NO_TITLE;
		return true;
	}

	if (str_eq(argv[1], "Info"))
	{
		c_style = STYLE_INFO;
		return true;
	}

	if (str_eq(argv[1], "Menu"))
	{
		c_style = STYLE_MENU;
		return true;
	}

	return false;
}

bool cmd_border_width(uint argc, char ** argv)
{
	if (argc != 5) return false;

	cfg_style * cfg = config::style + c_style;
	if (!to_uint(argv[1], &cfg->top))
		return false;
	if (!to_uint(argv[2], &cfg->left))
		return false;
	if (!to_uint(argv[3], &cfg->right))
		return false;
	if (!to_uint(argv[4], &cfg->bottom))
		return false;

	return true;
}

bool cmd_title_bar(uint argc, char ** argv)
{
	if (argc != 6) return false;

	if (!(c_style & STYLE_TITLEBAR))
		return false;

	uint act;
	if (!to_uint(argv[1], &act))
		return false;
	if (act >= NUM_BTN_ACT)
		return false;

	cfg_titlebar * cfg = &config::style[c_style].titlebar;
	cfg->act_idx = act;

	if (!to_int(argv[2], &cfg->position.left))
		return false;
	if (!to_int(argv[3], &cfg->position.top))
		return false;
	if (!to_int(argv[4], &cfg->position.right))
		return false;
	if (!to_int(argv[5], &cfg->position.bottom))
		return false;

	return true;
}

bool cmd_title_bg_color(uint argc, char ** argv)
{
	if (argc < 2 || argc > 5) return false;

	if (!(c_style & STYLE_TITLEBAR))
		return false;

	uint n = argc - 1;
	cfg_style * csp = config::style + c_style;
	csp->titlebar.num_col = n;

	ulong * cfg = csp->titlebar.bg_color;
	for (uint i = 0; i < n; i++)
	{
		if (!to_color(argv[1 + i], cfg + i))
			return false;
	}

	return true;
}

bool cmd_title_fg_color(uint argc, char ** argv)
{
	if (argc < 2 || argc > 5) return false;

	if (!(c_style & STYLE_TITLEBAR))
		return false;

	uint n = argc - 1;
	cfg_style * csp = config::style + c_style;
	csp->titlebar.num_col = n;

#ifdef USE_XFT
	XftColor * cfg = csp->titlebar.fg_color;
	Visual * vis = screen->visual();
	Colormap cmap = screen->colormap();
	for (uint i = 0; i < n; i++)
	{
		if (!XftColorAllocName(dpy, vis, cmap, argv[1 + i], cfg + i))
			return false;
	}
#else
	ulong * cfg = csp->titlebar.fg_color;
	for (uint i = 0; i < n; i++)
	{
		if (!to_color(argv[1 + i], cfg + i))
			return false;
	}
#endif

	return true;
}

bool cmd_title_pixmap(uint argc, char ** argv)
{
	if (argc < 2 || argc > 5) return false;

	if (!(c_style & STYLE_TITLEBAR))
		return false;

	uint n = argc - 1;
	cfg_style * csp = config::style + c_style;
	csp->titlebar.num_col = n;

	Pixmap * cfg = csp->titlebar.pixmap;
	for (uint i = 0; i < n; i++)
	{
		if (!pixmap::load(argv[1 + i], cfg + i))
			return false;
	}

	return true;
}

bool cmd_title_text(uint argc, char ** argv)
{
	if (argc != 5) return false;

	if (!(c_style & STYLE_TITLEBAR))
		return false;

	cfg_rect * cfg = &config::style[c_style].titlebar.title;
	if (!to_int(argv[1], &cfg->left))
		return false;
	if (!to_int(argv[2], &cfg->top))
		return false;
	if (!to_int(argv[3], &cfg->right))
		return false;
	if (!to_int(argv[4], &cfg->bottom))
		return false;

	return true;
}

bool cmd_num_title_border(uint argc, char ** argv)
{
	if (argc != 2) return false;

	if (!(c_style & STYLE_TITLEBAR))
		return false;

	uint num;
	if (!to_uint(argv[1], &num))
		return false;

	cfg_titlebar * cfg = &config::style[c_style].titlebar;
	if (cfg->borders) free(cfg->borders);

	cfg->borders = calloc<cfg_border>(num);
	cfg->num_borders = num;

	return true;
}

bool cmd_title_border(uint argc, char ** argv)
{
	if (argc != 6) return false;

	if (!(c_style & STYLE_TITLEBAR))
		return false;

	uint idx;
	if (!to_uint(argv[1], &idx))
		return false;

	cfg_titlebar * ctp = &config::style[c_style].titlebar;
	if (idx >= ctp->num_borders)
		return false;

	cfg_border * cfg = ctp->borders + idx;

	if (!to_int(argv[2], &cfg->position.left))
		return false;
	if (!to_int(argv[3], &cfg->position.top))
		return false;
	if (!to_int(argv[4], &cfg->position.right))
		return false;
	if (!to_int(argv[5], &cfg->position.bottom))
		return false;

	return true;
}

bool cmd_title_border_color(uint argc, char ** argv)
{
	if (argc < 3 || argc > 6) return false;

	if (!(c_style & STYLE_TITLEBAR))
		return false;

	uint idx;
	if (!to_uint(argv[1], &idx))
		return false;

	cfg_titlebar * ctp = &config::style[c_style].titlebar;
	if (idx >= ctp->num_borders)
		return false;

	uint n = argc - 2;
	cfg_border * cbp = ctp->borders + idx;

	ulong * cfg = cbp->bg_color;
	for (uint i = 0; i < n; i++)
	{
		if (!to_color(argv[2 + i], cfg + i))
			return false;
	}

	return true;
}

bool cmd_title_border_pixmap(uint argc, char ** argv)
{
	if (argc < 3 || argc > 6) return false;

	if (!(c_style & STYLE_TITLEBAR))
		return false;

	uint idx;
	if (!to_uint(argv[1], &idx))
		return false;

	cfg_titlebar * ctp = &config::style[c_style].titlebar;
	if (idx >= ctp->num_borders)
		return false;

	uint n = argc - 2;
	cfg_border * cbp = ctp->borders + idx;

	Pixmap * cfg = cbp->pixmap;
	for (uint i = 0; i < n; i++)
	{
		if (!pixmap::load(argv[2 + i], cfg + i))
			return false;
	}

	return true;
}

bool cmd_num_border(uint argc, char ** argv)
{
	if (argc != 2) return false;

	uint num;
	if (!to_uint(argv[1], &num))
		return false;

	cfg_style * cfg = config::style + c_style;
	if (cfg->borders) free(cfg->borders);

	cfg->borders = calloc<cfg_border>(num);
	cfg->num_borders = num;

	return true;
}

bool cmd_border(uint argc, char ** argv)
{
	if (argc != 7) return false;

	uint idx;
	if (!to_uint(argv[1], &idx))
		return false;

	cfg_style * csp = config::style + c_style;
	if (idx >= csp->num_borders)
		return false;

	uint act;
	if (!to_uint(argv[2], &act))
		return false;
	if (act >= NUM_BTN_ACT)
		return false;

	cfg_border * cfg = csp->borders + idx;
	cfg->act_idx = act;

	if (!to_int(argv[3], &cfg->position.left))
		return false;
	if (!to_int(argv[4], &cfg->position.top))
		return false;
	if (!to_int(argv[5], &cfg->position.right))
		return false;
	if (!to_int(argv[6], &cfg->position.bottom))
		return false;

	return true;
}

bool cmd_border_color(uint argc, char ** argv)
{
	if (argc < 3 || argc > 6) return false;

	uint idx;
	if (!to_uint(argv[1], &idx))
		return false;

	cfg_style * csp = config::style + c_style;
	if (idx >= csp->num_borders)
		return false;

	uint n = argc - 2;
	cfg_border * cbp = csp->borders + idx;
	cbp->num_col = n;

	ulong * cfg = cbp->bg_color;
	for (uint i = 0; i < n; i++)
	{
		if (!to_color(argv[2 + i], cfg + i))
			return false;
	}

	return true;
}

bool cmd_border_pixmap(uint argc, char ** argv)
{
	if (argc < 3 || argc > 6) return false;

	uint idx;
	if (!to_uint(argv[1], &idx))
		return false;

	cfg_style * csp = config::style + c_style;
	if (idx >= csp->num_borders)
		return false;

	uint n = argc - 2;
	cfg_border * cbp = csp->borders + idx;
	cbp->num_col = n;

	Pixmap * cfg = cbp->pixmap;
	for (uint i = 0; i < n; i++)
	{
		if (!pixmap::load(argv[2 + i], cfg + i))
			return false;
	}

	return true;
}

bool cmd_util_text(uint argc, char ** argv)
{
	if (argc != 4) return false;

	if (!(c_style & STYLE_UTIL))
		return false;

	cfg_style * cfg = config::style + c_style;

	if (!to_uint(argv[1], &cfg->util.left))
		return false;
	if (!to_uint(argv[2], &cfg->util.right))
		return false;
	if (!to_uint(argv[3], &cfg->util.height))
		return false;

	return true;
}

bool cmd_util_bg_color(uint argc, char ** argv)
{
	if (argc < 2 || argc > 3) return false;

	if (!(c_style & STYLE_UTIL))
		return false;

	uint n = argc - 1;
	cfg_style * csp = config::style + c_style;
	csp->util.num_col = n;

	ulong * cfg = csp->util.bg_color;
	for (uint i = 0; i < n; i++)
	{
		if (!to_color(argv[1 + i], cfg + i))
			return false;
	}

	return true;
}

bool cmd_util_fg_color(uint argc, char ** argv)
{
	if (argc < 2 || argc > 3) return false;

	if (!(c_style & STYLE_UTIL))
		return false;

	uint n = argc - 1;
	cfg_style * csp = config::style + c_style;
	csp->util.num_col = n;

#ifdef USE_XFT
	XftColor * cfg = csp->util.fg_color;
	Visual * vis = screen->visual();
	Colormap cmap = screen->colormap();
	for (uint i = 0; i < n; i++)
	{
		if (!XftColorAllocName(dpy, vis, cmap, argv[1 + i], cfg + i))
			return false;
	}
#else
	ulong * cfg = csp->util.fg_color;
	for (uint i = 0; i < n; i++)
	{
		if (!to_color(argv[1 + i], cfg + i))
			return false;
	}
#endif

	return true;
}

bool cmd_util_pixmap(uint argc, char ** argv)
{
	if (argc < 2 || argc > 3) return false;

	if (!(c_style & STYLE_UTIL))
		return false;

	uint n = argc - 1;
	cfg_style * csp = config::style + c_style;
	csp->util.num_col = n;

	Pixmap * cfg = csp->util.pixmap;
	for (uint i = 0; i < n; i++)
	{
		if (!pixmap::load(argv[1 + i], cfg + i))
			return false;
	}

	return true;
}

bool cmd_menu_arrow(uint argc, char ** argv)
{
	if (argc < 2 || argc > 3) return false;

	cfg_util * cfg = &config::style[STYLE_MENU].util;

	if (!pixmap::load(argv[1], cfg->arrow))
		return false;

	if (argc > 2)
	{
		if (!pixmap::load(argv[2], cfg->arrow + 1))
			return false;
	}
	else
	{
		cfg->arrow[1] = cfg->arrow[0];
	}

	union { Window w; int i; uint u; } u;
	if (!XGetGeometry(dpy, cfg->arrow[0], &u.w, &u.i, &u.i,
		&cfg->arrow_width, &cfg->arrow_height,
		&u.u, &u.u)) return false;

	return true;
}

bool cmd_menu_width(uint argc, char ** argv)
{
	if (argc != 2) return false;

	uint max;
	if (!to_uint(argv[1], &max))
		return false;

	config::max_menu_width = max;
	return true;
}

bool cmd_button_press(uint argc, char ** argv)
{
	if (argc < 4 || argc > 5) return false;

	uint btn;
	if (!to_uint(argv[1], &btn))
		return false;
	if (--btn >= NUM_BUTTONS) return false;

	uint idx;
	if (!to_uint(argv[2], &idx))
		return false;
	if (idx >= NUM_BTN_ACT)
		return false;

	action * act = action::create(argv[3], argv[4]);
	if (!act) return false;

	config::button_press[idx].act[btn] = act;

	return true;
}

bool cmd_button_release(uint argc, char ** argv)
{
	if (argc < 4 || argc > 5) return false;

	uint btn;
	if (!to_uint(argv[1], &btn))
		return false;
	if (--btn >= NUM_BUTTONS) return false;

	uint idx;
	if (!to_uint(argv[2], &idx))
		return false;
	if (idx >= NUM_BTN_ACT)
		return false;

	action * act = action::create(argv[3], argv[4]);
	if (!act) return false;

	config::button_release[idx].act[btn] = act;

	return true;
}

bool cmd_modifier(uint argc, char ** argv)
{
	if (argc != 3) return false;

	uint mod;
	if (!to_modifier(argv[1], &mod))
		return false;

	uint act;
	if (!to_uint(argv[2], &act))
		return false;
	if (act >= NUM_BTN_ACT)
		return false;

	config::modifier = mod;
	config::mod_act = act;

	return true;
}

bool cmd_key(uint argc, char ** argv)
{
	if (argc < 4 || argc > 5)
		return false;

	uint mod;
	if (!to_modifier(argv[1], &mod))
		return false;

	KeySym sym = XStringToKeysym(argv[2]);
	if (sym == NoSymbol)
		return false;

	KeyCode key = XKeysymToKeycode(dpy, sym);
	if (!key) return false;

	action * act = action::create(argv[3], argv[4]);
	if (!act) return false;

	uint n = config::num_keys;
	cfg_key * cfg = realloc<cfg_key>(config::keys, n + 1);

	cfg[n].key = key;
	cfg[n].mod = mod;
	cfg[n].act = act;

	config::keys = cfg;
	config::num_keys = n + 1;

	return true;
}

menu_action * last_menu = nullptr;

bool cmd_menu(uint argc, char ** argv)
{
	if (argc != 2) return false;

	if (menu_action::find(argv[1]))
		return false;

	size_t len = strlen(argv[1]) + 1;
	menu_action * menu = new (malloc(offsetof(menu_action, menu.name) + len)) menu_action();

	menu->next = menu_action::first;
	menu->menu.items = nullptr;
	menu->menu.window = nullptr;
	menu->menu.nitems = 0;
	memcpy(menu->menu.name, argv[1], len);

	menu_action::first = menu;
	last_menu = menu;

	return true;
}

bool cmd_menu_item(uint argc, char ** argv)
{
	if (argc < 3 || argc > 4)
		return false;

	if (last_menu == nullptr)
		return false;

	action * act = action::create(argv[2], argv[3]);
	if (!act) return false;

	uint n = last_menu->menu.nitems;
	cfg_menu_item * items = realloc<cfg_menu_item>(last_menu->menu.items, n + 1);
	cfg_menu_item * item = items + n;

	item->name = strdup(argv[1]);
	item->act = act;

	last_menu->menu.items = items;
	last_menu->menu.nitems = n + 1;

	return true;
}

bool cmd_sub_menu(uint argc, char ** argv)
{
	if (argc != 2) return false;

	if (last_menu == nullptr)
		return false;

	menu_action * menu = menu_action::find(argv[1]);
	if (!menu) return false;
	if (menu == last_menu) return false;

	uint n = last_menu->menu.nitems;
	cfg_menu_item * items = realloc<cfg_menu_item>(last_menu->menu.items, n + 1);
	cfg_menu_item * item = items + n;

	item->name = nullptr;
	item->menu = &menu->menu;

	last_menu->menu.items = items;
	last_menu->menu.nitems = n + 1;

	return true;
}

const command commands[] =
{
	{ "Include", cmd_include },
	{ "Font", cmd_font },
	{ "Cursor", cmd_cursor },
	{ "CursorColor", cmd_cursor_color },
	{ "SnapDistance", cmd_snap_dist },
	{ "Workspaces", cmd_workspaces },
	{ "Style", cmd_style },
	{ "BorderWidth", cmd_border_width },
	{ "TitleBar", cmd_title_bar },
	{ "TitleBGColor", cmd_title_bg_color },
	{ "TitleFGColor", cmd_title_fg_color },
	{ "TitlePixmap", cmd_title_pixmap },
	{ "TitleText", cmd_title_text },
	{ "NumTitleDecor", cmd_num_title_border },
	{ "TitleDecor", cmd_title_border },
	{ "TitleDecorColor", cmd_title_border_color },
	{ "TitleDecorPixmap", cmd_title_border_pixmap },
	{ "NumBorder", cmd_num_border },
	{ "Border", cmd_border },
	{ "BorderColor", cmd_border_color },
	{ "BorderPixmap", cmd_border_pixmap },
	{ "InfoText", cmd_util_text },
	{ "InfoBGColor", cmd_util_bg_color },
	{ "InfoFGColor", cmd_util_fg_color },
	{ "InfoPixmap", cmd_util_pixmap },
	{ "MenuText", cmd_util_text },
	{ "MenuBGColor", cmd_util_bg_color },
	{ "MenuFGColor", cmd_util_fg_color },
	{ "MenuPixmap", cmd_util_pixmap },
	{ "MenuArrow", cmd_menu_arrow },
	{ "MaxMenuWidth", cmd_menu_width },
	{ "ButtonPress", cmd_button_press },
	{ "ButtonRelease", cmd_button_release },
	{ "Modifier", cmd_modifier },
	{ "Key", cmd_key },
	{ "Menu", cmd_menu },
	{ "MenuItem", cmd_menu_item },
	{ "SubMenu", cmd_sub_menu }
};

bool run_cmd(uint argc, char ** argv)
{
	for (const command & cmd : commands)
	{
		if (str_eq(cmd.name, argv[0]))
			return cmd.run(argc, argv);
	}

	return false;
}

}

void config::init(const char * dir)
{
	if (dir)
	{
		confdir = strdup(dir);
		dirlen = strlen(confdir);
	}
	else
	{
		char * home = getenv("HOME");
		if (!home)
		{
			passwd * pwd = getpwuid(getuid());
			if (!pwd)
			{
				perror("getpwuid");
				exit(1);
			}
			home = pwd->pw_dir;
		}

		dirlen = strlen(home) + strlen(DEFAULT_PATH);
		confdir = malloc<char>(dirlen + 1);
		sprintf(confdir, "%s" DEFAULT_PATH, home);
	}
}

void config::read(const char * file)
{
	char * path = static_cast<char *>(alloca(strlen(file) + dirlen + 2));
	sprintf(path, "%s/%s", confdir, file);

	FILE * fp = fopen(path, "r");
	if (!fp)
	{
		perror(path);
		return;
	}

	char * line = nullptr;
	size_t n = 0;
	uint lineno = 0;

	while (getline(&line, &n, fp) >= 0)
	{
		lineno++;

		char * argv[MAX_ARGS + 1];
		uint argc = 0;
		char * ip = line;
		char * op = line;
		uchar s = 0;

		while (argc < MAX_ARGS)
		{
			uchar c = *(ip++);
			if (c == 0) break;

			if (s < 2)
			{
				if (c == '#') break;

				if (c <= ' ') // c is unsigned for this to work
				{
					if (s)
					{
						*(op++) = 0;
						argc++;
						s = 0;
					}

					continue;
				}

				if (s == 0)
				{
					argv[argc] = op;
					s = 1;
				}
			}

			if (c == '"')
			{
				s ^= 2;
				continue;
			}

			if (c == '\\')
			{
				c = *(ip++);
				if (c == 0) break;
			}

			*(op++) = c;
		}

		if (s)
		{
			*op = 0;
			argc++;
		}

		if (!argc) continue;

		for (uint i = argc; i <= MAX_ARGS; i++)
		{
			argv[i] = nullptr;
		}

		if (!run_cmd(argc, argv))
		{
			fprintf(stderr, "%s: Error at line %d\n", path, lineno);
		}
	}

	if (line) free(line);

	fclose(fp);
}

void config::fini()
{
#ifdef USE_XFT
	if (!font) font = xft_font_open("sans", 12);
#else
	if (!font) font = XLoadQueryFont(dpy, "fixed");
#endif

	int a = font->ascent;
	int h = a + font->descent;

	cfg_style * csp = style + STYLE_INFO;
	csp->util.left += csp->left;
	csp->util.right += csp->right;
	int ih = csp->util.height;
	if (ih)
	{
		csp->util.height = ih + csp->top + csp->bottom;
		csp->util.baseline = div2(ih - h) + a + csp->top;
	}
	else
	{
		csp->util.height = h + csp->top + csp->bottom;
		csp->util.baseline = a + csp->top;
	}

	cfg_util * cfg = &style[STYLE_MENU].util;
	int mh = cfg->height;
	if (mh)
	{
		cfg->baseline = div2(mh - h) + a;
	}
	else
	{
		cfg->height = h;
		cfg->baseline = a;
	}
}
