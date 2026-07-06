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

  libxfixes,

  fontconfig,
  freetype,

  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "selx";
  version = "2026-05-01";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "NRK";
    repo = "selx";
    rev = "bf21d29c19cc082ca0788712f93c38ff7d519682";
    sha256 = "156arh3lac1pxpcjm7gg4d94x1z7yzz7r7dhyb5n1s4jjq1xl3vn";
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

    libxfixes

    fontconfig
    freetype
  ];

  buildPhase = ''
    runHook preBuild

    cc -o selx selx.c -O3 -s -l X11 -l Xrandr

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/man/man1
    install -Dm755 selx $out/bin/selx
    install -Dm644 selx.1 $out/share/man/man1/selx.1

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/NRK/selx";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "selx";
  };
}
