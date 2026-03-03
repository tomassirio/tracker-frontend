# Google API Usage Audit — What Can We Remove?

**Date:** March 2026  
**Context:** The backend now computes and returns `encodedPolyline` on Trip responses. This document audits all Google API touchpoints in the frontend to identify what can be removed, what stays, and what changes.

---

## TL;DR

| Component | Status | Reason |
|-----------|--------|--------|
| `GoogleRoutesApiClient` | 🟡 **Keep for now** (fallback only) | Still used as fallback when backend polyline is `null`. Can be removed once backend covers all cases (100% of trips and plans). |
| `DirectionsService` | 🟡 **Keep for now** (fallback only) | Wraps `GoogleRoutesApiClient` with segment caching. Same removal timeline. |
| `DirectionsServiceWeb` / `directions_service_stub.dart` | 🟡 **Keep for now** | Web-specific directions. Same removal timeline as `DirectionsService`. |
| `GoogleMapsApiClient` | ✅ **Keep** | Generates Static Maps API URLs for card miniatures. This is a URL builder, not an API caller — the browser/image widget fetches the image. Still needed. |
| `GoogleGeocodingApiClient` | 🔴 **REMOVED** | Reverse-geocoding moved to backend. Trip updates now include `city` and `country` fields populated server-side. |
| `google_maps_flutter` package | ✅ **Keep** | The interactive map widget on trip detail, trip plan detail, and create-trip-plan screens. |
| `GOOGLE_MAPS_API_KEY` env var | ✅ **Keep** | Still needed for: Google Maps tiles (interactive + static). Geocoding is now handled by backend. |
| `web/index.html` Maps JS SDK | ✅ **Keep** | Required by `google_maps_flutter_web` for the interactive map widget on web. |

---

## Detailed Analysis

### 1. `GoogleRoutesApiClient` (`lib/data/client/google_routes_api_client.dart`)

**What it does:** Calls the Google Routes API v2 to compute walking/driving routes. Also has static `encodePolyline()` / `decodePolyline()` utility methods.

**Current consumers:**
- `DirectionsService` — segment-by-segment routing
- `TripRouteHelper` — fallback when backend polyline is `null`
- `TripMapHelper` — fallback when backend polyline is `null`
- `TripPlanCard` — fallback when backend polyline is `null` (prefers backend `encodedPolyline`)
- `TripPlanMapHelper` — fallback when backend polyline is `null` (prefers backend `encodedPolyline`)

**Can we remove it?**
- **Not yet.** The `encodePolyline()` / `decodePolyline()` static methods are still used everywhere. The API-calling parts (`getWalkingRoute`, `_computeRoutes`) are only needed as fallback.
- **When backend covers 100% of trips and plans**, we could split this into:
  - `polyline_codec.dart` — keep encode/decode utilities
  - Remove the HTTP client / API calling code entirely

**Action:** No change now. Candidate for removal in Phase 4 (once backend covers 100% of polylines).

---

### 2. `DirectionsService` (`lib/data/services/directions_service.dart`)

**What it does:** Wraps `GoogleRoutesApiClient` with segment-level caching. Computes routes segment-by-segment between consecutive waypoints.

**Current consumers:**
- `TripRouteHelper.fetchEncodedPolyline()` — fallback path
- `TripMapHelper._addDirectionsPolyline()` — fallback when no backend polyline
- `TripPlanMapHelper._addDirectionsPolyline()` — fallback when no backend polyline
- `TripPlanCard._loadRoute()` — fallback when no backend polyline

**Can we remove it?**
- **Not yet.** Same situation as `GoogleRoutesApiClient`. Needed as fallback when `encodedPolyline` is `null`.
- The segment cache becomes less valuable as backend polylines cover more trips.

**Action:** No change now. Same Phase 4 removal timeline.

---

### 3. `DirectionsServiceWeb` + `directions_service_stub.dart`

**What it does:** Web-specific Directions Service using the Google Maps JavaScript API. The stub is for non-web platforms.

**Action:** Same timeline as `DirectionsService`. Remove when all routing moves to backend.

---

### 4. `GoogleMapsApiClient` (`lib/data/client/google_maps_api_client.dart`)

**What it does:** Builds URLs for the **Google Static Maps API** — generates image URLs for card miniatures. This is purely a URL builder, not an HTTP client. The actual image fetching happens via Flutter's `Image.network()`.

**Current consumers:**
- `TripCard._generateStaticMapUrl()`
- `EnhancedTripCard._generateStaticMapUrl()`
- `ProfileTripCard._generateStaticMapUrl()`
- `TripPlanCard._generateStaticMapUrl()`

**Can we remove it?**
- **No.** The Static Maps API is how we render card miniatures without embedding a full interactive map widget. The `encodedPolyline` from the backend is *passed to* the Static Maps URL — it doesn't replace the Static Maps API itself.

**Action:** Keep. This is still needed.

---

### 5. `GoogleGeocodingApiClient` (`lib/data/client/google_geocoding_api_client.dart`)

**Status:** 🔴 **REMOVED** (March 2026)

**What it did:** Reverse-geocoded coordinates to get city/country names for trip location enrichment.

**Previous consumers:**
- `TripDetailRepository` — enriched trip locations with place names
- `TripDetailScreen` — initialized the geocoding client

