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

  rustPlatform,
  pkg-config,

  writeText,
  conf ? null,
}:

rustPlatform.buildRustPackage rec {
  pname = "wtftw";
  version = "2021-01-21";

  src = fetchFromGitHub {
    owner = "Kintaro";
    repo = "wtftw";
   #rev = "master";
    rev = "aacbfcb79c1f27a4017f48f618041bc9bd644524";
    sha256 = "1wdd9yy2civg07ll32c7ffg1f340lbhy64g60v13j1ccgqz1rbmg";
  };

  contribSrc = fetchFromGitHub {
    owner = "Kintaro";
    repo = "wtftw-contrib";
   #rev = "master";
    rev = "e55f47df061d0c601a6e217b8bc3244e98b50e49";
    sha256 = "0vmlqfk2bi87gaxn32cv1szjvdqspv5nxdsfi5xjw4mp6clll7vh";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.rs" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config/config.rs";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
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

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  prePatch = ''
    mkdir -p contrib wtftw-contrib
    cp -r ${contribSrc}/* contrib/
    cp -r ${contribSrc}/* wtftw-contrib/
    cp -r ${contribSrc}/src/* src/
  '';

  meta = with lib; {
    homepage = "https://github.com/Kintaro/wtftw";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "wtftw";
  };
}
