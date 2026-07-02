{ lib
, python3Packages
, fetchFromGitHub
, callPackage
}:

python3Packages.buildPythonPackage rec {
  pname = "expressive-shapes";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "amansxcalibur";
    repo = "expressive-shapes";
    rev = "v${version}";
    hash = "sha256-kvcit3t4Uic1GhKYnnzJNxREmzrTGMYFH61wMVh4uAo=";
  };

  pyproject = true;

  uv-build = callPackage ./uv-build-git.nix { };
  build-system = with python3Packages; [
   #uv
   #uv-build
    setuptools
    wheel
  ]
  ++
  [ uv-build ]
  ;

  dependencies = with python3Packages; [
   #uv-build
    cairocffi
    numpy
  ]
  ++
  [ uv-build ]
  ;

  nativeCheckInputs = with python3Packages; [
    pytest
  ];

  # If you have tests, uncomment this:
  # checkPhase = ''
  #   runHook preCheck
  #   pytest
  #   runHook postCheck
  # '';

  meta = {
    description = "Expressive shape morphing and animations";
    homepage = "https://github.com/amansxcalibur/expressive-shapes";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
