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
  fontconfig,
  freetype,
  pkg-config,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation {
  pname = "stw-git";
  version = "2024-11-25";

  src = fetchFromGitHub {
    owner = "sineemore";
    repo = "stw";
    rev = "fa09dcc95499eccb77ff82c39d08e9f6aadf9e8a";
    sha256 = "sha256-LpnZOJ6ybXXt3qLFoPFCOAes9RIcpW9EPD9Y37tP1fI=";
  };

  nativeBuildInputs = [ pkg-config ];

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
    fontconfig
    freetype
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";

  makeFlags = [
    "CC:=$(CC)"
    "PREFIX=$(out)"
  ];

  meta = {
    description = "Simple text widget for X";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ somasis ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
    mainProgram = "stw";
  };
}
