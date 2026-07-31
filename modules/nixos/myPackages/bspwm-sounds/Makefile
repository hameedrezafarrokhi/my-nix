CC      ?= cc
CFLAGS  ?= -O2 -Wall -Wextra -std=c11 -Wno-format-truncation
LDLIBS   = -lpthread -lm -ldl -lX11

SRCS = main.c config.c bspwm_conn.c wmclass.c audio.c
OBJS = $(SRCS:.c=.o)
BIN  = bspwm-sounds

all: $(BIN)

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LDLIBS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(BIN)

.PHONY: all clean
