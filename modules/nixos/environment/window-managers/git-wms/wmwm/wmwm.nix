{
  lib,
  stdenv,
  fetchFromGitHub,
  libX11,
  pkg-config,
  go,
  buildGoModule,
}:

buildGoModule rec {
  pname = "wmwm";
  version = "2026-05-18";

  src = fetchFromGitHub {
    owner = "Zamony";
    repo = "wmwm";
   #rev = "master";
    rev = "76772ef3fe6638dfc66d84403755d9183e63de88";
    sha256 = "16fk9sl469314klrwsp1xfh55wkqjw1k75yj1irn4akb627k7pfs";
  };

  vendorHash = "sha256-z4Qqc5oe/1ERFHI+gExVpDgy67pmXHjM+e53O4yp6dM=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libX11 ];

  meta = with lib; {
    homepage = "https://github.com/Zamony/wmwm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "wmwm";
  };
}
