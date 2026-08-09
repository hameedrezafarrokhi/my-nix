{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  meson,
  ninja,
  android-tools,
  fuse,
  conan,
  boost,
  spdlog,
  vcpkg,
  rapidcheck,
  asio,
}:

stdenv.mkDerivation rec {
  pname = "madbfs";
  version = "2020-10-21";

  src = fetchFromGitHub {
    owner = "mrizaln";
    repo = "madbfs";
   #rev = "main";
    rev = "AAA4d22bf6cf4e1abd520921eacce1fe38277741";
    sha256 = "AAAfcxhz8m399skm7jk0348561722kgwgpqs5gk351i6sb0phglf";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    conan

  ];

  buildInputs = [
    android-tools
    fuse
    boost
    spdlog
    vcpkg
    rapidcheck
    asio
  ];

  meta = with lib; {
    homepage = "https://github.com/mrizaln/madbfs";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "madbfs";
  };
}
