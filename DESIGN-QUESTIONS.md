# MiterPal — design questions to settle

A starting set of questions for the implementation kickoff. Not exhaustive —
we'll refine these live.

## Tech stack
- Native iOS (Swift / SwiftUI) now, separate native Android later? Or a
  cross-platform toolkit (React Native, Flutter, Kotlin Multiplatform) so
  Android comes mostly for free?
- Minimum iOS version to support?

## Inputs & UX
- How does the user enter N and S? Steppers, sliders, numeric keypad, dials?
- Sensible ranges/limits (e.g. N ≥ 3; S clamp)? Default values on launch?
- Units: degrees only, or also support a "rise/run" or pitch entry for S?

## Outputs & display
- Which of D, B, M, M' to show by default, and which behind an "advanced" toggle?
- Decimal precision (whole degrees, 0.1°, 0.05°)? Round to what the saw can set?
- Show the lean direction (outward/inward) and a which-edge-up reminder?
- A simple diagram that updates with the inputs?

## Saw conventions
- Let the user pick whether their saw reads miter from the fence (M) or the
  blade (M')? Persist that preference?

## Features / scope for v1
- Preset shapes (square, hexagon, octagon)?
- Save/recall recent calculations or named projects?
- Imperial/metric anywhere relevant (e.g. board dimensions), or angles only?
- Offline-only (no accounts/network)? Almost certainly yes — confirm.

## Geodesic sphere mode — future work
- **Hub-and-strut construction**: strut lengths are already shown; still to
  do are the end-cut angles (axial angle at each strut end so the end faces
  aim at the sphere center) and hub geometry (how many struts meet, at what
  face angles).
- **Paper cutting output**: a zero-thickness construction option — unfold
  each panel type flat (bevels don't matter at paper thickness) and generate
  an SVG cut file, with tabs for gluing, that can be sent to a CNC paper
  cutter. Useful for scale models before committing lumber.

## Non-functional
- App name/branding, icon, color scheme?
- Accessibility (large type, VoiceOver)?
- Distribution: App Store, TestFlight only, sideload for now?
