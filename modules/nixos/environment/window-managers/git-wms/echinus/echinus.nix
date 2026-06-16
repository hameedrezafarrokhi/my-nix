{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libXft,
  libXrandr,
  libxkbcommon,
  xorgproto,
  pkg-config,
  writeText,
  conf ? null,
  fetchpatch,
  patches ? [ ],
}:

stdenv.mkDerivation rec {
  pname = "echinus";

  version = "2019-05-06";
 #version = "v0.3.6";

  src = fetchFromGitHub {
    owner = "polachok";
    repo = "echinus";

   #rev = "master";
    rev = "987e1395dcf93a336ff2c090dc5936a9333b3704";
    sha256 = "1wgzmv93v0rgdjcxcxryw63v0djbibxryvm1xj2lq62yihvidzdz";

   #tag = version;
   #hash = "sha256-2R8fN6pZicZ64/+UZvbAN5KTJ8NG6727h1CksqMZJ4w=";
  };

  inherit patches;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libX11
    libXft
    libXrandr
    libxkbcommon
    xorgproto
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
    "DESTDIR=${placeholder "out"}"
  ];

  postInstall = ''
    mkdir -p $out/bin
    cp $out/$out/bin/echinus $out/bin/
  '';

  meta = with lib; {
    homepage = "https://github.com/polachok/echinus";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "echinus";
  };
}
