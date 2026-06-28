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

  lua,

}:

rustPlatform.buildRustPackage rec {
  pname = "nwm";
  version = "2026-02-21";

  src = fetchFromGitHub {
    owner = "prodbysky";
    repo = "nwm";
   #rev = "master";
    rev = "04f141ce484bdb4962f370d8506b07d2f240a083";
    sha256 = "1ndxc9190k26pq6n7w2h51y3f1i2h2pc3q20n8xhw92rr2p0cvxi";
  };

  nativeBuildInputs = [
    pkg-config

    lua
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

    lua
  ];

  cargoHash = "sha256-+T62japOnu69/r9z4Aj4CrABdIaTD48dHkHN6V2hhB8=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/prodbysky/nwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "nwm";
  };
}
