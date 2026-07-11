{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  yt-dlp,
  jq,
  fzf,
  mpv,
  ffmpeg,
  gum,
}:

let

  deps = [
    yt-dlp
    jq
    fzf
    mpv
    ffmpeg
    gum
  ];

in

stdenvNoCC.mkDerivation {
  pname = "rofi-ytx";
  version = "git";

  src = fetchFromGitHub {
    owner = "Benexl";
    repo = "yt-x";
    rev = "fbd2669c10f3d8a559b95c8a647da083e6178254";
    sha256 = "1929y7yw2vrrj1inkyf1v1wq3082al1f1pq02fcz93lr6cza7ghq";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp yt-x $out/bin/rofi-ytx
    chmod +x $out/bin/rofi-ytx
    wrapProgram $out/bin/rofi-ytx \
      --prefix PATH : ${lib.makeBinPath deps}

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Benexl/yt-x";
    description = " ";
    longDescription = '' '';
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-ytx";
  };

}
