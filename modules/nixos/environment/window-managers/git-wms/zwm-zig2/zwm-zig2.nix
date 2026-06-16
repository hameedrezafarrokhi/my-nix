{
  lib,
  stdenv,
  fetchFromGitHub,
  zig,
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
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "zwm-zig2";
  version = "2023-02-26";

  src = fetchFromGitHub {
    owner = "zuranthus";
    repo = "zwm";
   #rev = "main";
    rev = "b1a593c2d85fee33bb80858d9c12940615ff25aa";
    sha256 = "1874cx32p9lf5qas1fah3qi69zf0y0hzrh08ryfz1sk363rhrk37";
  };

  nativeBuildInputs = [ zig ];

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

  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.zig" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} src/config.zig";

  buildPhase = ''
    zig build install -p $out/bin
  '';

  postInstall = ''
    mkdir -p $out/bin
    cp $out/bin/zwm $out/bin/zwm-zig2
    rm -f $out/bin/zwm
  '';

  meta = with lib; {
    homepage = "https://github.com/zuranthus/zwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "zwm-zig2";
  };
}
