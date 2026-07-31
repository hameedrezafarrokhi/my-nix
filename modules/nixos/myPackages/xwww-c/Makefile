PREFIX ?= /usr/local
BINDIR  = $(PREFIX)/bin
CC     ?= cc

CFLAGS  ?= -O2 -Wall -Wextra -std=c11 -pthread
CFLAGS  += -D_POSIX_C_SOURCE=200809L
LDLIBS   = -lm -lpthread

# Required deps
X11_CFLAGS  := $(shell pkg-config --cflags x11 2>/dev/null)
X11_LIBS    := $(shell pkg-config --libs x11 2>/dev/null || echo -lX11)
IMLIB2_CFLAGS := $(shell pkg-config --cflags imlib2 2>/dev/null)
IMLIB2_LIBS   := $(shell pkg-config --libs imlib2 2>/dev/null || echo -lImlib2)

CFLAGS += $(X11_CFLAGS) $(IMLIB2_CFLAGS)
LDLIBS += $(X11_LIBS) $(IMLIB2_LIBS)

# Optional: MIT-SHM (fast per-frame blit). On by default; nearly every
# X11 install has it, but you can force it off with `make HAVE_XSHM=0`.
HAVE_XSHM ?= 1
ifeq ($(HAVE_XSHM),1)
CFLAGS += -DHAVE_XSHM
LDLIBS += -lXext
endif

# Optional: Xinerama (multi-monitor --output support). Falls back to
# treating the whole X screen as one monitor if unavailable.
HAVE_XINERAMA ?= $(shell pkg-config --exists xinerama 2>/dev/null && echo 1 || echo 0)
ifeq ($(HAVE_XINERAMA),1)
CFLAGS += -DHAVE_XINERAMA
LDLIBS += -lXinerama
endif

SRC = src/main.c src/config.c src/buffer.c src/image.c src/xroot.c \
      src/transitions.c src/lastrun.c src/util.c
OBJ = $(SRC:.c=.o)
BIN = xwww

.PHONY: all clean install uninstall
all: $(BIN)

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $(OBJ) $(LDLIBS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJ) $(BIN)

install: $(BIN)
	install -Dm755 $(BIN) $(DESTDIR)$(BINDIR)/$(BIN)
	install -Dm644 config/xwwwrc.example $(DESTDIR)$(PREFIX)/share/xwww/xwwwrc.example

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(BIN)
	rm -rf $(DESTDIR)$(PREFIX)/share/xwww
