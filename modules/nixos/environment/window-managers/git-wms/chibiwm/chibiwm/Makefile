CC = gcc
CFLAGS = -Wall -Wextra
LIBS = -lX11 -lXft $(shell pkg-config --cflags xft freetype2)

all: config.h chibiwm

config.h: 
	cp config.def.h config.h

chibiwm:
	$(CC) $(CFLAGS) main.c $(LIBS) -o chibiwm

clean:
	rm -f chibiwm

install:
	sudo cp -f chibiwm /usr/bin/chibiwm

.PHONY: all clean install
