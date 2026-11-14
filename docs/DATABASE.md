# Database Design

Primary store: PostgreSQL (with PostGIS extension enabled, see ARCHITECTURE.md §7).
Ephemeral store: Redis (presence only, never persisted to Postgres).

ORM: Prisma. Use parameterized raw SQL only for PostGIS-specific queries if/when they are
actually needed (not required for MVP presence/discovery, which is Redis GEO based).

## 1. `users`

| Field | Type | Notes |
|---|---|---|
| id | UUID PK | |
| email | VARCHAR UNIQUE | |
| password_hash | VARCHAR | bcrypt/argon2 |
| email_verified_at | TIMESTAMPTZ NULL | |
| status | ENUM(`ACTIVE`,`SUSPENDED`,`DELETED`) | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

## 2. `user_profiles`

| Field | Type | Notes |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK → users.id | |
| username | VARCHAR UNIQUE | |
| display_name | VARCHAR | |
| avatar_url | TEXT NULL | |
| bio | TEXT NULL | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

## 3. `communities`

| Field | Type | Notes |
|---|---|---|
| id | UUID PK | |
| name | VARCHAR | |
| slug | VARCHAR UNIQUE | |
| description | TEXT | |
| avatar_url | TEXT NULL | |
| visibility | ENUM(`PUBLIC`,`PRIVATE`) | |
| created_by | UUID FK → users.id | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

Index: `(visibility)` for public search; full-text or trigram index on `name` for search.

## 4. `community_invitations` (private community join via code — PRD §3.3/§3.4 FR-018)

| Field | Type | Notes |
|---|---|---|
| id | UUID PK | |
| community_id | UUID FK → communities.id | |
| code | VARCHAR UNIQUE | |
| created_by | UUID FK → users.id | |
| expires_at | TIMESTAMPTZ NULL | |
| max_uses | INT NULL | |
| used_count | INT DEFAULT 0 | |
| created_at | TIMESTAMPTZ | |

Assumption (documented per PRD rule 16): invitation codes are modeled as their own table
rather than a column on `communities`, so a private community can rotate/revoke codes and
support multiple active codes without affecting existing members.

## 5. `community_members`

| Field | Type | Notes |
|---|---|---|
| id | UUID PK | |
| community_id | UUID FK → communities.id | |
| user_id | UUID FK → users.id | |
| role | ENUM(`MEMBER`,`ADMIN`,`OWNER`) | |
| status | ENUM(`PENDING`,`ACTIVE`,`REJECTED`,`BANNED`,`LEFT`) | |
| joined_at | TIMESTAMPTZ | |

Constraint: `UNIQUE(community_id, user_id)`.
Index: `(community_id, status)` — discovery and member-count queries filter on this.

## 6. `connections`

| Field | Type | Notes |
|---|---|---|
| id | UUID PK | |
| requester_id | UUID FK → users.id | |
| recipient_id | UUID FK → users.id | |
| status | ENUM(`PENDING`,`ACCEPTED`,`REJECTED`,`BLOCKED`) | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

To prevent duplicate connections regardless of who initiated, enforce a unique index on
the canonically-ordered pair, e.g. a generated column
`pair_key = least(requester_id, recipient_id) || '_' || greatest(requester_id, recipient_id)`
with `UNIQUE(pair_key)`. Application logic still tracks `requester_id`/`recipient_id` for
Wave semantics (who sent it, daily rate limit accounting).

## 7. `conversations`

| Field | Type | Notes |
|---|---|---|
| id | UUID PK | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

## 8. `conversation_members`

| Field | Type | Notes |
|---|---|---|
| conversation_id | UUID FK → conversations.id | |
| user_id | UUID FK → users.id | |
| joined_at | TIMESTAMPTZ | |
| last_read_at | TIMESTAMPTZ NULL | used for unread count |

Constraint: `UNIQUE(conversation_id, user_id)`.

## 9. `messages`

| Field | Type | Notes |
|---|---|---|
| id | UUID PK | |
| conversation_id | UUID FK → conversations.id | |
| sender_id | UUID FK → users.id | |
| content | TEXT | |
| created_at | TIMESTAMPTZ | |

Index: `(conversation_id, created_at)` for paginated history.

## 10. `user_blocks`

| Field | Type | Notes |
|---|---|---|
| id | UUID PK | |
| blocker_id | UUID FK → users.id | |
| blocked_id | UUID FK → users.id | |
| created_at | TIMESTAMPTZ | |

Constraint: `UNIQUE(blocker_id, blocked_id)`. Checked by discovery, connections, and chat
on every read/write — never only enforced in the UI.

## 11. `user_reports`

| Field | Type | Notes |
|---|---|---|
| id | UUID PK | |
| reporter_id | UUID FK → users.id | |
| reported_user_id | UUID FK → users.id | |
| reason | VARCHAR | |
| description | TEXT NULL | |
| status | ENUM(`OPEN`,`REVIEWED`,`DISMISSED`) | |
| created_at | TIMESTAMPTZ | |

## 12. Presence (Redis only — never written to PostgreSQL)

Key: `presence:{userId}` → JSON value, TTL default 120s (configurable):

```json
{
  "userId": "uuid",
  "latitude": -7.123456,
  "longitude": 112.123456,
  "activeCommunityIds": ["uuid"],
  "visibility": "VISIBLE",
  "updatedAt": "2026-11-15T00:00:00Z"
}
```

Per-community GEO index for radius queries: `geo:community:{communityId}` (Redis `GEOADD`
member = `userId`). On Invisible or TTL expiry, the user must be removed from every
`geo:community:*` set they were added to — track membership so cleanup is O(active
communities), not a full scan.

Never expose raw `latitude`/`longitude` through any API response. Never persist presence
history — only the current snapshot exists, and only in Redis.
