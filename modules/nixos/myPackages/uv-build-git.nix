{
  lib,
  pkgs,
  fetchFromGitHub,
  python3Packages,
  rustPlatform,
  callPackage,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "uv-build";
  version = "0.10.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "uv";
    tag = finalAttrs.version;
    hash = "sha256-F0SA+DNCnJMMZK2vWaQB22ErvFOmvFZN6JT1z01DUxI=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-OfakFIDa2sbJSNQKWHaWZFia661h2QCGvrlnp1GrY08=";
  };

  buildAndTestSubdir = "crates/uv-build";

  # $src/.github/workflows/build-binaries.yml#L139
  maturinBuildProfile = "minimal-size";

  pythonImportsCheck = [ "uv_build" ];

  # The package has no tests
  doCheck = false;

  # Run the tests of a package built by `uv_build`.
  passthru = {
    tests.built-by-uv = callPackage ./built-by-uv.nix { };

    # updateScript is not needed here, as updating is done on staging
  };

  meta = {
    description = "Minimal build backend for uv";
    homepage = "https://docs.astral.sh/uv/reference/settings/#build-backend";
    inherit (pkgs.uv.meta) changelog license;
    maintainers = with lib.maintainers; [ bengsparks ];
  };
})
