{
  lib,
  stdenv,
 #fetchurl,
 #fetchTarball,
  libX11,
  libXinerama,
  libXft,
  writeText,
  patches ? [ ],
  conf ? null,
  # update script dependencies
  gitUpdater,

  imlib2,
  libxcb,
  xcbutil,
  xcbutilwm,
  xcbutilkeysyms,

  inputs,
}:

stdenv.mkDerivation rec {
  pname = "titus-wm";
  version = "6.6";

 #src = fetchurl {
 #  url = "https://dl.suckless.org/dwm/${pname}-${version}.tar.gz";
 #  sha256 = "sha256-Ideev6ny+5MUGDbCZmy4H0eExp1k5/GyNS+blwuglyk=";
 #};

 #src = fetchurl {
 #  url = "https://github.com/ChrisTitusTech/dwm-titus/archive/master.tar.gz";
 #  sha256 = "sha256-Om0StJTkXIHhtkAklwfNSy5KJsiRZto7CHrJlVvHl7U=";
 #};

  src = inputs.dwm-titus;

 #src = "${inputs.dwm-titus}/";

  buildInputs = [
    libX11
    libXinerama
    libXft

    imlib2
    libxcb
    xcbutil
    xcbutilwm
    xcbutilkeysyms
  ];
  #sed -i "s@release@$out@" Makefile
  #sed -i "s@/usr/share/xsessions@$out@" Makefile
  prePatch = ''
    sed -i "s@/usr/local@$out@" config.mk

    sed -i "s@/usr/share/xsessions@$out/share/xsessions@g" Makefile

    sed -i '/xinitrc/d' Makefile
  '';

  # Allow users set their own list of patches
  inherit patches;

  # Allow users to set the config.def.h file containing the configuration
  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

 #passthru.updateScript = gitUpdater {
 #  url = "git://git.suckless.org/dwm";
 #};

  meta = with lib; {
    homepage = "https://github.com/ChrisTitusTech/dwm-titus/";
    description = "Extremely fast, small, and dynamic window manager for X";
    longDescription = ''
      dwm is a dynamic window manager for X. It manages windows in tiled,
      monocle and floating layouts. All of the layouts can be applied
      dynamically, optimising the environment for the application in use and the
      task performed.
      Windows are grouped by tags. Each window can be tagged with one or
      multiple tags. Selecting certain tags displays all windows with these
      tags.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ neonfuz ];
    platforms = platforms.all;
    mainProgram = "titus-wm";
  };
}
