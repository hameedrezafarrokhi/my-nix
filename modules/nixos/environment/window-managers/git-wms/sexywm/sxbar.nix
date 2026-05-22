{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXinerama,
  libXcursor,
  libXft,
  xorgproto,
  fontconfig,
  freetype,
  pkg-config,
  gnumake,
}:

stdenv.mkDerivation rec {
  pname = "sexybar";
 #version = "1.0";
  version = "2026-01-01";

  src = fetchFromGitHub {
    owner = "uint23";
    repo = "sxbar";
   #rev = "v${version}";
    rev = "master";
   #hash = "sha256-wAOTUUpMAnnvFOQKgs7BCAg+CurrpY1bQL8hW3DMPps=";
    hash = "sha256-vDY4d9Ifjq43HqBfEcWj71NdxC6TCmsyfyD6b7hp0Ug=";
  };

  nativeBuildInputs = [ pkg-config gnumake ];

  buildInputs = [
    libX11
    libXinerama
    libXcursor
    libXft
    xorgproto
    freetype
    fontconfig
  ];

  postPatch = ''
    substituteInPlace src/parser.c \
      --replace '/usr/local/share/sxbarc' '/run/current-system/sw/share/sexybar/sxbarc'
  '';

  makeFlags = [
    "PREFIX=$out"
    "CC=${stdenv.cc.targetPrefix}cc"
    "LIBS=-lX11 -lXft -lfontconfig -lfreetype"
  ];

  buildPhase = ''
    make clean sxbar
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp sxbar $out/bin/sexybar
    mkdir -p $out/share/sexybar
    cp default_sxbarc $out/share/sexybar/sxbarc
    mkdir -p $out/share/man/man1
    cp sxbar.1 $out/share/man/man1/sexybar.1
  '';

  postInstall = ''
    install -Dm644 default_sxbarc $out/share/sexybar/sxbarc
    install -Dm644 sxbar.1 $out/share/man/man1/sexybar.1
  '';

  meta = with lib; {
    homepage = "https://github.com/uint23/sxbar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sxbar";
  };
}
