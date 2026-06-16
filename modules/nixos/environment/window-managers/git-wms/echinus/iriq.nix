{ lib
, stdenv
, fetchFromGitHub
, python3
, wrapGAppsHook3
, glib
, gtk3
, gobject-introspection
, cairo
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pygobject3
    python-uinput
    configparser
    pycairo
  ]);
in

stdenv.mkDerivation rec {
  pname = "iriq";
  version = "2010-01-01";

  src = fetchFromGitHub {
    owner = "polachok";
    repo = "iriq";
    rev = "master";
    hash = "sha256-ify19rIaxs0i10gW8FWN1+SWAxZ7xHzX6CXhoH5ngBg=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    gtk3
    glib
    cairo
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install the Python script
    mkdir -p $out/lib/${pname}
    cp ${src}/iriq.py $out/lib/${pname}/

    # Create executable wrapper
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname} \
      --add-flags "$out/lib/${pname}/iriq.py" \
      --set GDK_BACKEND x11 \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ gtk3 glib ]}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"

    # Install desktop file
    mkdir -p $out/share/applications
    cat > $out/share/applications/${pname}.desktop <<EOF
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=iriq
    Comment=Echinus GUI Tool
    Exec=$out/bin/${pname}
    Categories=Utility;Accessibility;
    StartupNotify=true
    EOF

    runHook postInstall
  '';

  meta = with lib; {
    description = "echinus gui tool";
    homepage = "https://github.com/polachok/iriq";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
