include config.mk

SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)

all: pwm

pwm: $(OBJ)
	$(CC) -o $@ $(OBJ) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f pwm $(OBJ)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f pwm $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/pwm

	mkdir -p $(DESTDIR)$(PREFIX)/share/xsessions
	cp -f pwm.desktop $(DESTDIR)$(PREFIX)/share/xsessions

	mkdir -p $(DESTDIR)$(PREFIX)/share/pwm
	cp -n config.def.h $(DESTDIR)$(PREFIX)/share/pwm/config.def.h

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/pwm
	rm -f $(DESTDIR)$(PREFIX)/share/xsessions/pwm.desktop
	rm -rf $(DESTDIR)$(PREFIX)/share/pwm

