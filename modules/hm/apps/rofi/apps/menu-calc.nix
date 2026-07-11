{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, bc
, rofi
, xclip
, wl-clipboard
}:

stdenv.mkDerivation rec {
  pname = "menucalc";
  version = "v1.3.0";

  src = fetchFromGitHub {
    owner = "sumnerevans";
    repo = "menu-calc";
    rev = "7e6d322e14d9bdd405c54b7a0ec86396787e08f2";
    sha256 = "0cn1ibza48sb6gs0xj1d2rdgycy9ahy5qygjdxyi4dzgqglc17ar";
  };

  buildInputs = [ makeWrapper ];
  dontBuild = true;

  installPhase = ''
    mkdir -p "$out/bin"
    install -D -m755 ./= "$out/bin/="
    mkdir -p "$out/share/man/man1"
    install -D -m644 ./=.1 "$out/share/man/man1/=.1"
    install -D -m644 ./menu-calc.1 "$out/share/man/man1/menu-calc.1"
  '';

  wrapperPath = lib.makeBinPath [ bc rofi xclip wl-clipboard ];

  fixupPhase = ''
    patchShebangs $out/bin
    wrapProgram $out/bin/= --prefix PATH : "${wrapperPath}"
  '';

  meta = {
    description = "A calculator for Rofi/dmenu(2)";
    homepage = "https://github.com/sumnerevans/menu-calc";
    # maintainers = with stdenv.lib.maintainers; [ sumnerevans ];
    license = lib.licenses.mit;
    platforms = with lib.platforms; linux;
  };
}
