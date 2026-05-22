{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  python3,
  wrapGAppsHook3,
  glib,
  gobject-introspection,
  writeText,
  conf ? null,
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    xlib
  ]);

  scriptRepo = fetchFromGitHub {
    owner = "SYZYGY-DEV333";
    repo = "vswm";
    rev = "master";
    hash = "sha256-m7+Oki+IhhPDmOtuWpTdv07hncjvwBqpqzUG3VW00Us=";
  };

  ename = "verysmallwm";

in

stdenv.mkDerivation rec {
  pname = "verysmallwm-py";
  version = "2021-01-01";

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    libX11
    glib
  ];

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "true";

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "vswm.py" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} vswm.py";

  installPhase = ''
    # Create python wrapper
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname} \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"

    mkdir -p $out/share/verysmallwm/
    cp ${scriptRepo}/vswm.py $out/share/verysmallwm/

    # Create Launcher
    cat > $out/bin/${ename} << 'EOF'
    #!/usr/bin/env bash

    ${pname} /run/current-system/sw/share/verysmallwm/vswm.py

    EOF

    chmod +x $out/bin/${ename}
  '';


  meta = with lib; {
    homepage = "https://github.com/SYZYGY-DEV333/vswm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "verysmallwm";
  };
}
