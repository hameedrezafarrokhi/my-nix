CC         ?= gcc
PKG_CONFIG ?= pkg-config

PKGS    := dbus-1 x11 xft xext
CFLAGS  ?= -O2 -Wall -Wextra -std=c11
CFLAGS  += -D_POSIX_C_SOURCE=200809L -D_DEFAULT_SOURCE
CFLAGS  += $(shell $(PKG_CONFIG) --cflags $(PKGS))
LDLIBS  := $(shell $(PKG_CONFIG) --libs $(PKGS)) -lm

TARGET  := polybar-kdeconnect
PREFIX  ?= $(HOME)/.local/bin

SRCS := main.c daemon.c render.c actions.c filepicker.c fmenu.c xmenu.c notify.c dbus_client.c state_file.c
OBJS := $(SRCS:.c=.o)

.PHONY: all install clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LDLIBS)

%.o: %.c config.h
	$(CC) $(CFLAGS) -c $< -o $@

install: $(TARGET)
	install -Dm755 $(TARGET) $(PREFIX)/$(TARGET)

clean:
	rm -f $(TARGET) $(OBJS)
