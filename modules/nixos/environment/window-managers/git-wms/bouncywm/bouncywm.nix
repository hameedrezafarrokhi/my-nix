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

#buildNimPackage (finalAttrs: {
stdenv.mkDerivation rec {
  pname = "BouncyWM";
  version = "2020-01-20";

  src = fetchFromGitHub {
    owner = "weskerfoot";
    repo = "BouncyWM";
   #rev = "main";
    rev = "fac173438bcb38bf469d38ba14438f6962c32325";
    sha256 = "1521hwxbq5bipgp21daps85vaz8m28z01fwc4a17zfzwwkis6fq1";
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

 #nimFlags = [
 #  "-d:release"
 #  "-p:${x11-nim}/"
 #  "src/nimwm.nim"
 #];

 #requiredNimVersion = 1;

 buildPhase = ''
   HOME=$TMPDIR
   nim --run -p:${x11-nim}/ c -d:release src/nimwin.nim
 '';

 installPhase = ''
   mkdir -p $out/bin
   cp nimwin $out/BouncyWM
 '';

  meta = with lib; {
    homepage = "https://github.com/weskerfoot/BouncyWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "BouncyWM";
  };
}
