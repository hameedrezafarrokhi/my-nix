{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  python3Packages,
  makeWrapper,
}:

let

  pythonEnv = python3.withPackages (ps: with ps; [
    requests
    psutil
    pygobject3
    configparser
    pyaml
  ]);

  ename = "mounch";

in

stdenv.mkDerivation rec {
  pname = "mounch-py";
  version = "2026-06-22";

  src = fetchFromGitHub {
    owner = "chmouel";
    repo = "mounch";
    rev = "aa0e55efe4ad299f8091e7f3733e67e7c9df4b2b";
    sha256 = "08sa4mpxbq3nfnr4ajvj1miigraqrz43vmvr9yidmhk8xw0jlrzs";
  };

  buildInputs = [ pythonEnv makeWrapper ];

  postPatch = ''
    substituteInPlace mounch.py \
      --replace '/usr/share/icons' '/run/current-system/sw/share/icons'

    substituteInPlace mounch.py \
      --replace '/usr/share/pixmaps' '/run/current-system/sw/share/pixmaps'
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp mounch.py $out/bin/mounch-unwrapped
    chmod +x $out/bin/mounch-unwrapped

    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname} \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"

    cat > $out/bin/${ename} << 'EOF'
    #!/usr/bin/env bash

    exec ${pname} $(which mounch-unwrapped) "$@"

    EOF

    chmod +x $out/bin/${ename}
  '';

  meta = with lib; {
    homepage = "https://github.com/chmouel/mounch";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "mounch";
  };
}
