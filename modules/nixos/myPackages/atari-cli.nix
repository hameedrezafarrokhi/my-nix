{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  buildNpmPackage,
  nodejs,
}:

buildNpmPackage rec {
  pname = "atari-cli";
  version = "2026-01-26";

  src = fetchFromGitHub {
    owner = "HugoRCD";
    repo = "atari-cli";
    rev = "6a9f8cd4879adfcdf91ccee78bf406b0c8019b35";
    sha256 = "18hsfc30z33w5m94f8051qpdscqiyiw5ld7v6jd9y49gfx4374ag";
  };

  lockfile = ./atari-cli-package-lock.json;

  postPatch = ''
    cp ${lockfile} ./package-lock.json
  '';

  npmDepsHash = "sha256-gxkAJtK6an36NvlwqS/+CdqH1/5CAiHR27JyJp9KuJg=";

  nativeBuildInputs = [ pkg-config nodejs ];

  meta = with lib; {
    homepage = "https://github.com/HugoRCD/atari-cli";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "atari-cli";
  };
}
