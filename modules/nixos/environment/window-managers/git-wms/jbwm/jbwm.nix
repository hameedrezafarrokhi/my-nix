{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  pkg-config,
  libXext,
  xorgproto,
  installShellFiles,
  writeText,
  conf ? null,
  keys ? null,
  client ? null,
  titlebar ? null,
}:

stdenv.mkDerivation rec {
  pname = "jbwm";
  version = "1.63";

  src = fetchFromGitHub {
    owner = "alisabedard";
    repo = "jbwm";
    tag = version;
    hash = "sha256-a+pBWnjjQglXmnbkcR+0fExFy7IQMLbcfFO5P23o7IY=";
  };

  buildInputs = [ libX11 libXext xorgproto ];

  nativeBuildInputs = [ pkg-config installShellFiles ];

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
      keysFile =
        if lib.isDerivation keys || builtins.isPath keys then keys else writeText "JBWMKeys.h" keys;
      clientFile =
        if lib.isDerivation client || builtins.isPath client then client else writeText "JBWMClientOptions.h" client;
      titlebarFile =
        if lib.isDerivation titlebar || builtins.isPath titlebar then titlebar else writeText "JBWMClientTitleBar.h" titlebar;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h"
    + " \n " +
    lib.optionalString (keys != null) "cp ${keysFile} JBWMKeys.h"
    + " \n " +
    lib.optionalString (client != null) "cp ${clientFile} JBWMClientOptions.h"
    + " \n " +
    lib.optionalString (titlebar != null) "cp ${titlebarFile} JBWMClientTitleBar.h"
    ;

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  preConfigure = ''
    cat > config.mk <<EOF
    PREFIX=$out
    CC=${stdenv.cc.targetPrefix}cc
    CFLAGS=-I${libX11.dev}/include -I${libXext.dev}/include -I${xorgproto}/include
    LDFLAGS=-L${libX11.out}/lib -L${libXext.out}/lib
    jbwm_cflags=
    jbwm_ldflags=
    DEBIAN=
    EOF
  '';

  postBuild = ''
    sed -i '/strip/d' Makefile
  '';

  installTargets = [ "install" ];

  meta = with lib; {
    homepage = "https://github.com/alisabedard/jbwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "jbwm";
  };
}
