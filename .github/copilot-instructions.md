# Tracker Frontend - Copilot Coding Agent Instructions

## Repository Overview

**tracker-frontend** is a Flutter mobile/web app for tracking trips and adventures. Clean architecture with data, presentation, and core layers.

**Key Stats:**
- Flutter 3.27.1, Dart ^3.9.2
- 34 models, 6 services, 26 tests
- Web deployment on port 51538 via nginx/Docker

## Critical Build & Test Commands

### Prerequisites
Before any commands, ensure Flutter SDK 3.27.1+ is available. The CI uses Flutter 3.35.7 (stable channel).

### Standard Workflow (Always Use This Order)

**1. Install Dependencies** (Required first step):
```bash
flutter pub get
```
⚠️ **ALWAYS run this before any other command** after cloning or when pubspec.yaml changes.

**2. Format Code** (Pre-commit requirement):
```bash
dart format .
```
This modifies files in place. CI checks formatting with:
```bash
dart format --set-exit-if-changed .
```
If this fails in CI, formatting is incorrect.

**3. Static Analysis** (Pre-commit requirement):
```bash
flutter analyze
```
Must pass with zero errors/warnings before committing.

**4. Run Tests** (Pre-commit requirement):
```bash
flutter test --coverage
```
Generates coverage in `coverage/lcov.info`. Takes ~30-60 seconds.

**5. Full Verification** (Recommended before PR):
```bash
make verify
```
Runs format, analyze, and test in sequence. This is equivalent to the CI checks.

### Build Commands

```bash
flutter build web --release        # Build for production (2-3 min)
flutter run -d chrome              # Run in Chrome for testing
./dev.sh                          # Dev server on :51538 (needs .env with GOOGLE_MAPS_API_KEY)
```

### Docker Commands

```bash
docker build -f docker/Dockerfile -t tracker-frontend:latest .  # 5-10 min
docker run -p 51538:51538 -e GOOGLE_MAPS_API_KEY=key tracker-frontend:latest
cd docker && docker-compose up    # Needs .env file
```

### Makefile Shortcuts

- `make verify` - Format + analyze + test (use before PR)
- `make format/analyze/test/clean/build/run/docker` - Individual commands

## Project Structure & Architecture

### Directory Layout

```
tracker-frontend/
├── lib/
│   ├── core/
│   │   ├── config/          # Configuration (API endpoint resolution)
│   │   └── constants/       # API endpoints, enums
│   ├── data/
│   │   ├── client/          # HTTP client wrapper
│   │   ├── models/          # Data models (requests/responses/domain)
│   │   ├── repositories/    # Data repositories
│   │   ├── services/        # API service classes (6 services)
│   │   └── storage/         # Local storage (token storage)
│   ├── presentation/
│   │   ├── helpers/         # UI helpers
│   │   ├── screens/         # App screens (Home, CreateTrip, TripDetail, etc.)
│   │   └── widgets/         # Reusable widgets
│   └── main.dart           # App entry point
├── test/                   # Mirror of lib/ structure with *_test.dart files
├── web/                    # Web-specific assets
│   ├── index.html          # Entry HTML (has environment variable placeholders)
│   ├── manifest.json       # Web app manifest
│   └── icons/              # App icons
├── docker/
│   ├── Dockerfile          # Multi-stage build (Flutter + nginx)
│   ├── docker-compose.yml  # Compose configuration
│   ├── nginx/
│   │   └── nginx.conf      # Nginx config (port 51538, Flutter routing)
│   └── scripts/
│       └── docker-entrypoint.sh  # Environment variable injection script
├── android/                # Android-specific files
├── ios/                    # iOS-specific files
├── pubspec.yaml           # Dart dependencies and project metadata
├── analysis_options.yaml  # Dart analyzer configuration
├── Makefile               # Build automation
└── dev.sh                 # Local development script with env var injection
```

### Key Files

