{
  lib,
  stdenv,
  fetchFromGitea,

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

  libjpeg,

}:

stdenv.mkDerivation rec {
  pname = "swp";
  version = "2026-06-29";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "Sushkyn";
    repo = "swp";
    rev = "d0a9e77e3bb109ee04e457bcf4ab5df440855d6b";
    sha256 = "0dj7qa40mpxbah4iqhph9a8h44b5ik35zwyqbrdjn3jib9xyafya";
  };

  nativeBuildInputs = [
    pkg-config
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

    libjpeg
  ];

  buildPhase = ''
    runHook preBuild

    gcc main.c -o swp -lX11 -ljpeg

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp swp $out/bin/swp

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/Sushkyn/swp";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "swp";
  };
}
