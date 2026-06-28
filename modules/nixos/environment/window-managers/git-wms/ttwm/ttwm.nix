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
  pname = "ttwm";
  version = "2026-01-08";

  src = fetchFromGitHub {
    owner = "adereth";
    repo = "ttwm";
   #rev = "main";
    rev = "610b158d9f04a65ad0ba6f7a6ed8b2b5afacd34e";
    sha256 = "08a2f2rds5cjyakv038y4l7mcqfxnkqqb8mmfb29mvjwcwkyh6xm";
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

  cargoHash = "sha256-5LxTWWd9fp/rniwMuQnmBDWvcZXd4qm+umDt00B9SEY=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/adereth/ttwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "ttwm";
  };
}
