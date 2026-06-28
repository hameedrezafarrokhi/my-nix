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
  pname = "subtle-rs";
  version = "2026-06-23";

  src = fetchFromGitHub {
    owner = "unexist";
    repo = "subtle-rs";
   #rev = "master";
    rev = "860a3b7b74290fbd5cee6df0b66b98365441bdd1";
    sha256 = "0krcn2491hcysj9xaph332x7ahpr5cp0xlvkzg62wgfqr4918j7f";
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

  cargoHash = "sha256-8sssfjXy0Sv5fvcOQL1bUqQM28UabnpGjx8w+GXNPwA=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/unexist/subtle-rs";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "subtle-rs";
  };
}
