{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXinerama,
  libXcursor,
  xorgproto,
  pkg-config,
  gnumake,
  writeText,
  fetchpatch,
  patches ? [ ],
}:

stdenv.mkDerivation rec {
  pname = "sexywm";
 #version = "1.7";
  version = "2026-03-01";

  src = fetchFromGitHub {
    owner = "uint23";
    repo = "sxwm";
   #rev = "v${version}";
    rev = "master";
   #hash = "sha256-Gytop4lYkQdVaYXWyXmlHotEFnaA0O8CZUmqfIe8X2w=";

   #hash = "sha256-jeOwahG5oNtAKAZTNlddCwzE3ZY9+apU8Lw2JQErB7k=";
    hash = "sha256-ovt8gjvSVA5i0T7SyRhgoFa8xsE50MHgxLP+ZdvRdME=";
  };

  nativeBuildInputs = [ pkg-config gnumake ];

  buildInputs = [
    libX11
    libXinerama
    libXcursor
    xorgproto
  ];

  inherit patches;

  postPatch = ''
    substituteInPlace src/parser.c \
      --replace '/usr/local/share/sxwmrc' '/run/current-system/sw/share/sexywm/sxwmrc'
  '';

  makeFlags = [ "PREFIX=$out" ];

  buildPhase = ''
    make clean sxwm
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp sxwm $out/bin/sexywm
    mkdir -p $out/share/sexywm
    cp default_sxwmrc $out/share/sexywm/sxwmrc
    mkdir -p $out/share/man/man1
    cp docs/sxwm.1 $out/share/man/man1/sexywm.1
  '';

  postInstall = ''
    install -Dm644 default_sxwmrc $out/share/sexywm/sxwmrc
    install -Dm644 docs/sxwm.1 $out/share/man/man1/sexywm.1
  '';

  meta = with lib; {
    homepage = "https://github.com/uint23/sxwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sexywm";
  };
}
