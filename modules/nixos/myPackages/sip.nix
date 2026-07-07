{
  lib,
  gcc13Stdenv,
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
  imlib2Full,

}:

gcc13Stdenv.mkDerivation rec {
  pname = "sip";
  version = "2023-11-23";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "marendowski";
    repo = "sip";
    rev = "035bfdd61a7ba79809ba3b36a2abb96a2e5f330a";
    sha256 = "1h2c2a25l73a25z7r8kq0y7w3xcwk7f8f5n94131z4dhscxxc9z4";
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
    imlib2Full
  ];

  buildPhase = ''
    runHook preBuild

    gcc -Wall -Wextra -pedantic -lX11 -lImlib2 -o sip sip.c

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp sip $out/bin/sip

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/marendowski/sip";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sip";
  };
}
