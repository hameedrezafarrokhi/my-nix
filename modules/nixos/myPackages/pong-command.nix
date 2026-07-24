{
  lib,
  fetchFromGitHub,
  pkg-config,
  go,
  buildGoModule,
}:

buildGoModule rec {
  pname = "pong-command";
  version = "2026-02-21";

  src = fetchFromGitHub {
    owner = "kurehajime";
    repo = "pong-command";
    rev = "3841bda644b4178b891cbdbe5afa5f928cc33fde";
    sha256 = "0zsh0x48ppfkc9x4lbryxy9lfrcpnxmwpkymldkwf2xig869z602";
  };

  nativeBuildInputs = [ pkg-config ];

  vendorHash = "sha256-HPOV0ODOTwBkWjtN7sdf0TipOTNCQJy/1XNDUyrLlkg=";

  meta = with lib; {
    homepage = "https://github.com/kurehajime/pong-command";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "pong-command";
  };
}
