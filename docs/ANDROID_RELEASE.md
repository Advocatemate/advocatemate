# Android release

Application ID `in.advocatemate.app` · label "AdvocateMate" · min/target SDK from Flutter defaults ·
Kotlin namespace `in.advocatemate.advocatemate` (unchanged from template; does not affect the store ID).

## Configured
* Launcher icons (all densities) and navy splash with brand mark.
* Permissions: `INTERNET`, `POST_NOTIFICATIONS` (Android 13+ runtime prompt via FCM `requestPermission`).
* Network security: release = HTTPS only, system CAs; debug overlay allows HTTP to `10.0.2.2`/`localhost`.
* Backups/device transfer disabled for app data.
* Deep links: `advocatemate://…` intent filter.
* Notification channel `advocatemate_updates` created in `MainActivity`; FCM default channel set.
* Release build: R8 minify + resource shrinking; signing from `android/key.properties`.

## Prerequisites (not available on the development machine used so far)
1. Android Studio or command-line tools + SDK 35/36 + build-tools; accept SDK licences (`flutter doctor --android-licenses`).
2. JDK 17 (installed).

## Release signing
```
keytool -genkey -v -keystore %USERPROFILE%\keys\advocatemate-upload.jks -keyalg RSA -keysize 4096 -validity 10000 -alias upload
```
Create `mobile/android/key.properties` (git-ignored):
```
storeFile=C:/Users/<you>/keys/advocatemate-upload.jks
storePassword=...
keyAlias=upload
keyPassword=...
```
Use Play App Signing; keep the upload key and passwords in a password manager. Without `key.properties` the
release build is debug-signed and **must not** be uploaded.

## Firebase (push + Crashlytics)
1. Create Firebase project → add Android app `in.advocatemate.app`.
2. `dart pub global activate flutterfire_cli` → `flutterfire configure` (adds `google-services.json` and the
   Gradle plugin entries). Keep `google-services.json` out of git (already ignored) and supply it in CI as a secret.
3. Build with `--dart-define=FIREBASE_ENABLED=true`.
4. Backend: service-account JSON in the secret manager, `FCM_ENABLED=true`, `FCM_CREDENTIALS_FILE=/run/secrets/…`,
   install `requirements-push.txt`.

## Builds
```
cd mobile
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000
flutter build apk --release --dart-define=APP_ENV=staging --dart-define=API_BASE_URL=https://staging-api.<domain>
flutter build appbundle --release --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://api.<domain> --dart-define=FIREBASE_ENABLED=true
```
CI (`.github/workflows/mobile.yml`) builds a debug APK on every change as build verification.

## Play Store checklist
Privacy policy URL, Data safety form (phone number, app activity; no data sold), content rating, store listing in
English/Telugu, screenshots, a statement that the app is not affiliated with or endorsed by the High Court unless
permission is obtained, internal testing track before production. **Production rollout requires owner approval.**

## Status
Configuration complete; **no APK/AAB has been built yet** (no Android SDK on the build machine). First real
verification will be the CI `android-build` job or a local build after installing the SDK.
