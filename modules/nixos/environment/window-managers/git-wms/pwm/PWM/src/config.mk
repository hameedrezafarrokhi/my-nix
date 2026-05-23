PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

X11INC = /usr/include/X11
X11LIB = /usr/lib64

INCS = -I$(X11INC)
LIBS = -L$(X11LIB) -lX11

CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_POSIX_C_SOURCE=200809L
ifneq (,$(wildcard $(X11INC)/extensions/Xrandr.h))
CPPFLAGS += -DHAVE_XRANDR
LIBS += -lXrandr
endif

CFLAGS = -std=c99 -pedantic -Wall -Wextra -Os $(INCS) $(CPPFLAGS)
LDFLAGS = $(LIBS)

CC = cc
