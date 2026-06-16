{
  lib,
  stdenv,
  fetchurl,
  libX11,
  libXext,
  libxcomposite,
  libxft,
  libxpm,
  autoconf,
  autoreconfHook,
  gettext,
  automake,
  libtool,
  libsm,
  freetype,
  fontconfig,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "wmx";
  version = "8";

  src = fetchurl {
    url = "https://www.all-day-breakfast.com/wmx/wmx-${version}.tar.gz";
    hash = "sha256-cxYJDln6iYghnWgZ5CaHDG2MBzmBjXfodw6BCN3wrt0=";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "Config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} Config.h";

  nativeBuildInputs = [
    libtool
    autoconf
    autoreconfHook
    gettext
    automake
    pkg-config
  ];

  buildInputs = [
    libX11
    libXext
    libxcomposite
    libxft
    libxpm
    autoconf
    gettext
    automake
    libtool
    libsm
    fontconfig
    freetype
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" "PREFIX=$(out)" ];

  buildPhase = ''
    runHook preBuild
    mkdir -p m4
    autoupdate
    autoconf --force
    make
    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp wmx $out/bin/wmx
  '';

  meta = with lib; {
    homepage = "http://www.all-day-breakfast.com/wmx/";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "wmx";
  };
}
