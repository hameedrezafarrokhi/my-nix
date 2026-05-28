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
    ewmh
    pygobject3
    configparser
  ]);
in

stdenv.mkDerivation rec {
  pname = "Konqi-Pet";
  version = "2026-05-01";

  src = fetchFromGitHub {
    owner = "rostikcermak-pixel";
    repo = "Konqi-Pet";
    rev = "main";
    hash = "sha256-G9wUFG7aYV4N3m3qizXrBmuvwOMLOWlrNz50UVF52BM=";
  };

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

  installPhase = ''
    runHook preInstall

    # Install the Python script
    mkdir -p $out/lib/${pname}
    cp *.py $out/lib/${pname}/
    cp config.json $out/lib/${pname}/
    cp -r assets $out/lib/${pname}/

    # Create executable wrapper
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname} \
      --add-flags "$out/lib/${pname}/main.py" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"

    # Install desktop file
    mkdir -p $out/share/applications
    cat > $out/share/applications/${pname}.desktop <<EOF
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Konqi
    Comment=A Pet
    Exec=$out/bin/${pname}
    EOF

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/rostikcermak-pixel/Konqi-Pet";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "Konqi-Pet";
  };
}
