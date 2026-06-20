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

  buildGoModule,
  go,

}:

buildGoModule rec {
  pname = "bouncy-wm";
  version = "2020-04-23";

  src = fetchFromGitHub {
    owner = "xordspar0";
    repo = "bouncy-wm";
   #rev = "main";
    rev = "8b2f8c0979ad8a2db170039ea580720ac374f97b";
    sha256 = "11wbvgpi33kjrqhvkxx22ckxp41lddf7ip4d63vccajvfd1gyh6p";
  };

  nativeBuildInputs = [
    pkg-config
    go
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

  vendorHash = "sha256-MqK8+MXinvHG7aIAsDIWvI0+TWwJvuAqJrqBU9ocRHc=";

  buildPhase = ''
    runHook preBuild
    go build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bouncy-wm $out/bin/bouncy-wm
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/xordspar0/bouncy-wm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bouncy-wm";
  };
}
