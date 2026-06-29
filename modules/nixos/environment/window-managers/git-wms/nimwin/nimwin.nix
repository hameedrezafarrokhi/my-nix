{
  lib,
  stdenv,
  fetchFromGitHub,

  libx11,
  libxft,
  libxrandr,
  libxrender,
  libxres,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxmu,
  libxpm,
  libxmp,
  libxt,
  libxdamage,
  libxdmcp,
  libxcomp,
  libxcomposite,
  libxkbcommon,

  libxcb,
  libxcb-wm,
  libxcb-util,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-errors,
  libxcb-cursor,

  fontconfig,
  freetype,

  pkg-config,

  buildNimPackage,

  nim1,

}:

let

  x11-nim = fetchFromGitHub {
    owner = "nim-lang";
    repo = "x11";
    rev = "3dd8f523fb2b502f4e5a958d8acf09a0b8ac0452";
    sha256 = "0zaarwii6h3njl96kwrv8ag3hfy60lyw2x5dg37fdplhkywdic66";
  };

in

stdenv.mkDerivation rec {
  pname = "nimwin";
  version = "2022-01-13";

  src = fetchFromGitHub {
    owner = "weskerfoot";
    repo = "Nimwin";
   #rev = "master";
    rev = "f7a10b510535e1a3c91da8416b26806c9b902ef9";
    sha256 = "0d75423774rwy789nxcpxijniqhfwvw3wh390zv2gnkha0272fj4";
  };

  nativeBuildInputs = [
    pkg-config
    nim1
  ];

  buildInputs = [
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    fontconfig
    freetype
  ];

  buildPhase = ''
   HOME=$TMPDIR
   nim --run -p:${x11-nim}/ c -d:release src/nimwin.nim
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp nimwin $out/bin/nimwin
  '';

  meta = with lib; {
    homepage = "https://github.com/weskerfoot/Nimwin";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "nimwin";
  };
}
