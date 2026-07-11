{
  lib,
  stdenv,
  fetchurl,

  openssl,
  sqlite,
  libgcc,

  makeWrapper,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  pname = "marcador-bin";
  version = "v0.6.0";

  src = fetchurl {
    url = "https://github.com/joajfreitas/marcador/releases/download/${version}/marcador-${version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-l0MnR3rFEre3s12M4oGuvolie0as9PlRXaqNsP+Z/D8=";
  };

  nativeBuildInputs = [ makeWrapper autoPatchelfHook ];

  buildInputs = [ openssl sqlite libgcc ];

  installPhase = ''
    mkdir -p $out/bin
    cp marcador $out/bin/marcador
    cp marcador_server $out/bin/marcador_server

    wrapProgram $out/bin/marcador \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    wrapProgram $out/bin/marcador_server \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/marcador || true

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/marcador_server || true
  '';

  meta = with lib; {
    description = "Rofi Bookmark Manager";
    homepage = "https://github.com/joajfreitas/marcador";
    mainProgram = "marcador";
    maintainers = [];
  };
}
