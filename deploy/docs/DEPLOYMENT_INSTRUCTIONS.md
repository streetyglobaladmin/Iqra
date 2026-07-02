# IQRA — Subdomain Deployment Instructions

One Flutter codebase, four web targets, built via `--dart-define=IQRA_TARGET=...`.
Each target folder under `deploy/` is a static site — deploy as-is to any static host
(Firebase Hosting, Nginx, Cloudflare Pages, S3+CloudFront, etc).

## Build commands (already run once; re-run after any code change)

```bash
cd flutter_app

# 1) iqra.nuerizo.com — main guest-first app (Splash -> Hub)
flutter build web --release --dart-define=IQRA_TARGET=app -o deploy/iqra-app

# 2) studio.iqra.nuerizo.com — IQRA Studio (teacher workspace, opens directly)
flutter build web --release --dart-define=IQRA_TARGET=studio -o deploy/iqra-studio

# 3) control.nuerizo.com — Nuerizo Control Center (admin, opens directly)
flutter build web --release --dart-define=IQRA_TARGET=control -o deploy/nuerizo-control

# 4) Public marketing website (can be served at iqra.nuerizo.com root or a
#    separate path — see note below)
flutter build web --release --dart-define=IQRA_TARGET=website -o deploy/iqra-website
```

Each target self-guards guests: Studio/Control show `GuestLockedScreen` for
unauthenticated visitors instead of a forced login page — this is intentional,
not a bug, per the guest-first + role-gated architecture.

## Subdomain -> folder mapping

| Subdomain                 | Deploy folder            | Notes                                   |
|----------------------------|--------------------------|------------------------------------------|
| iqra.nuerizo.com           | deploy/iqra-website (marketing) or deploy/iqra-app (direct-to-app) | Recommend marketing site at root, app at `/app` or `app.iqra.nuerizo.com` |
| studio.iqra.nuerizo.com    | deploy/iqra-studio        | Teacher workspace                         |
| control.nuerizo.com        | deploy/nuerizo-control    | Admin / Nuerizo Control Center            |
| api.iqra.nuerizo.com       | (backend — not built yet)| See "Backend / API" note below            |

## Static hosting — Firebase Hosting example (recommended, zero server mgmt)

```bash
npm install -g firebase-tools
firebase login
firebase init hosting   # choose 4 separate hosting targets/sites in one project

firebase target:apply hosting iqra-app iqra-nuerizo-app
firebase target:apply hosting iqra-studio iqra-nuerizo-studio
firebase target:apply hosting iqra-control nuerizo-control
firebase target:apply hosting iqra-website iqra-nuerizo-website

# firebase.json — one entry per target, "public" pointing at each deploy/ folder
firebase deploy --only hosting:iqra-app
firebase deploy --only hosting:iqra-studio
firebase deploy --only hosting:iqra-control
firebase deploy --only hosting:iqra-website
```

Then in Firebase Console -> Hosting -> each site -> "Add custom domain" and
point the DNS CNAME/A records per Firebase's instructions for:
`iqra.nuerizo.com`, `studio.iqra.nuerizo.com`, `control.nuerizo.com`.

## Static hosting — Nginx example (self-managed VPS)

```nginx
server {
    listen 443 ssl http2;
    server_name iqra.nuerizo.com;
    root /var/www/iqra-website;   # or iqra-app for direct-to-app
    index index.html;
    location / { try_files $uri $uri/ /index.html; }
}
server {
    listen 443 ssl http2;
    server_name studio.iqra.nuerizo.com;
    root /var/www/iqra-studio;
    index index.html;
    location / { try_files $uri $uri/ /index.html; }
}
server {
    listen 443 ssl http2;
    server_name control.nuerizo.com;
    root /var/www/nuerizo-control;
    index index.html;
    location / { try_files $uri $uri/ /index.html; }
}
```
Use `certbot --nginx` for TLS certificates on each subdomain.

## api.iqra.nuerizo.com — Backend / API note

The current build uses **Hive (local on-device storage)** as its database —
there is no standalone server-side API yet. `api.iqra.nuerizo.com` is
reserved for a future real backend (e.g. Firebase Cloud Functions, or a
Node/Python API talking to Postgres/Firestore) if/when IQRA needs shared
server-side data across devices (multi-device sync, admin managing data
outside of any single device's local Hive store). Until that backend
exists, do not point this subdomain at anything — leave it unconfigured or
show a "coming soon" placeholder.

## Android APK / AAB

Already built and signed (see release notes delivered separately):
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

Upload the AAB to Google Play Console under your app's Production/Internal
testing track. The APK can be side-loaded directly or shared for QA.

## Post-deploy smoke test checklist (guest-first)

1. Open iqra.nuerizo.com (or the app target) — should land on IQRA Hub, no
   forced login.
2. Prayer, Qibla, Tasbih, Hijri, Qur'an, Hadith, Duas, Scholars, Articles,
   Public Lectures — all open without login.
3. Tap Student/Parent/Studio/Admin card — login/register prompt appears,
   does not hard-redirect.
4. studio.iqra.nuerizo.com opens directly to `GuestLockedScreen` for a
   guest, and to the real Studio dashboard after signing in as a teacher.
5. control.nuerizo.com opens directly to `GuestLockedScreen` for anyone who
   isn't Academy Admin / Super Admin.
6. Nuerizo Control Center -> Flags -> confirm the 9 `FeatureAccessLevel`
   chips are editable per flag and persist after refresh.
7. Nuerizo Control Center -> Lectures -> add/edit/publish/hide/delete a
   test lecture, confirm it appears/disappears on the guest Lectures screen.
