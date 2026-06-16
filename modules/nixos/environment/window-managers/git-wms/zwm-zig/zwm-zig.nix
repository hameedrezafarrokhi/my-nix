{
  lib,
  stdenv,
  fetchFromGitHub,
  zig_0_15,
  libX11,
  libxinerama,
  libxrandr,
  libxcb,
  libxcb-util,
  libxcb-keysyms,
  libxcb-wm,
  libxcb-cursor,
  libxcb-render-util,
  libxcb-image,
  libxcb-errors,
  xorgproto,
  libxkbcommon,
}:

stdenv.mkDerivation rec {
  pname = "zwm-zig";
  version = "2026-04-09";

  src = fetchFromGitHub {
    owner = "midasdf";
    repo = "zwm";
   #rev = "main";
    rev = "66d3836c82ff3b1ab1580ecce2b12f64b6771b07";
    sha256 = "1aky493jx3gf6g7n601j4qqax8ny6fzc9igrjp94pl5i2i781h53";
  };

  nativeBuildInputs = [ zig_0_15 ];

  buildInputs = [
    libX11
    libxinerama
    libxrandr
    libxcb
    libxcb-util
    libxcb-keysyms
    libxcb-wm
    libxcb-cursor
    libxcb-render-util
    libxcb-image
    libxcb-errors
    xorgproto
    libxkbcommon
  ];

  buildPhase = ''
    #zig build -Doptimize=ReleaseSmall   # → 37KB
    zig build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp zig-out/bin/zwm $out/bin/zwm-zig
  '';

  meta = with lib; {
    homepage = "https://github.com/midasdf/zwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "zwm-zig";
  };
}
