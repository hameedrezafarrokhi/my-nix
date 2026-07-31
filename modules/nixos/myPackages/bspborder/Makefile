CC      ?= cc
CFLAGS  ?= -O2 -Wall -Wextra
LDLIBS  := -lX11

PREFIX  ?= /usr/local
BINDIR  := $(PREFIX)/bin

.PHONY: all clean install uninstall

all: bspborder

bspborder: bspborder.c
	$(CC) $(CFLAGS) -o $@ $< $(LDLIBS)

install: bspborder
	install -Dm755 bspborder $(DESTDIR)$(BINDIR)/bspborder
	install -Dm644 bspborder.conf $(DESTDIR)$(HOME)/.config/bspborder/bspborder.conf.example

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/bspborder

clean:
	rm -f bspborder
