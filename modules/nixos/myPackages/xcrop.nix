{
  lib,
  gcc13Stdenv,
  fetchFromGitea,

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

  writeText,
  conf ? null,
}:

gcc13Stdenv.mkDerivation rec {
  pname = "xcrop";
  version = "2026-03-11";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "begbaj";
    repo = "xcrop";
    rev = "a3611ec993ad5d0d2bfdbe548b76f5c3a250c621";
    sha256 = "1lbmaa26gadqs0513i23298lj7fjkrmvqw4mq1cafl5jglav0ml6";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.h";


  nativeBuildInputs = [
    pkg-config
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

  buildPhase = ''
    runHook preBuild

    #${gcc13Stdenv.cc.targetPrefix}cc -O2 xcrop.c -o build/xcrop -lX11

    ${gcc13Stdenv.cc.targetPrefix}cc -O3 -Wl,-z,relro,-z,now xcrop.c -o xcrop -lX11 -lpthread

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp xcrop $out/bin/xcrop

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/begbaj/xcrop";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xcrop";
  };
}
