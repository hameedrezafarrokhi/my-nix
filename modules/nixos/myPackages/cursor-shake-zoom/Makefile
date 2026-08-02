PREFIX      ?= /usr/local
BINDIR      ?= $(PREFIX)/bin

CC          ?= gcc
CFLAGS      ?= -O3 -Wall -Wextra -std=c11
LDFLAGS     ?=

TARGET      := cursor-scaler
SRC         := src/cursor_scaler.c src/config.c src/svg_loader.c
INCLUDES    := -Iinclude

BASE_PKGS   := x11 xext xcursor xi xrender xfixes
BASE_CFLAGS := $(shell pkg-config --cflags $(BASE_PKGS) 2>/dev/null)
BASE_LIBS   := $(shell pkg-config --libs $(BASE_PKGS) 2>/dev/null) -lm

# Optional: lossless SVG-based zoom. Auto-detected; force off with
# `make NO_RSVG=1` or force on with `make RSVG=1`.
RSVG_PKGS   := librsvg-2.0 cairo
ifeq ($(NO_RSVG),1)
  HAVE_RSVG :=
else ifeq ($(RSVG),1)
  HAVE_RSVG := 1
else
  HAVE_RSVG := $(shell pkg-config --exists $(RSVG_PKGS) 2>/dev/null && echo 1)
endif

ifeq ($(HAVE_RSVG),1)
  SVG_CFLAGS := -DHAVE_RSVG $(shell pkg-config --cflags $(RSVG_PKGS))
  SVG_LIBS   := $(shell pkg-config --libs $(RSVG_PKGS))
else
  SVG_CFLAGS :=
  SVG_LIBS   :=
endif

.PHONY: all clean install uninstall info

all: info $(TARGET)

info:
ifeq ($(HAVE_RSVG),1)
	@echo "cursor-scaler: building WITH librsvg support (lossless SVG zoom available)"
else
	@echo "cursor-scaler: building WITHOUT librsvg support (install librsvg2-dev + libcairo2-dev for lossless SVG zoom)"
endif

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(INCLUDES) $(BASE_CFLAGS) $(SVG_CFLAGS) -o $@ $(SRC) $(BASE_LIBS) $(SVG_LIBS) $(LDFLAGS)

clean:
	rm -f $(TARGET)

install: $(TARGET)
	install -Dm755 $(TARGET) $(DESTDIR)$(BINDIR)/$(TARGET)
	install -Dm644 config/cursor-scaler.conf.example $(DESTDIR)$(PREFIX)/share/doc/cursor-scaler/config.conf.example
	install -Dm644 systemd/cursor-scaler.service $(DESTDIR)$(PREFIX)/lib/systemd/user/cursor-scaler.service

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(TARGET)
	rm -f $(DESTDIR)$(PREFIX)/lib/systemd/user/cursor-scaler.service
