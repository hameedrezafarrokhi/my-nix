{ lib
, stdenv
, python3
, wrapGAppsHook3
, glib
, gobject-introspection
#, script ? ''
#from watchdog.observers import Observer
#from watchdog.events import FileSystemEventHandler, FileModifiedEvent
#import sys
#import time
#
#brightness_file = '/sys/class/backlight/intel_backlight/brightness'
#max_brightness_file ='/sys/class/backlight/intel_backlight/max_brightness'
#with open(max_brightness_file, 'r') as f:
#    maxvalue = int(f.read())
#
#def notify(file_path):
#    with open(file_path, 'r') as f:
#        value = int(int(f.read())/maxvalue*100)
#        print(value)
#
#class Handler(FileSystemEventHandler):
#
#    def on_modified(self, event):
#        if isinstance(event, FileModifiedEvent):
#            notify(event.src_path)
#
#handler = Handler()
#observer = Observer()
#observer.schedule(handler, path=brightness_file)
#observer.start()
#try:
#    while True:
#        sys.stdout.flush()
#        time.sleep(1)
#except KeyboardInterrupt:
#    observer.stop()
#observer.join()
#
#  ''

, script ? ''
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import sys

brightness_file = '/sys/class/backlight/intel_backlight/brightness'
max_brightness_file = '/sys/class/backlight/intel_backlight/max_brightness'

with open(max_brightness_file, 'r') as f:
    maxvalue = int(f.read())

class Handler(FileSystemEventHandler):
    def on_modified(self, event):
        if event.src_path == brightness_file:
            with open(brightness_file, 'r') as f:
                value = int(int(f.read()) / maxvalue * 100)
                print(value)
                sys.stdout.flush()  # Flush immediately!

handler = Handler()
observer = Observer()
observer.schedule(handler, path=brightness_file)
observer.start()

try:
    observer.join()  # Wait indefinitely
except KeyboardInterrupt:
    observer.stop()
observer.join()

  ''

, scriptName ? "xobbright"

}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pygobject3
    configparser
    watchdog
  ]);
in

stdenv.mkDerivation rec {
  pname = "xobbright";
  version = "1.0";

  src = stdenv.mkDerivation {
    name = "xobbright-script";
    buildCommand = ''
      mkdir -p $out
      cat > $out/${scriptName}.py <<'EOF'
      ${script}
      EOF
    '';
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    pythonEnv
    glib
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install the Python script
    mkdir -p $out/lib/${pname}
    cp ${src}/${scriptName}.py $out/lib/${pname}/

    # Create executable wrapper
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python $out/bin/${pname} \
      --add-flags "$out/lib/${pname}/${scriptName}.py" \
      --set GDK_BACKEND x11 \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "brightness script for xob";
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
