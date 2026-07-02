{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "aevum-shell";
  version = "2026-06-02";

  src = fetchFromGitHub {
    owner = "rudv-ar";
    repo = "aevum-shell";
   #rev = "main";
    rev = "50fcea08e830576a47f9fe61d30a003dca4cb85c";
    sha256 = "1hnxmmrmplfm1xacppwwwsxps63ql86saw96in71x1w8va7vl6sy";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/${pname}
    cp -r ${src}/* $out/share/${pname}/
  '';

  meta = with lib; {
    homepage = "https://github.com/rudv-ar/aevum-shell";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "aevum-shell";
  };
}
