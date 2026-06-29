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

  zig_0_13,
}:

stdenv.mkDerivation rec {
  pname = "fwwm";
  version = "2024-11-12";

  src = fetchFromGitHub {
    owner = "fawni";
    repo = "fwwm";
   #rev = "master";
    rev = "89fc6b217dadd8fb04636a1fa1e80069eb901811";
    sha256 = "09n04wa92x73vnyshndqga91qra5f2cqazz47721f7nvxq2zq988";
  };

  nativeBuildInputs = [
    pkg-config
    zig_0_13
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

    zig build --release=safe

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp zig-out/bin/fwwm $out/bin/fwwm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/fawni/fwwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "fwwm";
  };
}
