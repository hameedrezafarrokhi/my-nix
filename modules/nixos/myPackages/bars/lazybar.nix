{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cairo,
  pango,
  pulseaudio,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "lazybar";
  version = "2026-05-10";

  src = fetchFromGitHub {
    owner = "Qelxiros";
    repo = "lazybar";
   #rev = "main";
    rev = "c9329b95486718aadfb8f7af486ad1ff78d5f66e";
    sha256 = "131dkvbgznj155gk1rmvn6jv7lmx5ncjqz7mks2kzssq9zmgdq4y";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    pango
    cairo
    pulseaudio
    openssl
  ];

  cargoHash = "sha256-JqiwUo0+yw24vZcxfCtl5tMLef+oqhifxe2WzM1hZhE=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/Qelxiros/lazybar";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "lazybar";
  };
}
