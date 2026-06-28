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

  rustPlatform,

  cairo,

}:

rustPlatform.buildRustPackage rec {
  pname = "gridwm";
  version = "2025-11-30";

  src = fetchFromGitHub {
    owner = "simon0302010";
    repo = "gridwm";
   #rev = "master";
    rev = "83297e7307ac7352c73aa921a1fb79e6c173a1bf";
    sha256 = "0cay70fkaf2n9mx4rmk9gx6ydvi3c6h4gya119fw28ixal68cs0h";
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

    cairo
  ];

 #cargoLock = {
 #  lockFile = "${src}/Cargo.lock";
 #};

  cargoHash = "sha256-7HtTAHEnezGhFTpesNbdaVHvAoc3xjs1Pp43CxTOvvc=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/simon0302010/gridwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "gridwm";
  };
}
