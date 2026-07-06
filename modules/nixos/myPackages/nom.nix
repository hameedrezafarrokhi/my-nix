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
  pkg-config,
  rustPlatform,

}:

rustPlatform.buildRustPackage rec {
  pname = "num";
  version = "2024-03-17";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fawn";
    repo = "nom";
    rev = "9a180e4bd3064a917d4ddde36aa664d9fbe5f77f";
    sha256 = "1j05afasblgw7hw2xic4v91kx8mdi10wc29yb0wjzm4mrrnsrmk1";
  };

  cargoHash = "sha256-d3MLz0id68Sb0WQ8hBNiJsrk5+qIY28YBnvrS3S2D9k=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
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
  ];

  postInstall = ''
    cp $out/bin/nom $out/bin/num
    rm -f $out/bin/nom
  '';

  meta = {
    description = " ";
    homepage = "https://codeberg.org/fawn/nom";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "nom";
  };
}
