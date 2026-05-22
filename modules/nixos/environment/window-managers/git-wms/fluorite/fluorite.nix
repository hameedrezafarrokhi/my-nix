{
  lib,
  clangStdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXft,
  libXcursor,
  libXrandr,
  xdotool,
  libconfuse,
  freetype,
  bash,
  coreutils,
  gnugrep,
  gnused,
  gcc,
  pkg-config,
  makeWrapper,
  #enableHardening ? false,
}:

let



in

clangStdenv.mkDerivation (finalAttrs: rec {
  pname = "fluorite";
  version = "2026-03-01";

  src = fetchFromGitHub {
    owner = "l0wigh";
    repo = "Fluorite";
    rev = "master";
    hash = "sha256-CrCyZQM/MstLnAq9Fej/m/yixYecqNG2mdMqUbpgzQs=";
  };

  nativeBuildInputs = [ pkg-config makeWrapper ];

  buildInputs = [
    libX11
    libXcursor
    libXrandr
    libXft
    libXext
    xdotool
    libconfuse
    gcc
    freetype
  ];

  propagatedBuildInputs = [ xdotool ];

  #hardeningDesable = lib.optional (!enableHardening) [
  #  "fortify"
  #  "stackprotector"
  #  "pie"
  #];


  makeFlags = [
    "CC=${clangStdenv.cc.targetPrefix}cc"
    #"CFLAGS=-02 -pipe -D_FORTIFY_SOURCE=0"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error -Wno-unused-but-set-variable -Wno-unused-variable";

  installFlags = [ "PREFIX=$(out)" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 Fluorite $out/bin/fluorite

    wrapProgram $out/bin/fluorite \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath finalAttrs.buildInputs} \
      --set XDG_CONFIG_HOME \$HOME/.config

    mkdir -p $out/share/fluorite
    cp -r config $out/share/fluorite/

    runHook postInstall
  '';



     #  --replace "-Werror" "" \
     #--replace "-Werror=maybe-unintialized" "" \
     #--replace "-march=native" "-march=X86-64" \
     #--replace "-mtune=native" "-mtune=generic"


      #
      #

  postPatch = ''
    substituteInPlace Makefile \
       --replace "/usr/bin" "$out/bin" \
       --replace "sudo cp" "cp"



  '';

  meta = with lib; {
    homepage = "https://github.com/l0wigh/Fluorite";
    description = " ";
    longDescription = '' '';
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.linux;
    mainProgram = "fluorite";
    broken = false;
  };
})
