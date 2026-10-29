---
name: flutter-firebase-email-link-app-links
description: "Firebase Auth email link (passwordless) sign-in in a Flutter app that must open the Android app from the email through Android App Links: post-Dynamic-Links setup checklist, serving your own assetlinks.json from Firebase Hosting when the generated one comes back empty, on-device verification with `pm get-app-links`, and the traps that make the link open the browser instead of the app. Invoke when setting up or debugging email link sign-in, App Links verification, or an `assetlinks.json` on Firebase Hosting."
---

# Flutter + Firebase Email Link Sign-In with Android App Links

## How the flow works today

Firebase Dynamic Links was shut down in August 2025. The sign-in email now points at `https://<project>.firebaseapp.com/__/auth/links?link=...`, and the app opens only if Android has **verified** that domain for the app through Android App Links. If verification fails, the link opens in the browser and lands on the `url` from `ActionCodeSettings` (the fallback, usually the web app), so the user never gets back into the mobile app.

Two separate things must work, and they fail independently:

1. **The app code** completes sign-in from the link it receives (`isSignInWithEmailLink` + `signInWithEmailLink`, with the email saved when the link was sent).
2. **The OS hands the link to the app**, which depends only on domain verification (`assetlinks.json` + signing key), not on Dart code.

Test them separately (see "Verify on a device") so a verification problem is not mistaken for a code bug.

## Setup checklist

- **Providers:** Authentication, Sign-in method: "Email/Password" **and** "Email link (passwordless sign-in)" both on. The link needs both.
- **Authorized domains:** the link domain must be listed (the default `firebaseapp.com` and `web.app` domains already are).
- **`ActionCodeSettings`:** `handleCodeInApp: true`, `androidPackageName`, `androidInstallApp`, and `url` (only the browser fallback). Leave `linkDomain` null for the default domain: Firebase rejects `firebaseapp.com` and `web.app` there; it is only for a custom Hosting domain.
- **Fingerprints:** register the signing key's SHA-1 **and SHA-256** on the Android app (`firebase apps:android:sha:create <APP_ID> <hash without colons> --project <project>`). One entry per signing key you ship (beta key, release key, Play App Signing key).
- **Manifest:** an intent filter on `MainActivity` with `android:autoVerify="true"`, `scheme="https"`, `host="<project>.firebaseapp.com"`, `pathPrefix="/__/auth/links"`. With flavors pointing at different Firebase projects, put one filter per flavor in `src/<flavor>/AndroidManifest.xml`.
- **Routing:** set `<meta-data android:name="flutter_deeplinking_enabled" android:value="false"/>` in the main manifest so `go_router` does not try to open `/__/auth/links` as a route; receive the link with `app_links` (initial link + stream) and pass it to the auth layer.
- **Project config:** `mobileLinksConfig.domain` (Identity Toolkit admin config, `GET https://identitytoolkit.googleapis.com/admin/v2/projects/<project>/config`) should be `HOSTING_DOMAIN`.
- **Backend data:** if the post-login screen reads Firestore or Realtime Database, make sure the database actually **exists** in that project and its rules are deployed. A missing database surfaces as a generic "could not load your account / check your connection" error, not as an auth error.

## The main trap: the generated `assetlinks.json` is empty

Firebase Hosting serves an auto-generated `/.well-known/assetlinks.json` on the project domains. It can answer `[]` indefinitely even with the SHA-256 registered, both providers on and `mobileLinksConfig` right. With `[]`, Android marks the domain as failed and the link opens the browser.

Check it first, before touching app code:

```bash
curl -s https://<project>.firebaseapp.com/.well-known/assetlinks.json
```

Fix: serve your own file from the repo.

1. Create `web/.well-known/assetlinks.json`:
   ```json
   [
     {
       "relation": ["delegate_permission/common.handle_all_urls"],
       "target": {
         "namespace": "android_app",
         "package_name": "<applicationId of the flavor>",
         "sha256_cert_fingerprints": ["AA:BB:...:FF"]
       }
     }
   ]
   ```
   Get the SHA-256 from the APK you actually ship: `apksigner verify --print-certs app-release.apk`, or from the `Signatures:` line of `adb shell pm get-app-links <package>`. With Play App Signing, use the key from Play Console, not the upload key.
