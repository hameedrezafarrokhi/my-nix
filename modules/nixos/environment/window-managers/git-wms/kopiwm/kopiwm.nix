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

  zig_0_15,

  writeText,
  fetchpatch,
  patches ? [ ],
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "kopiwm";
  version = "2026-05-07";

  src = fetchFromGitHub {
    owner = "nguyenvukhang";
    repo = "kopiwm";
   #rev = "main";
    rev = "6a1e0e3751d092cbe76614ad87a739b0f4abe563";
    sha256 = "0sdcwcn0qybjbri1m5rmiad2h6bravmilfx8rinp188mmqlkzxv2";
  };


  inherit patches;
  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.zig" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} src/config.zig";


  nativeBuildInputs = [
    pkg-config
    zig_0_15
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

 #makeFlags = [
 #  #"CC=${stdenv.cc.targetPrefix}cc"
 #  "PREFIX=${placeholder "out"}"
 #];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin
    zig build --prefix $out/bin -Doptimize=ReleaseFast install

    runHook postBuild
  '';

  meta = with lib; {
    homepage = "https://github.com/nguyenvukhang/kopiwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "kopiwm";
  };
}
