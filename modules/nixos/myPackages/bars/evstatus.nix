{
  lib,
  stdenv,
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

  buildGoModule,
  go,

}:

buildGoModule rec {
  pname = "evstatus";
  version = "2024-05-19";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "kolunmi";
    repo = "evstatus";
    rev = "75e752768ba71c0a3c547066ca2d9374037a7f43";
    hash = "sha256-oi+8JX9YIOD8pKzUyuzThYaUfmcJspfNA1c0ysDZoAI=";
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

  vendorHash = lib.fakeHash;

 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp evstatus $out/bin/evstatus
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://codeberg.org/kolunmi/evstatus";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "evstatus";
  };
}
