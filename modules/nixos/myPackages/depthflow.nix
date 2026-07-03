{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "depthflow";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "BrokenSource";
    repo = "DepthFlow";
    rev = "v${version}";
    hash = lib.fakeHash;
  };

  nativeBuildInputs = with python3Packages; [
    hatchling
  ];

  propagatedBuildInputs = with python3Packages; [
    attrs
    cyclopts
    diskcache
    imageio
    numpy
    pillow
    platformdirs
    pooch
    pydantic
    scipy
    shaderflow
    torch
    torchvision
    transformers
    xxhash
  ];

  pythonImportsCheck = [
    "depthflow"
  ];

  meta = with lib; {
    description = "Images to 3D parallax effect videos";
    homepage = "https://github.com/BrokenSource/DepthFlow";
    license = licenses.agpl3Only;
    mainProgram = "depthflow";
    maintainers = [ ];
  };
}
