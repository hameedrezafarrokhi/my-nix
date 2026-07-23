{
  lib,
  fetchFromGitHub,
  fontconfig,
  freetype,
  pkg-config,
  buildGoModule,
}:

buildGoModule rec {
  pname = "clidle";
  version = "2025-03-29";

  src = fetchFromGitHub {
    owner = "ajeetdsouza";
    repo = "clidle";
    rev = "e0e2cb1d3c71d52f7f7294f52c497bf558a605d1";
    sha256 = "18bh8li8736bmc0rzrj3cmmpq55rg95a3w815qzdkh5cphrhj0ia";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fontconfig
    freetype
  ];

  vendorHash = "sha256-vevil9MxPr3YcB7m1Jzvypioq6aOkWrQeFCC1fPeQKw=";

  meta = with lib; {
    homepage = "https://github.com/ajeetdsouza/clidle";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "clidle";
  };
}
