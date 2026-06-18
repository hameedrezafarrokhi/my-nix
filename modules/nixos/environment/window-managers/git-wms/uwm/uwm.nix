{
  lib,
  stdenv,
  gcc13,
  fetchurl,
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
  libxmu,
  libxrandr,
  libstartup_notification,
}:

stdenv.mkDerivation rec {
  pname = "uwm";
  version = "0.2.11b";

  src = fetchurl {
    url = "https://sourceforge.net/projects/udeproject/files/UWM/uwm-${version}-stable/uwm-${version}.tar.gz";
    hash = "sha256-Zh8p8sFxjlwbBGsr0W4zW85yO31n8iCbki4OxH7NmO4=";
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
    libxmu
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
    homepage = "https://github.com/dylanaraps/uwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "uwm";
  };
}
