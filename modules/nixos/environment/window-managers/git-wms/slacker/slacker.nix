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

  clang-tools,
  clang,

}:

stdenv.mkDerivation rec {
  pname = "slacker";
  version = "2024-06-09";

  src = fetchFromGitHub {
    owner = "thebashpotato";
    repo = "slacker";
   #rev = "main";
    rev = "1d027ad6d5ff31c40b2afefa11dbdf6f6d64d9ed";
    sha256 = "1jhxfscv85akwg7xqipw17z6aasnf9pzcf4k1vkd31mzljf9sg8p";
  };

  prePatch = ''
    substituteInPlace make/settings.mk \
      --replace '/usr/local' '$out/'
    substituteInPlace make/settings.mk \
      --replace '$(HOME)/.config' '$out/share/slackerwm'

    mkdir -p $out/bin $out/share/slackerwm
  '';

  nativeBuildInputs = [
    pkg-config
    clang-tools
    clang
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
  ];

 #buildPhase = ''
 #  runHook preBuild
 #
 #
 #
 #  runHook postBuild
 #'';
 #
 #installPhase = ''
 #  runHook preInstall
 #
 #  mkdir -p $out/bin
 #  cp slacker $out/bin/slacker
 #
 #  runHook postInstall
 #'';

  meta = with lib; {
    homepage = "https://github.com/thebashpotato/slacker";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "slacker";
  };
}
