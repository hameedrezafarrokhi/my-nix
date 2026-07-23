CC = gcc
TARGET = swgt
SOURCES = swgt.c

LIBS = -lX11 -lXext -lXft -lm `pkg-config --libs fontconfig`
INCLUDES = `pkg-config --cflags fontconfig`
COMMON_FLAGS = -Wall -Wextra $(INCLUDES)

DEV_FLAGS = $(COMMON_FLAGS) -g -O0 -DDEBUG
RELEASE_FLAGS = $(COMMON_FLAGS) -O3 -Ofast -march=native -mtune=native -flto -funroll-loops -fomit-frame-pointer -ffast-math -DNDEBUG -s

all: release

dev:
	$(CC) $(DEV_FLAGS) $(SOURCES) -o $(TARGET) $(LIBS)
	@echo "Development build complete: $(TARGET)"

release:
	$(CC) $(RELEASE_FLAGS) $(SOURCES) -o $(TARGET) $(LIBS)
	@echo "Release build complete: $(TARGET)"

clean:
	rm -f $(TARGET)

install: release
	install -m 755 $(TARGET) /usr/local/bin/

uninstall:
	rm -f /usr/local/bin/$(TARGET)

.PHONY: all dev release clean install uninstall
