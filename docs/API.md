# API Conventions

This file describes conventions. The authoritative, machine-readable contract is
[`docs/api/openapi.yaml`](api/openapi.yaml) — when in doubt, the YAML file wins.

## Base

- Prefix: `/api/v1`
- Content type: `application/json`
- Auth: `Authorization: Bearer <access_token>` (JWT), except `auth/register`,
  `auth/login`, `auth/refresh`, `auth/verify-email`.

## Response envelope

Single resource:

```json
{ "data": { "...": "..." } }
```

List/paginated resource:

```json
{
  "data": [ { "...": "..." } ],
  "meta": { "page": 1, "limit": 20, "total": 42 }
}
```

Error:

```json
{ "statusCode": 400, "error": "Bad Request", "message": "email must be a valid email" }
```

## Pagination

Query params on list endpoints: `page` (default 1), `limit` (default 20, max 50).

## Rate limiting

Enforced server-side, not just documented. Initial limits (configurable):

- `POST /connections/wave`: max 20 per user per day; reject a repeated Wave to the same
  recipient while a request is still `PENDING` with `409 Conflict`.
- General API: a conservative per-IP/per-user limit should be applied globally to reduce
  abuse (exact numbers are an infra/ops decision, not a product one — document the chosen
  values in `docs/PROGRESS.md` once set).

## Endpoint groups (see openapi.yaml for full detail)

| Group | Prefix | Notes |
|---|---|---|
| Auth | `/auth/*` | register, login, refresh, logout, verify-email |
| Profile | `/users/*` | self profile CRUD, public profile read (filtered) |
| Communities | `/communities/*` | CRUD, search, join/leave, members |
| Presence | `/presence/*` | visible/invisible/heartbeat/status — optional `vibe` preset; never returns another user's coordinates |
| Discovery | `/discovery/nearby` | bucketed distance plus nullable `vibe`; never raw coordinates |
| Connections | `/connections/*` | wave/accept/reject/list |
| Chat | `/chats/*` | conversations + messages, membership-checked |
| Safety | `/users/:userId/block`, `/reports` | block/unblock/report |

## Contract-first rule

1. Any new/changed endpoint is written in `docs/api/openapi.yaml` first, including a
   realistic `example:`.
2. Mobile builds/updates its mock repository to match the new example.
3. Backend implements to match the contract exactly; its generated Swagger spec
   (`@nestjs/swagger`) should not contradict `openapi.yaml`. Treat a mismatch as a bug.
