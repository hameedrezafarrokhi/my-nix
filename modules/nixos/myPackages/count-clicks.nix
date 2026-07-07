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

  zig_0_15,
  alejandra,
}:

stdenv.mkDerivation rec {
  pname = "count-clicks";
  version = "2025-11-17";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "mtlynch";
    repo = "count-clicks";
    rev = "9054892db1902b291e4ca25806127161f591d4fb";
    sha256 = "0r96awz6zhy2scihbqlxhkh7wyycp2gyk3vq7cdsasraw566s22y";
  };

  nativeBuildInputs = [
    pkg-config
    zig_0_15
    alejandra
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

  buildPhase = ''
    runHook preBuild

    zig build --release=safe

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp zig-out/bin/count_clicks $out/bin/count_clicks

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/mtlynch/count-clicks";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "count-clicks";
  };
}
