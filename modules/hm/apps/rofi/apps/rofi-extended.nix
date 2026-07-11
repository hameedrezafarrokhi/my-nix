{ lib
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonPackage rec {
  pname = "rofi-extended";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "markhedleyjones";
    repo = "dmenu-extended";
    rev = "dd93e7aef1ec6991292b6a1ed2cfb6dfbf849ed5";
    sha256 = "1jggm6bzs5pb99fsb2xkd0781ai96ld1ph32pmci5g2ahw83rydk";
  };

  pyproject = true;

  build-system = with python3Packages; [ setuptools wheel build ];

  dependencies = with python3Packages; [ build ruff mock pytest ];

  nativeCheckInputs = with python3Packages; [ pytest ];

  meta = {
    description = " ";
    homepage = "https://github.com/markhedleyjones/dmenu-extended";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
