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

}:

stdenv.mkDerivation rec {
  pname = "tsarbar";
  version = "2026-04-25";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "iamcheeseman";
    repo = "tsarbar";
    rev = "16b93b43e899ca3c1fb076e3568a1421ef66b1c2";
    hash = "sha256-m/y+on8ouZ4P04U5KsqGZhF9IjJRdJwaqrcVb0bH/pg=";
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

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "INSTALL=${placeholder "out"}/bin"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp tsarbar $out/bin/tsarbar
    cp tsarc $out/bin/tsarc

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/iamcheeseman/tsarbar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "tsarbar";
  };
}
