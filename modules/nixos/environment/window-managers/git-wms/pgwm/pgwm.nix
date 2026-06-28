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

}:

rustPlatform.buildRustPackage rec {
  pname = "pgwm";
  version = "2026-02-22";

  src = fetchFromGitHub {
    owner = "MarcusGrass";
    repo = "pgwm";
   #rev = "main";
    rev = "6339a56c71034be77ac8786597da0298511962df";
    sha256 = "0hbm337qrg69i2zrw7ihazhf8r4ybg64sv1n0xh81n723h1yk5hp";
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

  cargoHash = "sha256-vz0ViLfsiCu6u/lunNuCZoYHBlXRk6IBRrIyZp9LmV8=";

  doCheck = false;

  buildPhase = ''
    RUSTFLAGS='-C panic=abort -C link-arg=-nostartfiles -C target-cpu=native -C target-feature=+crt-static -C relocation-model=pie' cargo b -p pgwm --target x86_64-unknown-linux-gnu
  '';

  installPhase = ''
    #cd target/x86_64-unknown-linux-gnu/debug
    #pwd
    #ls
    #bababooi
    mkdir -p $out/bin
    cp target/x86_64-unknown-linux-gnu/debug/pgwm $out/bin/pgwm
  '';

  meta = with lib; {
    homepage = "https://github.com/MarcusGrass/pgwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "pgwm";
  };
}