- **lib/core/constants/api_endpoints.dart**: API endpoints with conditional imports
- **lib/data/services/**: AuthService, UserService, TripService, CommentService, AchievementService, AdminService
- **lib/main.dart**: Entry point → InitialScreen
- **pubspec.yaml**: Version format: `x.y.z-SNAPSHOT+build` (dev), `x.y.z+build` (release)
- **analysis_options.yaml**: Uses flutter_lints
- **.gitignore**: Excludes `.env`, `build/`, `.dart_tool/`, `coverage/`, `web/index.html.template`

## Environment Variables & Configuration

### Development (dev.sh)
Requires `.env` file (NOT `.env.local`):
```
GOOGLE_MAPS_API_KEY=your_key
# Optional with defaults:
COMMAND_BASE_URL=http://localhost:8081/api/1
QUERY_BASE_URL=http://localhost:8082/api/1
AUTH_BASE_URL=http://localhost:8083/api/1
```

Script creates `web/index.html.template`, injects variables, runs on port 51538, restores on exit.
⚠️ Never commit `.env` or `web/index.html.template` (gitignored).

### Docker
Similar runtime injection via `docker/scripts/docker-entrypoint.sh` with same env vars and defaults.

## CI/CD & GitHub Workflows

### Feature Branch CI (.github/workflows/ci.yml)
Triggers: Push to non-master branches. Duration: ~5-7 min.

Steps: Setup Flutter 3.35.7 → pub get → format check (fails if not formatted) → analyze (fails on warnings) → test with coverage → Docker build (ci-test tag).

### Master Branch (.github/workflows/merge.yml)
Triggers: Push to master. Duration: ~8-12 min.

Steps: Version management (remove -SNAPSHOT, tag) → test → update README badges → build web → create release → increment version → push → Docker build (latest tag).

### Docker Build (.github/workflows/docker-build.yml)
Reusable workflow. Uses Flutter 3.27.1.

## Common Issues & Workarounds

1. **Format check fails in CI**: Run `dart format .` locally and commit.
2. **Test failures**: Ensure `flutter pub get` was run. Tests mirror `lib/` structure in `test/`.
3. **dev.sh fails**: Create `.env` (not `.env.local`) with `GOOGLE_MAPS_API_KEY` at repo root.
4. **Docker slow/fails**: Clean build takes 5-10 min, needs ~2GB space. Uses GitHub Actions cache.
5. **Port 51538 in use**: `lsof -ti:51538 | xargs kill -9`

## Testing Strategy

Tests mirror `lib/` in `test/` (client, core, models, repositories, services, storage).

```bash
flutter test --coverage                           # All tests
flutter test test/models/auth_models_test.dart   # Specific file
flutter test --verbose                           # Verbose
make test-watch                                  # Watch mode
```

Coverage: ~41%. CI uploads to Codecov.

## Dependencies

**Prod:** http ^1.2.0, shared_preferences ^2.2.2, google_maps_flutter ^2.5.0, geolocator ^14.0.2
**Dev:** flutter_test, flutter_lints ^6.0.0, mockito ^5.4.4, build_runner ^2.4.8

## Best Practices

1. **Always `flutter pub get` first** after pubspec.yaml changes or clone
2. **Format before commit**: `dart format .` to avoid CI failures
3. **Use `make verify`** before PR (runs CI checks)
4. **Never commit `.env`** - create locally as needed
5. **Don't manually update version** in pubspec.yaml (merge workflow handles it)
6. **Test Docker locally**: `make docker` before pushing
7. **Preserve placeholders** in `web/index.html`: `{{GOOGLE_MAPS_API_KEY}}`, etc.
8. **Zero warnings required**: `flutter analyze` must be clean
9. **Add tests**: Maintain/improve 41% coverage
10. **Follow structure**: Models in `lib/data/models/`, services in `lib/data/services/`, etc.

## Trust These Instructions

These instructions are comprehensive and tested. Only search for additional information if:
- These instructions are incomplete for your specific task
- You encounter an error not documented here
- You need to understand implementation details beyond structure

For standard build, test, and deployment tasks, follow these instructions exactly.
