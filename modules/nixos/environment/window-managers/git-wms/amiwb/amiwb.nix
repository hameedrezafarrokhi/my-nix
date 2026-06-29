{
  lib,
  stdenv,
  fetchFromGitHub,

  libx11,
  libxft,
  libxrandr,
  libxrender,
  libxres,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxmu,
  libxpm,
  libxmp,
  libxt,
  libxdamage,
  libxdmcp,
  libxcomp,
  libxcomposite,
  libxkbcommon,

  libxcb,
  libxcb-wm,
  libxcb-util,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-errors,
  libxcb-cursor,

  fontconfig,
  freetype,

  pkg-config,
  libsm,
  libice,
  libxfixes,
  imlib2Full,
  writeText,

  makefile ? ''
# AMIWB Desktop Environment Makefile
# Builds only amiwb window manager and toolkit library

CC = gcc
AR = ar

# Common flags
COMMON_CFLAGS = -g -Wall
COMMON_INCLUDES = -I. -Isrc -I/usr/include/freetype2 -I/usr/include/X11/Xft

# Libraries
LIBS = -lSM -lICE -lXext -lXmu -lX11 -lXrender -lXfixes -lXdamage \
       -lXft -lXrandr -lXcomposite -lm -lImlib2 -lfontconfig

# Directories
AMIWB_DIR = src/amiwb
TOOLKIT_DIR = src/toolkit

# Source files
AMIWB_SRCS = $(wildcard $(AMIWB_DIR)/*.c) \
             $(wildcard $(AMIWB_DIR)/intuition/*.c) \
             $(wildcard $(AMIWB_DIR)/workbench/*.c) \
             $(wildcard $(AMIWB_DIR)/menus/*.c) \
             $(wildcard $(AMIWB_DIR)/menus/addons/*.c) \
             $(wildcard $(AMIWB_DIR)/dialogs/*.c) \
             $(wildcard $(AMIWB_DIR)/events/*.c) \
             $(wildcard $(AMIWB_DIR)/render/*.c) \
             $(wildcard $(AMIWB_DIR)/icons/*.c)
TOOLKIT_SRCS = $(wildcard $(TOOLKIT_DIR)/*.c) \
               $(wildcard $(TOOLKIT_DIR)/button/*.c) \
               $(wildcard $(TOOLKIT_DIR)/inputfield/*.c) \
               $(wildcard $(TOOLKIT_DIR)/listview/*.c) \
               $(wildcard $(TOOLKIT_DIR)/progressbar/*.c) \
               $(wildcard $(TOOLKIT_DIR)/textview/*.c)

# Object files
AMIWB_OBJS = $(AMIWB_SRCS:.c=.o)
TOOLKIT_OBJS = $(TOOLKIT_SRCS:.c=.o)

# Outputs
AMIWB_EXEC = amiwb
TOOLKIT_LIB = libamiwb.so

# Default target
all: $(TOOLKIT_LIB) $(AMIWB_EXEC) reqasl editpad

# Toolkit shared library
$(TOOLKIT_LIB): $(TOOLKIT_OBJS)
	$(CC) -shared -o $@ $(TOOLKIT_OBJS) $(LIBS)

# amiwb window manager
$(AMIWB_EXEC): $(AMIWB_OBJS) $(TOOLKIT_LIB)
	$(CC) $(AMIWB_OBJS) -L. -lamiwb $(LIBS) -Wl,-rpath,'$$ORIGIN' -Wl,-rpath,$out/lib -o $@

# ReqASL file requester (depends on toolkit library)
reqasl: $(TOOLKIT_LIB)
	@echo "Building ReqASL..."
	$(MAKE) -C src/reqasl

# EditPad text editor (depends on toolkit library)
editpad: $(TOOLKIT_LIB)
	@echo "Building EditPad..."
	$(MAKE) -C src/editpad

# Pattern rules for object files
$(AMIWB_DIR)/%.o: $(AMIWB_DIR)/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -c $< -o $@

$(AMIWB_DIR)/intuition/%.o: $(AMIWB_DIR)/intuition/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -c $< -o $@

$(AMIWB_DIR)/workbench/%.o: $(AMIWB_DIR)/workbench/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -c $< -o $@

$(AMIWB_DIR)/menus/%.o: $(AMIWB_DIR)/menus/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -c $< -o $@

$(AMIWB_DIR)/menus/addons/%.o: $(AMIWB_DIR)/menus/addons/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -c $< -o $@

$(AMIWB_DIR)/dialogs/%.o: $(AMIWB_DIR)/dialogs/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -c $< -o $@

$(AMIWB_DIR)/events/%.o: $(AMIWB_DIR)/events/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -c $< -o $@

$(AMIWB_DIR)/render/%.o: $(AMIWB_DIR)/render/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -c $< -o $@

$(AMIWB_DIR)/icons/%.o: $(AMIWB_DIR)/icons/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -c $< -o $@

$(TOOLKIT_DIR)/%.o: $(TOOLKIT_DIR)/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -fPIC -c $< -o $@

$(TOOLKIT_DIR)/button/%.o: $(TOOLKIT_DIR)/button/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -fPIC -c $< -o $@

$(TOOLKIT_DIR)/inputfield/%.o: $(TOOLKIT_DIR)/inputfield/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -fPIC -c $< -o $@

$(TOOLKIT_DIR)/listview/%.o: $(TOOLKIT_DIR)/listview/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -fPIC -c $< -o $@

$(TOOLKIT_DIR)/progressbar/%.o: $(TOOLKIT_DIR)/progressbar/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -fPIC -c $< -o $@

$(TOOLKIT_DIR)/textview/%.o: $(TOOLKIT_DIR)/textview/%.c
	$(CC) $(COMMON_CFLAGS) $(COMMON_INCLUDES) -fPIC -c $< -o $@

# Clean
clean:
	rm -f $(AMIWB_OBJS) $(TOOLKIT_OBJS) $(AMIWB_EXEC) $(TOOLKIT_LIB)
	$(MAKE) -C src/reqasl clean
	$(MAKE) -C src/editpad clean

# Install
install: $(TOOLKIT_LIB) $(AMIWB_EXEC) reqasl editpad
	# Install toolkit shared library and headers
	mkdir -p $out/lib
	cp $(TOOLKIT_LIB) $out/lib/libamiwb.so.new
	mv $out/lib/libamiwb.so.new $out/lib/libamiwb.so
	ldconfig
	mkdir -p $out/include/amiwb/toolkit
	cp $(TOOLKIT_DIR)/*.h $out/include/amiwb/toolkit/
	cp $(TOOLKIT_DIR)/button/*.h $out/include/amiwb/toolkit/
	cp $(TOOLKIT_DIR)/inputfield/*.h $out/include/amiwb/toolkit/
	cp $(TOOLKIT_DIR)/listview/*.h $out/include/amiwb/toolkit/
	cp $(TOOLKIT_DIR)/progressbar/*.h $out/include/amiwb/toolkit/
	cp $(TOOLKIT_DIR)/textview/*.h $out/include/amiwb/toolkit/
	# Install amiwb binary
	mkdir -p $out/bin
	cp $(AMIWB_EXEC) $out/bin/amiwb.new
	mv $out/bin/amiwb.new $out/bin/amiwb
	# Install ReqASL file requester
	$(MAKE) -C src/reqasl install
	# Install EditPad text editor
	$(MAKE) -C src/editpad install
	# Install resources
	mkdir -p $out/share/amiwb/icons
	cp -r icons/* $out/share/amiwb/icons/ 2>/dev/null || true
	mkdir -p $out/share/amiwb/patterns
	cp -r patterns/* $out/share/amiwb/patterns/ 2>/dev/null || true
	mkdir -p $out/share/amiwb/fonts
	cp -r fonts/* $out/share/amiwb/fonts/ 2>/dev/null || true
	mkdir -p $out/share/amiwb/dotfiles
	cp -r dotfiles/* $out/share/amiwb/dotfiles/ 2>/dev/null || true
	# Fix permissions on all installed resources (files readable, directories accessible)
	chmod -R a+rX $out/share/amiwb/
	# Install default config files to user's home directory if they don't exist

	#@if [ -n "$$SUDO_USER" ]; then \
	#	USER_HOME=$$(getent passwd $$SUDO_USER | cut -d: -f6); \
	#elif [ -n "$$USER" ] && [ "$$USER" != "root" ]; then \
	#	USER_HOME=$$(getent passwd $$USER | cut -d: -f6); \
	#else \
	#	USER_HOME="$$HOME"; \
	#fi; \
	#if [ -n "$$USER_HOME" ] && [ -d "$$USER_HOME" ]; then \
	#	CONFIG_DIR="$$USER_HOME/.config/amiwb"; \
	#	mkdir -p "$$CONFIG_DIR"; \
	#	if [ ! -f "$$CONFIG_DIR/amiwbrc" ]; then \
	#		cp dotfiles/home_dot_config_amiwb/amiwbrc "$$CONFIG_DIR/amiwbrc"; \
	#		echo "Installed amiwbrc to $$CONFIG_DIR/"; \
	#	fi; \
	#	if [ ! -f "$$CONFIG_DIR/toolsdaemonrc" ]; then \
	#		cp dotfiles/home_dot_config_amiwb/toolsdaemonrc "$$CONFIG_DIR/toolsdaemonrc"; \
	#		echo "Installed toolsdaemonrc to $$CONFIG_DIR/"; \
	#	fi; \
	#	if [ -n "$$SUDO_USER" ]; then \
	#		chown -R $$SUDO_USER:$$SUDO_USER "$$CONFIG_DIR"; \
	#	elif [ -n "$$USER" ] && [ "$$USER" != "root" ]; then \
	#		chown -R $$USER:$$USER "$$CONFIG_DIR" 2>/dev/null || true; \
	#	fi; \
	#fi

	@echo "AmiWB, toolkit, ReqASL, and EditPad installed"

# Uninstall
uninstall:
	rm -f $out/bin/amiwb
	rm -f $out/lib/libamiwb.so
	$(MAKE) -C src/reqasl uninstall
	$(MAKE) -C src/editpad uninstall
	ldconfig
	rm -rf $out/include/amiwb
	rm -rf $out/share/amiwb
	@echo "AmiWB, ReqASL, and EditPad uninstalled"

.PHONY: all clean install uninstall reqasl editpad
  '',

}:

stdenv.mkDerivation rec {
  pname = "amiwb";
  version = "2025-12-20";

  src = fetchFromGitHub {
    owner = "nsklaus";
    repo = "amiwb";
   #rev = "master";
    rev = "c74edf2578d6e0ed88df3d9dea32d73828b186fc";
    sha256 = "1w9i0d1njs75pblr260gvs6ikf6gaksc4v8psmzccy694qlb6149";
  };

  postPatch =
    let
      makeFile =
        if lib.isDerivation makefile || builtins.isPath makefile then makefile else writeText "Makefile" makefile;
    in
    lib.optionalString (makefile != null) "cp ${makeFile} Makefile";


  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    fontconfig
    freetype
    libsm
    libice
    libxfixes
    imlib2Full
  ];

  preBuild = ''
    mkdir -p $out/etc
  '';

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];
 #
 #buildPhase = ''
 #  runHook preBuild
 #
 #
 #
 #  runHook postBuild
 #'';
 #
 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp amiwb $out/bin/amiwb
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/nsklaus/amiwb";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "amiwb";
  };
}
