{ lib
, libX11
, libXres
, pandoc
, pkg-config
, procps
#, unixtools
#, uutils-procps
, stdenv
, systemd
, systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemd
, tomlc99
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "gulp";
  version = "v0.0.1";

  src = fetchFromGitHub {
    owner = "Toalaah";
    repo = "gulp";
   #rev = "master";
    tag = version;
    hash = "sha256-t6zgaMJkX9bo91OKxDwF7Aonnfmqht4FWz1sO4hewXE=";
  };

  makeFlags = [
    "VERSION=${version}"
    "-lproc2"
  ];

  NIX_CFLAGS_COMPILE = "-I${procps}/include/proc";

  installFlags = [ "PREFIX=$(out)" ]
    ++ lib.optionals systemdSupport [
    "SYSTEMD=1"
    "SYSTEMD_PREFIX=$(out)/etc/systemd"
  ];

  nativeBuildInputs = [
    pkg-config
    pandoc
  ];

  buildInputs = [
    libX11
    libXres
    procps
    #unixtools.procps
    #uutils-procps
    tomlc99
  ];

 #propagatedBuilInputs = [ procps ];

  meta = {
    homepage = "https://github.com/Toalaah/gulp";
    description = "X Control Story";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

}
