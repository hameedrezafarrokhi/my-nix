{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  xorgproto,
  libxcb,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "mmwm";
  version = "2020-01-01";

  src = fetchFromGitHub {
    owner = "kaugm";
    repo = "mmwm";
    rev = "master";
    hash = "sha256-l8IFt1FOuaQl5+dKR5oQ3lbjF3wP/4R/p9b2KS0TPpc=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libX11
    xorgproto
    libxcb
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    homepage = "https://github.com/kaugm/mmwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "mmwm";
  };
}
