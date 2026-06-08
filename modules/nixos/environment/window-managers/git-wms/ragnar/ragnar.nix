{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  xcb-proto,
  xcbproto,
  libxcb-util,
  libxcb-keysyms,
  libxcb-cursor,
  libxcb-wm,
  libxcb,
  libxcb-image,
  libxcb-render-util,
  libxcb-errors,
  libconfig,
  pkg-config,
  libGL,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "ragnar";
  version = "2026-06-08";

  src = fetchFromGitHub {
    owner = "cococry";
    repo = "ragnar";
    rev = "main";
    hash = "sha256-uGliVoLCs3hFCWQg2dPGQbvkBzelH+O+gTCXBStrcxc=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libX11
    libxcb
    libxcb-image
    libxcb-render-util
    libxcb-errors
    xcb-proto
    libxcb-util
    libxcb-keysyms
    libxcb-cursor
    libxcb-wm
    libconfig
    pkg-config
    libGL
  ];

  propagatedBuildInputs = [ xcbproto ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
    "BINDIR=$(out)/bin"
  ];

  buildPhase = ''
    runHook preBuild
    make -C api
    mkdir -p bin
    make all
    runHook postBuild
  '';

  preInstall = ''
    mkdir -p $out/share/xsessions
    mkdir -p $out/etc/ragnarwm
  '';

  installPhase = ''
    runHook preInstall
    make install PREFIX=$out BINDIR=$out/bin
    install -Dm644 ragnar.desktop $out/share/xsessions/ragnar.desktop
    runHook postInstall
  '';

  postInstall = ''
    cp cfg/ragnar.cfg $out/etc/ragnarwm/ragnar.cfg
    wrapProgram $out/bin/ragnar \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  meta = with lib; {
    homepage = "https://github.com/cococry/ragnar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "ragnar";
  };
}
