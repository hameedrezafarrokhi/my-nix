PREFIX?=/usr/X11R6
CFLAGS?=-pedantic -Wall -O3

all:
	$(CC) $(CFLAGS) -I$(PREFIX)/include vswm.c -L$(PREFIX)/lib -lX11 -o vswm
	cp -f vswm /usr/games

clean:
	rm -f vswm

