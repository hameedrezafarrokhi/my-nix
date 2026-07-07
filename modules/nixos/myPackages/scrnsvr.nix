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

  libxscrnsaver,

  pkg-config,
  pwntools,
  pcre,

}:

gcc13Stdenv.mkDerivation rec {
  pname = "scrnsvr";
  version = "2021-10-02";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "koraynilay";
    repo = "scrnsvr";
    rev = "04c8344506ce7275c647d346c787e13e5e547280";
    sha256 = "0l0wa632j3jwqz58kpbr1maszgs9qj12mchkxify4zp9zykzgy89";
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

    libxscrnsaver
    pwntools
    pcre
  ];

  buildPhase = ''
    runHook preBuild

    #${gcc13Stdenv.cc.targetPrefix}cc -g -O0 -Wl,-z,relro,-z,now src/scrnsvr.c -o scrnsvr -lXss -lX11 -lpthread
    ${gcc13Stdenv.cc.targetPrefix}cc -O3 -Wl,-z,relro,-z,now src/scrnsvr.c -o scrnsvr -lpthread -lXss -lX11 -lXinerama -lXrandr -lpcre

    #${gcc13Stdenv.cc.targetPrefix}cc src/scrnsvr.c -o scrnsvr -lXss -lX11 -lpthread

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/scrnsvr
    cp scrnsvr $out/bin/scrnsvr
    cp scrnsvr.ini.example $out/share/scrnsvr/scrnsvr.ini.example
    cp scrnsvr.service $out/share/scrnsvr/scrnsvr.service.example

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/koraynilay/scrnsvr";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "scrnsvr";
  };
}
