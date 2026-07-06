{ lib
, python3Packages
, fetchFromGitHub
, callPackage
}:

python3Packages.buildPythonPackage rec {
  pname = "cortile-addons";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "leukipp";
    repo = "cortile-addons";
    rev = "v${version}";
    hash = "sha256-zEntsnrnI/pviqtWzcsjCG2M/EvWgbtdvtgUxtvvOMs=";
  };

  pyproject = true;

  build-system = with python3Packages; [ setuptools hatchling ];

  dependencies = with python3Packages; [ dbus-python ];

  nativeCheckInputs = with python3Packages; [ pytest ];

  meta = {
    description = " ";
    homepage = "https://github.com/leukipp/cortile-addons";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
