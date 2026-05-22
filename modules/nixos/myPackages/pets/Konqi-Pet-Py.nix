{ lib
, stdenv
, fetchFromGitHub
, python3
, wrapGAppsHook3
, glib
, gobject-introspection
, libxcb
, libxcb-cursor
, libxcb-image
, libxcb-keysyms
, libxcb-render-util
, libxcb-util
, libxcb-wm
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pillow
    pyqt6
    requests
    xlib
    psutil
   #ewmh          # WARNING Need After Internet
    pygobject3
    configparser
  ]);
in

stdenv.mkDerivation rec {
  pname = "Konqi-Pet-Py";
  version = "2026-05-01";

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    glib
    libxcb
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
  ];

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "true";

  installPhase = ''
    # Create executable wrapper
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname} \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"
  '';

  meta = with lib; {
    homepage = "https://github.com/rostikcermak-pixel/Konqi-Pet";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "Konqi-Pet-Py";
  };
}
