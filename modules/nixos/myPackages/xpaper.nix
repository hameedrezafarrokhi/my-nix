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

}:

stdenv.mkDerivation rec {
  pname = "xpaper";
  version = "2025-11-09";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "embeddingbits";
    repo = "xpaper";
    rev = "6d37ca5f84f36bf9f0fcbe2bf5eca88a11b3da05";
    sha256 = "18kib8xi5v7329wa3jwafhkw7gnsyzrl9ph16k99zhz71f8207bx";
  };

  nativeBuildInputs = [
    pkg-config
    zig_0_15
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

  sourceRoot = "source/src";

  buildPhase = ''
    runHook preBuild

    #zig init
    #zig build

    zig build-exe main.zig -lX11 -lc

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp main $out/bin/xpaper
    chmod +x $out/bin/xpaper

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/embeddingbits/xpaper";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xpaper";
  };
}
