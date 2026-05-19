{
  stdenv,
  lib,
  fetchFromGitHub,
  gcc,
  makeWrapper,
  pkg-config,
  libX11,
  sdl2,
  SDL2_ttf,
  ffmpeg,
  sfml,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cygnus-wm";
  version = "2026-04-01";

  src = fetchFromGitHub {
    owner = "jt-copernicus";
    repo = "Cygnus";
    rev = "main";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    which
  ];

  buildInputs = [
    gcc
    libX11
    sdl2
    SDL2_ttf
    ffmpeg
    sfml
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "XSESSIONDIR=${placeholder "out"}/share/xsessions"
  ];

  # Handle the cygnus-paint subdirectory
  preBuild = ''
    # Ensure cygnus-paint has its own Makefile
    if [ -f pmakefile ] && [ ! -f cygnus-paint/Makefile ]; then
      cp pmakefile cygnus-paint/Makefile
    fi
  '';

  # Build all targets
  buildPhase = ''
    runHook preBuild
    
    make all ${lib.optionalString (stdenv.cc.isGNU) "CC=gcc"}
    
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    
    # Create directories
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
    mkdir -p $out/share/xsessions
    
    # Install binaries
    make install DESTDIR=$out
    
    # Ensure all binaries are executable
    chmod +x $out/bin/*
    
    runHook postInstall
  '';

  postInstall = ''
    # Copy configuration examples if they exist
    if [ -f menu ]; then
      mkdir -p $out/share/cygnus-wm
      cp menu keys icons session $out/share/cygnus-wm/ 2>/dev/null || true
    fi
  '';

  # Fixup phase to wrap binaries with library paths if needed
  postFixup = ''
    for bin in $out/bin/*; do
      if [ -x "$bin" ]; then
        wrapProgram "$bin" \
          --prefix PATH : ${lib.makeBinPath [ which ]}
      fi
    done
  '';

  meta = with lib; {
    homepage = "https://github.com/cliquesoft/fxWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "fxwm";
  };

})
