{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus,
  fontconfig,
  freetype,
  pkg-config,
  libx11,
  libxft,
  libxext,
  libxrender,
  writeText,
  udev,
  keyutils,
  jmtpfs,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "udisk-polybar";
  version = "unstable";

  src = ./.;

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def";


  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    fontconfig
    freetype
    libx11
    libxft
    libxext
    libxrender
    udev
    keyutils
    jmtpfs
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp polybar-udisks $out/bin/udisk-polybar

    runHook postInstall
  '';

  meta = with lib; {
    homepage = " ";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "udisk-polybar";
  };
}
