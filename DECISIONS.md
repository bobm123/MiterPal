# MiterPal — decisions log

Settled during the kickoff on 2026-06-22. Open items are at the bottom.

## Tech stack
- **Flutter.** Single Dart codebase.
- **Develop desktop-first** on Windows (`flutter run -d windows`) — fast iterate
  with hot-reload, no simulator needed early.
- Target order: **iOS first**, then **Android** (mostly free from the same code).
- Note: shipping to the iOS App Store will require a Mac with Xcode at the end;
  desktop-first defers that until the app is basically done.

## Inputs
- **N (sides):** +/- stepper.
- **S (side angle):** numeric keypad field.
- **Ranges/limits:** minimal guardrails — N ≥ 3 only; S unrestricted.

## Outputs
- **Default view:** Bevel **B** + Miter **M** only (the two numbers you set on the saw).
- **Advanced toggle:** reveals dihedral **D** and miter complement **M'**.
- **Saw convention:** miter measured **from the fence (M)**, 0° = straight crosscut.
- **Precision:** round to the nearest **0.5°** by default; optional toggle to show
  full **4-decimal-place** values.

## v1 features
- **Save/recall projects** — save named calculations to revisit. Persisted to
  disk via `shared_preferences` (survives app restart).
- **Live diagram** — simple drawing of the box/joint that updates with N and S.
- **Cut checklist/reminders** — mark outside face, flip end-for-end, cut scrap first.
- (Shape presets deferred — not in v1.)

## Behavior
- **First launch:** square box, N=4, S=10° (a real compound result out of the gate).
- **Offline:** fully offline, no accounts, no network, nothing leaves the phone.

## Still open (decide later)
- Minimum iOS version (Flutter default is fine to start).
- App branding: name lock, icon, color scheme.
- Accessibility: large type, VoiceOver/TalkBack.
- Distribution: TestFlight vs. full App Store; Android via Play Store or sideload.
