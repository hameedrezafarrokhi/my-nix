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

# Optional: GLX/OpenGL 3.3-core rendering for the "3D" effects (cube,
# axis-spin, full/half-swing, page-turn, roll-away/carpet, shatter,
# paper-plane, burn, melt, ripple). Auto-detected via pkg-config, or
# a raw compile probe if pkg-config doesn't know about it (older distros
# ship libGL without a .pc file). Force off with `make HAVE_GL=0` --
# everything still builds and runs without it, those effects just fall
# back to their CPU versions. src/glrender.c is the only file that
# actually #includes any GL header; without HAVE_GL it compiles to a
# small stub instead, so there's no GL header dependency at all in that
# case, not even at parse time.
HAVE_GL ?= $(shell pkg-config --exists gl 2>/dev/null && echo 1 || \
             (echo 'int main(){return 0;}' | $(CC) -include GL/glx.h -x c - -o /dev/null -lGL 2>/dev/null && echo 1 || echo 0))
ifeq ($(HAVE_GL),1)
CFLAGS += -DHAVE_GL
GL_CFLAGS := $(shell pkg-config --cflags gl 2>/dev/null)
GL_LIBS   := $(shell pkg-config --libs gl 2>/dev/null || echo -lGL)
CFLAGS += $(GL_CFLAGS)
LDLIBS += $(GL_LIBS)
endif

SRC = src/main.c src/config.c src/buffer.c src/image.c src/xroot.c \
      src/transitions.c src/lastrun.c src/util.c \
      src/glrender.c src/gl_effects.c
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
