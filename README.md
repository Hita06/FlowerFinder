# flowerfinder

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Sticker photo sources

Create Sticker supports Perenual flower search and photos selected from the device gallery.
The gallery remains available when the API is offline or unconfigured. Personal photo bytes
are processed by the existing sticker maker; they are not sent to Perenual.

For local development, copy `config/perenual.example.json` to
`config/perenual.local.json` and replace the placeholder with your Perenual key.
The local file is ignored by Git. Run:

```sh
flutter run --dart-define-from-file=config/perenual.local.json
```

Search uses https://perenual.com/api/v2/species-list and the returned image URLs.
A real key is required to verify live responses and account-specific image access.
Dart defines are embedded in the app; a distributed production app should access
Perenual through a backend that keeps the API key private.

Saved stickers currently remain in memory for the running session, as before.
