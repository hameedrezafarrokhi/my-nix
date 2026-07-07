{
  lib,
  rustPlatform,
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
  chafa,
  glib,

}:

rustPlatform.buildRustPackage rec {
  pname = "wallrs";
  version = "2026-03-27";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "altair-39";
    repo = "wallrs";
    rev = "23e05ac2ea923d79de5eb021b1eebe16f615255f";
    sha256 = "1n2c4m2an86l5hjy2wv3ynwqbpap3q54vfi6d0cnza44ljnsyggj";
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
    chafa
    glib
  ];

  postPatch = ''
    mkdir -p build/source
    cp ${cargoLock.lockFile} build/source/Cargo.lock
    cp ${cargoLock.lockFile} ./Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Wallrs-Cargo.lock;
  };

  meta = with lib; {
    homepage = "https://codeberg.org/altair-39/wallrs";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "wallrs";
  };
}
