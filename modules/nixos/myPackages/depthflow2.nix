{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, attrs
, cyclopts
, diskcache
, imageio
, numpy
, pillow
, platformdirs
, pooch
, pydantic
, scipy
, shaderflow
, torch
, torchvision
, transformers
, xxhash
}:

buildPythonPackage rec {
  pname = "depthflow";
  version = "1.0.0";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "BrokenSource";
    repo = "DepthFlow";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [
    # hatchling will be auto-detected from pyproject.toml
  ];

  propagatedBuildInputs = [
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

  # Include examples in the package
  postInstall = ''
    mkdir -p $out/${python.sitePackages}/depthflow/examples
    cp -r examples/* $out/${python.sitePackages}/depthflow/examples/
  '';

  pythonImportsCheck = [ "depthflow" ];

  meta = {
    description = "Images to 3D parallax effect videos";
    homepage = "https://github.com/BrokenSource/DepthFlow";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "depthflow";
  };
}
