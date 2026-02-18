{
  lib,
  stdenv,
  fetchurl,
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
  dash,
  xsetroot,
}:

stdenv.mkDerivation rec {
  pname = "chadwm";
  version = "6.6";

  src = "${inputs.chadwm}/chadwm/";

  buildInputs = [
    libX11
    libXinerama
    libXft

    imlib2
    libxcb
    xcbutil
    xcbutilwm
    xcbutilkeysyms

    dash
    xsetroot
  ];

  dependencies = buildInputs;

  prePatch = ''
    sed -i "s@/usr/local@$out@" config.mk

    sed -i "s@/usr/share/xsessions@$out/share/xsessions@g" Makefile

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
    homepage = "https://github.com/siduck/chadwm";
    description = "Extremely fast, small, and dynamic window manager for X";
    longDescription = ''
      chadwm is a dynamic window manager for X. It manages windows in tiled,
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
    mainProgram = "chadwm";
  };
}
