{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  libxcb,
  libxcb-util,
  libxcb-keysyms,
  libxcb-wm,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "frankenwm";
  version = "2024-06-04";

  src = fetchFromGitHub {
    owner = "sulami";
    repo = "frankenwm";
   #rev = "master";
    rev = "1e0a6ef1b1d9fcdf87266d7a3cb8bb48c2d03ead";
    sha256 = "0b8cin1pzi8lg2hbiryrxi4ah1mbngwg6v29iqsshcj0wvv2y68l";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libX11
    libxcb
    libxcb-util
    libxcb-keysyms
    libxcb-wm
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  meta = with lib; {
    homepage = "https://github.com/sulami/frankenwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "frankenwm";
  };
}
