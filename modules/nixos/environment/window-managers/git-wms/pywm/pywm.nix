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
  python3,
  python3Packages,
  makeWrapper,
  gobject-introspection,
  glib,
  wrapGAppsHook3,
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pygobject3
    configparser
    xlib
    setuptools
    ewmh
    psutil
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "Gabe-Corral";
    repo = "pywm";
   #rev = "master";
    rev = "9fe2bf17e0d9addfcf1fe62d5d23d7185013ae60";
    sha256 = "10hw8d5xwp9a3ymb9497cikyzgclbc37sw0i8c6n3ijb9i1ydzan";
  };

  ename = "pywm";

in

stdenv.mkDerivation rec {
  pname = "pywm-py";
  version = "2026-05-28";

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    glib
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
  ];

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "true";

  installPhase = ''

    # Create python wrapper
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname} \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"

    # Create Launcher
    cat > $out/bin/${ename} << 'EOF'
    #!/usr/bin/env bash

    SCRIPT_DIR="$HOME/.config/${ename}"
    MAIN_SCRIPT="$SCRIPT_DIR/main.py"

    if [ ! -f "$MAIN_SCRIPT" ]; then
      mkdir -p "$SCRIPT_DIR"
      cp -r ${scriptRepo}/pywm/* "$SCRIPT_DIR/"
    fi
    chmod -R u+rw "$SCRIPT_DIR"
    chmod 644 $MAIN_SCRIPT

    exec ${pname} "$MAIN_SCRIPT"

    EOF

    chmod +x $out/bin/${ename}

  '';

  meta = with lib; {
    homepage = "https://github.com/Gabe-Corral/pywm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "pywm-py";
  };
}
