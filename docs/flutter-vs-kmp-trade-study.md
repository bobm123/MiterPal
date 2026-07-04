# Trade study: Flutter/Dart vs. Kotlin Multiplatform for MiterPal

_Prepared 2026-07-02. Purpose: sanity-check the framework choice for MiterPal
before investing further._

## TL;DR

For **MiterPal specifically** — a small, UI-centric calculator built by a solo
newcomer on Windows, iOS-first then Android — **Flutter remains the better fit**,
and it's already building. Kotlin Multiplatform (KMP) is an excellent technology,
but its core advantage (share business logic, keep native UI per platform) gives
almost nothing here, because MiterPal's "business logic" is a single trig formula
and the app is ~95% UI. Choosing KMP would mean either writing the UI twice or
using Compose Multiplatform — which renders non-natively much like Flutter, giving
up the very thing that makes KMP distinctive.

## The scope this is judged against

MiterPal is not a generic "which is better" question — the answer depends on the
project. The relevant facts:

- **Tiny shared logic.** The entire calculation is a handful of trig lines
  (`compound_miter.dart`). There is almost no business logic to share.
- **UI-centric.** Steppers, a numeric field, result cards, a live custom-painted
  diagram, a checklist. The app essentially _is_ its UI.
- **Solo developer, new to this.** No existing Kotlin/Swift codebase or team.
- **Windows development machine**, iOS first for release, Android later.
- **Flutter is already working** — SDK verified, desktop build running on C:.

## The fundamental difference

The two frameworks share code at different layers:

- **Flutter** shares **everything** — UI _and_ logic — in Dart, drawn by its own
  rendering engine on every platform. One codebase, one UI, looks identical
  everywhere.
- **KMP** shares **only logic** — models, math, networking — in Kotlin, and keeps
  **native UI** per platform (Jetpack Compose on Android, SwiftUI on iOS). You get
  a genuinely native look/feel, at the cost of writing the UI twice.
- **KMP + Compose Multiplatform** is a middle path: share the UI too, using
  Compose. But Compose-on-iOS uses its own renderer (not UIKit/SwiftUI) — so it
  is architecturally the _same trade-off as Flutter_, and you lose KMP's native-UI
  advantage.

The choice is really: **where do you want shared ownership to live — the render
layer (Flutter) or the logic layer (KMP)?** MiterPal has barely any logic layer
to own, which is the crux.

## Side-by-side

| Dimension | Flutter / Dart | Kotlin Multiplatform |
|---|---|---|
| What's shared | UI + logic (one codebase) | Logic only; native UI per platform (or shared UI via Compose MP) |
| Code reuse (typical) | ~80–90% | ~60% logic-only; ~90%+ with Compose MP |
| Value of sharing **for MiterPal** | High — the whole UI is shared | Low — almost no logic to share; UI would be duplicated |
| iOS look & feel | Consistent, non-native (own engine) | **Truly native** with SwiftUI; non-native if using Compose MP |
| Learning curve (newcomer, no Kotlin) | Gentler; productive in hours; must learn Dart | Steeper; must know Kotlin, plus Swift/SwiftUI for native iOS UI |
| Windows-based dev | Full desktop target; build/run on Windows today | Android/desktop/web build on Windows; **iOS run configs unavailable on Windows** |
| Mac needed for iOS release | Yes (Xcode) | Yes (Xcode) — same constraint |
| Desktop target (for fast dev) | First-class Windows/macOS/Linux | Compose Multiplatform desktop (JVM) on Windows/macOS/Linux |
| Persistence/plugins | Huge plugin ecosystem (`shared_preferences`, etc.) | Growing; often use platform APIs via `expect/actual` |
| App binary size | Larger (bundles rendering engine) | Smaller for logic-only; Compose MP adds ~9 MB on iOS |
| iOS maturity | Very mature | Compose MP for iOS went **stable May 2025** (1.8.0); logic-sharing long stable |
| Tooling | Flutter/Dart in VS Code or Android Studio | Android Studio / IntelliJ + Xcode; KMP wizard/plugin improving |
| Momentum / adoption | Large, established | Fastest-growing cross-platform framework; used by Netflix, Cash App, Duolingo, Airbnb |

## What each is genuinely best at

**Flutter shines when** you want one team/codebase to own the whole app, UI
included; when the app is UI-heavy; when you value a gentle on-ramp and instant
hot-reload; and when a consistent (if non-native) look across platforms is fine.
That is MiterPal.

**KMP shines when** you already have (or want) native UIs and a Kotlin/Android
team; when there's substantial business logic worth sharing (sync engines, domain
models, offline data); when native iOS feel is a hard requirement; or when you're
adding cross-platform logic to an _existing_ native app incrementally. That is not
MiterPal.

## MiterPal-specific analysis

1. **The sharing benefit inverts.** KMP's pitch is "share the hard logic, keep
   native UI." MiterPal's logic is trivially small and its UI is the whole app —
   so KMP would have you _duplicate_ the expensive part (UI) to save nothing on
   the cheap part (one formula). Flutter shares exactly the part that matters here.

2. **Newcomer economics.** The oft-quoted "KMP needs ~40% of the learning
   investment" assumes you already know Kotlin. With no Kotlin background, that
   advantage disappears, and KMP actually asks _more_ (Kotlin **and** Swift/SwiftUI
   for native iOS UI) versus Flutter's single language (Dart).

3. **Windows workflow.** Both need a Mac eventually for iOS release. But day to
   day, Flutter's mature Windows desktop target already gives you a live app to
   iterate on — which you have running now.

4. **Sunk-cost is real but small.** You already have a working Flutter app,
   tested logic, and persistence. Switching to KMP means re-learning and rebuilding
   the UI for no functional gain on this app.

## Recommendation

**Stay with Flutter for MiterPal.** It matches the project's shape (UI-centric,
tiny logic), your situation (solo, new, Windows), and it's already running. The
May-2025 arrival of stable Compose Multiplatform for iOS makes KMP a legitimately
strong option in general — but adopting it here would trade a working, well-fitted
setup for added complexity and no payoff for _this_ app.

## When it would be worth revisiting KMP

- You start a **second, logic-heavy app** (real data model, sync, offline store)
  and want to share that logic with existing native apps.
- **Native iOS feel becomes a hard requirement** and you're willing to write
  SwiftUI.
- You **learn Kotlin** for other reasons (Android-native work) and want to
  standardize on it.

For a compound-miter calculator, none of these apply today.

## Sources

- [JetBrains: Compose Multiplatform 1.8.0 — iOS is Stable and Production-Ready (May 6, 2025)](https://blog.jetbrains.com/kotlin/2025/05/compose-multiplatform-1-8-0-released-compose-multiplatform-for-ios-is-stable-and-production-ready/)
- [Kotlin docs: Kotlin Multiplatform and Flutter](https://kotlinlang.org/docs/multiplatform/kotlin-multiplatform-flutter.html)
- [Kotlin Multiplatform FAQ (iOS/macOS require Apple hardware)](https://kotlinlang.org/docs/multiplatform/faq.html)
- [Shorebird: Flutter vs. Kotlin Multiplatform — 2026 Architecture Guide](https://shorebird.dev/blog/flutter-vs-kotlin-multiplatform)
- [Volpis: Kotlin Multiplatform vs. Flutter — What to choose in 2026](https://volpis.com/blog/kotlin-multiplatform-vs-flutter/)
- [JetBrains: What's Next for KMP and Compose Multiplatform — Aug 2025](https://blog.jetbrains.com/kotlin/2025/08/kmp-roadmap-aug-2025/)
