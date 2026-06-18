{
  lib,
  clangStdenv,
  fetchFromGitHub,
  libX11,
  libXext,
  libXft,
  libXcursor,
  libxres,
  libXrandr,
  libxcb,
  libxcb-util,
  libxcb-keysyms,
  libxcb-wm,
  libxcb-cursor,
  libxcb-render-util,
  libxcb-image,
  libxcb-errors,
  xorgproto,
  libxkbcommon,
  xdotool,
  xdo,
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
   #rev = "master";
    rev = "c79fc5bfc2759b4665b5b37c77db1f9d06d2a66d";
   #hash = "sha256-hrii3nJEWVqSPVbw4gb4X/FUk7smotqDeDP8cmu6Myo=";
    sha256 = "0aikp9mp5z1kg21xm8i6pf9m9wazz03f5w2n7n95lna4fbga5f46";
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
    libxres
    libxcb
    libxcb-util
    libxcb-keysyms
    libxcb-wm
    libxcb-cursor
    libxcb-render-util
    libxcb-image
    libxcb-errors
    xorgproto
    libxkbcommon
  ];

 #propagatedBuildInputs = [ xdotool ];

  #hardeningDesable = lib.optional (!enableHardening) [
  #  "fortify"
  #  "stackprotector"
  #  "pie"
  #];


  makeFlags = [
    "CC=${clangStdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
    #"CFLAGS=-02 -pipe -D_FORTIFY_SOURCE=0"
  ];

  buildPhase = ''
    make CFLAGS="$CFLAGS -Ddsw=1"
  '';

  installPhase = ''
     mkdir -p $out/bin
     mkdir -p $out/share/fluorite
     cp -f Fluorite $out/bin/Fluorite
     cp config/standard.conf $out/share/fluorite/fluorite.conf
  '';

 #env.NIX_CFLAGS_COMPILE = "-Wno-error -Wno-unused-but-set-variable -Wno-unused-variable";

 #installFlags = [ "PREFIX=$(out)" ];

 #installPhase = ''
 #  runHook preInstall
 #
 #  install -Dm755 Fluorite $out/bin/fluorite
 #
 #  wrapProgram $out/bin/fluorite \
 #    --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath finalAttrs.buildInputs} \
 #    --set XDG_CONFIG_HOME \$HOME/.config
 #
 #  mkdir -p $out/share/fluorite
 #  cp -r config $out/share/fluorite/
 #
 #  runHook postInstall
 #'';



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
