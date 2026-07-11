{ lib
, python3Packages
, fetchFromGitHub
, callPackage
, xdotool
, libxrandr
, xrandr
, libx11
, gnugrep
, bash
}:

python3Packages.buildPythonPackage rec {
  pname = "xdisplayinfo";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "lu0";
    repo = "current-x-display-info";
    rev = "v${version}";
    hash = "sha256-wgzwfy/gXyMvzLOxoCsgwu8ZiTEf99MpZkAQGW1wBnA=";
  };

  pyproject = true;

  build-system = with python3Packages; [ setuptools wheel ];

  dependencies = with python3Packages; [ cairocffi numpy ] ++ [ xdotool libxrandr libx11 xrandr gnugrep ];

  nativeCheckInputs = with python3Packages; [ pytest ];

  meta = {
    description = " ";
    homepage = "https://github.com/lu0/current-x-display-info";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
