# IQRA — Islamic Education Ecosystem

IQRA is a Flutter-based Islamic education platform for daily companions, students, parents, teachers (Studio), and platform admins.

## Features

- 🕌 **IQRA Daily** — Prayer times (real astronomical calculation), Qibla compass, Tasbih counter, Duas, Hijri calendar, Qur'an reader, Daily Hadith
- 👨‍🎓 **Student Dashboard** — Enrolled classes, live-class join (Zoom/Google Meet), memorization & homework tracker
- 👨‍👩‍👧 **Parent Dashboard** — Linked children, attendance, invoices
- 👨‍🏫 **IQRA Studio** — Teacher workspace: create/manage classes, enrolled students, earnings
- 🌐 **Web targets** — Hub ecosystem launcher, Admin/Control Center (web-only)

## Tech Stack

| Layer | Technology |
|---|---|
| App framework | Flutter 3.35.4 / Dart 3.9.2 |
| State management | `provider` 6.1.5 (ChangeNotifier) |
| Local database | `hive` 2.2.3 + `hive_flutter` |
| Sensors | `sensors_plus` (Qibla compass), `geolocator` |
| Build targets | Android APK/AAB, Flutter Web |

## Getting Started

### Prerequisites
- Flutter SDK **3.35.4** (Dart 3.9.2)
- Android SDK: API 35, Build Tools 35.0.0, Java 17

### Run locally
```bash
flutter pub get
flutter run
```

### Build APK (debug)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Build APK (release — needs your own signing keystore)
```bash
flutter build apk --release
```

## Download APK

Use GitHub Actions:
1. Go to **Actions** tab → **Build Android Debug APK**
2. Click the latest green run
3. Download the `iqra-debug-apk` artifact

## Routes (build-time flag: `IQRA_TARGET`)

| Target | Description |
|---|---|
| `app` (default) | IQRA Daily mobile app |
| `studio` | Teacher Studio web build |
| `control` | Nuerizo Control Center admin (web only) |
| `website` | Public marketing site (web only) |

## Notes

- **Local-only**: All data stored on-device via Hive. No live backend API is wired yet.
- Qur'an content: Al-Fatihah has full ayah text; other surahs listed but need a Qur'an API for content.
- Payments: simulated only (no Stripe/Razorpay integration yet).
- iOS/macOS/Linux/Windows: platform scaffolds exist but not built/tested.
