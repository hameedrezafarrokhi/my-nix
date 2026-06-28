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

  libxkbfile,
  unclutter-xfixes,
  lua5_4,
  cairo,
  pango,
  libpng,
  spdlog,
  cmake,
  wayland,
  wayland-protocols,
  kdePackages,

}:

stdenv.mkDerivation rec {
  pname = "sirenwm";
  version = "2020-10-21";

  src = fetchFromGitHub {
    owner = "TheB1t";
    repo = "sirenwm";
   #rev = "master";
    rev = "24f2a09ec27c6fa6a638a94f659f78c023f32982";
    sha256 = "0zyvwv91njnr8vv575jvf3z9n20xnqg13j5z8y21blv12m6cbalw";
  };

  nativeBuildInputs = [
    pkg-config
    lua5_4
    cmake
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

    libxkbfile
    unclutter-xfixes
    lua5_4
    cairo
    pango
    libpng
    spdlog
    wayland
    wayland-protocols
    kdePackages.wayland-protocols.out

  ];

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];

  buildPhase = ''
    runHook preBuild

    # X11 build
    cmake -S .. -B build -DSIRENWM_BACKEND=x11
    cmake --build build -j$(nproc)

    # Wayland build
    #cmake -S .. -B build-wayland -DSIRENWM_BACKEND=wayland
    #cmake --build build-wayland -j$(nproc)
    #
    #mkdir -p $out/bin
    #cp ../output/sirenwm-wayland $out/bin/sirenwm-wayland

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ../output/sirenwm-x11 $out/bin/sirenwm-x11

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/TheB1t/sirenwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sirenwm";
  };
}
