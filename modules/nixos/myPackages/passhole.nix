{ lib
, python312Packages
, fetchFromGitHub
, callPackage
}:

python312Packages.buildPythonPackage rec {
  pname = "passhole";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "Evidlo";
    repo = "passhole";
    rev = "v${version}";
    hash = "sha256-Xnm2hU3okekBx3UFEyL6+NeTy9KVTXr2EbDfh6Ek46g=";
  };

  pyproject = true;

  build-system = with python312Packages; [
    setuptools
    wheel
  ];

  pykeepass-cache = callPackage ./pykeepass-cache.nix { };

  dependencies = with python312Packages; [
    argon2-cffi
    argon2-cffi-bindings
    cffi
    colorama
    construct
    evdev
    future
    lockfile
    lxml
    plumbum
    pycparser
    pycryptodomex
    pykeepass
    pynput
    pyotp
    python-daemon
    xlib
    qrcode
    rpyc
    six
  ]
  ++ [ pykeepass-cache ]
  ;

  nativeCheckInputs = with python312Packages; [
    pytest
  ];

  meta = {
    description = " ";
    homepage = "https://github.com/Evidlo/passhole";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
