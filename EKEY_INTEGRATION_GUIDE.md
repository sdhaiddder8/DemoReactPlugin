# eKey 2.0 — React Native Plugin Integration Guide

This guide walks your team through adding eKey 2.0 app-to-app login to your React Native app. It's a true drop-in plugin now — almost everything lives inside one folder, and Android needs no manual wiring at all. No native development experience required, just follow the steps in order.

**What you're adding:** a single JavaScript function, `initiateEkeyLogin()`, that opens the eKey 2.0 login screen, hands off to the eKey app for authentication, and returns you an authorization code your backend can exchange for tokens.

**Time to integrate:** roughly 15–20 minutes.

---

## What you need from us

One folder: **`ekey-react-native-sdk/`**

That's it. Everything — the Android module, the iOS module, the JS bridge, the build configuration — lives inside it. You won't need to copy loose files into your own `android/` or `ios/` folders, and you won't need to rename any packages or classes to match your app.

---

## Step 1 — Drop the plugin into your project

Copy the `ekey-react-native-sdk` folder into the root of your React Native project, next to your `package.json`:

```
YourApp/
├── android/
├── ios/
├── ekey-react-native-sdk/   ← copy it here
├── package.json
└── ...
```

---

## Step 2 — Add it as a dependency

Open your `package.json` and add it to `dependencies`:

```json
"dependencies": {
  "ekey-react-native-sdk": "file:./ekey-react-native-sdk"
}
```

Then install:

```sh
npm install
```

(or `yarn install`, whichever your project uses.)

That single line is the only change needed in your `package.json`. No `codegenConfig` block, no extra scripts.

---

## Step 3 — Android: nothing else to do

If your app already has React Native's New Architecture enabled (`newArchEnabled=true` in `android/gradle.properties`), you're done. `npm install` was enough — the plugin registers itself automatically the same way any other React Native library does (like `react-native-safe-area-context`, if you're using it).

No edits to `settings.gradle`, `build.gradle`, or `MainApplication.kt` are required.

---

## Step 4 — iOS: a few unavoidable steps

Apple doesn't allow this part to be fully automated — your app's own `AppDelegate` has to be told how to hand a returning eKey link back to the SDK. It's three short edits.

**4a. Install the pod**

```sh
cd ios && bundle exec pod install
```

**4b. Register the return URL scheme**

Open `ios/YourApp/Info.plist` and add:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.yourapp.ekey</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>necekey</string>
        </array>
    </dict>
</array>
```

**4c. Forward the return URL to the SDK**

In `AppDelegate.swift`, add the import at the top:

```swift
import EkeySDK
```

...and add this method inside your `AppDelegate` class:

```swift
func application(
  _ app: UIApplication,
  open url: URL,
  options: [UIApplication.OpenURLOptionsKey: Any] = [:]
) -> Bool {
  Ekey.shared.handleOpenURL(url)
  return true
}
```

That's the full iOS setup — no manual Xcode project wiring, no dragging files into your target, no Swift Package configuration. CocoaPods handles linking automatically.

---

## Step 5 — Use it in your app

From here it's plain JavaScript. Import the function and call it from a button:

```tsx
import { initiateEkeyLogin } from 'ekey-react-native-sdk';

const onPress = async () => {
  const result = await initiateEkeyLogin();

  switch (result.status) {
    case 'completed':
      // result.redirectUri contains the authorization code — send it to
      // your backend to exchange for tokens. Never do the token exchange
      // inside the app itself.
      console.log('Success:', result.redirectUri);
      break;
    case 'cancelled':
      // user closed the login screen
      break;
    case 'failed':
      // e.g. a security check failed — do not treat as success
      console.log('Failed:', result.error);
      break;
  }
};
```

---

## Step 6 — Test it

1. Run your app on both Android and iOS.
2. Tap your button — the real eKey 2.0 login screen should open.
3. Complete a login (or use the test/UAT tooling eKey provides) and confirm you get back a `completed` result with a URL containing a `code`.

---

## Before going live

- **Swap in your production credentials.** The plugin ships pointing at eKey's test/UAT environment. The `EkeySDK.xcframework` / `EkeySDK.aar` binaries inside the plugin have your credentials compiled in, so switching environments means asking us for a new build with your production `client_id` and `redirect_uri` — there's no config file to edit yourself.
- **The SDK never sees your final tokens.** It only gets you as far as the authorization code. Exchanging that code for real access/ID tokens must happen on your backend, since it requires a client secret that must never ship inside a mobile app.
- **Threading is already handled.** The plugin runs the login flow on the main thread internally — just call `initiateEkeyLogin()` from your normal UI code.

---

## Troubleshooting

**`pod install` fails with `find: No such file or directory`, referencing part of your folder path**
This is a bug in React Native 0.86.x's own codegen scripts — they don't handle spaces in the project's folder path (e.g. a folder named `My Project`). Two options:
- Move your project to a path with no spaces, or
- Patch `node_modules/react-native/scripts/codegen/generate-artifacts-executor/generateReactCodegenPodspec.js`: wrap the two `${resolvedAppPath}`/`${path.join(...)}` variables used inside `find` commands in quotes. This fix lives in `node_modules`, so you'll need to reapply it after every fresh `npm install`.

**Android build fails with a CMake/native-build error mentioning "SDK XML versions"**
Your Gradle daemon is running on too new a JDK (22+) for your installed Android Gradle Plugin version. Pin `android/gradle/gradle-daemon-jvm.properties` to `toolchainVersion=17`, and make sure a JDK 17 is installed (e.g. Temurin 17) somewhere Gradle can auto-detect it, such as `~/Library/Java/JavaVirtualMachines/` on macOS.

**iOS build error: "No such module 'EkeySDK'"**
`pod install` hasn't run yet (or failed) against the plugin. Re-run step 4a and check the CocoaPods output for errors before rebuilding.

**iOS crashes on tap with "UI API called on a background thread"**
The plugin already guards against this internally. If you see it, make sure you copied the current version of the `ekey-react-native-sdk` folder rather than an older one.

---

Questions? Reach out to the NEC integration team with your build logs and we'll help you get unblocked quickly.
