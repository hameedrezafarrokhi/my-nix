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
  pname = "derpy-wm";
  version = "2020-03-29";

  src = fetchFromGitHub {
    owner = "DerpyCrabs";
    repo = "derpy-wm";
   #rev = "master";
    rev = "bc10fbcd238bdd54fc3f36c6ec763f915435bf8e";
    sha256 = "1py01yc70v99px8gj2ncwl6kbf13l8dchgfvfcy6bp3y5xb55j6d";
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

  cargoHash = "sha256-zqOMV+fByYRHrbzdSQxB6Rlr+/dew/Z08JZCHzoBVHE=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/DerpyCrabs/derpy-wm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "derpy-wm";
  };
}
