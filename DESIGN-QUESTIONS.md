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

2. **3D part output for the box/frame modes.** ✅ *OpenSCAD output shipped
   (2026-07): Picture Frame, Mitered Box, and Geodesic Sphere emit a
   parametric `.scad` file (assembled model + one isolated part) with wall
   thickness as a percentage of W / A / R. Butt Joint Box and Fixed Bevel
   Bit are intentionally excluded — their geometry is covered by the other
   modes.* Still open: **.step** (harder — no practical in-browser STEP
   writer; would likely mean a server-side or CLI companion, or settling
   for STL/3MF which are easy to write from triangles) — evaluate whether
   STEP demand justifies the tooling.

3. **Paper mode for the box/frame joint types.** Zero-thickness version of
   the picture frame / mitered box / butt-joint box: tilt and bevel angles
   drop out, leaving a connected fold-up outline — the N-gon base (or frame)
   with its sides/walls unfolded flat around it, fold scores at the base
   edges, cuts elsewhere, sized from real dimensions (needs the same
   width/height input as item 2). Reuses the geodesic SVG plumbing (layers,
   mm sizing, download) and the glue tabs from item 1. A picture frame at
   paper scale is essentially a mat template, which may be independently
   useful.

4. **Rectangular / non-regular frames and boxes (dimensions).** *(Confirmed
   near-term — 2026-07.)* Add outside **width × height** inputs (A and B)
   plus material (stock) width, with a toggle for whether the given
   dimensions are the *inside* (rabbet/opening) or *outside* of the frame.
   For N=4 this turns the square into proper **rectangles**; for other N,
   treat the two dimensions as major/minor axes of the polygon and scale
   side lengths accordingly. The results should **show the A- and B-side
   lengths** (they come in opposite pairs), not one length for a regular
   polygon.
   Notes for implementation: a rectangle keeps 45° corners, but a stretched
   (non-regular) polygon no longer has equal corner angles — each corner's
   miter is half its own interior angle, and opposite sides come in pairs,
   so the cut list becomes per-side lengths *plus* per-corner miters.
   Output should give long-point/short-point lengths derived from the
   stock width and the inside/outside reference. The same width/height
   inputs feed the OpenSCAD (item 2) and box paper (item 3) outputs, which
   are already shipped for regular shapes and would extend to these.

5. **Dodecahedron base solid for Geodesic Sphere mode.** ✅ *Shipped
   (2026-07), as designed: kis pre-triangulation like the cube (pentakis
   dodecahedron = subdivision 1), subdivision 0 special-cased as the true
   flat dodecahedron (12 pentagon panels, one edge class, 116.57° dihedral
   / 31.72° bevel), classic two-rosette net in paper mode built by rigidly
   unfolding the actual solid, pentagon paper module (cut 12), OpenSCAD
   output included. Max subdivision capped at 2 (240 triangles; the cut
   list stays readable).*

6. **Geodesic hub-and-strut fabrication.** *(Confirmed — 2026-07.)* The
   strut cut list (lengths, end-cut angles, hub classes) is implemented;
   the struts view still needs work to make the *hubs* buildable:
   - **Hub size as a percentage of strut length.** One input that sets the
     hub radius (centre to socket mouth), the same pattern as the wall/panel
     thickness percentage already used in the OpenSCAD outputs.
   - **Automatic strut shortening.** Subtract the hub allowance from each
     strut so the reported cut lengths already account for the hub sitting
     at each end (the "hub-diameter allowance" noted under *Geodesic sphere
     mode — future work* above).
   - **3D-printable hub shapes (OpenSCAD output).** Emit a solid per hub
     class: a central body with one socket per incident strut, each bore
     aimed along that strut's direction — this needs the azimuth angles
     between adjacent struts around the hub plus the elevation from the
     hub's radial axis (the azimuth work also noted above). Sockets should
     be **optional** and sized for a dowel/rod of a given diameter and
     depth, so the struts become plain dowels cut to the adjusted lengths
     and glued into the printed hubs. Show the per-hub-class quantity, and
     expose hub radius, socket diameter, and socket depth as variables at
     the top of the `.scad`, matching the existing panel/box SCAD files.

## Non-functional
- App name/branding, icon, color scheme?
- Accessibility (large type, VoiceOver)?
- Distribution: App Store, TestFlight only, sideload for now?
