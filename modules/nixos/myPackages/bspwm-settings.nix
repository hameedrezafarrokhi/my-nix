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

  libxkbcommon,
  rustPlatform,

  gtk3,
  feh,
  bspwm,

  makeWrapper,
  autoPatchelfHook,

}:

rustPlatform.buildRustPackage rec {
  pname = "bspwm-settings";
  version = "2026-03-04";

  src = fetchFromGitHub {
    owner = "rudv-ar";
    repo = "bspwm-settings";
    rev = "5301b77d9349eee17140187ce81709d41c6ec37c";
    sha256 = "07myih7wp8fjrx766msm9wcw90mx895vmmdxfw8xzvq3dypndm7w";
  };

  cargoHash = "sha256-Nxp3SyOufWONgVhv5w+/S1KlBJ9UIk4av1aOUmE/7MI=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    makeWrapper
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

    fontconfig
    freetype

    gtk3
    feh
    bspwm
  ];

  doCheck = false;

  postFixup = ''
    wrapProgram $out/bin/bspwm-settings \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/bspwm-settings || true
  '';

  meta = {
    description = " ";
    homepage = "https://github.com/rudv-ar/bspwm-settings";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "bspwm-settings";
  };
}
