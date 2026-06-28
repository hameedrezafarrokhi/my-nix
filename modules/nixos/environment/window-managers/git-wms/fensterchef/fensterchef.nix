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
  pname = "fensterchef";
  version = "2026-06-21";

  src = fetchFromGitHub {
    owner = "DevByProxy";
    repo = "fensterchef";
   #rev = "main";
    rev = "4ca8d161c6a9962411ec70af06e29660b8339333";
    sha256 = "1d33arp66lq4fd0ragbs7z25kc5fhrfvs70p36klxy37l9n138nd";
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

  prePatch = ''
    substituteInPlace make \
      --replace '/usr/' '$out/'
  '';

 #makeFlags = [
 #  "CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];

  buildPhase = ''
    runHook preBuild
    ./make fensterchef install
    runHook postBuild
  '';

  installPhase = ''
   #runHook preInstall
   #
   #mkdir -p $out/bin
   #cp fensterchef $out/bin/fensterchef
   #
   #runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/DevByProxy/fensterchef";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "fensterchef";
  };
}
