{ lib
, stdenv
, fetchFromGitHub
, python3
, wrapGAppsHook3
, glib
, gtk3
, gobject-introspection
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pygobject3
    numpy
    vispy
    watchdog
    argparse-addons
    configargparse
    datetime
    pyqt6
  ]);
in

stdenv.mkDerivation rec {
  pname = "shadertoy-render";
  version = "2015-11-24";

  src = fetchFromGitHub {
    owner = "alexjc";
    repo = "shadertoy-render";
    rev = "e0d344dbeb5a191ddb899cbce5c671d0b604a13c";
    sha256 = "08x7bgm40ihcdn1l539abfiwlbxd3hz5zcvy5zpa1r5v116vz54p";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    gtk3
    glib
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install the Python script
    mkdir -p $out/lib/${pname}
    cp ${src}/shadertoy-render.py $out/lib/${pname}/

    # Create executable wrapper
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname} \
      --add-flags "$out/lib/${pname}/shadertoy-render.py" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"

    # Install desktop file
    mkdir -p $out/share/applications
    cat > $out/share/applications/${pname}.desktop <<EOF
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Shadertoy Render
    Comment=shadertoy glsl to video
    Exec=$out/bin/${pname}
    Categories=Utility;
    StartupNotify=true
    EOF

    runHook postInstall
  '';

  meta = with lib; {
    description = " ";
    homepage = "https://github.com/alexjc/shadertoy-render";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
