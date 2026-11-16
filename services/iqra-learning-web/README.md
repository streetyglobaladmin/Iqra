# IQRA Learning Web — bounded website-first implementation milestone

**Status:** Local/staging foundation, **not production-ready and not deployed**. Project authority: `streetyglobaladmin/Iqra/docs/decisions/IQRA_WEBSITE_FIRST_DELIVERY.md` and Nuerizo Company Standard v1.9.0. No changes to existing Flutter mobile app packages or production website.

This is the first **persistent web learning vertical**, implemented inside the existing IQRA repository as `services/iqra-learning-web`. It uses a real SQL database, signed HTTP-only sessions and parent-managed child profiles. It is not a substitute for the current Flutter app, and must be integrated with the verified existing API/deployment contract before an authorized launch. We intentionally built this alongside, rather than overwriting, the existing Flutter site while its backend is unverified.

## Functional now (when locally launched)

- Responsive public website with separate Adult IQRA and IQRA Kids discovery.
- Adult/parent registration (adult confirmation required), sign-in and sign-out.
- Initial founder/admin and qualified-reviewer accounts via explicit terminal bootstrap (no default passwords or hardcoded staff users).
- Parent-only creation of child learning profiles with minimal age-band data.
- Two draft curriculum tracks: Al-Fatiha introduction/study/review and Arabic letters Alif through Jim.
- Reviewer approval + admin publication gates. **Seeded lessons are drafts and are not visible to ordinary learners until actual review and publication.** Quran translation/recitation media are not yet licensed or reviewed; no audio-recitation scoring is claimed.
- Ordered lessons, server-validated answer selection, saved completion, cross-login/cross-browser state via DB, idempotent submission event IDs.
- Owner-only profile and progress access (tested). Public API never exposes the correct answer index.
- CSRF validation, same-origin requests, HTTP-only signed session cookies, Argon2 password hashing and basic security response headers.

## Local test and exploratory run

Requires Python 3.11+ and the dependencies in `requirements-dev.txt`.

```sh
cd services/iqra-learning-web
python -m venv .venv
. .venv/bin/activate
pip install -r requirements-dev.txt
pytest -q
```

For local-only execution, configure a randomly generated secret and disposable local SQLite file **outside source control**:

```sh
export IQRA_ENV=local
export IQRA_COOKIE_SECURE=0
export IQRA_SESSION_SECRET="$(python -c 'import secrets; print(secrets.token_urlsafe(48))')"
export IQRA_DATABASE_URL="sqlite:///./iqra-local.sqlite"
uvicorn app:create_app --factory --host 127.0.0.1 --port 8800
```

Open `http://127.0.0.1:8800/`.

To create privileged accounts (with the same `IQRA_*` variables), execute one-time:

```sh
python app.py bootstrap-admin founder@example.com
python app.py bootstrap-reviewer qualified-reviewer@example.com
```

These commands prompt securely for a password and do **not** create accounts automatically. A reviewer must actually be qualified and authorized by the founder before reviewing religious content.

## Stage and environment restrictions

- `IQRA_ENV=production` **deliberately refuses to start** until migrations, audit logging, rate limiting, privacy review, and release gates are implemented. This is a prevention of premature deployment, not a feature defect.
- SQLite is local development/testing only. Before a protected staging rollout, agree the operational PostgreSQL infrastructure, reviewed migrations, backups, secure secrets and hosting/API deployment owner. Do not install a parallel production database blindly.
- No paid services, user emails, payments, third-party AI, external media or children-targeted tracking are integrated.
- Session handling is limited; password reset, MFA, anti-bruteforce throttling, user lifecycle, cookie/session revocation, observability and security review are release blockers.
- Staff review and publication are implemented, but formal qualified reviewer onboarding, comprehensive curriculum CMS, immutable audit logs and version migration are pending.
- The initial content is a **draft lesson skeleton** requiring verified scholarly review, sources and appropriate audio before learners should receive it. There is no AI-controlled religious ruling or recitation grading.
- Child activity needs further accessibility, educational, privacy and Play Families/child-protection assessment. No child self-registration, ads or public leaderboards.
- The existing IQRA Flutter API client is targeted at `https://iqra.nuerizo.cloud/api/v1`, while older deployment notes describe no server. Runtime connectivity/hosting ownership could not be verified from this working environment. **Do not change the existing production API or DNS based on this new service.**

## Contract and next work

Supported endpoints under `/api/v1`:

- `GET /session`, `GET /health`
- `POST /auth/register`, `/auth/login`, `/auth/logout`
- `GET /profiles`, `POST /profiles/child`
- `GET /learning/lessons?profile_id=...`, `POST /learning/answer`
- `GET /admin/lessons`, `PUT /admin/lessons/{id}`
- `POST /admin/lessons/{id}/review`, `POST /admin/lessons/{id}/publish`

The **next accepted milestone** requires: (1) identify actual website backend/API host and source; (2) locate IQRA Kids release code; (3) merge or adapt this learning vertical into the approved existing backend; (4) implement persistent migrations, invitations, content sources and media; (5) complete child/teacher/parent/admin workflows; (6) security/accessibility QA; (7) protected staging website URL and real cross-browser smoke tests; and (8) separate founder release approval.
## Academy operations — REA review implementation

This review branch adds original academy/education operations based on workflow lessons from [WebotApp College ERP](https://github.com/webotapp-academy/college-management-software). **No external ERP code was copied**; its repository does not have an identifiable top-level open-source license in the inspected tree. The Laravel starter's `composer.json` license does not independently license its bespoke management modules.

Implemented staging-only API capabilities:
- Founder/admin: create academies, assign verified `teacher` accounts to classes, view real academy counts.
- Adult learner or parent account: enroll an owned learning profile in a class and submit one assignment per profile.
- Assigned teacher: create assignments, grade submissions within the assigned class, record/update attendance.
- Learner parent: see attendance and graded work only for a profile their account owns; other parents and unrelated teachers are denied.
- Academy changes write server-side audit events, not browser-local Hive records.

`python app.py bootstrap-teacher email@example.com` provisions a dedicated teacher account interactively in local/staging; not a production identity/teacher-vetting flow.

API routes under `/api/v1`:
- `POST /admin/academies`, `POST /admin/classes`, `GET /admin/academies/{academy_id}/summary`
- `POST /academy/classes/{class_id}/enroll`
- `POST /academy/classes/{class_id}/assignments`
- `POST /academy/assignments/{assignment_id}/submit`
- `POST /academy/submissions/{submission_id}/grade`
- `POST /academy/classes/{class_id}/attendance`
- `GET /academy/classes/{class_id}/progress?profile_id=...`

All mutating endpoints require a session and same-site CSRF token. Both the base learning service and academy extensions refuse production startup, because operational account recovery, moderation, parental identity verification, reviewed migrations, concurrent-write handling, rate limiting, hosting ownership and real website integration have not passed release gates.

**Test evidence:** six local automated tests passed in the bounded execution environment. This is not deployment or independently validated production proof. Run `python3 -m pytest -q` to reproduce against an isolated temporary SQLite database; never run test commands against real learner data.

**Review:** See `docs/reviews/IQRA_COLLEGE_ERP_REA_2026-11-16.md` for the reuse decision, rejected campus-specific features, authorization risks and remaining integration blockers.
