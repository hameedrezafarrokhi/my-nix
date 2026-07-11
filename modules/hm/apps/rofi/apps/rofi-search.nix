{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs-slim,
 #rofi,
  ddgr,
  xclip,
  xdg-utils,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "rofi-search";
  version = "2022-11-08";

  src = fetchFromGitHub {
    owner = "fogine";
    repo = "rofi-search";
    rev = "880bc39a29160282da5727cb93ba0a2408cf29d7";
    sha256 = "126pssc0x7m5c415lp04qlxb51dkifgfb27345k19iwxjdl3lsm0";
  };

  buildInputs = [ nodejs-slim makeWrapper /*rofi*/ ddgr xclip xdg-utils ];

  wrapperPath = lib.makeBinPath [ /*rofi*/ xclip xdg-utils ddgr ];

  installPhase = ''
    mkdir -p $out/bin
    cp rofi-search $out/bin/rofi-search
    chmod +x $out/bin/rofi-search
    substituteInPlace $out/bin/rofi-search \
      --replace '/bin/sh' '${nodejs-slim}/bin/node'
    wrapProgram $out/bin/rofi-search \
      --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    homepage = "https://github.com/fogine/rofi-search";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-search";
  };
}
