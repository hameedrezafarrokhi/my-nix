{ lib
, fetchFromGitHub
, python3Packages
, wmctrl
, xdotool
}:

python3Packages.buildPythonApplication rec {
  pname = "xsession-manager";
  version = "unstable-2021-09-08";  # Based on last commit date

  src = fetchFromGitHub {
    owner = "nlpsuge";
    repo = "xsession-manager";
    rev = "master";  # Or use a specific commit/tag
    hash = "sha256-jcFeyrF3aFzJBK6jsUgeCY/P6uNLIxEIZB5k+3D/gNk=";  # Update this
  };

 #nativeBuildInputs = [ ];

  nativeBuildInputs = [
    python3Packages.setuptools
  ];

  pyproject = true;

 #build-system = [ python3Packages.setuptools ];

  propagatedBuildInputs = with python3Packages; [
    psutil
    pycurl
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  doCheck = false;  # Tests might not exist or need X server

  # Runtime dependencies
  buildInputs = [
    wmctrl
    xdotool
  ];

 #postInstall = ''
 #  ln -s $out/bin/xsession-manager $out/bin/xsm
 #'';

  # The version is defined dynamically in the source
  # We need to patch the version.py file
 #postPatch = ''
 #  # Create a static version file
 #  cat > xsession_manager/version.py <<EOF
 #  version = "${version}"
 #  EOF
 #
 #  # Patch setup.py to use our version directly instead of exec
 #  substituteInPlace setup.py \
 #    --replace "exec(compile(open('xsession_manager/version.py').read(), 'xsession_manager/version.py', 'exec'))" \
 #              "version = '${version}'"
 #'';

    # Or use a simpler approach: just override the version variable
  preBuild = ''
    # Set the version directly in the environment
    export SETUPTOOLS_SCM_PRETEND_VERSION="${version}"
  '';

  meta = with lib; {
    description = "A command line tool to save and restore sessions for X11 desktops like Gnome";
    homepage = "https://github.com/nlpsuge/xsession-manager";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
    mainProgram = "xsession-manager";
  };
}
