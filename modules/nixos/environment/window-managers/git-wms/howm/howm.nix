{
  lib,
  stdenv,
  fetchFromGitHub,
  gcc,
  libX11,
  libxcb,
  libxcb-util,
  libxcb-keysyms,
  libxcb-wm,
  cottage,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "howm";
  version = "2021-10-07";

  src = fetchFromGitHub {
    owner = "HarveyHunt";
    repo = "howm";
   #rev = "master";
    rev = "3ee6ff4b66603126f8ba8bab6569e2702f551160";
    sha256 = "0c26k513z7xwf28gxxyjhdqfc535ryi6aag953cyp66qslk8pvbw";
  };

  nativeBuildInputs = [ gcc pkg-config ];

  buildInputs = [
    libX11
    libxcb
    libxcb-util
    libxcb-keysyms
    libxcb-wm
    cottage
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "howm.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} src/howm.h";

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
    "INSTALL_PREFIX=$(out)"
    "XSESSION_PREFIX=$(out)/share"
    "DESTDIR= "
  ];

  postInstall = ''
    cp $out/bin $out/howm
    rm -f $out/bin
    mkdir $out/bin
    cp $out/howm $out/bin/howm
  '';

  meta = with lib; {
    homepage = "https://github.com/HarveyHunt/howm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "howm";
  };
}
