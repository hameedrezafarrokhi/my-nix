{
  lib,
  stdenv,
  fetchFromGitHub,
  nim2,
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
  makeWrapper,
  autoPatchelfHook,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "vertex-bin";
  version = "2026-07-06";

  src = fetchFromGitHub {
    owner = "hameedrezafarrokhi";
    repo = "unpatched-bins";
    rev = "412a5505cd307b4d468539b70565a0adee0f3ea0";
    sha256 = "04c0lmff7sj9zrhlkmnwd1cbi9qlxk3frjg2y3xgrf0lfkv6j9wk";
  };

  nativeBuildInputs = [ makeWrapper autoPatchelfHook ];

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
    mkdir -p $out/bin
    cp ${src}/vertex/vertex $out/bin/vertex
  '';

  installPhase = ''
    wrapProgram $out/bin/vertex \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/vertex || true
  '';

  meta = {
    description = "hot corners for x11";
    homepage = "https://codeberg.org/anhsirk0/vertex";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "vertex";
    platforms = lib.platforms.linux;
  };
}
