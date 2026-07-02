# IQRA — Database Migration Notes

**Current state**: IQRA stores all data locally on-device via **Hive**
(boxes listed in `lib/data/local/hive_boxes.dart`: users, session,
feature_flags, academies, classes, students, pricing_plans, currencies,
cms_pages, advertisements, referrals, audit_log, payments,
prayer_settings, tasbih_state, reader_state, bookmarks, app_settings,
teachers, lectures). There is **no central server database yet** — each
device/browser has its own local store. This is why `api.iqra.nuerizo.com`
is currently unconfigured (see DEPLOYMENT_INSTRUCTIONS.md).

Because there is no live external database today, there are no destructive
schema migrations to run yet. This file documents the **migration
strategy for when a real backend is introduced** (Firestore or
Postgres/Supabase), so the transition is safe and reversible.

## Migration path A — Firestore (recommended, least code change)

1. Every repository in `lib/data/repositories/*.dart` already isolates all
   Hive access behind a small class (`getAll/getByKey/upsert/delete`).
   Swap the Hive `Box` calls for `FirebaseFirestore` collection calls
   inside each repository — the rest of the app (screens, AppState) does
   not need to change.
2. Collections should mirror the existing Hive box names 1:1: `users`,
   `feature_flags`, `classes`, `students`, `lectures`, `cms_pages`, etc.
3. Write a one-time export script (`export_hive_to_firestore.dart`, not
   included — build when the backend is ready) that reads each Hive box
   and `.set()`s the same documents into Firestore under the same IDs, so
   existing local data migrates without loss.
4. Add `firebase_core` + `cloud_firestore` per the Firebase Integration
   Guide (exact locked versions), keep Hive as an **offline cache** layer
   if desired, or remove it once Firestore is the source of truth.

## Migration path B — Postgres/Supabase (if relational reporting is needed)

1. Suggested schema (derived directly from existing Dart models):
   - `users(id, email, name, password_hash, password_salt, roles[], status, locale, academy_id, parent_id, referral_code, referred_by_code, created_at, updated_at)`
   - `feature_flags(key PK, module, name, description, release_state, killswitch, rollout_pct, allowed_access_levels[], updated_at)`
   - `classes(id, teacher_id, title, level, schedule_summary, provider, meeting_link, price_amount_minor, student_ids[], ...)`
   - `lectures(id, title, scholar_name, category, thumbnail_url, description, video_link, audio_link, duration, language, status, is_premium, updated_at)`
   - `cms_pages(id, slug, title, body, status, is_blog_post, cover_url, tags[], updated_at)`
   - `payments`, `pricing_plans`, `currencies`, `audit_log`, `academies`, `students`, `teachers`, `advertisements`, `referrals` — same field shape as their `toMap()`/`fromMap()` pairs today.
2. Run migrations with a standard tool (Prisma, Drizzle, or plain SQL
   files under `deploy/scripts/migrations/NNN_description.sql`) — none are
   included yet since there is no live schema to version.
3. Point repositories at a REST/GraphQL API served from
   `api.iqra.nuerizo.com` instead of local Hive boxes.

## Rollback safety

Because Hive remains the local source of truth until a backend migration
is actually performed, rollback is simply: stop writing to the new
backend and resume reading/writing Hive boxes directly (no data is
deleted during a Firestore/Postgres migration if you follow the "read
Hive, write remote, verify, then cut over" pattern above).
