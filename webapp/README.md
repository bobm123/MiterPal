# MiterPal — web app version (PWA)

A vanilla-JavaScript port of MiterPal, built to compare against the Flutter
version in the repo root. Same math (ported from
`lib/models/compound_miter.dart`), same features: four joint modes, live
bevel/miter results, polygon + lean diagram, save/recall (localStorage),
advanced D/M′ readout, 0.5°-vs-exact precision, and system/light/dark theme.

The app itself is one file (`index.html`); the extra files here make it an
installable Progressive Web App: `manifest.json` (name, icon, standalone
display), `sw.js` (service worker that caches the app for offline use), and
`icons/`.

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

## Deploying to iOS/Android via GitHub Pages

1. On GitHub: repo **Settings → Pages → Deploy from a branch**, branch
   `main`, folder `/ (root)`, Save.
2. After the first deploy (about a minute), the app is live at:
   `https://bobm123.github.io/MiterPal/webapp/`
3. On the phone, open that URL, then:
   - **iOS Safari:** Share → **Add to Home Screen**.
   - **Android Chrome:** menu → **Add to Home screen** (or the install prompt).

Installed this way it launches full-screen with its own icon, works offline
(the service worker pre-caches everything), and — important on iOS — gets
**durable storage**: saved projects in home-screen web apps are exempt from
Safari's 7-day inactivity eviction that applies to plain browser tabs.

**When you update the app:** bump `CACHE_VERSION` in `sw.js` in the same
commit. Installed copies check for a new service worker when opened online
and switch to the new version on the following launch.

## Comparison notes (vs. Flutter)

- **Distribution:** a URL vs. app stores / desktop builds; "Add to Home
  Screen" replaces installation.
- **Size:** a few small files, no runtime; Flutter ships an engine (~10s of MB).
- **Offline:** service worker pre-caches the app shell — works with no signal
  after the first visit.
- **Persistence:** localStorage here vs. shared_preferences in Flutter; both
  survive restarts, neither syncs between devices.
- **Native feel:** Flutter has richer widgets/animations out of the box; the
  web version is lighter but hand-rolled.
