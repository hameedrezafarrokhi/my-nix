# xwww — gl-effects branch

This branch adds a real GLX/OpenGL 3.3-core renderer for the effects
that per-pixel CPU math couldn't make convincing: `cube`, `axis-spin`,
`full-swing-forward/backward`, `half-swing-forward/backward`,
`page-turn-left/right/up/down`, `roll-away-*`, `carpet-*`, `shatter`,
`paper-plane`, `burn`, `melt`, `ripple`. Every other effect (the ~60
others) is unchanged from `main` — this branch is purely additive.

**`main` is untouched.** If this doesn't work out, `git checkout main`
gets you back to the pure-C, zero-GL-dependency version with nothing
lost. Nothing on `main` depends on anything added here.

## What actually changed

- `src/mat4.h` — small self-contained 4x4 matrix/vector math (no GLM
  dependency), fully unit-testable in isolation (no GL/X11 needed) —
  verified by hand: identity/translate composition, a 90° rotation
  landing where it should, and a perspective projection putting a
  point on the view axis at NDC (0,0).
- `src/glrender.h/.c` — the GLX plumbing: creates a hidden (never
  mapped) 1x1 X window purely so GLX has a drawable to attach a context
  to, an FBO for the actual render target, a hand-rolled GL 3.x function
  loader (via `glXGetProcAddressARB` — no GLEW/GLAD/epoxy dependency),
  shader compile/link helpers, and the shared "draw a lit, textured
  mesh" and "draw a fullscreen fragment-shader quad" primitives every
  effect uses. **Nothing here is ever displayed directly** — every
  frame is read back into a plain `buf_t` and handed to the exact same
  `xroot_push_frame()` pipeline the CPU effects already use, so all the
  X11/multi-monitor/RENDER_SCALE/threading machinery from `main` is
  unchanged and still applies.
- `src/gl_effects.c/h` — the actual effects: mesh-based ones build real
  3D geometry in C each frame (rotating cube faces, a hinged door that
  actually rotates instead of just foreshortening, a strip that bends
  into a real cylindrical curl) and let the GPU rasterize/light/depth-
  composite it; `burn`/`melt`/`ripple` are fullscreen GLSL fragment
  shaders using a small shared fbm-noise function, since noise-driven
  2D distortion is what fragment shaders are actually good at.
- `Makefile` — `HAVE_GL` auto-detects (pkg-config, falling back to a
  raw compile probe) and adds `glrender.c`/`gl_effects.c` to the build
  either way: without `HAVE_GL`, `glrender.c` compiles to a small stub
  that never touches any GL header, so there's no GL dependency at all
  in that configuration, not even at parse time. `make HAVE_GL=0`
  forces it off.
- `default.nix` — see below.

## Fallback behavior

If GL context creation fails for any reason (no GPU, no driver, remote
X11 without GLX, built with `HAVE_GL=0`, whatever), every one of these
effects **automatically falls back to its original CPU implementation**
from `main` — same names, same config keys, same CLI flags. You'll see
a one-line stderr notice (`xwww(gl): GL rendering unavailable...`) and
otherwise nothing changes. This isn't a "hope it works" fallback: the
check happens before the first frame of the transition, so it's either
fully GL for the whole transition or fully CPU, never a mix.

## Build

```sh
make                    # HAVE_GL auto-detected
make HAVE_GL=0           # force the CPU-only build (matches `main`)
```

Extra dependency beyond `main`'s: `libgl1-mesa-dev` (Debian/Ubuntu),
`mesa` (Arch), or `mesa-libGL-devel` (Fedora) — i.e. whatever gives you
`<GL/glx.h>` and `libGL.so`. Everything else is identical to `main`.

## Known, disclosed limitations

Being upfront about where this is a stylization rather than a
simulation, same spirit as `main`'s honesty about its CPU
approximations:

- **`cube`** is a real 6-face textured, lit, depth-tested cube (3 faces
  "from", the opposite 3 "to") — genuinely 3D now, not a 2-face flip.
- **`page-turn-*`/`roll-away-*`/`carpet-*`** now bend into an actual
  cylindrical curl (real geometry, real per-vertex normals, real
  lighting) instead of shading a flat cut. `page-turn` uses a larger,
  gentler radius (a page); `roll-away`/`carpet` use a small, tight one
  (a rolled shade/carpet).
- **`half-swing`**'s non-hinged side does a hard cut at t=0.5 rather
  than a true two-texture crossfade blend (that needs a dedicated
  2-sampler blend shader on that quad; the shared mesh shader takes one
  texture at a time). Everything else about the hinge motion itself is
  real 3D rotation around the configured pivot.
- **`shatter`** pieces now have real per-piece 3D translation *and*
  rotation (pitch+yaw as they tumble) with correct lighting/occlusion —
  the CPU version could only translate.
- **`paper-plane`** is a small, deliberately simple folded-paper-*like*
  mesh (six triangles) on a swooping 3D flight path with real banking
  rotation — not a literal paper-fold simulation, which is well outside
  what's reasonable here.
- There can be a faint scale "pop" between the very last GL-rendered
  frame and the guaranteed-correct final frame `main`'s pipeline always
  pushes afterward (mesh effects deliberately keep geometry a little
  inside the view frustum rather than exactly edge-matching it). Should
  be imperceptible at normal frame rates; mentioned for honesty.
- `burn`/`melt`/`ripple` stay 2D fragment-shader effects by design (a
  screen-space fire/goo/water distortion doesn't need real 3D geometry
  to look good — it needs good noise, which GLSL is well suited for).

## Tuning

Same CLI flags/config keys as `main` for all of these (`--cube-zoom`,
`--curl-pct`, `--pivot-pct`, `--burn-jaggedness`, `--ripple-amp`, etc.)
— nothing new to learn, the GL versions read the exact same `tparams_t`
values the CPU versions do.

## default.nix

Kept deliberately conservative: it links against nixpkgs' `libGL` and
does no runpath/driver patching beyond that. I looked at using
`addOpenGLRunpath` (nixpkgs' usual fix for "the binary can't find the
real driver at runtime") but couldn't verify its current signature
against a real nixpkgs checkout from here, and I'd rather hand you
something that reliably builds than something clever built on a guess.

If the built binary can't find your GPU driver at runtime: on NixOS
that's almost always `hardware.opengl.enable`/`hardware.graphics.enable`
not being set at the system level (unrelated to this file — that's what
makes a real driver exist to find at all). Off NixOS, or if you need to
force a specific driver, the standard community tool for exactly this
is [nixGL](https://github.com/guibou/nixGL) — wrap the binary with it
(`nixGLMesa xwww ...` / `nixGLNvidia xwww ...`) rather than anything
here. Either way, xwww degrades to the CPU transitions automatically
when GL isn't usable (see "Fallback behavior" above), so a driver
that isn't found is a "you get CPU rendering" situation, not a crash.

```sh
nix-build                         # GL-enabled build
nix-build --arg glEnabled false   # CPU-only build, no libGL dependency at all
```

## Merging back to main

If this holds up, the intent is to merge `gl-effects` into `main`
outright (it's additive and always falls back safely, so there's no
real reason not to) rather than keep them as permanently separate
lines. Until then, treat `main` as the trusted baseline and this branch
as the one still finding its feet.
