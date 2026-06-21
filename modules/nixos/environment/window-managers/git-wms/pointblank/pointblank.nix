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

  cairo,
  glib,
  cmake,
  procps,

}:

stdenv.mkDerivation rec {
  pname = "pointblank";
  version = "2026-03-25";

  src = fetchFromGitHub {
    owner = "Point-project";
    repo = "PointBlank";
   #rev = "main";
    rev = "0d8c32d18229a7d9c648285ae88c529b0c1e622c";
    sha256 = "07rqi4g7ls7xk5y59g4ha0cp0z8r8lid7bh24hc5z5aq79fg8rkv";
  };

  nativeBuildInputs = [
    pkg-config
    glib
    cmake
    procps
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

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  cmakeFlags = [ "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}" ];

  buildPhase = ''
    runHook preBuild

    #mkdir build && cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${placeholder "out"} ..
    make -j$(nproc)

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make install

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Point-project/PointBlank";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "pointblank";
  };
}
