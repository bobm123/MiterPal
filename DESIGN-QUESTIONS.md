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
- **Hub-and-strut refinements**: lengths, end-cut angles, and hub classes
  (count, valence, strut composition) are implemented. Still open: azimuth
  angles between adjacent struts around a hub (for fabricating hub plates),
  and a hub-diameter allowance that shortens strut cut lengths automatically.
- **Paper cutting refinements**: the connected-net SVG output (cuts + fold
  scores, collision-free unfolding) is implemented. Still open: glue tabs
  along cut edges, labeling matching cut-edge pairs so assembly is easier,
  and a page-size option (tile the net across A4/Letter sheets).

## Enhancement backlog (noted 2026-07, not yet started)

1. **Glue tabs on geodesic paper nets.** Add trapezoid tabs "where possible":
   each cut edge exists as a pair of lips, so put the tab on exactly one lip
   of each pair (and none on the other). Constraints to work through: tab
   depth vs. slit width — the V-slits between patches get narrow near
   connectors, so tabs may need to shrink or be skipped where the opposing
   lip is too close (the overlap tester can arbitrate); tabs must fold under
   the *mating* triangle, so alternate lips around a piece boundary for
   even gluing. Tab outlines join the *cuts* layer; the tab's fold line
   joins *scores*.

2. **3D part output for the box/frame modes.** Beyond cut lists: emit each
   part (stave, frame side) as a solid model with the bevels/miters applied.
   Two candidate formats: **OpenSCAD code** (easy — it's just text; a module
   per part with `N`, `S`, board width/thickness as parameters, plus an
   assembled-view preview; users can tweak and re-render) and **.step**
   (harder — no practical in-browser STEP writer; would likely mean a
   server-side or CLI companion, or settling for STL/3MF which are easy to
   write from triangles). Suggested order: OpenSCAD first, then evaluate
   whether STEP demand justifies the tooling. New inputs needed: board
   thickness and width/height, since the calculator is currently
   angles-only.

3. **Paper mode for the box/frame joint types.** Zero-thickness version of
   the picture frame / mitered box / butt-joint box: tilt and bevel angles
   drop out, leaving a connected fold-up outline — the N-gon base (or frame)
   with its sides/walls unfolded flat around it, fold scores at the base
   edges, cuts elsewhere, sized from real dimensions (needs the same
   width/height input as item 2). Reuses the geodesic SVG plumbing (layers,
   mm sizing, download) and the glue tabs from item 1. A picture frame at
   paper scale is essentially a mat template, which may be independently
   useful.

4. **Picture Frame dimensions.** Add length, height, and material (stock)
   width inputs, with a toggle for whether the given dimensions are the
   *inside* (rabbet/opening) or *outside* of the frame. For N=4 this turns
   the square into proper rectangles; for other N, treat the two dimensions
   as major/minor axes of the polygon and scale side lengths accordingly.
   Notes for implementation: a rectangle keeps 45° corners, but a stretched
   (non-regular) polygon no longer has equal corner angles — each corner's
   miter is half its own interior angle, and opposite sides come in pairs,
   so the cut list becomes per-side lengths *plus* per-corner miters.
   Output should give long-point/short-point lengths derived from the
   stock width and the inside/outside reference. Same width/height inputs
   feed backlog items 2 (3D parts) and 3 (box paper mode).

5. **Dodecahedron base solid for Geodesic Sphere mode.** Treat it like the
   cube, since its faces aren't triangles: pre-triangulate each pentagon
   through its sphere-projected center (5 triangles per face — a pentakis
   dodecahedron, 60 triangles) and count that as subdivision 1, with
   subdivision 0 special-cased as the true flat dodecahedron — 12 pentagon
   panels, one edge class, 116.57° dihedral so a 31.72° edge bevel, and a
   classic dodecahedron net in paper mode (flat-cube-cross equivalent).
   Also: GEO_MODULE_COUNT = 12, and the paper module becomes a pentagon
   patch. Max subdivision may want to stay at 2 (60 × 4² = 960 faces at
   subdiv 3 is fine, but the cut-list class count gets long).

## Non-functional
- App name/branding, icon, color scheme?
- Accessibility (large type, VoiceOver)?
- Distribution: App Store, TestFlight only, sideload for now?
