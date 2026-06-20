{
  lib,
  stdenv,
  fetchFromGitHub,

  libx11,
  libxft,
  libxrandr,
  libxrender,
  libxres,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxmu,
  libxpm,
  libxmp,
  libxt,
  libxdamage,
  libxdmcp,
  libxcomp,
  libxcomposite,
  libxkbcommon,

  libxcb,
  libxcb-wm,
  libxcb-util,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-errors,
  libxcb-cursor,

  fontconfig,
  freetype,

  pkg-config,

  bundlerEnv,
  gem,
  ruby,
  makeWrapper,
  procps,

}:

let

  repo = fetchFromGitHub {
    owner = "aldrinmartoq";
    repo = "bouncywm-ruby";
   #rev = "master";
    rev = "f6d424b6107c1349c8ee338b6a46c7116c6d1ea7";
    sha256 = "10vbzbr5b49j0f5l88d6p6c5j2ibn141r4m8s0yxz91pkxmpcl7p";
  };

  gems = bundlerEnv {
    name = "bouncywm-ruby";
    gemdir = repo;
    gemfile = "${repo}/Gemfile";
    lockfile = "${repo}/Gemfile.lock";
    gemset = ./gemset.nix;
  };

in

stdenv.mkDerivation rec {
  pname = "bouncywm-ruby";
  version = "2019-11-29";

  src = repo;

  nativeBuildInputs = [
    pkg-config
    gem
    ruby
  ];

  buildInputs = [
    libx11
    libxft
    libxrandr
    libxrender
    libxres
    libxcursor
    libxext
    libxi
    libxinerama
    libxmu
    libxpm
    libxmp
    libxt
    libxdamage
    libxdmcp
    libxcomp
    libxcomposite
    libxkbcommon

    libxcb
    libxcb-wm
    libxcb-util
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-errors
    libxcb-cursor

    fontconfig
    freetype

    makeWrapper
    procps

    ruby
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -r lib/* $out/lib

    mkdir -p $out/bin
    #cp bin/bouncywm $out/bin/bouncywm

    cat > $out/bin/bouncywm <<EOF
    #!/bin/sh
    cd ${repo}
    exec ${gems}/bin/bundle exec ruby bin/bouncywm "\$@"
    EOF

    chmod +x $out/bin/bouncywm

    #wrapProgram $out/bin/bouncywm \
    #  --set GEM_PATH ${gems}/lib/ruby/gems/3.4.0

    wrapProgram $out/bin/bouncywm \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/aldrinmartoq/bouncywm-ruby";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "bouncywm";
  };
}
