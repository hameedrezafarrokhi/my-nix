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
  pname = "xuv";
  version = "2026-05-01";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "NRK";
    repo = "xuv";
    rev = "2a179e0c48f1407aa15acb1f2bbf6564cc793a18";
    sha256 = "1kq3yj4pkdyx7rkafzbj2qirzg8j7sg4ssy15vl09wc6ngnql3vj";
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

    cc -o xuv xuv.c -O3 -s -l X11

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/man/man1 $out/share/man/man5
    install -Dm755 xuv $out/bin/xuv
    install -Dm644 etc/xuv.1 $out/share/man/man1/xuv.1
    install -Dm644 etc/xuv.conf.5 $out/share/man/man1/xuv.conf.5

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/NRK/xuv";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xuv";
  };
}
