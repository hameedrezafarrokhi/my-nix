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
  pname = "zentile";
  version = "2021-06-16";

  src = fetchFromGitHub {
    owner = "blrsn";
    repo = "zentile";
   #rev = "master";
    rev = "d33522ecc2fb62e16449d765faef2c218523510c";
    sha256 = "03r16yl8ii4k0hwn3vimk1786cz4nw4dwg6m6bnras6b5mb7bj9v";
  };

  vendorHash = "sha256-610B3i3KvQjLuYvjIp5IPdZ01r+jjOBehJ5/YB5mME0=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libX11 ];

  meta = with lib; {
    homepage = "https://github.com/blrsn/zentile";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "zentile";
  };
}
