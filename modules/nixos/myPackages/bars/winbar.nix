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

  cmake,
  ninja,
  dbus,
  pango,
  cairo,
  librsvg,
  libpulseaudio,
  pulseaudio,
  alsa-lib,
  unzip,
  glew,
  glm,
  libGL,
  egl-x11,
  pipewire,

}:

stdenv.mkDerivation rec {
  pname = "winbar";
  version = "2026-06-13";

  src = fetchFromGitHub {
    owner = "jmanc3";
    repo = "winbar";
   #rev = "main";
    rev = "d46b558a7269bdc5a7e126dc4a326a7a673b8d58";
    sha256 = "126vmzcg699bfsr49i72ji2wrcxf3043y1vdgy12j2jykdc9fvgn";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    unzip
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

    dbus
    pango
    cairo
    librsvg
    libpulseaudio
    pulseaudio
    alsa-lib
    unzip
    glew
    glm
    libGL
    egl-x11
    pipewire

  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  preBuild = ''
    mkdir -p $out/bin $out/share/winbar $out/etc
    unzip -o ${src}/winbar.zip
    cp -R winbar/fonts $out/share/winbar
    cp -R winbar/resources $out/share/winbar
    cp -R winbar/plugins $out/share/winbar
    cp winbar/tofix.csv $out/share/winbar
    cp winbar/items_custom.ini $out/share/winbar
    cp winbar/winbar.cfg $out/etc
    rm -rf winbar
  '';

 #buildPhase = ''
 #  runHook preBuild
 #
 #  mkdir -p newbuild
 #  cd newbuild
 #  cmake -DCMAKE_BUILD_TYPE=Release ../
 #  make -j 16
 #  make -j 16 install
 #  ./winbar --create-cache
 #
 #  runHook postBuild
 #'';

  installPhase = ''
    runHook preInstall

    cp winbar $out/bin/winbar

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/jmanc3/winbar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "winbar";
  };
}
