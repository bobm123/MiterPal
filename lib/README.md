# MiterPal Flutter app (future native port)

The [web app](../webapp/README.md) is the primary MiterPal implementation.
This directory holds the Flutter/Dart port — the plan of record for eventual
native releases (iOS App Store first, Android later), parked while the web
feature set settles.

**Feature status:** the four box/frame joint modes (Picture Frame, Mitered
Box, Butt Joint Box, Fixed Bevel Bit) with save/recall, live diagram,
settings, and dark mode. The Geodesic Sphere mode exists only in the web app
and has not been ported.

## Layout

```
lib/
  main.dart                 app entry + theme
  models/
    compound_miter.dart     calculation core (ported from scripts/compound_miter.py)
    saved_project.dart      saved-calculation model
  state/
    calculator_controller.dart   ChangeNotifier holding inputs + settings + saved list
  services/
    project_store.dart      saved-project persistence (shared_preferences)
    settings_store.dart     theme-mode persistence
  util/
    formatting.dart         angle rounding (0.5°) + display
  widgets/                  inputs, result cards, live diagram, cut checklist
  screens/                  calculator, saved-projects, settings screens
test/                       unit tests (verified against the reference values)
windows/                    generated Windows desktop runner
```

## Running the Windows desktop simulation

One-time setup (full details in [`docs/SETUP-WINDOWS.md`](../docs/SETUP-WINDOWS.md)):

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
   (stable channel) and put `flutter` on your PATH.
2. Install [Visual Studio 2022 Community](https://visualstudio.microsoft.com/)
   with the **Desktop development with C++** workload. (Stay on VS **2022**;
   VS 2026 currently breaks Flutter's Windows build.)
3. `flutter doctor` should show check marks for Flutter and Visual Studio.

Then, from the repo root:

```
flutter pub get        # fetch dependencies
flutter run -d windows # build + launch
flutter test           # run the unit tests
```

Debug builds open inside a phone-frame simulator
([`device_preview`](https://pub.dev/packages/device_preview)): pick an iPhone
or Pixel in the side panel, rotate it, toggle dark mode, or switch the
preview off for a plain desktop window. Release builds run the app directly.

Add other platform targets later with e.g.
`flutter create --platforms=android,ios .`

> **Project location:** the project must live on an **NTFS** drive (e.g.
> `C:\Projects\MiterPal`), not an exFAT drive. Flutter creates a symbolic
> link per plugin during the build, and exFAT doesn't support symlinks —
> builds fail there with `ERROR_INVALID_FUNCTION`. The Flutter SDK itself
> can live anywhere.

## Why Flutter — and why web-first

The framework choice (Flutter vs. Kotlin Multiplatform) is worked through in
[`docs/flutter-vs-kmp-trade-study.md`](../docs/flutter-vs-kmp-trade-study.md).
How the two implementations compare in practice:

- **Distribution:** the web app is a URL and "Add to Home Screen"; Flutter
  means app stores (and a Mac with Xcode for the iOS build) or desktop builds.
- **Size:** the web app is a few small files with no runtime; Flutter ships
  an engine (tens of MB).
- **Offline:** the web app's service worker pre-caches the shell — both work
  offline once installed.
- **Persistence:** `localStorage` vs. `shared_preferences`; both survive
  restarts, neither syncs between devices.
- **Native feel:** Flutter has richer widgets and animations out of the box;
  the web version is lighter but hand-rolled.

That balance is why the web app ships first: instant distribution and
iteration while features are still moving, with this port ready when a
native app-store release is worth the packaging overhead.
