# Store Release Readiness v1

## Current app identity
- Product name: `Movaro`
- Android application ID: `com.movaro.app`
- iOS bundle identifier: `com.movaro.app`
- Launcher name on device: `Movaro`

## What was corrected in the project
- Replaced template-style launcher names with the production-facing name `Movaro`.
- Aligned Android and iOS identifiers to a cleaner production pattern.
- Prepared Android release signing to read `android/key.properties` when available.
- A localização passou a ser opcional e contextual, com explicação antes do prompt.

## Permissions actually required today
- Android: `INTERNET`, `ACCESS_COARSE_LOCATION` e/ou `ACCESS_FINE_LOCATION`
  conforme o manifesto real.
- iOS: `NSLocationWhenInUseUsageDescription`.

## Location and maps
- The app can request location only when the user asks it to suggest an origin city.
- After reverse geocoding, it stores locally only the confirmed city and an
  approximate municipal point. It does not persist the raw GPS fix.
- The user may choose a city manually, deny permission, and delete the saved
  city in Settings.
- Do not request always-on/background location.
- Store privacy declarations must disclose this optional on-device use.

## Store metadata draft

### App Store
- Name: `Movaro`
- Subtitle: `Plan your move with clarity`
- Promotional text: `Compare cities, understand practical paperwork, and generate a first migration plan without starting from information overload.`
- Description:
  `Movaro helps people who are planning a move understand their first practical options with more clarity. Compare cities with real-world context, review practical documentation, and generate a first migration direction in a few steps.

  With Movaro you can:
  - compare cities using clearly labeled sourced and curated signals
  - review practical information about documents, health, mobility, and everyday setup in Brazil
  - answer a short guided flow to generate a first migration plan
  - explore without creating an account`
- Keywords:
  `migration,moving abroad,brazil,cities,planning,relocation,documents`

### Google Play
- App name: `Movaro`
- Short description:
  `Compare cities and build your first migration plan with more clarity.`
- Full description:
  `Movaro helps you understand your first migration options without starting from information overload.

  Explore cities with practical context, compare key signals like cost and safety, and generate a first plan for your next step.

  What you can do in Movaro:
  - compare cities using curated decision signals
  - understand practical life topics such as documents, health, work, and mobility
  - generate a first migration direction through a short guided flow
  - use the app without creating an account

  Movaro is built to reduce uncertainty at the beginning of the decision process and help you move from vague doubt to a clearer first direction.`

## Privacy and policy declarations to prepare before submission

### Apple
- Add a working support URL in App Store Connect.
- Add a working privacy policy URL in App Store Connect.
- Complete App Privacy details in App Store Connect based on the real SDKs and data flows in the release build.
- Ensure screenshots and metadata reflect only features that are actually available in the build.

### Google Play
- Add a privacy policy URL in Play Console.
- Complete Data safety based on actual collected/shared data in the release build.
- Complete App content declarations:
  - app access
  - ads status
  - content rating
  - target audience
  - news declaration if applicable
- Keep metadata accurate and avoid claiming features that are not yet shipped.

## Operational release checklist

### Android
- Create `android/key.properties` with the release keystore values:
  - `storeFile`
  - `storePassword`
  - `keyAlias`
  - `keyPassword`
- Build an Android App Bundle (`.aab`) for Play submission.
- Verify version code increments for each release.

### iOS
- Set the final Apple Developer team and signing assets in Xcode.
- Confirm the bundle identifier in Apple Developer portal matches `com.movaro.app`.
- Archive with a release configuration and validate in Xcode before upload.

## Review risk notes
- Do not ship placeholder links, coming soon flows, or misleading store screenshots.
- Do not add privacy-sensitive permissions before the feature exists.
- If authentication, analytics, crash reporting, or the location flow changes, update:
  - privacy policy
  - App Privacy details
  - Google Play Data safety
  - permission purpose strings

## Official references
- Apple App Review overview: https://developer.apple.com/app-store/review/
- Apple app information in App Store Connect: https://developer.apple.com/help/app-store-connect/reference/app-information/app-information
- Apple app privacy details: https://developer.apple.com/app-store/app-privacy-details/
- Apple privacy guidance in HIG: https://developer.apple.com/design/human-interface-guidelines/privacy
- Google Play launch checklist: https://developer.android.com/distribute/best-practices/launch/launch-checklist
- Google Play app setup: https://support.google.com/googleplay/android-developer/answer/9859152?hl=en
- Google Play metadata policy: https://support.google.com/googleplay/android-developer/answer/9898842?hl=en
- Google Play listing best practices: https://support.google.com/googleplay/android-developer/answer/13393723?hl=en
- Android permissions overview: https://developer.android.com/guide/topics/permissions/overview
