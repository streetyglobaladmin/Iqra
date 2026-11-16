# IQRA Academy Management — REA-style Review of WebotApp College ERP
Date: 2026-11-16
Task: IQRA-ACADEMY-REA-001
Authority: ENGINEERING ANALYSIS (not founder scope change or production/release proof)
Base implementation: streetyglobaladmin/Iqra @ fa3d2b37aeb6680d2430c21e7d97426478c281f4
Reference: https://github.com/webotapp-academy/college-management-software (inspected default branch 2026-11-16)
Process: Research -> Evaluate -> Adapt; dedicated REA agent package was not available in this runtime.

## Decision
Borrow *workflows*, not source code or framework. The external college ERP contains academic administration features useful to IQRA, but should NOT be merged wholesale. Keep website-first scope, preserve Flutter code and any verified existing API. Build original, role-safe educational operations.

## Evidence
- Reference project: Laravel 13, MySQL, ~30 advertised ERP modules; models include academics, admission enquiries, attendance, LMS materials/assignments/submissions, parent/student portals, fees, complaints, admin/audit. README calls itself production ready; do not treat that marketing claim as independently verified.
- Reference includes no top-level LICENSE/COPYING/NOTICE in the inspected repository tree. A "license: MIT" in Laravel starter composer.json cannot license all custom reference code. Do not copy source unless rights are separately established.
- Reference routes/web.php places broad printable student documents under auth only, without an explicit resource-owner policy at route level. A separate object-level authorization review is required before reuse.
- IQRA has Flutter web/mobile targets, student and parent shells, teacher Studio, admin shell, academy/class/student/payment repositories. Many of the latter still use browser-local Hive. A more recent API client points to https://iqra.nuerizo.cloud/api/v1, but deployment and backend behavior remain unverified. Historical hosting notes conflict with newer code.
- Founder-approved IQRA_WEBSITE_FIRST_DELIVERY.md requires a fully working website, shared server-side state, safe child/parent permissions, verified adult + Kids learning journeys before mobile redesigns.

## Gap / adoption matrix
| Reference feature | IQRA evidence | Adaptation | Priority |
|---|---|---|---|
| Admissions + enquiry CRM | No verified server-side academy onboarding CRM | Learner enquiry -> guardian consent -> academy enrolment, follow-up and lead attribution | P1 |
| Multi-campus/college governance | Local academy model | Multi-academy row/claim authorization, academy-level configuration and staff | P0 |
| Attendance tracking | Parent UI mentions attendance; no verified shared attendance service | Class-session attendance, teacher edit with audit, parent view only after authorized linkage | P0 |
| LMS assignments/submissions/grades | Student UI mentions homework; Studio local classes | Signed-in teacher assignments, enrolled-student submission, teacher grading and limited parent progress | P0 |
| Courses and schedules | Existing class model | Server-backed timetables, instructor assignments and class capacity | P1 |
| Exams, assessments, certificates | No verified end-to-end central workflow | Quran/Arabic mastery assessments, signed certificate records, verified rubrics and review | P1/P2 |
| Fee ledger | Local payment records plus API client | Verified provider payments, invoices, reconciliations, receipts, refunds | P2 |
| Communication | Existing lecture/teacher surfaces | Consent-aware parent and teacher notifications; no unrestricted child messaging | P1 |
| Management analytics and audit | Admin has analytics/audit local repositories | Server-owned metrics and append-only audit events for account, content and learner operations | P0 |
| Payroll, hostel, bus, college accreditations, placements, biometrics | Unrelated to online Islamic teaching | REJECT for website-first scope | Excluded |

## Security and safeguarding
- Every read/write checks authenticated identity and academy membership at the backend; UI role checks alone are insufficient.
- Child profiles are created/controlled by authenticated adults, with recorded verification/consent before guardian linking; no unmoderated child forum/chat/leaderboards.
- Teacher progress view must be limited to *their* assigned classes, not other classes within the academy.
- No built-in predictable demo logins in production; data is fictional in staging.
- Do not import sensitive data from a reference college seed or use unverified claims to enable payments.
- External project lacks a source reuse grant; implementation must be independently authored and tested.

## First implementation slice
Isolated academy-operations candidate (services/academy_ops): academy/class setup, authenticated role checks, enrollment, recorded guardian link (consent reference), teacher assignment, learner submission, grading, attendance, parent progress, admin counts and audit events. Excludes the full Learning Passport and full curriculum. No automatic deployment or production migration; integrate only after upstream identity, hosting and source-of-truth are reconciled.

## Stage gates still blocked
1. Locate and verify IQRA Kids repository and published-app source.
2. Establish which host/backend presently serves IQRA, how auth tokens are issued and what DB is authoritative. The code client's endpoint is not operational proof.
3. Replace candidate upstream JWT test-issuer contract with actual validated identity provider and server-owned roles; enforce rate limits, key rotation, revocation, guardianship verification and tenant-isolation defense in depth.
4. Add managed Postgres migration/backup/rollback + RLS (if chosen), staging environment, CI, authorization, concurrency and child-safety/security testing.
5. Wire the actual website UX to the proven service; show end-to-end real account journey; gate production release separately.

## Evidence needed for "complete"
- Linked code checkpoint, tests + staging URL + API response, persisted server data across sessions, authorization negatives and parent/teacher isolation checks.
- Actual real teacher -> enrolled student -> parent -> academy admin journey in staging.
- No marketing-complete status on a folder of models, visual demo or local SQLite test.
