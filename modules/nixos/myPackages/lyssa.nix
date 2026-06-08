{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  gcc13,
  leif,
  taglib,
  miniaudio,
  libxcb,
  jq,
  exiftool,
 #yt-dlp,
 #ffmpeg,
  libGL,
  glfw,
  cglm,
  libclipboard,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "lyssa";
  version = "2024-01-01";

  src = fetchFromGitHub {
    owner = "cococry";
    repo = "lyssa";
    rev = "main";
    hash = "sha256-cW2V1l/LyxiIItDtB3/AEyQsIl6rG+57ZxfAMAs0dwQ=";
  };

  nativeBuildInputs = [
    pkg-config
    gcc13
    makeWrapper
  ];

  buildInputs = [
    leif
    taglib
    miniaudio
    glfw
    cglm
    libclipboard
    libxcb
    jq
    exiftool
   #yt-dlp
   #ffmpeg
  ];

  dependencies = [
    jq
    exiftool
   #yt-dlp
   #ffmpeg
  ];

  NIX_CFLAGS_COMPILE = lib.concatStringsSep " " [
    "-O3"
    "-ffast-math"
    "-DGLFW_INCLUDE_NONE"
    "-std=c++17"
    "-I${leif}/include"
    "-I${leif}/vendor/glad/include"
    "-I${cglm}/include"
    "-I${cglm}/include/cglm"
    "-I${src}/vendor/miniaudio"
    "-I${src}/vendor/stb_image_write"
    "-DGLM_FORCE_RADIANS"
    "-DGLM_FORCE_DEPTH_ZERO_TO_ONE"
  ];

  buildPhase = ''
    runHook preBuild
    mkdir -p bin
    mkdir -p $out/share/lyssa
    $CC $NIX_CFLAGS_COMPILE src/*.cpp -o bin/lyssa \
      -L${leif}/lib \
      -L${cglm}/lib \
      ${lib.concatStringsSep " " (map (p: "-L${p}/lib") buildInputs)} \
      -lleif \
      -lclipboard \
      -lglfw \
      -lm \
      -lminiaudio \
      -lxcb \
      -lcglm \
      -lGL \
      '${pkg-config} --cflags --libs taglib'
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/applications $out/bin $out/share/lyssa $out/share/icons
    install -Dm755 bin/lyssa $out/bin/lyssa
    install -Dm644 Lyssa.desktop $out/share/applications/Lyssa.desktop
    cp -r logo $out/share/icons/lyssa 2>/dev/null || true
    cp -r scripts $out/share/lyssa/
    cp -r assets $out/share/lyssa/
    cp -r .lyssa $out/share/lyssa/default-config 2>/dev/null || true
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/lyssa \
      --set LYPHA_DATA_DIR "$out/share/lyssa" \
      --run 'mkdir -p ~/.lyssa/playlists ~/.lyssa/downloaded_playlists && \
             cp -r $out/share/lyssa/default-config/favourites ~/.lyssa/playlists/ 2>/dev/null || true'
  '';

  meta = {
    homepage = "https://github.com/cococry/lyssa";
    description = " ";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
