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

}:

stdenv.mkDerivation rec {
  pname = "ferawm";
  version = "2026-03-14";

  src = fetchFromGitHub {
    owner = "Fera-Maxwell";
    repo = "FeraWM";
   #rev = "main";
    rev = "ce29b2b5d4b9c6f98b9a72673811658a455da541";
    sha256 = "1gxmmfz6w7ns0k7x6cz981m18wpb3mjqk5ykgafjvnkdqsi5cv7r";
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
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
    "DESKTOPDIR=${placeholder "out"}/share/fera"
    "CONFDIR=${placeholder "out"}/etc/fera"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/etc/fera
    cp build/ferawm $out/bin/ferawm
    install -Dm644 ferawm.conf $out/etc/fera/ferawm.conf

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Fera-Maxwell/FeraWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "ferawm";
  };
}
