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

  xorgproto,
  libjack2,

  bash,
}:

stdenv.mkDerivation rec {
  pname = "MrMessy";
  version = "2023-08-21";

  src = fetchFromGitHub {
    owner = "noudio";
    repo = "MrMessy";
    rev = "986d9d6ebe055934f055ae1beaa8a2f497c2be9a";
    sha256 = "0bafkqg2w1saykda65gzr804l74cnj49pcvh724y48f2brbp78yc";
  };

  nativeBuildInputs = [
    pkg-config
    bash
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
    xorgproto
    libjack2
  ];

  makeFlags = [
   #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  postPatch = ''
    substituteInPlace make.sh \
      --replace '/bin/bash -x' '${bash}/bin/bash'
    substituteInPlace make.sh \
      --replace 'cp $odir/noudioJack noudioJack' ' '
  '';

  buildPhase = ''
    runHook preBuild

    ./make.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp xdisp $out/bin/xdisp
    #cp noudioJack $out/bin/noudioJack

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/noudio/MrMessy";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "MrMessy";
  };
}
