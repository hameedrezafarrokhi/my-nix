{ lib
, python3Packages
, fetchFromGitHub
, callPackage
}:

python3Packages.buildPythonPackage rec {
  pname = "cysystemd";
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "mosquito";
    repo = "cysystemd";
    rev = "${version}";
    hash = "sha256-1ewI4geRW+PoJasBALe/fspZyr1+9GM2SCpLCBQIMxY=";
  };

  pyproject = true;

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ ];

  nativeCheckInputs = with python3Packages; [ pytest ];

  meta = {
    description = " ";
    homepage = "https://github.com/mosquito/cysystemd";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
