# Psi Circle

Location-based social discovery. Members of the same community can find each other when they are in a public place, then say hello with a Wave once both sides agree.

Location is used only while the app is open and the user turns Visible on. The default is Invisible. Other people never receive GPS coordinates, only an approximate distance. Product detail is in [`prd.md`](prd.md).

## Status

The mobile app runs on mock data shaped like the API contract. The backend is not connected to the app yet. Chat is still a placeholder.

## Repository

```text
prd.md                  product requirements
docs/                   architecture, schema, privacy, development plan
docs/api/openapi.yaml   API contract between mobile and backend
apps/mobile             Flutter
apps/backend            NestJS
apps/web                not an MVP priority
docker-compose.yml      PostgreSQL + PostGIS and Redis
```

## Run the mobile app

```bash
cd apps/mobile
flutter pub get
flutter run --dart-define-from-file=dart_defines.json
```

Copy `dart_defines.example.json` to `dart_defines.json` when the Radar map should use CARTO tiles. Without that file, the map falls back to OpenStreetMap tiles. `dart_defines.json` is not committed.

```bash
flutter analyze
flutter test
```

## Local services

Postgres and Redis:

```bash
docker compose up -d postgres redis
```

Backend, after copying `apps/backend/.env.example` to `apps/backend/.env`:

```bash
cd apps/backend
npm install
npm run start:dev
```

## Docs

| File | Contents |
|---|---|
| [`prd.md`](prd.md) | Product behavior |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Module boundaries and data flow |
| [`docs/api/openapi.yaml`](docs/api/openapi.yaml) | API contract |
| [`docs/DATABASE.md`](docs/DATABASE.md) | Postgres schema and Redis presence |
| [`docs/PRIVACY_AND_SECURITY.md`](docs/PRIVACY_AND_SECURITY.md) | Rules that always win |
| [`docs/DEVELOPMENT_PLAN.md`](docs/DEVELOPMENT_PLAN.md) | Work order |
| [`docs/PROGRESS.md`](docs/PROGRESS.md) | What has been built |
