{
  lib,
  stdenv,
  buildNimPackage,
  fetchFromGitHub,
  libx11,
  xorg-server,
  nimble,
  nim1,
}:

#stdenv.mkDerivation rec {
buildNimPackage rec {

  pname = "worm";
  version = "2024-05-30";

  src = fetchFromGitHub {
    owner = "codic12";
    repo = "worm";
   #rev = "master";
    rev = "be59f192956b3e38050d45520adc878e509388dd";
    sha256 = "160jrp267cmfwhqc6wzqbhalg6w2hcw4chk8in85qib6z0zvjr6l";
  };

  requiredNimVersion = 1;

  nativeBuildInputs = [
    nimble
    nim1
    xorg-server
    libx11.dev
    libx11
  ];

  depsBuildBuild = [
    libx11
    xorg-server
    libx11.dev
  ];

  buildInputs = [
    libx11
    libx11.dev
    xorg-server
  ];

  NIX_CFLAG_COMPILE = "-I${libx11.dev}/include";

  nimFlags = [
    "-d:release"
   #"--verbose"
  ];

 #preBuild = ''
 #  export HOME=$(mktemp -d)
 #  export NIMBLE_CACHE_DIR=$TMPDIR
 #'';

 #buildPhase = ''
 #  runHook preBuild
 #
 #  nimble build -d:release --verbose
 #  #nimble -y build -d:release --gc:arc --passC:"-Wno-error=incompatible-pointer-types" --verbose
 #  # --outdir:$out/bin

 #  runHook postBuild
 #'';

  installPhase = ''
    runHook preInstall

    # bin
    install -D -m755 worm $out/bin/worm
    install -D -m755 wormc $out/bin/wormc

    # docs
    install -Dm644 README.md $out/share/doc/worm/README.md
    install -Dm644 docs/wormc.md $out/share/doc/worm/WORMC.md

    # examples
    install -Dm755 examples/rc $out/share/doc/worm/examples/rc
    install -Dm644 examples/sxhkdrc $out/share/doc/worm/examples/sxhkdrc
    install -Dm755 examples/jgmenu_run $out/share/doc/worm/examples/jgmenu_run

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/codic12/worm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "worm";
  };
}
