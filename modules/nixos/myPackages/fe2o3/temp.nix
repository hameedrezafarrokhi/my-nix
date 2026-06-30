{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

let

  crust = fetchFromGitHub {
    owner = "isene";
    repo = "crust";
   #rev = "master";
    rev = "7d2e5ef009042c299b3c84ebd249df1f0f3e3103";
    sha256 = "0fsxiwp25qf7p8h6674n1bmmfci3kahkjhvvc0n9xz1fy4d2dfl3";
  };

  glow = fetchFromGitHub {
    owner = "isene";
    repo = "glow";
   #rev = "master";
    rev = "9af8ac03e37f79d87ef8fe81a1ce14e4d729efec";
    sha256 = "1ms56p58dsvx2yfsj7iqjgk550q4mp4xgx8nvpswsi235ir24606";
  };

  plot = fetchFromGitHub {
    owner = "isene";
    repo = "plot";
   #rev = "master";
    rev = "fb71e49ed01767420343bd5631538ea2cdf9237d";
    sha256 = "0vd76bk0flng86jd105p4m58s2s9f4dsc7iyrg6blgs0afs49pmz";
  };

  orbit = fetchFromGitHub {
    owner = "isene";
    repo = "orbit";
   #rev = "master";
    rev = "d5f53f82d6017995cb2df4ec34e28285ca01b434";
    sha256 = "110gc3b2rykvhwgqqw3d116gq0a87d9akwccdzyy4ad16wxy1hyz";
  };
  orbit-lock = ./Orbit-Cargo.lock;

  highlight = fetchFromGitHub {
    owner = "isene";
    repo = "highlight";
   #rev = "master";
    rev = "17efdab513523f9cab40329b76782936697a4472";
    sha256 = "0607ajcw5cw2bfk3lssynsacqz11n9jp6ib4p8xfdzd7ibknw2vs";
  };

in

rustPlatform.buildRustPackage rec {
  pname = "temp";
  version = "0000-00-00";

  src = fetchFromGitHub {
    owner = "isene";
    repo = "temp";
   #rev = "master";
    rev = "AAAe580abd078fc280c40e70673fdde5b77db22a";
    sha256 = "AAA3b7i7p5j57jclwcs9g4qy159c10g1w2y36p9bss97w5sczsss";
  };

  buildInputs = [ ];

  prePatch = ''
    mkdir -p highlight
    cp -r ${highlight}/* highlight/
    mkdir -p orbit
    cp -r ${orbit}/* orbit/
    cp ${orbit-lock} orbit/Cargo.lock

    substituteInPlace Cargo.toml \
      --replace '../crust' '${crust}'
    substituteInPlace Cargo.toml \
      --replace '../glow' '${glow}'
    substituteInPlace Cargo.toml \
      --replace '../plot' '${plot}'
    substituteInPlace Cargo.toml \
      --replace '../highlight' './highlight'
    substituteInPlace highlight/Cargo.toml \
      --replace '../crust' '${crust}'
    substituteInPlace Cargo.toml \
      --replace '../orbit' './orbit'
  '';

  cargoHash = lib.fakeHash;

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/isene/temp";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "temp";
  };
}
