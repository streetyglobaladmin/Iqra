# IQRA — Mandatory Governance Entry Point

Before work: read the current Nuerizo Company Standard in `streetyglobaladmin/nuerizo-console`, then read root `NUERIZO_CONTEXT.yaml`, verify this repository/branch/checkpoint, and identify the exact IQRA component being changed.

## Authority
- Product: IQRA.
- This repository (`streetyglobaladmin/Iqra`) is the most advanced connected IQRA Flutter/application implementation line observed in the integrity audit.
- `iqra-ecosystem-hostinger` is a related historical/hosting line, not interchangeable application authority.
- `iqra-studio-desktop` is a separate desktop wrapper component.
- Current source contains a production API service targeting `https://iqra.nuerizo.cloud/api/v1`; do not rely on stale README claims that no live backend is wired.

## Rules
- Identify mobile/web/studio/backend/deployment scope before edits.
- Preserve product/customer/credential isolation.
- Never infer release readiness from route/code existence or build success alone.
- Never use unqualified `PRESERVE`, `APPROVED`, `CANONICAL`, `COMPLETE`, `FOUNDATION`, or `REFERENCE` in authority-bearing instructions.
- Use `NUERIZO CHECK-IN v1` / `NUERIZO HANDOFF v1` and exact Git evidence.
- The eight required context categories are `prd`, `agents`, `design`, `architecture`, `rules`, `memory`, `decisions`, and `testing`. If a required source is missing or contradictory, stop dependent work and report it instead of guessing.
