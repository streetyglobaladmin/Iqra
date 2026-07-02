# IQRA — Backup & Restore Instructions

## What needs backing up today

Since IQRA currently stores data on-device via Hive (no central server DB
yet — see `deploy/scripts/db_migrate.md`), "backup" today means two things:

1. **The codebase itself** (source of truth for everything) — already
   backed up via git (`genspark` remote, see project auto-backup) and can
   be archived anytime with the `ProjectBackup` tool.
2. **Per-device Hive data** — local to each install (browser IndexedDB for
   web, app sandbox storage for Android). Not centrally recoverable yet;
   this is expected until a real backend (Firestore/Postgres) is
   introduced per the migration doc.

## Codebase backup

```bash
# Full project archive (source + git history), from the sandbox:
# use the ProjectBackup tool, or manually:
cd /home/user
tar -czf flutter_app_backup_$(date +%Y%m%d_%H%M%S).tar.gz flutter_app \
  --exclude=flutter_app/build \
  --exclude=flutter_app/.dart_tool \
  --exclude=flutter_app/android/.gradle \
  --exclude=flutter_app/android/build \
  --exclude=flutter_app/android/app/build
```

Restore: extract the tarball into `/home/user/`, then:
```bash
cd /home/user/flutter_app && flutter pub get
```

## Git-based backup (recommended — already active)

- Every turn's commits are auto-pushed to the project's Genspark git
  backup remote (`genspark/main`).
- For an additional off-platform copy, push to a GitHub repo the user
  selects via the GitHub tab, using `setup_github_environment` then
  `git push`.
- Restore: `git clone` the repo, `flutter pub get`, rebuild.

## Signing keystore backup (CRITICAL — cannot be regenerated)

The Android release signing key is the **one artifact that cannot be
recreated** if lost — losing it means you can never publish an update to
an app already live on Google Play under the same package.

**Back up immediately and store securely (password manager / secure
vault), outside of git:**
```
android/release-key.jks
android/key.properties
```

Restore: copy both files back into `android/` before running
`flutter build apk --release` / `flutter build appbundle --release`.

## Once a real backend exists (Firestore / Postgres) — future backup plan

- **Firestore**: use `gcloud firestore export gs://<bucket>/backups/$(date +%F)`
  on a schedule (Cloud Scheduler + Cloud Function, or manual). Restore
  with `gcloud firestore import gs://<bucket>/backups/<date>`.
- **Postgres/Supabase**: nightly `pg_dump` to encrypted storage; restore
  with `pg_restore`. Supabase also offers built-in point-in-time recovery
  on paid tiers.
- Update this document with the exact bucket/schedule once the backend
  from `deploy/scripts/db_migrate.md` is actually deployed.

## Quick recovery checklist

1. Restore codebase (git clone or tarball extract).
2. Restore `android/release-key.jks` + `android/key.properties` from
   secure storage.
3. `flutter pub get`.
4. Rebuild web targets (`deploy/docs/DEPLOYMENT_INSTRUCTIONS.md`) and/or
   APK/AAB.
5. Re-deploy to hosting / Play Console.
6. (Future backend) Restore latest Firestore/Postgres snapshot before
   pointing the app at it.
