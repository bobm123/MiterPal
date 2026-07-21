# MiterPal

It all started when I purchased a miter saw. I soon realized just how complicated the math was for computing the blade angles I'd need in the workshop. This involves pretty much all of Trigonometry (see references below). So I had my AI friend (Claude) "vibe code" a workshop companion for computing these angles. 

<p align="center">
  <img src="images/515mAsGIQ0L_AC_SL1000.png" width="300" alt="A compound miter saw">
</p>

The app grew from there. What if the box has butt joints instead of actual miters? What I wanted to make a 7-sided picture frame for my [Snallygaster](https://en.wikipedia.org/wiki/Snallygaster)? What about geodesic domes? Why not print some paper models or templates. Could it generate 3D models too?

The app calculates blade tilt and angle setting for the miter saw (the original use case) along with SVG files for making templates and can generate 3D models in the form of OpenSCAD code

**→ Use it now: <https://bobm123.github.io/MiterPal/webapp/>**

Works in any phone, tablet, or desktop browser. To make it a home-screen app
(recommended — full screen, works offline in the shop, and saved projects
persist reliably):

- **iOS Safari:** Share → **Add to Home Screen**
- **Android Chrome:** menu → **Add to Home screen** (or accept the install prompt)

<p align="center">
  <img src="images/MiteredBox.png" width="300" alt="MiterPal showing a 5-sided box with sides leaning 10 degrees: a 35.5 degree bevel and a 7 degree miter">
</p>

*A typical calculation: a 5-sided box with sides leaning 10° — set the saw to
a 35.5° bevel and a 7° miter.*

## What it does

Pick a project, set the inputs, and read the settings off the cards:

- **Picture Frame** — flat N-sided frame: the miter angle, plus per-stick
  outside/inside/rabbet lengths.
- **Box** — N-sided box with leaning sides. The saw-settings output has a
  **Joint** selector: *Mitered* (blade bevel + table miter, with dihedral D
  and miter complement M′ behind an advanced toggle), *Butt* (ends cut flush
  against the neighbor: the adjusted blade tilt), or *Bevel bit* (the cutter
  fixes the bevel, so MiterPal returns the side lean that fits it).
- **Geodesic Sphere** — pick a base solid (tetrahedron, cube, octahedron,
  dodecahedron, icosahedron), subdivisions, and a radius. Construction
  outputs: beveled **panels** (edge lengths + glue bevels), **hub-and-strut**
  (strut lengths, end-cut angles, hub inventory), **paper** — an SVG
  cut-and-fold net of the whole model or one repeating module, with separate
  *cuts* and *scores* layers for CNC paper cutters — or **OpenSCAD**, a
  parametric solid model.

The Box and Picture Frame projects also offer **paper model** (fold-up SVG
template) and **OpenSCAD** (parametric solid with wall thickness) outputs.

Every mode has a live diagram, project save/recall, 0.5°-or-exact precision,
dark mode, and a pre-cut checklist. Everything runs locally in the browser —
no accounts, no network needed after the first load.

## Implementation details

The motivation behind all this was really finding a non-trivial example to serve as an "exercise for the student (me)" in using the the current generation of AI tools.
  
That started with some research into the math behind these calcualtions (derivations, sanity checks, worked examples), see [`docs/compound-miter-angles.md`](docs/compound-miter-angles.md), with a reference implementation in [`scripts/compound_miter.py`](scripts/compound_miter.py).

The code itself was originally in Dart using Flutter libraries as it seemed like a good subject for a mobile app and the AI recommended this approach. As complicated as the math is for humans, it really doesn't require much of a mobile device. It's simply a user interface with some calculations and file outputs. There's no wireless (beyond initial load) nor use of camera, gyro, or other devices smart phones typically have. A Progressive Web App (PWA) that really only needs an off-line mode is a better fit. The benefit is a much simpler deployment story; a link from GitHub vs. dealing with the App store. So it was ported to Javascript early on and development continued from that.

## Screens

<table>
  <tr>
    <td align="center" width="33%"><img src="images/box-bevel.png" width="240" alt="Box mode with the Bevel-bit joint selected"><br><sub><b>Box</b> — Joint selector (bevel-bit shown)</sub></td>
    <td align="center" width="33%"><img src="images/box-paper.png" width="240" alt="Box mode fold-up paper template"><br><sub><b>Box</b> — fold-up paper model</sub></td>
    <td align="center" width="33%"><img src="images/box-scad.png" width="240" alt="Box mode parametric OpenSCAD output"><br><sub><b>Box</b> — parametric OpenSCAD</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="images/frame-saw.png" width="240" alt="Picture Frame mode showing miter angle and per-stick lengths"><br><sub><b>Picture Frame</b> — miter + cut lengths</sub></td>
    <td align="center"><img src="images/geo-panels.png" width="240" alt="Geodesic Sphere mode showing the panel cut list"><br><sub><b>Geodesic Sphere</b> — panel cut list</sub></td>
    <td align="center"><img src="images/geo-paper.png" width="240" alt="Geodesic Sphere cut-and-fold paper net"><br><sub><b>Geodesic Sphere</b> — cut-and-fold net</sub></td>
  </tr>
</table>

## From file to object

Two exports, each shown from the generated file to the finished object.

The paper (SVG) net goes straight to a craft plotter &mdash; cut the solid
lines, score the dashed ones, then fold up and glue:

<table>
  <tr>
    <td align="center" width="50%"><img src="images/svg-box5.png" width="300" alt="SVG cut-and-fold net for a 5-sided box at a 10 degree slope"><br><sub><b>SVG net</b> — 5-sided box, 10° slope (red cuts, blue scores, glue tabs)</sub></td>
    <td align="center" width="50%"><img src="images/box5-folded.png" width="300" alt="The same net cut out and folded into a paper box"><br><sub><b>…folded up</b> — cut, scored, and glued into the finished box</sub></td>
  </tr>
</table>

The OpenSCAD output is a parametric solid &mdash; render it, then slice it for
3D printing:

<table>
  <tr>
    <td align="center" width="50%"><img src="images/scad-tetra.png" width="300" alt="OpenSCAD render of a tetrahedron with one subdivision plus flattened panel templates"><br><sub><b>OpenSCAD output</b> — tetrahedron, 1 subdivision</sub></td>
    <td align="center" width="50%"><img src="images/TetrahedronWithOneDivision-slicer.png" width="300" alt="The tetrahedron model loaded on a 3D printer bed in the slicer"><br><sub><b>…on the print bed</b> — sliced and ready to print</sub></td>
  </tr>
</table>

## Deploy your own copy

The app is static files — the `webapp/` folder is the whole thing, no build
step, no dependencies.

- **GitHub Pages:** fork this repo, then *Settings → Pages → Deploy from a
  branch*, branch `main`, folder `/ (root)`. About a minute later your copy
  is live at `https://<your-username>.github.io/MiterPal/webapp/`.
- **Any static host or local network:** copy `webapp/` to any web server, or
  serve it straight from a clone (`cd webapp && python -m http.server 8000`)
  and open it from a phone on the same network.

When you change the app, bump `CACHE_VERSION` in `webapp/sw.js` in the same
commit — that's how installed (home-screen) copies know to fetch the update.
Implementation details are in [`webapp/README.md`](webapp/README.md).

## Repository layout

```
webapp/               the app — single-file index.html + PWA wrapper (webapp/README.md)
images/               README screenshots
docs/                 math derivation + diagrams, Windows setup, framework trade study
scripts/              canonical Python reference for the miter formulas
lib/ test/ windows/   Flutter port, planned future native app (lib/README.md)
DECISIONS.md          settled design choices
DESIGN-QUESTIONS.md   open questions and future work
```

## Roadmap

Current development happens in the web app. A Flutter port of the four
box/frame modes runs today as a Windows desktop simulation and is the plan of
record for future native iOS/Android releases — see
[`lib/README.md`](lib/README.md).
