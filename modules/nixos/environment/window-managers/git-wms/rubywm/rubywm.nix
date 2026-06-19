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

  ruby,

  writeText,
  conf ? null,

  makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "rubywm";
  version = "2024-07-02";

  src = fetchFromGitHub {
    owner = "vidarh";
    repo = "rubywm";
   #rev = "master";
    rev = "6b80d24bdf07d3343d8b36870dbeae8906a6b2e2";
    sha256 = "1xkzjl0src869khzfb4063539x2d28rmzrr6kglaiplv6qy3ngc9";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.yaml" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.yaml";

  nativeBuildInputs = [
    pkg-config
    ruby
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

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rubywm $out/bin
    cp -r ./* $out/share/rubywm/

    runHook postInstall
  '';

  postInstall = ''
    cat > $out/bin/rubywm << 'EOF'
    #!/usr/bin/env bash

    (${ruby}/bin/ruby $out/share/rubywm/rubywm.rb 2>&1 | logger -t rubywm) &

    while true; do
      wait
      sleep 5
    done

    EOF

    chmod +x $out/bin/rubywm
  '';

  meta = with lib; {
    homepage = "https://github.com/vidarh/rubywm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rubywm";
  };
}
