{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "plot";
  version = "2026-06-24";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "plot";
   #rev = "master";
    rev = "fb71e49ed01767420343bd5631538ea2cdf9237d";
    sha256 = "0vd76bk0flng86jd105p4m58s2s9f4dsc7iyrg6blgs0afs49pmz";
  };

  buildInputs = [ ];

  cargoHash = "sha256-T+wq8Utms6JjOzSIeaaMt3Q01bK1pahSOKZOXwgtViQ=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/plot";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "plot";
  };
}
