{ lib
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonPackage rec {
  pname = "python-rofi";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "bcbnz";
    repo = "python-rofi";
    rev = version;
    hash = "sha256-VNaXRwKNhTCHY2Ns1HcoMd1R+GTPVtnaStix0HGUdlA=";
  };

  pyproject = true;
  build-system = with python3Packages; [ setuptools wheel ];
  dependencies = with python3Packages; [ ];
  nativeCheckInputs = with python3Packages; [ pytest ];

  meta = {
    description = " ";
    homepage = "https://github.com/bcbnz/python-rofi";
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