**Why removed:**
- **Backend now handles geocoding.** Trip updates now include `city` and `country` fields populated automatically at write time via reverse geocoding on the backend.
- The `TripLocation` model already supported these fields; they are now populated server-side.
- A new admin endpoint (`POST /api/1/admin/trips/{tripId}/recompute-geocoding`) was added to backfill existing trip updates.

**Action:** Removed in geocoding migration. No longer needed in frontend.

---

### 6. `google_maps_flutter` Package

**What it does:** Renders interactive Google Maps widgets with markers, polylines, camera controls.

**Used in:**
- `TripMapView` (trip detail screen)
- `CreateTripPlanScreen` (trip plan creation with map picker)
- `TripPlanDetailScreen` (trip plan detail view)

**Can we remove it?**
- **Absolutely not.** This is the core interactive map experience. The backend polyline just provides the *data* that gets rendered on this map.

**Action:** Keep.

---

### 7. `GOOGLE_MAPS_API_KEY` Environment Variable

**Used for:**
1. **Google Maps JavaScript SDK** (`web/index.html`) — required by `google_maps_flutter_web`
2. **Android Maps SDK** (`AndroidManifest.xml`) — required by `google_maps_flutter` on Android
3. **Static Maps API** — card miniature images (`GoogleMapsApiClient` URL builder)
4. ~~**Geocoding API** — reverse geocoding (`GoogleGeocodingApiClient`)~~ ← **REMOVED: now handled by backend**
5. ~~**Routes API** — computing walking directions (`GoogleRoutesApiClient`)~~ ← **replaced by backend polylines**

**Can we remove it?**
- **No.** Even with backend handling polylines and geocoding, we still need the API key for items 1-3.
- The key's **required API permissions** can be reduced on the Google Cloud Console side: disable both the Routes API and Geocoding API on the frontend's key.

**Action:** Keep the env var. Restrict the key's API permissions in Google Cloud Console to only: Maps JavaScript API, Maps Static API.

---

### 8. `web/index.html` — Maps JavaScript SDK Script Tag

```html
<script src="https://maps.googleapis.com/maps/api/js?key={{GOOGLE_MAPS_API_KEY}}&libraries=places,geometry&callback=initGoogleMaps"></script>
```

**Can we remove it?**
- **No.** Required by `google_maps_flutter_web` to render interactive maps in the browser.

**Action:** Keep.

---

## Summary: What Changes Now vs. Later

### Now (Phase 2 — Backend polylines for trips) ✅
- `TripRouteHelper` checks `trip.encodedPolyline` first → **fewer Routes API calls**
- `TripMapHelper` decodes backend polyline instead of calling Directions API → **fewer Routes API calls**
- No files deleted, no env vars removed

### Now (Phase 3 — Backend polylines for trip plans too) ✅
- `TripPlanCard` and `TripPlanMapHelper` now use backend polylines when available
- Falls back to client-side Directions API when `encodedPolyline` is `null`
- This eliminates the last consumer of `DirectionsService` for routing (when backend covers all plans)

### Later (Phase 4 — Full cleanup, once backend covers 100% of polylines)

**Files that can be deleted:**
- `lib/data/services/directions_service.dart`
- `lib/data/services/directions_service_web.dart`
- `lib/data/services/directions_service_stub.dart`
- `test/services/directions_service_test.dart`

**Files that can be simplified:**
- `lib/data/client/google_routes_api_client.dart` — Extract `encodePolyline()` / `decodePolyline()` into a standalone `polyline_codec.dart`, then delete the rest (HTTP client, `getWalkingRoute`, `_computeRoutes`)
- `test/client/google_routes_api_client_test.dart` + `.mocks.dart` — Simplify to only test encode/decode
- `lib/presentation/helpers/trip_route_helper.dart` — Remove the DirectionsService fallback path
- `lib/presentation/helpers/trip_map_helper.dart` — Remove `_addDirectionsPolyline()` fallback

**Files that stay forever:**
- `lib/data/client/google_maps_api_client.dart` — Static Maps URL builder
- ~~`lib/data/client/google_geocoding_api_client.dart` — Reverse geocoding~~ ← **REMOVED: backend handles this now**
- `GOOGLE_MAPS_API_KEY` env var everywhere — Still needed for maps (interactive + static)
- `google_maps_flutter` package — Interactive maps

### Geocoding Migration (March 2026) ✅

**Removed:**
- `lib/data/client/google_geocoding_api_client.dart` — Deleted entirely
- `test/client/google_geocoding_api_client_test.dart` + `.mocks.dart` — Deleted
- Geocoding logic in `TripDetailRepository.loadTripUpdates()` — Simplified to just fetch from API

**Added:**
- Backend now populates `city` and `country` fields on trip updates automatically
- Admin endpoint: `POST /api/1/admin/trips/{tripId}/recompute-geocoding` — Backfills existing trip updates
- WebSocket event: `POLYLINE_UPDATED` — Real-time polyline updates after route computation
- `TripUpdatedEvent` extended with `city` and `country` fields for real-time updates

**Result:** Zero frontend geocoding API calls. All location enrichment happens server-side.

### Optional: Restrict Frontend API Key Permissions
Once the backend handles all Routes API calls and geocoding, you can go to the **Google Cloud Console** and remove the "Routes API" and "Geocoding API" permissions from the frontend's API key. This:
- Reduces the attack surface if the frontend key is ever leaked
- Makes it clear which key is responsible for which API
- The frontend key would only need: Maps JavaScript API, Maps Static API (geocoding and routing now on backend)

