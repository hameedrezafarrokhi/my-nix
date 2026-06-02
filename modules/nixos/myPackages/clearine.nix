{ lib
, stdenv
, python3
, wrapGAppsHook3
, glib
, gobject-introspection
, script ? ''
from pulsectl import Pulse, PulseLoopStop
import sys

with Pulse() as pulse:
  def callback(ev):
    if ev.index == sink_index: raise PulseLoopStop
  def current_status(sink):
    return round(sink.volume.value_flat * 100), sink.mute == 1
  try:
    sinks = {s.index:s for s in pulse.sink_list()}
    if len(sys.argv) > 1:
      # Sink index from command line argument if provided
      sink_index = int(sys.argv[1])
      if not sink_index in sinks:
        raise KeyError(f"Sink index {sink_index} not found in list of sinks.")
    else:
      # Automatic determination of default sink otherwise
      default_sink_name = pulse.server_info().default_sink_name
      try:
        sink_index = next(index for index, sink in sinks.items()
                          if sink.name == default_sink_name)
      except StopIteration: raise StopIteration("No default sink was found.")

    pulse.event_mask_set('sink')
    pulse.event_callback_set(callback)
    last_value, last_mute = current_status(sinks[sink_index])

    while True:
      pulse.event_listen()
      sinks = {s.index:s for s in pulse.sink_list()}
      value, mute = current_status(sinks[sink_index])
      if value != last_value or mute != last_mute:
        print(str(value) + ('!' if mute else ' '))
        last_value, last_mute = value, mute
      sys.stdout.flush()

  except Exception as e:
    print(f"ERROR: {e}", file=sys.stderr)

  ''
, scriptName ? "xobvol"
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pygobject3
    configparser
    pulsectl
  ]);
in

stdenv.mkDerivation rec {
  pname = "xobvol";
  version = "1.0";

  src = stdenv.mkDerivation {
    name = "xobvol-script";
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
    description = "volume script for xob";
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
