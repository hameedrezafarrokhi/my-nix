static const unsigned int borderpx = 2;
static const unsigned int snap = 32;
static const float uiscale = 1.0f;
static const int showbar = 1;
static const int topbar = 1;

static const unsigned int gappih = 8;
static const unsigned int gappiv = 8;
static const unsigned int gappoh = 8;
static const unsigned int gappov = 8;
static const int smartgaps = 0;

static const char *fonts[] = {
    "-misc-fixed-medium-r-normal--13-120-75-75-c-70-iso10646-1",
    "9x15",
    "fixed"
};
static const char *colors[][2] = {
    [SchemeNorm] = { "#bbbbbb", "#222222" },
    [SchemeSel]  = { "#eeeeee", "#005577" },
};

static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

/* Hyprland-style: each monitor only shows / switches its own workspaces (tags). */
static const int per_monitor_ws = 1;
/* For each tag index, which monitor (0..n-1) owns it; -1 means tag_index % num_monitors */
static const int tagmonmap[] = { -1, -1, -1, -1, -1, -1, -1, -1, -1 };

static const Rule rules[] = {
    { "Gimp",     NULL,     NULL,       0,         1,          -1 },
};

static const char *dmenucmd[] = { "dmenu_run", NULL };
static const char *termcmd[] = { "xterm", NULL };
static const char *scratchcmd[] = { "xterm", "-name", "pwm-scratch", NULL };

static const Layout layouts[] = {
    { "TILE",     tile },
    { "MAX",      maxview },
    { "FLOAT",    NULL },
};

#define MODKEY Mod1Mask
#define TAGKEYS(KEY,TAG) \
    { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
    { MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

static const Key keys[] = {
    { MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },
    { MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
    { MODKEY,                       XK_s,      togglescratch,  {.v = scratchcmd } },
    { MODKEY,                       XK_b,      togglebar,      {0} },
    { MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
    { MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
    { MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
    { MODKEY|ShiftMask,             XK_i,      incnmaster,     {.i = -1 } },
    { MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
    { MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
    { MODKEY,                       XK_Return, zoom,           {0} },
    { MODKEY,                       XK_Tab,    view,           {0} },
    { MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
    { MODKEY,                       XK_m,      setlayout,      {.v = &layouts[1]} },
    { MODKEY,                       XK_f,      setlayout,      {.v = &layouts[2]} },
    { MODKEY,                       XK_space,  setlayout,      {0} },
    { MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
    { MODKEY,                       XK_g,      togglegaps,     {0} },
    { MODKEY|ShiftMask,             XK_minus,  incrgaps,       {.i = -1 } },
    { MODKEY|ShiftMask,             XK_equal,  incrgaps,       {.i = +1 } },
    { MODKEY,                       XK_0,      view,           {.ui = ~0 } },
    { MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
    { MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
    { MODKEY,                       XK_period, focusmon,       {.i = +1 } },
    { MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
    { MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
    { MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
    { MODKEY|ShiftMask,             XK_q,      quit,           {0} },
    TAGKEYS(                        XK_1,                      0)
    TAGKEYS(                        XK_2,                      1)
    TAGKEYS(                        XK_3,                      2)
    TAGKEYS(                        XK_4,                      3)
    TAGKEYS(                        XK_5,                      4)
    TAGKEYS(                        XK_6,                      5)
    TAGKEYS(                        XK_7,                      6)
    TAGKEYS(                        XK_8,                      7)
    TAGKEYS(                        XK_9,                      8)
};

static const Button buttons[] = {
    { ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
    { ClkWinTitle,          0,              Button2,        zoom,           {0} },
    { ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
    { ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
    { ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
    { ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
    { ClkTagBar,            0,              Button1,        view,           {0} },
    { ClkTagBar,            0,              Button3,        toggleview,     {0} },
    { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
    { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
