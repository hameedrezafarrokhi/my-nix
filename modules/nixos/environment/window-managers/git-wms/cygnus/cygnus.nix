{
  stdenv,
  lib,
  fetchFromGitHub,
  gcc,
  makeWrapper,
  pkg-config,
  libX11,
  SDL2,
  SDL2_ttf,
  ffmpeg,
  sfml,
  csfml,
  which,
}:

let

  cygnus = fetchFromGitHub {
    owner = "jt-copernicus";
    repo = "Cygnus";
   #rev = "main";
    rev = "67d94edafd7be4280038d516e079566a3b205ff4";
    sha256 = "1xli5d2jzk4wjvf93x9zvxsgldfsigwvsj4x56n26ppif27r1mn2";
  };

in

stdenv.mkDerivation rec {
  pname = "cygnus-wm";
  version = "2026-04-01";

  src = fetchFromGitHub {
    owner = "hameedrezafarrokhi";
    repo = "unpatched-bins";
    rev = "eee8a316b0b3b0b14233872d258f0062443519bf";
    sha256 = "146lmf5nv7sn14yj05b0n2g0yz30k73qn38wrzry2cn4zz93ar61";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    which
  ];

  buildInputs = [
    gcc
    libX11
    SDL2
    SDL2_ttf
    ffmpeg
    sfml
    csfml
  ];

 #makeFlags = [
 #  "PREFIX=${placeholder "out"}"
 #  "XSESSIONDIR=${placeholder "out"}/share/xsessions"
 #];
 #
 #buildPhase = ''
 #  mkdir -p cygnus-paint
 #  mv main.cpp cygnus-paint/
 #  mv cygnus-paint.1 cygnus-paint/
 #  mv pmakefile cygnus-paint/Makefile
 #  make
 #'';
 #
 #installPhase = ''
 #  make install
 #'';

  buildPhase = ''
    mkdir -p $out/bin
    cp ${src}/cygnus/bin/* $out/bin/
    mkdir -p $out/share/man/man1
    cp ${src}/cygnus/man/* $out/share/man/man1/
  '';

  installPhase = ''
    wrapProgram $out/bin/cygnus \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    wrapProgram $out/bin/cygnus-calc \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

     wrapProgram $out/bin/cygnus-cam \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

     wrapProgram $out/bin/cygnus-clock \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

     wrapProgram $out/bin/cygnus-edit \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

     wrapProgram $out/bin/cygnus-fm \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

     wrapProgram $out/bin/cygnus-media \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

     wrapProgram $out/bin/cygnus-mount \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

     wrapProgram $out/bin/cygnus-open \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

     wrapProgram $out/bin/cygnus-shot \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

     wrapProgram $out/bin/cygnus-view \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

  '';

  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/cygnus || true

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/cygnus-calc || true

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/cygnus-cam || true

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/cygnus-clock || true

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/cygnus-edit || true

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/cygnus-fm || true

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/cygnus-media || true

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/cygnus-mount || true

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/cygnus-open || true

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/cygnus-shot || true

    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/cygnus-view || true

  '';

  meta = with lib; {
    homepage = "https://github.com/jt-copernicus/Cygnus";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "fxwm";
  };

}