2. `flutter build web` copies everything under `web/`, dot-directories included, into `build/web/`. Confirm with `ls build/web/.well-known/`.
3. **`firebase.json` must not ignore dotfiles wholesale.** The default `"ignore": ["firebase.json", "**/.*", "**/node_modules/**"]` silently drops `.well-known` on upload. Replace `**/.*` with the specific files to skip (for example `**/.last_build_id`, `**/.DS_Store`).
4. Deploy to a **preview channel** first and check the file there: `firebase hosting:channel:deploy <name> --project <project>`, then `curl -s -w "%{http_code} %{content_type}"` on `<channel-url>/.well-known/assetlinks.json` (expect `200 application/json`).
5. Deploy live (`firebase deploy --only hosting`). A Hosting deploy publishes the whole web build, so it also replaces whatever web app was on `web.app`. With the Flutter web frameworks integration set `FIREBASE_CLI_EXPERIMENTS=webframeworks`.
6. Check both `<project>.firebaseapp.com` and `<project>.web.app`.

Changing the signing key, adding a flavor or creating the production keystore means editing this file and redeploying, or the link goes back to opening the browser.

## Verify on a device

Use a build signed with the key listed in `assetlinks.json`. **Debug builds use the debug keystore and never verify**, so test with the beta/release APK.

```bash
P=<applicationId>
adb shell pm get-app-links $P                 # domain state per host
adb shell pm verify-app-links --re-verify $P  # ask the verifier to fetch the file again
```

- `verified`: the OS will hand the link to the app.
- `1024` (or another number >= 1024): verification failed, usually `[]` or a SHA-256 mismatch.
- `none`: not attempted yet; re-verify and wait about 10 seconds.

**Test the app code without waiting for verification:** approve the domain by hand, then open the link from the email again:

```bash
adb shell pm set-app-links-user-selection --user 0 --package $P true <project>.firebaseapp.com
```

**Undo that before testing verification itself** (`... false <domain>`), otherwise the link opens the app even with a broken `assetlinks.json` and the test proves nothing.

To replay a link without touching the phone, take the URL from `adb shell dumpsys activity activities | grep -oE "dat=https?://[^ ]+"` and fire it with `adb shell am start -a android.intent.action.VIEW -d '<url>'`.

## Other traps

- **Gmail wraps the link** in `https://www.google.com/url?q=...`. That is fine on a device (it still resolves to the App Link), but unwrap `q` before replaying it with `am start`.
- **The link is single-use** and tied to the email saved when it was sent. After a successful sign-in, request a new link to test again; an old one fails with an invalid action code.
- **On web, `url` must be the address the request came from.** The email saved when the link is sent lives in that origin's storage. With a fixed `url` (say the `web.app` site) a user who asked from another host (a portal, a custom domain, `localhost`) lands on a different origin: the app asks for the email again and the session is created there, not where they started. Build it from `Uri.base` without query and fragment (`Uri(scheme:, host:, port:, path:)`) under `kIsWeb`, keep the fixed fallback for mobile, and make sure every host is in Authorized domains. Gmail opens the link in a new tab; with the same origin that tab finds the saved email and the session is shared with the original tab.
- **Missing Realtime Database breaks web startup.** If the app touches `FirebaseDatabase` and the project has no instance (or the options lack `databaseURL`), web fails at launch with `FIREBASE FATAL ERROR: Cannot parse Firebase url` (gray screen in release) while mobile only fails when the database is first used. Create the default instance and add `databaseURL` to the generated options and native configs.
- **The browser fallback is the `url` web app.** If it hosts an old build, users who fall through see an outdated login screen, which looks like a different bug.
- **Stale Flutter web build cache:** after switching branches, `flutter build web` can fail with "Couldn't resolve the package '<plugin>_web'" for plugins no longer in `pubspec.yaml`. Delete `.dart_tool/flutter_build` (not the whole `build/`) and rebuild.
- **iOS** needs Universal Links on the same domain (Associated Domains `applinks:<project>.firebaseapp.com`, the Apple app id registered in Firebase, and an `apple-app-site-association` file); the same "serve it yourself" approach applies.
- **Firebase and Google Cloud changes** (enabling APIs, creating a database, Hosting deploys) may be blocked by an agent's safety classifier; hand the exact commands to the user instead of retrying.
