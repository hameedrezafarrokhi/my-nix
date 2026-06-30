{
  lib,
  stdenv,
  fetchFromGitea,
  libX11,
  pkg-config,
  go,
  buildGoModule,
}:

buildGoModule rec {
  pname = "go-afwm";
  version = "2026-04-11";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "gruf";
    repo = "go-afwm";
   #rev = "main";
    rev = "0455b59a1cf3964fa7f703e415f03a7c41238e88";
    sha256 = "0ny2397v967s9l902q7blfinsrjq1sd4bh94y0sp0rs7g3fvg8ia";
  };

  vendorHash = null;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libX11 ];

  meta = with lib; {
    homepage = "https://codeberg.org/gruf/go-afwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "go-afwm";
  };
}
