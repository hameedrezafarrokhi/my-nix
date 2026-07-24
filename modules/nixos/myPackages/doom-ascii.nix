{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  freetype,
  pkg-config,
  wget,
}:

stdenv.mkDerivation rec {
  pname = "doom-ascii";
  version = "2025-07-21";

  src = fetchFromGitHub {
    owner = "wojciech-graj";
    repo = "doom-ascii";
    rev = "b5188d7c9c4da6c81264a7803e8725ac3df2cfea";
    sha256 = "0v98i2n2gq2jnp3fhgchxj373vl4789ap04n3bnbs6kcinq7kwhh";
  };

  nativeBuildInputs = [ pkg-config wget ];

  buildInputs = [ fontconfig freetype ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp _unix/game/doom_ascii $out/bin/doom-ascii

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/wojciech-graj/doom-ascii";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "doom-ascii";
  };
}
