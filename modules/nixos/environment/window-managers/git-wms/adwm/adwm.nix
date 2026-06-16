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

 #fetchpatch,
 #patch,
 #patches ? ./gcc15.patch,
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

 #inherit patches;

 #prePatch = ''
 #  patch -Np2 <${patches}
 #'';

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
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" "PREFIX=$(out)" ];

  buildPhase = ''
    runHook preBuild
    ./configure
    # Fight unused direct deps
    sed -i -e "s| -shared | $LDFLAGS\0 |g" -e "s|    if test \"\$export_dynamic\" = yes && test -n \"\$export_dynamic_flag_spec\"; then|      func_append compile_command \" $LDFLAGS\"\n      func_append finalize_command \" $LDFLAGS\"\n\0|" libtool
    make
    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp adwm $out/bin/
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
