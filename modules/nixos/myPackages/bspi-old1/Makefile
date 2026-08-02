CC      ?= cc
PREFIX  ?= /usr/local
BINDIR  := $(PREFIX)/bin

CFLAGS  ?= -O2 -Wall -Wextra -std=c11 -D_POSIX_C_SOURCE=200809L -D_GNU_SOURCE
LDFLAGS ?=
LDLIBS  := -lxcb

SRC := $(wildcard src/*.c)
OBJ := $(SRC:src/%.c=build/%.o)
BIN := bspi

.PHONY: all clean install uninstall

all: $(BIN)

build:
	mkdir -p build

build/%.o: src/%.c | build
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN): $(OBJ)
	$(CC) $(LDFLAGS) $(OBJ) -o $@ $(LDLIBS)

clean:
	rm -rf build $(BIN)

install: $(BIN)
	install -Dm755 $(BIN) $(DESTDIR)$(BINDIR)/$(BIN)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(BIN)
