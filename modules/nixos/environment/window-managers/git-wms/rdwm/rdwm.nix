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

  rustPlatform,

  lua5_4,

}:

rustPlatform.buildRustPackage rec {
  pname = "rdwm";
  version = "2026-04-22";

  src = fetchFromGitHub {
    owner = "ntBre";
    repo = "rwm";
   #rev = "master";
    rev = "c9ad971af6befbe2b37ea0c18ce0056280cacde4";
    sha256 = "17r316g79ip5hzxifks3yb4ss62v5gy5rp6405kknhpa8ynjd0w2";
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

    lua5_4

  ];

  cargoHash = "sha256-2T4Q56x/xteW0Kjh5phCvyD7FCtyo0Y+UAg4TpjnGc8=";

  doCheck = false;

  postInstall = ''
    cp -f $out/bin/rwm $out/bin/rdwm
    rm -f $out/bin/rwm
  '';

  meta = with lib; {
    homepage = "https://github.com/ntBre/rwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rwm";
  };
}
