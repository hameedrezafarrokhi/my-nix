MAKEFLAGS+=-rR

XFT=1

CC=gcc
CFLAGS=-O2
LDFLAGS=-s

STD=-std=gnu++11 -nostdinc++ -fno-exceptions -fno-rtti
WARN=-Wall -Wextra -Wold-style-cast -Wzero-as-null-pointer-constant -Wshadow
CCFLAGS=$(CFLAGS) $(STD) $(WARN)
LIBS=-lXpm -lXext -lX11

ifeq (1,$(XFT))
LIBS:=-lXft -lfontconfig $(LIBS)
CCFLAGS+=-I/usr/include/freetype2 -DUSE_XFT=1
endif

PROG=fowm
OFILES=main.o screen.o frame.o client.o title.o border.o \
	decoration.o info.o menu.o winmenu.o utility.o window.o \
	action.o atoms.o pixmap.o cursor.o config.o misc.o
CFILES=main.cc screen.cc frame.cc client.cc title.cc border.cc \
	decoration.cc info.cc menu.cc winmenu.cc utility.cc window.cc \
	action.cc atoms.cc pixmap.cc cursor.cc config.cc misc.cc

$(PROG): $(OFILES)
	$(CC) $(LDFLAGS) -o $(PROG) $(OFILES) $(LIBS)

%.o: %.cc
	$(CC) $(CCFLAGS) -c $<

distclean: clean
	rm -f $(PROG) depend.mk

clean: tidy
	rm -f *.o

tidy:
	rm -f *~ *.bak *.orig

depend:
	$(CC) -MM $(CFILES) > depend.mk

ifeq (depend.mk, $(wildcard depend.mk))
include depend.mk
endif
