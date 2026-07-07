{
  lib,
  clangStdenv,
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

  cmake,
  ninja,
  clang,
  clang-tools,
  lua5_4,
  cairo,
  pango,

}:

clangStdenv.mkDerivation rec {
  pname = "librarywm";
 #version = "2026-07-04";
  version = "0.3";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "kelseythedreamer";
    repo = "librarywm";
   #rev = "22e3d51d6ab2e6eb75819e37ff3229d28f38bfe8";
    tag = version;
   #sha256 = "05fh1545czkfzayyan81yzmb00x4rwyha1j55alfd867wkcwq3rh";
    hash = "sha256-z4iHP6MvVCqoEaqJo6f6/bjN2kGBntJw6kfH+FeordE=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    clang
    clang-tools
    lua5_4
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
    lua5_4

    cairo
    pango
  ];

 #env = {
 #  "CC" = "clang";
 #  "CXX" = "clang++";
 #};

  buildPhase = ''
    runHook preBuild

    #CC=clang CXX=clang++ cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release ..
    #ninja -C build

    cmake -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$out \
      -DENABLE_ANIMATIONS=ON \
      -DENABLE_THEMES=ON \
      -DENABLE_HARDENING=ON \
      -Wno-dev \
      ..
    ninja -C build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    #ninja -C build install
    #DESTDIR="$out" cmake --install build

    #mkdir -p $out/bin $out/share
    #cp -r $out/$out/* $out/
    #rm -rf $out/$out

    cmake --install build

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/kelseythedreamer/librarywm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "librarywm";
  };
}
