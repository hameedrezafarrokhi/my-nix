{ lib
, python3Packages
, python313Packages
, fetchFromGitHub
}:

python3Packages.buildPythonPackage rec {
  pname = "keyboardsounds";
  version = "2026-03-05";

  src = fetchFromGitHub {
    owner = "nathan-fiscaletti";
    repo = "keyboardsounds";
    rev = "6785c7ac17b9f4db1f3d7f3d1d87a23067944517";
    sha256 = "0pmw4q5ad1p69a5yjl365jky8ypfd5h8nn883p6ng4xq7s0pbzpm";
  };

  pyproject = true;

  build-system = with python3Packages; [
    setuptools
    wheel
    requests
  ];

  dependencies =
  (with python3Packages; [
    imageio-ffmpeg
    psutil
    pygame
    pynput
    pyyaml
    requests
    setuptools
    pydub
    pyinstaller
    libevdev
    wheel
  ])
  ++ (with python313Packages; [ audioop-lts ]);

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
    description = " ";
    homepage = "https://github.com/nathan-fiscaletti/keyboardsounds";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
