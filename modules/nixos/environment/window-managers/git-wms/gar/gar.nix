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

  rustPlatform,
  pkg-config,
  lua,
}:

rustPlatform.buildRustPackage rec {
  pname = "gar";
  version = "2026-06-04";

  src = fetchFromGitHub {
    owner = "gardesk";
    repo = "gar";
   #rev = "trunk";
    rev = "5a485202cc28a9c754ca8809eb8fc95494537ca9";
    sha256 = "0smfbk74i7a9yrhzwz35n4pzspgiqbc30254l9znb58ypqrnv1hr";
  };

 #nativeBuildInputs = [  ];

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

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  postInstall = ''
    #install -Dm755 target/release/garctl $out/bin/garctl
    install -Dm755 start-gar.sh $out/bin/start-gar
    install -Dm755 gar-session.sh $out/bin/gar-session
  '';

  meta = with lib; {
    homepage = "https://github.com/gardesk/gar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "gar";
  };
}
