{
  stdenv,
  lib,
  fetchFromGitHub,
  fltk,
  libx11,
  which,
  squashfsTools,
  gcc13,
  bash,
  writeShellScript,
}:

stdenv.mkDerivation rec {
  pname = "fxwm";
  version = "2026-01-01";

  src = fetchFromGitHub {
    owner = "cliquesoft";
    repo = "fxWM";
    rev = "main";
    hash = "sha256-bLNIdpG9YY0qcsbDCk8riuIGONXhmq8f06KEqVZKipg=";
  };

  nativeBuildInputs = [ which squashfsTools gcc13 ];

  buildInputs = [ libx11 fltk bash ];

  buildPhase = ''
    ./make PREFIX=$out install
  '';

# # Override the build script's environment
# preBuild = ''
#   # Create a dummy fltk-config script if needed
#   if [ ! -f "$(which fltk-config)" ]; then
#     export PATH="${fltk}/bin:$PATH"
#   fi
# '';
#
# buildPhase = ''
#   runHook preBuild
#
#   # Set architecture based on system
#   if [ "$(uname -m)" == 'x86_64' ]; then
#     export CFLAGS="-mtune=generic -Os -pipe"
#     export CXXFLAGS="-mtune=generic -Os -pipe -fno-exceptions -fno-rtti"
#     export LDFLAGS="-Wl,-O1"
#   else
#     export CFLAGS="-march=i486 -mtune=i686 -Os -pipe"
#     export CXXFLAGS="-march=i486 -mtune=i686 -Os -pipe"
#     export LDFLAGS="-Wl,-O1"
#   fi
#
#   export CXXFLAGS="$CXXFLAGS $(fltk-config --cxxflags)"
#   export CXXFLAGS="$CXXFLAGS -Wall -ffunction-sections -fdata-sections -Wno-strict-aliasing"
#   export LDFLAGS="$LDFLAGS $(fltk-config --ldstaticflags --use-images)"
#
#   # Set PKG_CONFIG_PATH
#   export PKG_CONFIG_PATH="${fltk}/lib/pkgconfig"
#
#   # Compile the window manager
#   g++ -std=c++11 -o fxwm *.C *.cpp $CXXFLAGS $LDFLAGS || {
#     echo "ERROR: compilation failed!"
#     exit 1
#   }
#
#   # Strip debug symbols
#   find . -type f -executable -exec file {} \; | \
#     grep ELF | grep -v stripped | cut -d: -f1 | \
#     xargs strip --strip-unneeded 2>/dev/null || true
#
#   runHook postBuild
# '';
#
# installPhase = ''
#   runHook preInstall
#
#   # Install binary
#   install -Dm755 fxwm $out/bin/fxwm
#   install -Dm755 fxwm $out/bin/.fxwm
#
#   # Install man page if exists
#   if [ -f fxwm.1 ]; then
#     install -Dm644 fxwm.1 $out/share/man/man1/fxwm.1.gz
#     gzip -f $out/share/man/man1/fxwm.1
#   fi
#
#   # Install config files
#   install -Dm644 chrome.css $out/etc/fxwm/chrome.css
#
#   runHook postInstall
# '';
#
#
#   # Create wrapper script
#   #install -Dm755 ${wrapperScript} $out/bin/fxwm-wrapper
#
#
# # Create the wrapper script as a separate derivation
##wrapperScript = writeShellScript "fxwm-wrapper" ''
##  # create necessary directories
##  [ ! -e "$HOME/.etc/fxwm" ] && mkdir -p "$HOME/.etc/fxwm"
##
##  # create default values
##  [ ! -e "$HOME/.etc/fxwm/supervisor" ] && [ -e "/etc/fxwm/supervisor" ] && \
##    ln -sf /etc/fxwm/supervisor "$HOME/.etc/fxwm/supervisor"
##  [ ! -e "$HOME/.etc/fxwm/supervisor.conf" ] && [ -e "/etc/fxwm/supervisor.conf" ] && \
##    ln -sf /etc/fxwm/supervisor.conf "$HOME/.etc/fxwm/supervisor.conf"
##  [ ! -e "$HOME/.etc/fxwm/windows.conf" ] && [ -e "/etc/fxwm/windows.conf" ] && \
##    ln -sf /etc/fxwm/windows.conf "$HOME/.etc/fxwm/windows.conf"
##
##  # execute any executables present for the WM
##  IFS=$'\n'
##  for FILE in $(find -L "$HOME/.etc/fxwm" -maxdepth 1 -type f -perm /u=x ! -perm /o=w); do
##    setsid "$FILE" >>/var/log/fxwm.log 2>&1
##  done
##
##  # start the WM
##  exec @out@/bin/.fxwm -S "$(cat "$HOME/.etc/fxwm/supervisor")" \
##    $(cat "$HOME/.etc/fxwm/supervisor.conf") \
##    $(cat "$HOME/.etc/fxwm/windows.conf") >>/var/log/fxwm.log 2>&1
##'';
#
# # Substitute the output path in the wrapper script
##postInstall = ''
##  substituteInPlace $out/bin/fxwm-wrapper --replace '@out@' "$out"
##'';

  meta = with lib; {
    homepage = "https://github.com/cliquesoft/fxWM";
    description = " ";
    longDescription = '' '';
    license = licenses.mit;
    maintainers = with maintainers; [ meee ];
    platforms = platforms.all;
    mainProgram = "fxwm";
  };

}
