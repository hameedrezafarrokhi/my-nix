#include "vswm.h"

#define DEBUG 0

#define BAR_HEIGHT 15
#define BAR_BACKGROUND 0xbbbbbb
#define BAR_TEXT 0x101010
#define BAR_BORDER 0xaaaaaa
#define BAR_BORDER_WIDTH 2
#define BAR_SHADOW 0x000000
#define BAR_SHADOW_Y 3
#define BAR_DECORATION "/usr/include/X11/bitmaps/hlines2" 

#define BORDER_WIDTH 2
#define BORDER_ACTIVE_COLOR 0xaaaaaa
#define BORDER_INACTIVE_COLOR 0x202020

#define TITLEBAR_HEIGHT 17
#define TITLEBAR_ACTIVE_COLOR 0xbbbbbb
#define TITLEBAR_INACTIVE_COLOR 0x404040
#define TITLEBAR_BORDER_WIDTH 2
#define TITLEBAR_BORDER_ACTIVE_COLOR 0xaaaaaa
#define TITLEBAR_BORDER_INACTIVE_COLOR 0x202020
#define TITLEBAR_DECORATION "/usr/include/X11/bitmaps/hlines2"

#define TEXT_FONT "fixed"
#define TEXT_ACTIVE_COLOR 0x101010
#define TEXT_INACTIVE_COLOR 0x606060
#define STATUS_TEXT_COLOR 0xFFFFFF

#define MOVE_DELTA 20

#define SHADOW_X 3
#define SHADOW_Y 3
#define SHADOW_COLOR 0x000000

int MOVE_KEY = super;

combo keys[] = {
    { super, "c",   close,         0     },
    { super, "z",   center,        0     },
    { super, "m",   maximize,      0     },
    { super, "Tab", switch_window, 0     },
    { super, "h",   move,          LEFT  },
    { super, "j",   move,          DOWN  },
    { super, "k",   move,          UP    },
    { super, "l",   move,          RIGHT },
    { super, "q",   logout,        0     },

};

// button titlebar[] = {
//     {"/usr/inlcude/X11/bitmaps/xlogo11", close, 0},
// };
