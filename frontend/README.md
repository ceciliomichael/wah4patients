# frontend

Flutter frontend for WAH for Patients.

## Getting Started

## Runtime Configuration

The app reads backend settings from `frontend/.env` at runtime. For local
development and physical-device builds, you can also pass the same values at
build time with `--dart-define`.

Example:

```bash
flutter run \
  --dart-define=BACKEND_BASE_URL=https://your-backend.example.com/api/v1 \
  --dart-define=BACKEND_API_KEY=your-api-key
```

If you are testing on a physical phone, the backend URL must be reachable from
that phone. `localhost` only works for the device itself, not for your computer.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
