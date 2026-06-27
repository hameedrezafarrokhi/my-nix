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

  ansi,

  writeText,
  lua5_1,
  conf ? null,
  make ? ''
PROJECT = sweetwm

all: run

build:
	cd src; make

arch: clean
	mkdir -p archive
	tar c include src Makefile $(PROJECT).lua README | gzip > archive/$(PROJECT)_`date +%Y-%m-%d_%H-%M-%S`.tgz

clean:
	cd src; make clean

run: build
	#Xephyr -screen 1280x780 :1 &
	#sleep 1
	#DISPLAY=:1 xterm -geometry 105x29+0+0 &
	#DISPLAY=:1 xterm -geometry 105x59+640+0 -e "src/$(PROJECT) $(PROJECT).lua || sleep 1000"
	#pkill Xephyr
	echo hello

  '',
}:

stdenv.mkDerivation rec {
  pname = "sweetwm";
  version = "2009-12-28";

  src = fetchFromGitHub {
    owner = "darmovzal";
    repo = "sweetwm";
   #rev = "master";
    rev = "67d8a4bba033c324bfc96efe48b53fc13a4e0c99";
    sha256 = "0q96k8zz8g9cl9fjx97ji4kb0axg865da2lmkw4j6k79mfkscd4y";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "sweetwm.lua" conf;
      makeFile =
        if lib.isDerivation make || builtins.isPath make then make else writeText "Makefile" make;
    in
    lib.optionalString (conf != null) "cp ${configFile} sweetwm.lua"
    + " \n " +
    lib.optionalString (make != null) "cp ${makeFile} Makefile"
    ;


  nativeBuildInputs = [
    pkg-config
    lua5_1
    ansi
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

    lua5_1
    ansi
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp src/sweetwm $out/bin/sweetwm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/darmovzal/sweetwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "sweetwm";
  };
}
