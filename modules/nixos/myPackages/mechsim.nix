{
  lib,
  stdenv,
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
  libevdev,
  libinput,
  udev,
  json_c,
  libpulseaudio,
  pulseaudio,
  libsndfile,
  json-glib,
  libudev-zero,

  gettext,

  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "MechSim";
  version = "2025-06-20";

  src = fetchFromGitHub {
    owner = "cjlangan";
    repo = "MechSim";
   #rev = "main";
    rev = "b5ea4665a41ee1aa2241ef889b26a33a56e14ed3";
    sha256 = "0j6kkkybm8mb53s7hsl1k066azbv75hz28d4i1w70gnjzaij1in4";
  };

  prePatch = ''
    #substituteInPlace mechsim.c \
    #  --replace 'execl keyboard_sound_player' 'exec keyboard_sound_player'
    #substituteInPlace mechsim.c \
    #  --replace 'execl get_key_presses' 'exec get_key_presses'
    #substituteInPlace mechsim.c \
    #  --replace '512' '10000'
    #substituteInPlace config.h \
    #  --replace '/usr/bin/pkexec' '/run/wrappers/bin/pkexec'
    #substituteInPlace config.h \
    #  --replace '/usr' '/run/current-system/sw'
    #substituteInPlace config.h \
    #  --replace 'MECHSIM_DATA_DIR PACKAGE_PREFIX "/share/mechsim"' 'MECHSIM_DATA_DIR "/run/current-system/sw/share/mechsim"'
    #substituteInPlace config.h \
    #  --replace 'MECHSIM_BIN_DIR PACKAGE_PREFIX "/bin"' 'MECHSIM_BIN_DIR "/run/current-system/sw/bin"'

    substituteInPlace mechsim.c \
      --replace 'execl(sudo_path, "sudo", "-n", get_key_presses_path, (char *)NULL);' 'execvp("sudo", (char *[]){"sudo", "-n", "get_key_presses", NULL});'

  '';

 #postPatch =
 #  let
 #    configFile =
 #      if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
 #  in
 #  lib.optionalString (conf != null) "cp ${configFile} config.h";


  nativeBuildInputs = [
    pkg-config
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

    libevdev
    libinput
    udev
    json_c
    libpulseaudio
    pulseaudio
    libsndfile
    json-glib
    libudev-zero

    gettext
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

 #buildPhase = ''
 #  runHook preBuild
 #
 #
 #
 #  runHook postBuild
 #'';
 #
 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp MechSim $out/bin/MechSim
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/cjlangan/MechSim";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "MechSim";
  };
}
