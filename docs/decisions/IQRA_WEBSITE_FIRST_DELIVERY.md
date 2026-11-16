# IQRA — Website-First Delivery Decision

Date: 2026-11-16
Authority: Explicit founder direction, PRODUCT_INTENT
Status: APPROVED DELIVERY ORDER (not implementation/release evidence)
Repository: streetyglobaladmin/Iqra
Baseline observed before this decision: main 6ae2e0ade916f33c41569be94d37f9b3347178d9
Company authority: NUERIZO-COMPANY-STANDARD v1.9.0 and docs/company-training/REFERENCE_MAP.yaml

## Decision
The first product-delivery priority is a genuinely functional IQRA educational **website**, encompassing separate adult/teen and child learning experiences with a shared secure backend, as well as parent, teacher and founder administrative workflows. Android/iOS app redesigns and new releases follow **only after** the website and its backend learning journeys are tested and verified.

This supersedes any prior plan to start with mobile UI redesign or to present a landing page, disconnected prototype or passing demo as a finished product.

## Product surfaces
1. Public discovery/marketing and guest-available content.
2. Authenticated adult/teen learning web app with lessons, assessments, Quran learning, memorization/practice and persisted progress.
3. Child-focused web app with age-appropriate curricula, parent-managed profiles and permissions; no independent child-facing unrestricted accounts.
4. Parent portal for assigned lessons, visibility and consent.
5. Teacher/academy Studio: authoring, cohorts, assignments, assessments, scheduling and learner feedback.
6. Founder admin: account and role control, curriculum publishing, scholarly review, teacher verification, CMS, support/CRM, analytics, audit and financial admin.

All authenticated surfaces use one authoritative server-side service layer and appropriate tenant/family access boundaries. Frontends may differ, but data contracts and progress semantics are shared.

## Website-first acceptance
- Adult: one complete Surah Al-Fatiha learning sequence, scholar-reviewed and reference-backed, with reading/audio practice, appropriate assessment and saved progress. Accuracy and verse boundaries verified; do not assume an arbitrary three-ayah subdivision is acceptable.
- Kids: one complete Arabic letter foundation pathway (Alif through Jim as an initial slice), recognition, accessible interaction, recall and saved progress, reviewed for child safety.
- One profile can log in, start the correct lesson, complete activities, log out, log in again on another browser and see the persisted state.
- Parent and teacher access to child learning records is authenticated, consented and least-privilege; other families/teachers cannot access them.
- Content is editable/versioned in founder-authorized CMS with reviewed and published states; no production lesson changes by hardcoded JSON or app republishing.
- Test authentication, authorization, synchronization/retry, offline conflict handling if enabled, backend API, mobile web responsive UX, accessibility and failure states.
- Staging deployment with explicit source checkpoint, API and DB health checks, rollback and content QA. Production release is a separate explicit founder decision after gates.

## Architecture guardrail
Inventory existing Flutter web targets, existing IQRA API client at lib/services/iqra_api_service.dart and hosting/backend deployment before selecting NestJS/FastAPI, Postgres/RLS, Redis or new storage. Avoid gratuitous backend rewrites and duplicate databases. Prefer existing validated services. Redis, S3/R2 and offline cache are conditional on demonstrated operational need and economics; enforce parental/role authorization server-side regardless of database technology. Progress sync needs idempotent event IDs, conflict rules, server-verified achievement and device revocation. Minimal child data collection; do not use manipulative engagement systems, public leaderboards or unrestricted chat.

## Existing app protection
Do not change published Android apps, package IDs, signing keys or live user data as part of website-first work. Locate and verify Kids source; no inference from the adult IQRA repository. Existing app upgrade is a later authorized milestone, with compatibility and migration validation.

## Work protocol
Use NUERIZO CHECK-IN v1 before implementation and NUERIZO HANDOFF v1 after. Reverify current Git and deployed environments at start. Document exact website hosting/source mapping, Kids source blocker, actual production endpoint checks and release evidence. Only verified state goes into implementation/release records.
