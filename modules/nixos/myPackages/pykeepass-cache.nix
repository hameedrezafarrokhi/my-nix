{ lib
, python312Packages
, fetchFromGitHub
, callPackage
}:

python312Packages.buildPythonPackage rec {
  pname = "pykeepass_cache";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "libkeepass";
    repo = "pykeepass_cache";
   #rev = "v${version}";
    rev = "master";
    hash = "sha256-2QbbjC/GyBHMCEEZOJimPe+MZpHr5Hs1QzHhXS8Hn0k=";
  };

  pyproject = true;

  build-system = with python312Packages; [
    setuptools
    wheel
  ];

  dependencies = with python312Packages; [
    pykeepass
    python-daemon
    rpyc
  ];

  nativeCheckInputs = with python312Packages; [
    pytest
  ];

  meta = {
    description = " ";
    homepage = "https://github.com/libkeepass/pykeepass_cache";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
