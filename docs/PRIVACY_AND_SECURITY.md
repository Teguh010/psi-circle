# Privacy & Security — Mandatory Rules

These rules are not optional and override convenience, speed, or feature requests. If an
implementation would conflict with any rule below, stop and prioritize this document over
the feature request, then flag the conflict to the user.

Source: PRD §4, §13, §16, §20.

## 1. Location privacy (PRD §4.1)

1. Default visibility is **Invisible** for every user, always.
2. No location tracking without explicit, in-the-moment consent (tapping "Visible").
3. Location is only used while the app is in the foreground and the user is Visible.
4. Never store location history / movement timeline, anywhere, ever.
5. Never return another user's raw GPS coordinates to any client.
6. Never create an endpoint that returns another user's coordinates, directly or
   indirectly (e.g. no "get last known position of user X").
7. Community admins never get access to member location, live or historical.
8. Visibility can be turned off instantly, at any time.
9. Presence data expires automatically (Redis TTL) — no permanent presence records.
10. Any user can block any other user, which immediately removes mutual discoverability.

## 2. Location data retention (PRD §4.2)

- Redis only. Presence TTL default 120s. Heartbeat interval 30–60s.
- If heartbeats stop, the user becomes Invisible automatically (TTL expiry) — no code
  path should rely on a manual "mark offline" job for correctness, though a cleanup sweep
  for orphaned GEO-set entries is acceptable.
- Turning Invisible must delete the Redis presence key and remove GEO-set membership
  immediately — do not wait for TTL in this case.
- Never write raw GPS coordinates into any PostgreSQL table, log line, or analytics event.

## 3. Data access (PRD §4.3)

Never:

- Let a user query the position of an Invisible user.
- Expose exact coordinates of any other user.
- Provide a "find location by user id" endpoint.
- Build an admin dashboard showing member positions.
- Leak presence/location to a community the user did not select as active.
- Add a hidden/background tracking feature of any kind.

## 4. Safety features (mandatory for MVP, PRD §4.4)

- Block user / unblock user.
- Report user.
- Mute notifications.
- Invisible mode (instant).
- Leave community.
- Delete account.
- Clear, upfront explanation before requesting location permission.
- Rate limiting on sensitive/spammable actions (e.g. Wave: max 20/day, no duplicate
  pending Wave to the same user).

## 5. Security baseline (PRD §13)

- Passwords hashed (bcrypt/argon2), never reversible, never logged.
- JWT access tokens short-lived; refresh tokens stored server-side and revocable
  (logout/compromise must invalidate them).
- Every API endpoint validates authorization server-side — UI-only checks are not
  sufficient and must be treated as a bug if found.
- Validate all input via DTOs (`class-validator` on the backend).
- Prevent IDOR: always scope queries to the authenticated user's permissions (e.g. a
  conversation read must check the caller is a `conversation_members` row, not just that
  the conversation id exists).
- Parameterized queries only — no string-concatenated SQL.
- Never log raw location coordinates (redact before logging).
- WebSocket connections must authenticate (JWT) before accepting events, same
  authorization checks apply as REST.

## 6. Mandatory privacy tests (PRD §16 — must exist as automated tests before a phase is "done")

1. Invisible users never appear in discovery results.
2. API responses never contain another user's raw coordinates (assert absence of
   `latitude`/`longitude` keys for any non-self user payload).
3. Community admins cannot access member location via any endpoint.
4. Users outside a community cannot discover its members through that community.
5. Blocked users cannot discover each other (either direction).
6. Expired presence does not appear in discovery (simulate TTL expiry).
7. A user cannot activate discovery for a community where they are not an ACTIVE member.

## 7. Reporting a conflict

If a feature request in `prd.md` or `docs/DEVELOPMENT_PLAN.md` appears to require
violating any rule above, do not implement it silently either way:
stop, document the conflict (where, why), and prioritize this document until a human
decision is made.
