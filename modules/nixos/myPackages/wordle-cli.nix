{
  lib,
  fetchFromGitHub,
  fontconfig,
  freetype,
  pkg-config,
  buildGoModule,
}:

buildGoModule rec {
  pname = "wordle-cli";
  version = "2022-10-01";

  src = fetchFromGitHub {
    owner = "nimblebun";
    repo = "wordle-cli";
    rev = "90f3c622983dd9b37056b111ea4096774bfd4b59";
    sha256 = "0c9ci24qmfisbjmcmybg7ml9ivszjvk6fq5lcchdzwqpmc3g0364";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fontconfig
    freetype
  ];

  vendorHash = "sha256-+8SIvfQ50FvyNl3ECzgQFFydE1UcQfJrcmApK7Zq3Lc=";

  meta = with lib; {
    homepage = "https://github.com/nimblebun/wordle-cli";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "wordle-cli";
  };
}
