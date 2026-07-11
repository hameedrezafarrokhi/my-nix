{
  lib,
  stdenv,
  fetchFromGitHub,
  sitespeed-io,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "rofi-chrome-switch";
  version = "2020-05-16";

  src = fetchFromGitHub {
    owner = "kevinmorio";
    repo = "rofi-switch-browser-tabs";
    rev = "788cce881ba8c3891175fbbe62b9c799aa47652b";
    sha256 = "0m4vldx9k6wxx7s7zkkwbj11r7vckvdky8fypf73qzmgl0yn4vmi";
  };

  buildInputs = [ makeWrapper /*sitespeed-io*/ ];

  installPhase = ''
    mkdir -p $out/bin
    ln -sf ${sitespeed-io}/lib/node_modules/sitespeed.io/node_modules/.bin/chrome-remote-interface $out/bin/chrome-remote-interface
    cp chrome-switch-tabs/chrome-switch-tabs $out/bin/rofi-chrome-switch

    #cp chrome-switch-tabs/chrome-switch-tabs $out/bin/rofi-chrome-switch-unwrapped
    #cat > $out/bin/${pname} << 'EOF'
    ##!/usr/bin/env bash
    #
    #brave --remote-debugging-port=9222
    #
    #exec rofi-chrome-switch-unwrapped "$@"
    #
    #EOF
    #
    #chmod +x $out/bin/${pname}

  '';

  meta = with lib; {
    homepage = "https://github.com/kevinmorio/rofi-switch-browser-tabs";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "rofi-chrome-switch";
  };
}
