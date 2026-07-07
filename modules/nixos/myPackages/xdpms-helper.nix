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

  writeText,
  conf ? null,

}:

stdenv.mkDerivation rec {
  pname = "xdpms-helper";
  version = "2026-06-05";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "rsm";
    repo = "xdpms-helper";
    rev = "b3c22bb7fef59ebc5b1e3438bf80e15c3b789408";
    sha256 = "1gf5lr2vsjpqq1jg46m5q27si4f6grzdjf59hipklckprylklffr";
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

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "app-defaults" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} app-defaults";


  buildPhase = ''
    runHook preBuild

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/etc/X11/app-defaults
    cp xdpms-helper $out/bin/xdpms-helper
    cp app-defaults $out/etc/X11/app-defaults/xdpms-helper
    chmod +x $out/bin/xdpms-helper

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/rsm/xdpms-helper";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "xdpms-helper";
  };
}
