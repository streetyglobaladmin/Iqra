# IQRA — Islamic Education Ecosystem

IQRA is a Flutter-based Islamic education platform for daily companions, students, parents, teachers (Studio), and platform admins.

> Governance note: `streetyglobaladmin/Iqra` is the most advanced connected IQRA Flutter/application implementation line observed in the 2026-09-11 integrity audit. Related repositories such as `iqra-ecosystem-hostinger` and `iqra-studio-desktop` have different roles and are not interchangeable implementation authority.

## Features

- **IQRA Daily** — Prayer times, Qibla compass, Tasbih counter, Duas, Hijri calendar, Qur'an reader, Daily Hadith
- **Student Dashboard** — Enrolled classes, live-class join, memorization & homework tracker
- **Parent Dashboard** — Linked children, attendance, invoices
- **IQRA Studio** — Teacher workspace: create/manage classes, enrolled students, earnings
- **Web targets** — Hub ecosystem launcher, Admin/Control Center (web-only)

## Tech Stack

| Layer | Technology |
|---|---|
| App framework | Flutter 3.35.4 / Dart 3.9.2 |
| State management | `provider` 6.1.5 (ChangeNotifier) |
| Local database/cache | `hive` 2.2.3 + `hive_flutter` |
| Sensors | `sensors_plus`, `geolocator` |
| Build targets | Android APK/AAB, Flutter Web |

## Backend integration status

This repository is **not local-only anymore**. It contains `lib/services/iqra_api_service.dart`, a typed production API client whose default base URL is:

`https://iqra.nuerizo.cloud/api/v1`

The service includes authentication/token persistence, HTTP API calls, and offline cache support. Individual screens/features may still be local, simulated, incomplete, or not yet wired to every production endpoint; verify the exact feature before claiming backend completeness.

A source integration is not by itself production/release proof. Deployment, authentication/permissions, API health, mobile sync and runtime validation must be checked separately.

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
```

### Build APK (release)
A release build requires the appropriate signing configuration and release validation.

```bash
flutter build apk --release
```

## Routes (build-time flag: `IQRA_TARGET`)

| Target | Description |
|---|---|
| `app` (default) | IQRA Daily mobile app |
| `studio` | Teacher Studio web build |
| `control` | Nuerizo Control Center admin (web only) |
| `website` | Public marketing site (web only) |

## Release cautions

- Do not treat build success as deployment/release authority.
- Verify API/auth/permissions and the exact feature path being released.
- Payments or external providers must be described according to current source/runtime evidence, not historical README text.
- Platform scaffolds are not proof that every desktop/mobile target has been built or tested.
- See root `AGENTS.md` and `.nuerizo/PROJECT.yaml` before work.
