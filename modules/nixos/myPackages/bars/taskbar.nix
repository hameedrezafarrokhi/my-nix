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

  writeText,
  conf ? null,

  zig,
  git,
}:

stdenv.mkDerivation rec {
  pname = "taskbar";
  version = "2026-06-27";

  src = fetchFromGitHub {
    owner = "baverman";
    repo = "taskbar";
   #rev = "main";
    rev = "f036f6900b35b5ad1e34d956bc80b6126c092813";
    sha256 = "0f1y4rmy300wbn712y3vgpny5ibza4nc0c5d0mrg0wqxrqvpyvy6";
  };

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.zig" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} src/config.zig";


  nativeBuildInputs = [
    pkg-config
    zig
    git
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

  buildPhase = ''
    runHook preBuild

    zig build --prefix zig-release --release=safe

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp zig-release/bin/taskbar $out/bin/simple-taskbar

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/baverman/taskbar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "taskbar";
  };
}
