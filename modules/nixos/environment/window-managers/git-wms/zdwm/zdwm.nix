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

  xorgproto,

  pkg-config,
  zig,
  autoPatchelfHook,

}:

stdenv.mkDerivation rec {
  pname = "zdwm";
  version = "2026-06-21";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "metanoia";
    repo = "zdwm";
    rev = "560bbfc61bcacd3c289e5cd4bbdd1869b7902afd";
    sha256 = "0sh8lz8rya3h2py29vqa00fx0kfzsz55211hn7h03cdp5pw67flf";
  };

  nativeBuildInputs = [
    pkg-config
    zig
    autoPatchelfHook
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

    xorgproto

    fontconfig
    freetype
  ];

  buildPhase = ''
    runHook preBuild

    cat build.zig
    sed -i 's#/include" });#/include" });\nc_bindings.addIncludePath(.{ .cwd_relative = "${libxrender.dev}/include" });\nc_bindings.addIncludePath(.{ .cwd_relative = "${libxft.dev}/include" });\nc_bindings.addIncludePath(.{ .cwd_relative = "${fontconfig.dev}/include" });\nc_bindings.addIncludePath(.{ .cwd_relative = "${freetype.dev}/include" });\nc_bindings.addIncludePath(.{ .cwd_relative = "${libxinerama.dev}/include" });\nc_bindings.addIncludePath(.{ .cwd_relative = "${libx11.dev}/include" });\nc_bindings.addIncludePath(.{ .cwd_relative = "${xorgproto}/include" });#g' build.zig
    cat build.zig
    ZIG_GLOBAL_CACHE_DIR=$PWD/zig-cache zig build -Drelease=true

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp zig-out/bin/zdwm $out/bin/zdwm

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/metanoia/zdwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "zdwm";
  };
}
