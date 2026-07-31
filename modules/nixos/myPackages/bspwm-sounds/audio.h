#ifndef AUDIO_H
#define AUDIO_H

#include "config.h"

/* Initializes the audio engine (device starts stopped -- see audio_tick). */
int audio_init(config_t *cfg);

/* For every configured sound, makes sure resolved_path points at something
 * miniaudio can decode natively, transcoding ogg/opus/etc to a cached wav
 * via ffmpeg exactly once (keyed off source mtime+size). Call after
 * config_load() and again after a config reload. */
void audio_resolve_sounds(config_t *cfg);

/* Attempts to play `path` at `volume` with the given `priority` and an
 * instance cap of `max_instances` (0 = use the global voice pool limit
 * only). May silently drop the request if the voice pool is full of
 * equal-or-higher priority sounds -- that's by design. */
void audio_play(const char *path, float volume, int priority, int max_instances);

/* Call periodically (driven by the main poll() loop's timeout) so the
 * engine can notice it's been idle for idle_shutdown_ms and fully
 * disconnect from the audio backend (PipeWire/Pulse/ALSA), dropping CPU
 * usage to genuine zero until the next sound is triggered. This is a real
 * ma_engine_uninit(), not just a stop/cork -- a merely-stopped stream can
 * still get woken up periodically by the server's graph scheduling. */
void audio_tick(void);

/* Blocking one-shot playback used by --test. */
void audio_play_and_wait(const char *path, float volume);

void audio_shutdown(void);

#endif
