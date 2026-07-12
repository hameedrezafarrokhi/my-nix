{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  python3,
  wrapGAppsHook3,
  gobject-introspection,
  glib,
}:

let

  pythonEnv = python3.withPackages (ps: with ps; [
    pillow
    requests
    pyyaml
    pyxdg
    docopt
    notify2
    psutil
    pygobject3
    configparser
  ]);

in

stdenv.mkDerivation rec {
  pname = "rofi-clip";
  version = "2024-10-29";

  src = fetchFromGitHub {
    owner = "seamus-45";
    repo = "roficlip";
    rev = "2a00a022d7fec5659bf56280059491f74c17c56b";
    sha256 = "0vfisciw3x7maxld7wk52mncpqc77ll9wbdx3m46xykkq9mcrsf1";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    glib
  ];

  installPhase = ''
    mkdir -p $out/bin

    cp roficlip.py $out/bin/rofi-clip-unwrapped
    chmod +x $out/bin/rofi-clip-unwrapped

    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname}-py \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"

    cat > $out/bin/${pname} << 'EOF'
    #!/usr/bin/env bash
    exec ${pname}-py $(which rofi-clip-unwrapped) "$@"
    EOF

    chmod +x $out/bin/${pname}
  '';

  meta = with lib; {
    homepage = "https://github.com/seamus-45/roficlip";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-clip";
  };
}
