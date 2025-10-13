{
  lib,
  fetchFromGitHub,
  python3,
  python3Packages,
  gtk3,
  gtk-layer-shell,
  cairo,
  gobject-introspection,
  libdbusmenu-gtk3,
  gdk-pixbuf,
  cinnamon-desktop,
  gnome-bluetooth,
}:
python3Packages.buildPythonPackage {
  pname = "fabric";
  version = "0.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric";
    rev = "v0.0.1";
    hash = "sha256-8HrzieeOj9dmRNXXV1AA6jV7COVYPnD7dK9npPxtER4=";
  };

  buildInputs = [
    gtk3
    gtk-layer-shell
    cairo
    gobject-introspection
    libdbusmenu-gtk3
    gdk-pixbuf
    cinnamon-desktop
    gnome-bluetooth
  ];

  dependencies = with python3Packages; [
    setuptools
    click
    pycairo
    pygobject3
    pygobject-stubs
    loguru
    psutil
  ];

  meta = {
    changelog = "";
    description = ''
      next-gen framework for building desktop widgets using Python (check the rewrite branch for progress)
    '';
    homepage = "https://github.com/Fabric-Development/fabric";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [];
  };
}
