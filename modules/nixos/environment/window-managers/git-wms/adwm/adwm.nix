{
  lib,
  stdenv,
  gcc13,
  fetchFromGitHub,
  libxext,
  autoconf,
  autoreconfHook,
  gettext,
  automake,
  libtool,
  freetype,
  fontconfig,
  pkg-config,
  libsm,
  libjpeg_turbo,
  librsvg,
  libxcomposite,
  libxdamage,
  libxft,
  libx11,
  libxinerama,
  libxpm,
  libxrandr,
  libstartup_notification,
}:

stdenv.mkDerivation rec {
  pname = "adwm";
  version = "0.7.17";

  src = fetchFromGitHub {
    owner = "bbidulock";
    repo = "adwm";
    rev = "93d2370b873c8489d129383a5e5f807a055b2693";
    sha256 = "028wd23f2isccbaghb5pxxx5ybfyz124ilkhs32n9bj8zrw0h09f";
  };

  nativeBuildInputs = [
    gcc13
    libtool
    autoconf
    autoreconfHook
    gettext
    automake
    pkg-config
  ];

  buildInputs = [
    libxext
    autoconf
    gettext
    automake
    libtool
    fontconfig
    freetype
    libjpeg_turbo
    librsvg
    libxcomposite
    libxdamage
    libxft
    libx11
    libxinerama
    libxpm
    libxrandr
    libstartup_notification
    libsm
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" "PREFIX=$(out)" "DESTDIR=$out" ];

  buildPhase = ''
    runHook preBuild
    autoupdate
    autoconf --force
    #./configure
    make
    runHook postBuild
  '';

  installPhase = ''
    make install
  '';

  meta = with lib; {
    homepage = "http://adwm.sourceforge.net/";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "adwm";
  };
}
