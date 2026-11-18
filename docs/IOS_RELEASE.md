# iOS release

Bundle ID `in.advocatemate.app` · display name "AdvocateMate" · deployment target iOS 15.0.

## Configured (in repository)
* App icons (all sizes in `AppIcon.appiconset`) and navy launch screen with brand mark.
* `Info.plist`: URL scheme `advocatemate`, `UIBackgroundModes: remote-notification`, ATS default with
  `NSAllowsLocalNetworking` (simulator → local backend only), `ITSAppUsesNonExemptEncryption=false`.
* `Runner/Runner.entitlements` with `aps-environment` (development) linked via `CODE_SIGN_ENTITLEMENTS`.
* Tokens stored in Keychain with `first_unlock_this_device`.

## Requires macOS + Xcode (not available on the Windows development machine)
**No iOS build, simulator run or device test has been performed.** Steps:
1. Install Xcode (current), CocoaPods; `cd mobile && flutter pub get && cd ios && pod install`.
2. Open `ios/Runner.xcworkspace`, select the team, enable **Push Notifications** and **Background Modes →
   Remote notifications** capabilities (the entitlement file already exists).
3. Simulator: `flutter run -d "iPhone 16" --dart-define=API_BASE_URL=http://localhost:8000`.
4. Device: same with the machine's LAN URL over HTTPS (or a staging URL).
5. Firebase: add iOS app in Firebase, upload the APNs auth key (.p8) to Firebase Cloud Messaging, run
   `flutterfire configure` to add `GoogleService-Info.plist` (git-ignored); build with `--dart-define=FIREBASE_ENABLED=true`.
6. Release: set `aps-environment` to `production` for distribution;
   `flutter build ipa --release --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://api.<domain> --dart-define=FIREBASE_ENABLED=true`
   → upload with Transporter/Xcode → TestFlight → App Store review.
7. CI (`ios-build` job on `macos-latest`) runs `flutter build ios --no-codesign` as a compile check.

## App Store checklist
Apple Developer Program membership, privacy nutrition labels, privacy policy, review notes explaining OTP login
(provide a demo account on a staging backend), and clarity that the app is independent from the High Court
unless permission is obtained. **Submission requires owner approval.**
