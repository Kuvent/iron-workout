# Iron — Gym workout tracker

Offline Android app with push, pull, legs and full-body routines, exercise instructions, set/weight/rep logging, rest timer, session resume, history, and kg/lb settings. Android 8.0 or later. Data stays on the device; uninstalling removes it.

## Build without installing tools: GitHub Actions

1. Create a GitHub repository and upload the contents of this project, including `.github/workflows/android.yml`.
2. Open Actions, select Build Android APK, and click Run workflow. The workflow also runs on pushes to main or master.
3. Open the completed run and download the Iron-APK artifact.
4. Unzip the artifact and copy app-debug.apk to your Android phone. Open it to install. Allow installation from that file manager if Android asks.

This produces a debug-signed APK for personal use. Publishing to Google Play requires your own release signing key. The workflow has been provided but has not been executed in this environment.

## Android Studio

Install current Android Studio. In SDK Manager install Android SDK Platform 35 and Android SDK Build-Tools 35.0.0. Use JDK 17 or newer. This source uses Android Gradle Plugin 8.7.3 with Gradle 8.9.

The project does not include a Gradle wrapper binary. Install Gradle 8.9 and run `gradle wrapper --gradle-version 8.9` from the project directory, then open the project in Android Studio and sync. Select Build > Build App Bundle(s) / APK(s) > Build APK(s), or run `./gradlew :app:assembleDebug`.

Output: `app/build/outputs/apk/debug/app-debug.apk`.

## Linux command-line alternative

With Java 21, Python 3, curl and unzip installed, run `./build-apk.sh`. It downloads Android build tools, Platform 35 and Eclipse's Java compiler into `.toolchain`, then creates `dist/Iron-1.0.apk`. Requires network access to dl.google.com and repo.maven.apache.org. Keep the generated local signing key if you want future builds to update the installed app without losing data. The local key is intended for personal builds, not Play Store distribution.

## Verification status

JavaScript syntax checked. Android compilation and device testing have not run: network permission requests to download the missing build tools were interrupted. This archive is source code, not an APK.
