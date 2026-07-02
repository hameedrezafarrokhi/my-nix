{
  python3Packages,
  uv-build,
  anyio,
  pytestCheckHook,
}:
python3Packages.buildPythonPackage {
  pname = "built-by-uv";
  version = "0.1.0";
  pyproject = true;

  src = "${uv-build.src}/test/packages/built-by-uv";

  build-system = with python3Packages; [ uv-build ];

  dependencies = with python3Packages; [ anyio ];

  pythonImportsCheck = [ "built_by_uv" ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];
}
