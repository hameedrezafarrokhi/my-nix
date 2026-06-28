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

  meson,
  ninja,
  vulkan-loader,
  vulkan-headers,
  glm,
  boost,
  python3,
  harfbuzz,
  shaderc,
  makeWrapper,
  libdrm,

}:

stdenv.mkDerivation rec {
  pname = "chamferwm";
  version = "2024-09-28";

  src = fetchFromGitHub {
    owner = "jaelpark";
    repo = "chamferwm";
   #rev = "master";
    rev = "b5bc7250143e4d80c47ffcb468bb0ef326a213ce";
    sha256 = "09nwibjc0azd2symzgfcbsdrxbiznm65cy8q92f8vbdk74hfi801";
  };

  pythonEnv = python3.withPackages (ps: with ps; [
    xlib
    psutil
    setuptools
    boost
  ]);

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    vulkan-loader
    vulkan-headers
    shaderc
    makeWrapper
    boost
    pythonEnv
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

    vulkan-loader
    vulkan-headers
    glm
    boost
    harfbuzz
    shaderc
    makeWrapper

    pythonEnv
    libdrm.dev

  ];

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];

  mesonFlags = [
    "--buildtype=release"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/chamfer/shaders $out/share/chamfer/config
    cp chamfer $out/bin/chamfer
    cp ./*.spv $out/share/chamfer/shaders/
    #cp -r ./*.spv.p $out/share/chamfer/shaders/
    cp ${src}/shaders/* $out/share/chamfer/shaders/
    cp ${src}/config/* $out/share/chamfer/config/

    wrapProgram $out/bin/chamfer \
      --prefix PATH : ${lib.makeBinPath [ pythonEnv ]} \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/jaelpark/chamferwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "chamferwm";
  };
}
