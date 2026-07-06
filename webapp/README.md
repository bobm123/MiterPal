# MiterPal — web app version

A single-file vanilla-JavaScript port of MiterPal, built to compare against
the Flutter version in the repo root. Same math (ported from
`lib/models/compound_miter.dart`), same features: three joint modes, live
bevel/miter results, polygon + lean diagram, save/recall (localStorage),
advanced D/M′ readout, 0.5°-vs-exact precision, and system/light/dark theme.

## Running it

No build step, no dependencies. Either:

- **Open `index.html` directly** in any modern browser (double-click it), or
- Serve the folder and open it from a phone on the same network:

  ```
  cd webapp
  python -m http.server 8000
  ```

  then browse to `http://<your-pc-ip>:8000` on the phone.

For real distribution, enable **GitHub Pages** on this repo (Settings →
Pages → deploy from branch, folder `/webapp` via an action or move/copy to
`/docs`) and any phone or tablet can use it at a plain URL — no app store,
no install. From the browser menu, "Add to Home Screen" gives it an app
icon.

## Comparison notes (vs. Flutter)

- **Distribution:** a URL (or one HTML file) vs. app stores / desktop builds.
- **Size:** ~1 file, no runtime; Flutter ships an engine (~10s of MB).
- **Offline:** works after first load; a service worker (PWA) would make that
  guaranteed and enable install banners — natural next step if this version
  wins.
- **Persistence:** localStorage here vs. shared_preferences in Flutter; both
  survive restarts, neither syncs between devices.
- **Native feel:** Flutter has richer widgets/animations out of the box; the
  web version is lighter but hand-rolled.
