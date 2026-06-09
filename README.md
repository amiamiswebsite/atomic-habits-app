# HabitVotes

HabitVotes is a native iOS 17+ SwiftUI habit tracker where each completed habit is treated as an identity vote: visible proof of who the user is becoming.

The product uses general habit-building concepts only. It does not use Atomic Habits branding, copy, structure, illustrations, or proprietary UI.

## What Is Included

- SwiftUI iOS app target: `HabitVotes`
- WidgetKit extension target: `HabitVotesWidget`
- Local Swift package: `HabitVotesCore`
- SwiftData models for habits, schedules, reminders, completions, and notes
- Swift Charts-based weekly progress
- Local notification scheduling through `UserNotifications`
- App Intents-powered widget button MVP
- Reusable design system components and tokens
- Unit tests for deterministic habit logic
- CLI smoke-check target for environments without XCTest

## Open In Xcode

Open:

```sh
open HabitVotes.xcodeproj
```

Scheme:

```text
HabitVotes
```

## Run On Simulator

With full Xcode selected:

```sh
xcodebuild \
  -project HabitVotes.xcodeproj \
  -scheme HabitVotes \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

Or:

```sh
./scripts/build.sh
```

## Run Tests

Core logic smoke check, available without XCTest:

```sh
cd HabitVotesCore
swift run HabitVotesCoreChecks
```

Full Xcode test run:

```sh
xcodebuild \
  -project HabitVotes.xcodeproj \
  -scheme HabitVotes \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  test
```

Or:

```sh
./scripts/test.sh
```

## Build For Appetize

Do not upload the source-code zip of this repository to Appetize. Appetize needs a compiled iOS Simulator `.app` bundle, compressed as a zip.

With full Xcode selected locally:

```sh
./scripts/build-appetize.sh
```

Upload this file to Appetize:

```text
build/Appetize/HabitVotes-Appetize.zip
```

You can also build it in GitHub Actions:

1. Push this repo to GitHub.
2. Open the Actions tab.
3. Run `Build Appetize Simulator App`.
4. Download the `HabitVotes-Appetize` artifact.
5. Upload `HabitVotes-Appetize.zip` to Appetize.

## Run On Physical iPhone

1. Open `HabitVotes.xcodeproj`.
2. Select the `HabitVotes` target.
3. Replace placeholder bundle IDs:
   - `com.example.HabitVotes`
   - `com.example.HabitVotes.HabitVotesWidget`
4. Replace the placeholder app group:
   - `group.com.example.HabitVotes`
5. Select your development team under Signing & Capabilities.
6. Run the `HabitVotes` scheme on your connected iPhone.

## Signing Notes

The project uses automatic signing and placeholder identifiers. Widget app-group entitlements are present, but the app group must be created in the Apple Developer portal for a real team before device distribution.

## Architecture

```text
HabitVotes/
  App/
  Models/
  Services/
  Views/
  Components/
  DesignSystem/
  Resources/
HabitVotesWidget/
HabitVotesCore/
HabitVotesTests/
scripts/
```

The habit rules live in `HabitVotesCore` so streaks, schedules, recovery, weekly rates, and reminder descriptors are deterministic and testable without SwiftUI or SwiftData.

## Known Limitations

- This workstation has Command Line Tools selected instead of full Xcode, so `xcodebuild`, Simulator listing, UI launch, screenshots, and XCTest could not run here.
- The widget button updates the shared widget snapshot as an MVP interaction. A production version should resolve and persist the exact next habit completion into a shared SwiftData/App Group store.
- The app icon is a placeholder asset catalog entry; replace it with final branded icon artwork before distribution.
- App group and bundle identifiers are placeholders and must be replaced before physical-device or App Store distribution.
