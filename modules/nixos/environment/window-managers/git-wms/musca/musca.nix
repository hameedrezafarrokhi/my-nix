{
  lib,
  gcc13Stdenv,
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

}:

gcc13Stdenv.mkDerivation rec {
  pname = "musca";
  version = "2020-10-23";

  src = fetchFromGitHub {
    owner = "enticeing";
    repo = "musca";
    rev = "f2d04f1cd007e52a84493027e1730aa0ad1b22f6";
    sha256 = "1997d4jhgkqrfd7cn4f5045zcx5azqlmpfgdwlpwwrcksqdf49ij";
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
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp musca $out/bin/musca
    cp apis $out/bin/apis
    cp xlisten $out/bin/xlisten

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/enticeing/musca";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "musca";
  };
}
