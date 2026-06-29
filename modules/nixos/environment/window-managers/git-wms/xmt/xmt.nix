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
  xxd,

}:

stdenv.mkDerivation rec {
  pname = "xmt";
  version = "2020-08-29";

  src = fetchFromGitHub {
    owner = "Cubified";
    repo = "xmt";
   #rev = "master";
    rev = "6a067264a8eb17f82b572a36ef96e7539f214b29";
    sha256 = "03bc5gfgfwdd57hh2161y9rzcgpn3mmxmq2l414blr8a1c1xz35i";
  };

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
    xxd
  ];

  makeFlags = [
    #"CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild

    #make -s -C lib/wsServer
    xxd -i web/web.html > include/web.html.h

    gcc -o xmt -lm -lpthread -lX11 -lXdamage -lXfixes -Os -pipe -s -Ilib -Ilib/wsServer/include

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp xmt $out/bin/xmt

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Cubified/xmt";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xmt";
  };
}
