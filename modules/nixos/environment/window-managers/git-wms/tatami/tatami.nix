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
  pname = "tatami";
  version = "2026-03-25";

  src = fetchFromGitHub {
    owner = "0xMukesh";
    repo = "tatami";
   #rev = "main";
    rev = "942330708de05eafb104ba737dffd89fadfad75b";
    sha256 = "1scrd5dy7xcrn0vchvccf9bz18sp4qp9qqrrngy57y1rsgjbkxjs";
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

  vendorHash = "sha256-KCSU5bHS4qprqNbrNxRCGJJSJdHs5OF/yZkTX+XlYo0=";

  buildPhase = ''
    runHook preBuild
    go build -o ./dist/tatami .
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp dist/tatami $out/bin/tatami
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/0xMukesh/tatami";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "tatami";
  };
}
