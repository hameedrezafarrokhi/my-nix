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
  wails,

}:

stdenv.mkDerivation rec {
  pname = "keyboardsounds-pro";
  version = "desktop/v0.3.2";

  src = fetchFromGitHub {
    owner = "keyboard-sounds";
    repo = "keyboardsounds-pro";
    tag = version;
    hash = "sha256-by6xrG96rHpr52MBlqDIC8KpBYHEyZXWQ7fGSn7u5Uk=";
  };

  nativeBuildInputs = [
    pkg-config
    wails
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

  sourceRoot = "source/desktop";

  postPatch = ''
    substituteInPlace wails.json \
      --replace '"dev"' '"${version}"'
  '';

  buildPhase = ''
    runHook preBuild

    wails build -tags webkit2_41

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pwd
    ls

    mkdir -p $out/bin
    cp keyboardsounds-pro $out/bin/keyboardsounds-pro

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/keyboard-sounds/keyboardsounds-pro";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "keyboardsounds-pro";
  };
}
