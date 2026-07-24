{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "flappy-bird";
  version = "2020-01-09";

  src = fetchFromGitHub {
    owner = "emrahyldrm";
    repo = "flappy-bird";
    rev = "e57ffb7d769086fbd00f33cc4e9eec3dddb3df90";
    sha256 = "1z7vk61jdyracpcgsblvfr83r0k29qsw5krj3i24mjs9m1gx81sj";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ ncurses ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp flappybird $out/bin/flappybird

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/emrahyldrm/flappy-bird";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "flappy-bird";
  };
}
