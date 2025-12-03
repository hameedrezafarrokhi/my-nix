{ lib
, fetchFromGitHub
, python3Packages
, wmctrl
, xdotool
, gobject-introspection
, wrapGAppsHook3
, libwnck
, gtk3
, tk
, tcl
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

  nativeBuildInputs = [
    python3Packages.setuptools
    wrapGAppsHook3
    gobject-introspection
  ];

  pyproject = true;

 #build-system = [ python3Packages.setuptools ];

  propagatedBuildInputs = with python3Packages; [
    psutil
    pycurl
    pygobject3
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  doCheck = false;  # Tests might not exist or need X server

  # Runtime dependencies
  buildInputs = [
    wmctrl
    xdotool
    libwnck
    gtk3
    tk
    tcl
  ];

  pythonPath = with python3Packages; [
    tkinter
  ];

 #  # Or use a simpler approach: just override the version variable
  preBuild = ''
    # Set the version directly in the environment
    export SETUPTOOLS_SCM_PRETEND_VERSION="${version}"
  '';

  # Fix the version issue in setup.py
 #preBuild = ''
 #  # Create version.py
 #  echo 'version = "${version}"' > xsession_manager/version.py
 #
 #  # Replace the exec line in setup.py with a simple assignment
 #  sed -i "s/exec(compile(open('xsession_manager\/version.py').read(), 'xsession_manager\/version.py', 'exec'))/__version__ = '${version}'/" setup.py
 #'';

  # Make sure GI_TYPELIB_PATH is set correctly
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
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
