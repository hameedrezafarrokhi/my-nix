{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go,
  bash,
  installShellFiles,
}:

buildGoModule rec {
  pname = "simplewm";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "janbina";
    repo = "swm";
    tag = version;
    hash = "sha256-nm2GGDjDM0cH7Qj7KWUV1IBhObtU0d4U8UIhBkZmWmw=";
  };

  vendorHash = "sha256-5qZKknIbMT66iAKNT6vWKtsYYvFmcsh5Z2YJt2l6+9E=";

  subPackages = [ "cmd/swm" "cmd/swmctl" ];

  ldflags= [
    "-X github.com/janbina/swm/internal/buildconfig.Version=${version}"
  ];

  nativeBuildInputs = [ go bash installShellFiles ];

  postInstall = ''
    # Install shell completions if available
    # Install man pages if available
  '';

  meta = with lib; {
    homepage = "https://github.com/janbina/swm";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "simplewm";
  };
}
