{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "dunst-history-reporting";
  version = "2022-01-09";

  src = fetchFromGitHub {
    owner = "shanenoi";
    repo = "dunst-history-reporting";
    rev = "29ab780f168831e78204c78b93dbb5c4027742de";
    sha256 = "0gvclddwzlcynjbmz2hyi3hmwk6myn33xy6wcn2m16zlm8rj80j8";
  };

  cargoHash = "sha256-XrPJaZzmpncgc26gcYgmixdzDNIAEAUpwV+GygHZ2lc=";

  postInstall = ''
    cp $out/bin/history $out/bin/dunst-history-reporting
    rm -f $out/bin/history
  '';

  meta = {
    description = " ";
    homepage = "https://github.com/shanenoi/dunst-history-reporting";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "dunst-history-reporting";
  };
}
