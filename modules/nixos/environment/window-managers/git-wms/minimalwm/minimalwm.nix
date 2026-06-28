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

  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "minimalwm";
  version = "2025-08-07";

  src = fetchFromGitHub {
    owner = "KrzysztofMarciniak";
    repo = "minimal-window-manager-plus";
   #rev = "master";
    rev = "dc8091306dadbf8bd7244bdb836dea73ed4fb9cd";
    sha256 = "15dpx94ws9bdps3clijbnqmdflxsf4j9y60ln1lv99kny4lm81ji";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "main.c" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} main.c";


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
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp minimalwm $out/bin/minimalwm
 #
 #  runHook postInstall
 #'';

  postInstall = ''
    cp ${src}/status_bar_script.sh $out/bin/mwmp-bar
    chmod +x $out/bin/mwmp-bar
    cp ${src}/audio.sh $out/bin/mwmp-audio
    chmod +x $out/bin/mwmp-audio
  '';

  meta = with lib; {
    homepage = "https://github.com/KrzysztofMarciniak/minimal-window-manager-plus";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "minimalwm";
  };
}
