# Progress Log

Update this file after every completed phase (see `AGENTS.md` §7 "Definition of done").
Newest entry on top.

---

## 2026-11-15 — Good vibe on Radar (PRD + contract + mock UI)

**Status:** Documented and visible on the mock Radar. Backend presence is still unbuilt.

**Decision (user-approved change to `prd.md`):** While Visible, a member may set one
fixed preset — `NGOPI`, `DISKUSI`, `KEGIATAN`, or `OPEN_TO_SAY_HI`. No free text and no
place name. The preset is a badge on the avatar and one word on the member card. It is
stored only in the Redis presence value and disappears with Invisible, a stopped
heartbeat, or TTL expiry. Event Mode stays P1.

**What changed:**

- `prd.md` §3.4, §3.5, §4.1, FR-021, §8.11, §9.4, §9.5, §15.
- `docs/api/openapi.yaml` — `VibeStatus` on presence requests/status and discovery items.
- `docs/DATABASE.md`, `docs/ARCHITECTURE.md`, `docs/API.md`,
  `docs/PRIVACY_AND_SECURITY.md`, `docs/DEVELOPMENT_PLAN.md`.
- Mobile mock Radar: vibe picker while Visible, badge on nearby avatars, word on the
  member screen. Repositories still return contract-shaped JSON. No HTTP yet.

---

## 2026-11-15 — Phase 2 (partial): Flutter UI on mock data

**Status:** In progress (mobile mock UI done; backend + integration not started)

**What was built (`apps/mobile`):**

- Feature-first layout per `docs/ARCHITECTURE.md` §4: `auth`, `onboarding`,
  `communities`, `radar`, `chat` (placeholder), `profile`, plus `core/models` and
  Riverpod repository providers.
- Repository interfaces + mock implementations that return payloads shaped like the
  `example:` blocks in `docs/api/openapi.yaml` (auth, profile, communities, presence,
  discovery). No real HTTP yet.
- Screens: welcome, login, register, profile setup, interest selection, join-community
  onboarding, main shell (Radar / Communities / Chats / Profile), community search /
  detail / create, Radar with Visible toggle + nearby list (bucketed distance labels
  only), profile + logout.
- `flutter analyze` clean; widget smoke test passes.

**Assumptions / notes:**

- Interest selection is local-only onboarding UX (PRD §3.2); OpenAPI has no interests
  endpoint yet.
- "My communities" is a mock-repository helper until the contract adds a dedicated
  memberships list endpoint.
- Radar map is a visual placeholder; real `flutter_map` + geolocator wiring belongs
  with Phase 3 integration.
- Chats tab is intentionally a placeholder until Phase 5.

**Still open for Phase 2:** backend auth/communities modules + HTTP swap.

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

**Known issues:** none. Note: Phase 1 scaffolding (apps + docker-compose) was added after
this entry and is present in the repo even though Phase 0 originally said "no code yet".
