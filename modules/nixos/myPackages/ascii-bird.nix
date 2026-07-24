{
  lib,
  gcc13Stdenv,
  fetchFromGitHub,
}:

gcc13Stdenv.mkDerivation rec {
  pname = "ASCII-BIRD";
  version = "2014-02-28";

  src = fetchFromGitHub {
    owner = "carlosruizp";
    repo = "ASCII-BIRD";
    rev = "d3fb7bd6c9464e117cc5eb42e057687204a59c94";
    sha256 = "055ba9yg3lgzqhl7swi2b5yf4pjh7hgcj1h0szv3dljxamyrvjyf";
  };

  preBuild = ''
    mkdir -p build
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ascii-birds $out/bin/ascii-bird

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/carlosruizp/ASCII-BIRD";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "ASCII-BIRD";
  };
}
