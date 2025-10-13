{ lib
, stdenv
, python3
, wrapGAppsHook
, glib
, gtk3
, gobject-introspection
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pygobject3
    python-uinput
    configparser
  ]);
in

stdenv.mkDerivation rec {
  pname = "vboard";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [
    wrapGAppsHook
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
    cp ${src}/vboard.py $out/lib/${pname}/

    # Create executable wrapper
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname} \
      --add-flags "$out/lib/${pname}/vboard.py" \
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
    Name=Virtual Keyboard
    Comment=A virtual keyboard using GTK and uinput
    Exec=$out/bin/${pname}
    Icon=input-keyboard
    Categories=Utility;Accessibility;
    StartupNotify=true
    EOF

    runHook postInstall
  '';

  meta = with lib; {
    description = "A virtual keyboard using GTK and uinput";
    homepage = "https://example.com"; # Replace with actual homepage if available
    license = licenses.mit; # Adjust license as needed
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}