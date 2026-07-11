# MiterPal web app

The primary implementation of MiterPal: a single-file vanilla-JavaScript app,
installable as a PWA. `index.html` holds everything — markup, styles, the
calculation core, and the UI logic. The other files make it installable:
`manifest.json` (name, icons, standalone display), `sw.js` (service worker
that pre-caches the app for offline use), and `icons/`.

What it does and how to deploy it are covered in the
[root README](../README.md); this file is about how the app is built.

## How it's put together

Everything lives in the one `<script>` block of `index.html`, roughly in
order:

- **Calculation core** — the compound-miter formulas mirror
  [`scripts/compound_miter.py`](../scripts/compound_miter.py) and the
  derivation in [`docs/compound-miter-angles.md`](../docs/compound-miter-angles.md):
  mitered box, butt joint, picture frame, and the fixed-bevel-bit inverse.
- **Geodesic engine** — builds the base platonic solid (cube faces are
  pre-triangulated through sphere-projected centers; the un-subdivided cube
  is special-cased as the true flat cube), recursively subdivides with
  projection onto the circumsphere, then classifies edges by
  (length, dihedral) into cut-list classes, groups panels by shape, derives
  strut end-cut angles from chord central angles, and inventories hubs by
  the strut classes meeting at each vertex.
- **Paper nets** — rigid unfolding through a spanning tree of the
  face-adjacency graph: tree edges become fold (score) lines, all other
  edges are cut and open into slits that close when folded. Tidy patch-tree
  layouts (grouped by base face, hinged mid- or corner-edge) are tried
  first and checked with a triangle-overlap test; if they self-overlap, a
  greedy collision-tested growth attaches one face at a time and routes
  around collisions, so the result is non-overlapping by construction. The
  "one module" variant unfolds a single base-face patch to cut N times.
- **Exported SVGs** carry two named layers — `cuts` (solid red) and `scores`
  (dashed blue), Inkscape layer convention — and are sized in millimetres
  from the radius input.
- **State & UI** — a plain state object, one `render()` pass, canvas
  drawing for the diagrams, `localStorage` for settings and saved projects.

The math functions are exposed via `module.exports` at the bottom of the
script block, so they can be exercised in Node (read the file, extract the
script, `require` it) without a browser.

## Running it locally

No build step, no dependencies. Either:

- **Open `index.html` directly** in any modern browser (double-click it), or
- Serve the folder and open it from a phone on the same network:

  ```
  cd webapp
  python -m http.server 8000
  ```

  then browse to `http://<your-pc-ip>:8000` on the phone.

(The service worker only registers when served over http/https, not from a
`file:` URL — the app works either way.)

## Releasing an update

**Bump `CACHE_VERSION` in `sw.js` in the same commit as any change to the
app files.** The service worker is cache-first: installed copies serve the
cached app and only re-fetch when they see a byte-changed `sw.js` on the
server. With the bump, phones pick up the new version on the second launch
after the deploy; without it, they stay on the old version indefinitely.

Installed (home-screen) copies also get **durable storage** — on iOS, saved
projects in home-screen web apps are exempt from Safari's 7-day inactivity
eviction that applies to plain browser tabs.
