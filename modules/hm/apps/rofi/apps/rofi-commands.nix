{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "rofi-commands";
  version = "2019-02-23";

  src = fetchFromGitHub {
    owner = "moustacheful";
    repo = "myrmidon";
    rev = "15ccf12b036b88f38156e31adae982212447b64b";
    sha256 = "1384y2f7xy3z3mrar3ch3bkqch82798kb075ibm4ziwrkzczjfbh";
  };

  postPatch = ''
    substituteInPlace myrmidon.sh \
      --replace '$cwd/confirm.sh' 'rofi-commands-confirm'
    substituteInPlace myrmidon.sh \
      --replace '.myrmidon-tasks.json' '.config/rofi-commands.json'
  '';

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    install -D -m755 ./myrmidon.sh $out/bin/rofi-commands
    install -D -m755 ./confirm.sh $out/bin/rofi-commands-confirm
  '';

  meta = {
    description = " ";
    homepage = "https://github.com/moustacheful/myrmidon";
    platforms = with lib.platforms; linux;
  };
}
