# FlowerFinder

FlowerFinder is a Flutter mobile application for COMP602. The app helps users identify flowers, search for flower information, save diary records, and create custom flower stickers from flower photos. The project combines scanning, search, diary, profile, and sticker creation features into one shared mobile app.

## Features

- **Flower Scanner / Identification**: use the device camera and PlantNet integration to identify flowers.
- **Flower Search and Information**: search flower data and view flower details.
- **Diary**: record saved flower-related memories and diary entries.
- **User Profile**: view profile details, saved stickers, uploaded photos, profile statistics, and profile customisation.
- **Sticker Creation**: create generated flower stickers from API images or personal gallery photos.
- **Sticker Effects**: apply outline, inner shadow, drop shadow, glitter texture, rainbow prism texture, and colour wheel tinting.
- **Sticker Handoffs**: saved generated stickers can be selected from Profile for future Sharing and Diary integration.

## Team responsibilities

| Area | Responsibility |
| --- | --- |
| G3 User Profile | Linda |
| G6 Sticker Creation | Linda |
| Scanner / Flower Identification | Iris |
| Flower Search | Hita |
| Flower Information | Hita |
| Diary | Erin |
| Sharing | Erin |
| Authentication / Login | Iris |

Update this table with the final team member names before submission if required by the course.

## Tech stack

- Flutter
- Dart
- iOS and Android mobile targets
- PlantNet API for flower identification
- Perenual API for flower search/photo data
- Firebase packages for authentication integration

## Main dependencies

The project dependencies are listed in `pubspec.yaml`. Key packages include:

- `camera`
- `http`
- `firebase_core`
- `firebase_auth`
- `flutter_sticker_maker`
- `image_picker`
- `google_fonts`
- `path_provider`
- `flutter_dotenv`

Install dependencies with:

```sh
flutter pub get
```

## API configuration

The app uses API keys for external flower services. Do not commit real API keys to GitHub.

For local development, use local environment configuration such as `.env` or Flutter dart defines depending on the feature being tested. For Perenual sticker photo search, the project supports a local config file flow:

```sh
cp config/perenual.example.json config/perenual.local.json
flutter run --dart-define-from-file=config/perenual.local.json
```

`config/perenual.local.json` should contain the local Perenual key and should stay ignored by Git.

For PlantNet, make sure the local environment contains the correct key before testing scanner identification. If the app reports that the PlantNet key is not accepted, verify the key in the PlantNet dashboard and confirm that the app is reading the updated local value.

## Running the app

First install dependencies:

```sh
flutter pub get
```

Run on a connected Android device or emulator:

```sh
flutter run
```

Run on a connected iPhone in release mode:

```sh
flutter run --release -d <device-id>
```

List available devices with:

```sh
flutter devices
```

For this project, iOS real-device testing may require opening the iOS workspace in Xcode and setting a valid development team and bundle identifier:

```sh
open ios/Runner.xcworkspace
```

In Xcode, check **Runner > Signing & Capabilities** and make sure automatic signing is enabled with a valid Apple developer account.

## Building the app

Build an iOS release app:

```sh
flutter build ios --release
```

Build an Android APK:

```sh
flutter build apk --release
```

## Testing and code checks

Run Flutter tests:

```sh
flutter test
```

Run static analysis:

```sh
flutter analyze
```

Known note: the current scanner page may report `avoid_print` info messages during analysis. These are informational lint messages from scanner debugging output and should be reviewed by the scanner owner before final submission.

## Sticker Creation notes

Create Sticker supports flower images from Perenual and photos selected from the device gallery. The gallery flow remains available when the API is offline or unconfigured. Personal photo bytes are processed by the sticker maker; they are not sent to Perenual.

Generated stickers use `flutter_sticker_maker` for background removal. After generation, the app crops excessive transparent padding so the flower fills the sticker frame more clearly. Users can then apply optional effects and save the generated PNG.

Only final generated sticker PNG bytes should be passed from Profile to Sharing or Diary handoff callbacks. Original flower photos should not be treated as generated stickers.

## iOS real-device note

On iOS 14 and later, a Flutter debug build cannot always be launched from the home screen after the Flutter tool or Xcode debug session is stopped. For a phone demo where the app should open from the home screen without the terminal running, install a release/profile build instead of a debug build.

Example:

```sh
flutter run --release -d <device-id>
```

## Repository notes

- Keep API keys and local config files out of Git.
- Commit small, focused changes.
- Avoid modifying another teammate's feature unless required for a small integration adapter.
- Run tests and analysis before merging to `main`.
