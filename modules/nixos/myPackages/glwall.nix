{
  lib,
  gcc13Stdenv,
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

  glfw,
  libGL,
  libGLX,
  egl-x11,
  glew,
  stb,

  makeWrapper,
  autoPatchelfHook,

  writeText,
  conf ? null,
}:

gcc13Stdenv.mkDerivation rec {
  pname = "GLWall";
  version = "2025-05-28";

  src = fetchFromGitHub {
    owner = "ikz87";
    repo = "GLWall";
   #rev = "main";
    rev = "207283ad1f466f1f6df8b7d6e6f55bcb19607216";
    sha256 = "1nbihf4k4xa5lnw7g1kpgp90hmv2avi03q9rikpswdhvnjxhmarm";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";


  nativeBuildInputs = [
    pkg-config
    stb
    makeWrapper
    autoPatchelfHook
    glew
    libGL
    libGLX
    egl-x11
    glfw
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

    glfw
    libGL
    libGLX
    egl-x11
    glew
    stb

  ];

  buildPhase = ''
    runHook preBuild

    gcc main.c -o GLWall -lm -I${stb.out}/include/stb -lglfw -lGL -lGLEW

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/GLWall
    cp GLWall $out/bin/GLWall
    cp -r textured_shaders $out/share/GLWall/
    cp -r regular_shaders $out/share/GLWall/

    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/GLWall \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/GLWall || true
  '';

  meta = with lib; {
    homepage = "https://github.com/ikz87/GLWall";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "GLWall";
  };
}
