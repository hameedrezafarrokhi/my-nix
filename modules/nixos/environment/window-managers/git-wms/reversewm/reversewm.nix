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

  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "reversewm";
  version = "2026-06-19";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "Apzhyn";
    repo = "reverseWM";
    rev = "4b4168878887f944bb381d2b51ac5207af800681";
    sha256 = "0mrmz7l5z3yqh2i85x69blpd1avlgb0lvwj7i5glsfynvbnh0nj3";
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

  cargoHash = "sha256-qluT8dCrs2L4ZirfC4HnsD34lLV1yjbHG9WM25gwZrg=";

  meta = with lib; {
    homepage = "https://codeberg.org/Apzhyn/reverseWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "reversewm";
  };
}
