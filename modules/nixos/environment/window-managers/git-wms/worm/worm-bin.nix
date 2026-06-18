{
  lib,
  stdenv,
  buildNimPackage,
  fetchFromGitHub,
  libx11,
  libxext,
  libxrandr,
  libxft,
  libxinerama,
  xorg-server,
  zlib,
  makeWrapper,
  autoPatchelfHook,
}:

let

  worm = fetchFromGitHub {
    owner = "codic12";
    repo = "worm";
   #rev = "master";
    rev = "be59f192956b3e38050d45520adc878e509388dd";
    sha256 = "160jrp267cmfwhqc6wzqbhalg6w2hcw4chk8in85qib6z0zvjr6l";
  };

in

stdenv.mkDerivation rec {

  pname = "worm-bin";
  version = "2026-06-18";

  src = fetchFromGitHub {
    owner = "hameedrezafarrokhi";
    repo = "unpatched-bins";
    rev = "959ddcbd9d697dc7b817161ac3dc6ff66c961898";
    sha256 = "1a7akwgrf7r9cjkwxnkni7wmdzg14l18p1bpr8xgr78fxxhv0my0";
  };

  nativeBuildInputs = [ makeWrapper autoPatchelfHook ];

  buildInputs = [
    libx11
    libxext
    libxrandr
    libxinerama
    libxft
    xorg-server
    zlib
  ];

  buildPhase = ''
    mkdir -p $out/bin
    cp ${src}/worm/worm $out/bin/worm
    cp ${src}/worm/wormc $out/bin/wormc
  '';

  installPhase = ''
    runHook preInstall

    # docs
    install -Dm644 ${worm}/README.md $out/share/doc/worm/README.md
    install -Dm644 ${worm}/docs/wormc.md $out/share/doc/worm/WORMC.md

    # examples
    install -Dm755 ${worm}/examples/rc $out/share/doc/worm/examples/rc
    install -Dm644 ${worm}/examples/sxhkdrc $out/share/doc/worm/examples/sxhkdrc
    install -Dm755 ${worm}/examples/jgmenu_run $out/share/doc/worm/examples/jgmenu_run

    wrapProgram $out/bin/worm \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

     wrapProgram $out/bin/wormc \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    runHook postInstall
  '';

  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/worm || true
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/wormc || true
  '';


  meta = with lib; {
    homepage = "https://github.com/codic12/worm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "worm";
  };
}
