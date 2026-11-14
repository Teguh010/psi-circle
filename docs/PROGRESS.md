# Progress Log

Update this file after every completed phase (see `AGENTS.md` §7 "Definition of done").
Newest entry on top.

---

## 2026-11-15 — Phase 0: Documentation & Planning

**Status:** Complete

**What was created:**

- `AGENTS.md` — operational instructions for AI coding agents (tech stack, repo layout,
  contract-first workflow, non-negotiable rules).
- `docs/PRD.md` — pointer to root `prd.md` (no duplication).
- `docs/ARCHITECTURE.md` — monorepo layout, module boundaries, mobile feature structure,
  presence/discovery data flow, WebSocket event list.
- `docs/DATABASE.md` — full schema for all PostgreSQL tables + Redis presence structure,
  including constraints/indexes not fully spelled out in the PRD (e.g. connection pair
  uniqueness, invitation code table).
- `docs/PRIVACY_AND_SECURITY.md` — consolidated mandatory privacy/security rules and the
  7 required privacy tests.
- `docs/DEVELOPMENT_PLAN.md` — phased, checkbox-level task breakdown, restructured to
  enforce a contract-first order (OpenAPI contract → Flutter UI on mock data → backend →
  integration) within each feature phase.
- `docs/API.md` — narrative description of API conventions; `docs/api/openapi.yaml` is
  the authoritative machine-readable contract.
- `docs/api/openapi.yaml` — OpenAPI 3.0 contract for all P0/P1 endpoints in PRD §9, with
  embedded `example:` payloads usable as mock data and/or servable via a mock server
  (e.g. Prism) before the backend exists.

**Decisions / assumptions documented:**

- PostGIS is enabled but not required by any MVP table; presence/discovery is Redis-only
  (see `docs/ARCHITECTURE.md` §7).
- Invitation codes modeled as their own table (`community_invitations`) rather than a
  single column on `communities` (see `docs/DATABASE.md` §4).
- Connection uniqueness enforced via a canonically-ordered pair key rather than relying
  on `(requester_id, recipient_id)` alone (see `docs/DATABASE.md` §6).

**Not started yet:** no code. `apps/mobile`, `apps/backend`, `apps/web`, and
`docker-compose.yml` do not exist yet — that is Phase 1 in `docs/DEVELOPMENT_PLAN.md`.

**Known issues:** none.
