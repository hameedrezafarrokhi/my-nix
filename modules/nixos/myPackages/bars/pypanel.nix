{ lib
, fetchFromGitHub
, python3Packages
, freetype
, imlib2
, libxft
, libxrender
, libx11
}:

python3Packages.buildPythonPackage rec {
  pname = "pypanel";
  version = "2.4"; # 2011-04-18
  src = fetchFromGitHub {
    owner = "madprog";
    repo = "PyPanel";
   #rev = "main";
    rev = "2c4f879360dee59dc8d22984dfbdc02dbca3c604";
    sha256 = "1304hdflq4vdd68f1j6spc61fjzryiv8790n7i0ad3clg4wq2jwh";
  };

  buildInputs = [
    freetype
    imlib2
    libx11
    libxft
    libxrender
  ];

  propagatedBuildInputs = [
    python3Packages.xlib
  ];

  pyproject = true;
  build-system = [ python3Packages.setuptools python3Packages.xlib ];

  patchPhase = ''
    substituteInPlace setup.py \
      --replace 'configs = ["freetype-config", "imlib2-config"]' \
                'configs = ["${freetype.dev}/bin/freetype-config", "${imlib2.dev}/bin/imlib2-config"]' \
      --replace 'idirs   = ["/usr/X11R6/include"]' \
                'idirs   = ["${libx11.dev}/include", "${libxft.dev}/include", "${freetype.dev}/include", "${imlib2.dev}/include"]' \
      --replace 'ldirs   = []' \
                'ldirs   = ["${libx11.out}/lib", "${libxft.out}/lib", "${freetype.out}/lib", "${imlib2.out}/lib"]' \
      --replace 'print "\nPyPanel requires the Python X library -"' \
                '  ' \
      --replace 'print "http://sourceforge.net/projects/python-xlib/"' \
                '  ' \
      --replace 'print "\nPyPanel requires the Imlib2 library -"' \
                '  '  \
      --replace 'print "http://www.enlightenment.org/pages/imlib2.html"' \
                '  ' \
      --replace 'print "#!%s -OO" % sys.executable' \
                'print("hello")' \
      --replace 'print line' \
                'print("hello")'

    substituteInPlace bin/pypanel \
      --replace '/usr/bin/env python' '${python3Packages.python}/bin/python'
  '';

  doCheck = false;
}
