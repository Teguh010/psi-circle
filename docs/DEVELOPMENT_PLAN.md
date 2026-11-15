# Development Plan

This elaborates PRD §14's roadmap into a checkbox-level task list, restructured so every
feature phase follows the contract-first order from `AGENTS.md` §4:
**contract → Flutter UI (mock) → backend → integration**. This is an operational
elaboration, not a change to product scope — if a task here seems to conflict with the
PRD, the PRD wins and the conflict must be flagged.

Work top to bottom. Do not start a phase while the previous one has unresolved critical
errors (failing lint/tests, broken build).

---

## Phase 0 — Documentation & Planning ✅ (this phase)

- [x] `AGENTS.md`
- [x] `docs/ARCHITECTURE.md`
- [x] `docs/DATABASE.md`
- [x] `docs/API.md`
- [x] `docs/PRIVACY_AND_SECURITY.md`
- [x] `docs/DEVELOPMENT_PLAN.md` (this file)
- [x] `docs/PROGRESS.md`
- [x] `docs/api/openapi.yaml` (v0.1 — covers all P0 endpoints + P1 stubs)

## Phase 1 — Project Foundation

- [ ] Create monorepo folders: `apps/mobile`, `apps/backend`, `apps/web` (empty/README
      placeholder for `web`, not a priority yet).
- [ ] Scaffold `apps/backend` (NestJS + TypeScript), module skeleton per
      `docs/ARCHITECTURE.md` §3 (empty modules, no business logic yet).
- [ ] Scaffold `apps/mobile` (Flutter), feature folder skeleton per
      `docs/ARCHITECTURE.md` §4.
- [ ] `docker-compose.yml`: PostgreSQL+PostGIS, Redis, backend service.
- [ ] `.env.example` for backend (DB url, Redis url, JWT secrets, token TTLs).
- [ ] Wire up Prisma against `docs/DATABASE.md` schema; initial migration.
- [ ] Backend: ESLint + Prettier. Mobile: `flutter analyze` configured
      (`analysis_options.yaml`).
- [ ] Basic CI (lint + test) for backend and mobile.
- [ ] `@nestjs/swagger` wired up in backend, exporting a live spec (for later drift
      checking against `docs/api/openapi.yaml`).

**Deliverable:** `docker compose up` runs Postgres+Redis; backend boots with empty
modules; mobile app boots to a blank/placeholder screen. No feature logic yet.

## Phase 2 — Auth & Community (contract → mock UI → backend → integration)

- [x] Contract: confirm/refine `auth/*`, `users/me`, `communities/*` sections of
      `docs/api/openapi.yaml` (already drafted in v0.1 — adjust if needed, do not drift
      silently).
- [x] Mobile UI (mock data): onboarding (welcome, register, login, profile setup,
      interest selection), community search/create/join screens — all backed by mock
      repositories returning contract `example:` payloads.
      Also included a mock Radar shell (presence toggle + nearby list) and Chats
      placeholder so main navigation matches PRD §3.1 while later phases fill in.
- [ ] Backend: `auth` module (register, login, refresh, logout, verify-email —
      password hashing, JWT access+refresh, revocation), `users`/`profiles` modules,
      `communities` + `memberships` modules (CRUD, search, join/leave, invitation code).
- [ ] Integration: swap mobile mock repositories for HTTP implementations for this
      phase's features only.
- [ ] Tests: auth service unit tests, membership rule unit tests, registration/login
      integration test, join-community integration test.

**Assumption (mock UI):** interest tags are local onboarding state only — no OpenAPI
field yet. "My communities" uses a mock-repo helper until a memberships list endpoint
is added to the contract.

**Deliverable:** Users can create accounts and join communities, end-to-end.

## Phase 3 — Presence & Radar (the most important milestone)

- [ ] Contract: confirm `presence/*` and `discovery/nearby` sections of the OpenAPI
      contract, including the bucketed distance label values.
- [ ] Mobile UI (mock data): Radar screen (map, visibility toggle, nearby count,
      community filter, nearby members list, profile preview) against mock discovery
      results — no real location/network calls yet.
- [ ] Backend: `presence` module (Redis TTL keys, GEO sets per active community,
      heartbeat, instant delete on Invisible) and `discovery` module (batch filtering:
      community membership, blocks, privacy; bucketed distance calculation).
- [ ] Integration: real foreground location permission flow, real presence
      enable/disable, real discovery calls replacing the mock repository.
- [ ] Tests: presence service unit tests (TTL, expiry, instant delete), discovery
      filtering unit tests, heartbeat-expiration integration test, nearby-discovery
      integration test.
- [ ] **All 7 mandatory privacy tests from `docs/PRIVACY_AND_SECURITY.md` §6 must pass
      before this phase is considered done.**

**Decision (2026-11-15, user-approved PRD change):** Good vibe is an optional preset on
Visible, not a fourth visibility mode and not Event Mode. Contract field `vibe` is
`NGOPI`, `DISKUSI`, `KEGIATAN`, `OPEN_TO_SAY_HI`, or null. It is stored only in the Redis
presence value and cleared with it. Heartbeats that omit `vibe` keep the current preset.
Mock Radar UI shows the badge; the presence backend is still this phase's later work.

**Deliverable:** Users can discover nearby members from shared active communities, with
no raw coordinates ever leaving the backend.

## Phase 4 — Social Interaction

- [ ] Contract: confirm `connections/*`, `users/:userId/block`, `reports` sections.
- [ ] Mobile UI (mock data): member profile preview, Wave button, incoming Wave
      requests (accept/ignore), connection list, block/report actions.
- [ ] Backend: `connections` module (wave/accept/reject/list, rate limiting, duplicate
      pending-wave prevention), `blocks` module, `reports` module.
- [ ] Integration: swap mock repositories for HTTP.
- [ ] Tests: connection state-transition unit tests, block-rule unit tests, wave/accept
      integration test.

**Deliverable:** Users can safely connect with people they discover.

## Phase 5 — Chat & Notifications

- [ ] Contract: confirm `chats/*` sections and WebSocket event payloads.
- [ ] Mobile UI (mock data): conversation list, message screen, unread counts,
      block/report actions from chat.
- [ ] Backend: WebSocket gateway (authenticated), `chats`/`messages` modules,
      `notifications` module (nearby/wave/connection/chat push via FCM).
- [ ] Integration: real WebSocket connection + reconnection handling, real push
      notifications.
- [ ] Tests: chat authorization unit/integration tests (non-members cannot read/send),
      WebSocket auth tests.

**Deliverable:** Users can communicate in real time.

## Phase 6 — Stabilization

- [ ] Security pass (see `docs/PRIVACY_AND_SECURITY.md` §5 checklist).
- [ ] Full privacy test suite re-run (§6 of the same doc).
- [ ] Location edge cases (permission denied, GPS unavailable, airplane mode).
- [ ] Network interruption / reconnection testing (mobile + WebSocket).
- [ ] Performance pass: confirm discovery avoids N+1 queries, pagination applied to all
      list endpoints, API responses under 500ms for common operations under normal load.
- [ ] UI polish pass.
- [ ] Account deletion flow verified end-to-end (data removal/anonymization).
- [ ] Production deployment configuration (separate env files per environment).

**Deliverable:** MVP ready for controlled beta testing.

---

## How to use this file

- Check boxes as work completes; do not check a box until tests for that item pass.
- When a phase finishes, add an entry to `docs/PROGRESS.md` (newest on top) summarizing
  what was built, decisions made, and any known issues — then move to the next phase.
- If a task turns out to need a product decision not covered by the PRD, stop and
  document the assumption here (in the relevant phase) before implementing it.
