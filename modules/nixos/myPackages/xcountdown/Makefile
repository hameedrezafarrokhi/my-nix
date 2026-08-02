CC ?= cc
PKG_CONFIG ?= pkg-config

PKGS := x11 xft xrender xext
CFLAGS ?= -O2 -Wall -Wextra -std=c11
CFLAGS += $(shell $(PKG_CONFIG) --cflags $(PKGS))
LDLIBS := $(shell $(PKG_CONFIG) --libs $(PKGS)) -lm

SRC := $(wildcard src/*.c)
OBJ := $(SRC:.c=.o)
BIN := countdown

PREFIX ?= /usr/local

.PHONY: all clean install uninstall

all: $(BIN)

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $(OBJ) $(LDLIBS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(BIN) src/*.o

install: $(BIN)
	install -Dm755 $(BIN) $(DESTDIR)$(PREFIX)/bin/$(BIN)
	install -Dm644 config/countdown.conf.example \
		$(DESTDIR)$(PREFIX)/share/doc/countdown/countdown.conf.example

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(BIN)
