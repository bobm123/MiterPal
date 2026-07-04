# Windows dev setup — `flutter run -d windows`

Goal: build and run MiterPal as a Windows desktop app for fast iteration, before
touching iOS/Android. Large toolchains (Flutter SDK, Visual Studio) live on **D:**
to save C: space — but see the project-location caveat below.

## ⚠️ Project must live on an NTFS drive (not exFAT D:)

The D: ("Backup Plus") drive is **exFAT**, which does not support symbolic links.
Flutter creates one symlink per plugin during a build, so building from D: fails
with `ERROR_INVALID_FUNCTION` as soon as any plugin (e.g. `shared_preferences`)
is used. The project therefore lives on **`C:\Projects\MiterPal`** (NTFS).

The Flutter SDK and Visual Studio can stay on D: — only the *project* needs NTFS.
Bonus: NTFS records file ownership, so the git "dubious ownership" warning that
hit the D: copy doesn't occur on C:.

To relocate the project (run in PowerShell), copying everything including git
history but skipping regenerated folders:

```
robocopy D:\Projects\ClaudeSessions\MiterPal C:\Projects\MiterPal /E /XD build .dart_tool ephemeral
cd C:\Projects\MiterPal
flutter create --platforms=windows .
flutter run -d windows
```

Once the C: copy builds and runs, the old `D:\Projects\ClaudeSessions\MiterPal`
folder can be deleted.

## Status

| Component | State | Notes |
|---|---|---|
| Visual Studio 2022 | ✅ Done | Community 17.14.13, installed on `D:\Microsoft Visual Studio\2022\Community`, with the **Desktop development with C++** workload (MSVC v143, C++ CMake tools, Windows 11 SDK). Nothing to do. |
| Flutter SDK | ✅ Verified | v3.44.2 stable at `D:\develop\flutter`, on PATH. `flutter doctor`: Flutter ✓, Visual Studio ✓, Windows device ✓. (Android + web ✗ — expected, not needed for desktop-first.) |
| Git | ✅ Already installed | Git is present (used for the repo). Only reinstall if `git --version` fails. |

## Visual Studio — leave it as-is

- It already has exactly what Flutter needs. **Do not modify it.**
- **Do NOT install "Visual Studio 2026"** (the banner in the VS Installer). VS 2026
  currently breaks Flutter's Windows build — Flutter auto-selects it and the build
  fails. Stay on **2022**.
- The 17.14.35 patch update is **optional** and not required for Flutter. If you
  apply it, it lands on the D: install (small temporary cache on C: only).

## Gotcha: git "dubious ownership" on the D: drive

The D: drive doesn't record file ownership, so git refuses to operate inside
repos there until each is whitelisted. The Flutter **SDK** is itself a git repo
and lives on D:, so it needs the exception:

```
git config --global --add safe.directory D:/develop/flutter
```

(The MiterPal project no longer needs this once it's on C: NTFS, which records
ownership normally.)

## 1. Install the Flutter SDK (on D:)

1. Download the Flutter SDK zip for Windows from
   <https://docs.flutter.dev/install/manual> (button under "Download the Flutter
   SDK bundle" — latest stable). All versions: <https://docs.flutter.dev/install/archive>.
   - Note: the old `/get-started/install/windows/desktop` URL is retired (404).
2. Extract it to **`D:\flutter`** (so `D:\flutter\bin` exists). Via PowerShell:
   `Expand-Archive -Path $env:USERPROFILE\Downloads\flutter_windows_<version>-stable.zip -Destination D:\`
   (the zip's top-level folder is `flutter`, so this yields `D:\flutter`).
   - Do NOT put it under `C:\Program Files` or any path needing admin rights.
   - If `flutter.bat` is missing from `bin` after extracting, antivirus may have
     quarantined it — whitelist `D:\flutter` and re-extract.
3. Add the SDK's `bin` to your PATH. **Actual install path: `D:\develop\flutter`**,
   so add **`D:\develop\flutter\bin`**:
   - Start menu → "Edit environment variables for your account" → `Path` → New →
     `D:\develop\flutter\bin` → OK.

### Keep Flutter's package cache off C:

Flutter's pub cache defaults to your C: user profile and grows over time. Redirect
it to D::

- In the same env-variables dialog, add a **new user variable**:
  - Name: `PUB_CACHE`
  - Value: `D:\pub-cache`

## 2. Verify Git (likely already fine)

Open a fresh terminal and run `git --version`. If it prints a version, you're done.
If not, install Git for Windows from <https://git-scm.com> and point its
"Select Destination Location" screen at **`D:\Git`**.

## 3. Verify everything

Open a **new** terminal (so the PATH change takes effect) and run:

```
flutter doctor
```

What to expect:

- **Visual Studio — develop Windows apps** → should be a ✓ (this is the line that
  matters; we already confirmed the C++ workload is present).
- **Flutter** → ✓ after it finishes its first-run download into `D:\flutter\bin\cache`.
- Android/Xcode lines will show ✗ for now — that's fine; we're desktop-first.

If `flutter devices` doesn't list **Windows**, run once:

```
flutter config --enable-windows-desktop
```

Optional: turn on **Developer Mode** (Settings → Privacy & security → For developers)
— Flutter uses symlinks and may prompt for this.

## 4. First run

From the project's Flutter app folder (once we scaffold it):

```
flutter run -d windows
```

This opens a live desktop window with hot-reload.

## Later: Android (when we add it)

The Android SDK and Gradle cache also default to C:. When we get there, we'll set:

- Android SDK location → `D:\Android\Sdk` (choose during Android Studio setup)
- `GRADLE_USER_HOME` → `D:\gradle`

iOS builds will still require a Mac with Xcode at the end — desktop-first just
defers that until the app is basically done.
