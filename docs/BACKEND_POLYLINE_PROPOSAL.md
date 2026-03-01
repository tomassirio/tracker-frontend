# RFC: Backend-Computed Encoded Polylines for Trips

**Date:** March 2026  
**Author:** Frontend Team  
**Status:** Proposal  
**Audience:** Backend Team, Frontend Team

---

## 1. Problem Statement

Currently, the **frontend** is responsible for computing road-snapped polylines for every trip. When rendering a trip card miniature or the trip detail map, the Flutter app:

1. Sorts the trip's locations chronologically
2. Calls the **Google Routes API** segment-by-segment (location₁→location₂, location₂→location₃, …)
3. Receives detailed road-snapped points for each segment
4. Encodes the combined result as a [Google Encoded Polyline](https://developers.google.com/maps/documentation/utilities/polylinealgorithm)
5. Uses that encoded string to render both the interactive map and the Static Maps API miniature

### Current Pain Points

| Problem | Impact |
|---------|--------|
| **Redundant API calls** | Every client that views a trip independently calls Google Routes API for the same segments. If 100 users view a trip, that's up to 100× the same API calls. |
| **Cost** | Google Routes API charges per request. Frontend-driven routing multiplies cost by number of viewers. |
| **Latency** | Trip cards render without a polyline initially, then "pop in" after the async route computation finishes. Users see a flash of empty/straight-line maps. |
| **API key exposure** | The Google Maps API key must be embedded in the frontend (currently injected at build/deploy time). Moving routing to the backend confines the key to server-side only. |
| **Inconsistency** | Different clients may get slightly different routes if Google changes routing between calls, or if a client falls back to straight lines due to rate limiting. |
| **Offline/low-bandwidth** | Mobile clients on poor connections may fail to fetch routes entirely, showing degraded miniatures. |

### Current Mitigations (Frontend)

We've implemented two layers of caching to reduce the damage:

- **Segment cache** (`DirectionsService._segmentCache`): Caches individual A→B route segments in memory. Adding a new location to a trip only requires one new API call for the last segment.
- **Trip polyline cache** (`TripRouteHelper._polylineCache`): Caches the full encoded polyline per trip ID. Navigating back from trip detail to the list reuses it instantly.

But these caches are **in-memory only** — they're lost on app restart and are per-client.

---

## 2. Proposed Solution

**The backend computes and stores the encoded polyline whenever a trip's locations change**, and returns it as a field on the Trip response. The frontend simply reads it and renders — no Google API calls needed for polyline rendering.

### 2.1 New Field on Trip Response

```json
{
  "id": "trip-123",
  "name": "Round Utrecht",
  "locations": [ ... ],
  "encodedPolyline": "a~l~Fjk~uOwHJy@P??fHzR...",
  "polylineUpdatedAt": "2026-03-01T14:30:00Z",
  ...
}
```

| Field | Type | Description |
|-------|------|-------------|
| `encodedPolyline` | `String?` | [Google Encoded Polyline Algorithm](https://developers.google.com/maps/documentation/utilities/polylinealgorithm) string representing the full road-snapped route through all locations, sorted chronologically. `null` if the trip has 0–1 locations or if computation hasn't completed yet. |
| `polylineUpdatedAt` | `DateTime?` | Timestamp of when the polyline was last recomputed. Useful for cache invalidation and debugging. |

### 2.2 When to Compute

The polyline should be **(re)computed** whenever the ordered set of locations changes:

| Event | Action |
|-------|--------|
| **Trip update added** (new location) | Compute only the **new segment** (previous last location → new location) and **append** it to the existing polyline. |
| **Trip update deleted** | Recompute the **full polyline** from all remaining locations (sorted chronologically). |
| **Trip update reordered** (if ever supported) | Recompute the **full polyline**. |
| **Trip created with 0-1 locations** | Set `encodedPolyline = null`. |
| **Trip created from plan** (with planned waypoints) | Compute polyline from planned start → waypoints → end. |

### 2.3 Incremental Segment Appending (Key Optimization)

This is the most important optimization. When a user adds a new trip update (the most common operation), the backend should **not** recompute the entire polyline from scratch. Instead:

```
Existing polyline:  A ──road──> B ──road──> C
New location added: D

Backend computes ONLY: C ──road──> D  (one API call)
Result: Append the new segment's points to the existing polyline
Updated polyline:   A ──road──> B ──road──> C ──road──> D
```

#### How This Works with Encoded Polylines

An encoded polyline is a sequence of delta-encoded lat/lng pairs. To append a new segment:

1. **Decode** the existing polyline to get the list of `(lat, lng)` points
2. The new segment from Google Routes API returns its own list of points: `[C, p1, p2, ..., D]`
3. **Skip the first point** of the new segment (it's the same as the last point of the existing polyline) to avoid duplicates
4. **Append** the remaining points
5. **Re-encode** the combined list

Alternatively, the backend can store the **decoded points** internally and only encode on response serialization, making appending trivial (just concatenate lists).

#### Pseudocode

```python
def on_trip_update_added(trip_id, new_location):
    trip = get_trip(trip_id)
    locations = sort_by_timestamp(trip.locations)
    
    if len(locations) < 2:
        trip.encoded_polyline = None
        return
    
    previous_last = locations[-2]  # second to last (was the last before this update)
    new_last = locations[-1]       # the newly added location
    
    if trip.encoded_polyline and trip.polyline_points:
        # INCREMENTAL: compute only the new segment
        new_segment = google_routes_api.get_walking_route(
            origin=previous_last,
            destination=new_last
        )
        # Append (skip first point to avoid duplicate)
        trip.polyline_points.extend(new_segment.points[1:])
        trip.encoded_polyline = encode_polyline(trip.polyline_points)
    else:
        # FULL RECOMPUTE: first time or after deletion
        trip.polyline_points = compute_full_route(locations)
        trip.encoded_polyline = encode_polyline(trip.polyline_points)
    
    trip.polyline_updated_at = now()
    save(trip)
```

### 2.4 Cacheability

Backend-computed polylines are **extremely cacheable**:

| Layer | Strategy |
|-------|----------|
| **Database** | Store `encodedPolyline` as a column on the trip table. It's just a string — no special storage needed. |
| **HTTP cache** | The Trip GET response can include `ETag` or `Last-Modified` based on `polylineUpdatedAt`. Clients can use `If-None-Match` / `If-Modified-Since` for conditional requests. |
| **CDN / API Gateway** | Trip responses with polylines can be edge-cached. The polyline only changes when locations change, so cache hit rate is very high for popular/finished trips. |
| **Frontend** | The frontend reads `encodedPolyline` from the Trip JSON — no separate API call needed. The existing `TripRouteHelper._polylineCache` becomes a simple local read cache. |

**Finished/completed trips** are especially cacheable since their locations never change — the polyline is computed once and served forever.

### 2.5 Async Computation (Optional but Recommended)

For trips with many locations, computing the full polyline can take several seconds (one Google API call per segment). The backend should handle this **asynchronously**:

1. When a trip update is added, **immediately return 202 Accepted** (as it does today)
2. Enqueue a background job to compute/update the polyline
3. Next time any client fetches the trip, the polyline is ready

If the polyline computation is still in progress, `encodedPolyline` is `null` and the frontend falls back to its existing client-side computation (which we'd keep as a fallback). This ensures zero degradation during the transition.

---

## 3. Frontend Changes

Once the backend provides `encodedPolyline`, the frontend changes are minimal:

### 3.1 Trip Model

```dart
class Trip {
  // ...existing fields...
  final String? encodedPolyline;
  final DateTime? polylineUpdatedAt;
  
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      // ...existing parsing...
      encodedPolyline: json['encodedPolyline'] as String?,
      polylineUpdatedAt: json['polylineUpdatedAt'] != null
          ? DateTime.parse(json['polylineUpdatedAt'])
          : null,
    );
  }
}
```

### 3.2 TripRouteHelper Update

```dart
static Future<String?> fetchEncodedPolyline(Trip trip) async {
  // 1. Backend-provided polyline (best case: zero API calls)
  if (trip.encodedPolyline != null) {
    _polylineCache[trip.id] = trip.encodedPolyline!;
    return trip.encodedPolyline;
  }
  
  // 2. In-memory cache (e.g., from a previous detail view)
  final cached = _polylineCache[trip.id];
  if (cached != null) return cached;
  
  // 3. Fallback: client-side computation (transition period / edge cases)
  // ...existing DirectionsService logic...
}
```

### 3.3 What the Frontend No Longer Needs to Do

- ❌ Call Google Routes API for trip card miniatures
- ❌ Call Google Routes API for trip detail polylines (if backend polyline exists)
- ❌ Manage segment-by-segment caching for already-computed trips
- ❌ Expose Google Maps API key for routing purposes

The frontend **still uses** the Google Maps API key for:
- Google Maps widget rendering (map tiles)
- Static Maps API (miniature images — these use `encodedPolyline` in the URL, not a routing call)
- Real-time routing during active trip recording (before the backend has computed the polyline)

---

## 4. API Contract Summary

### What We Need from the Backend

#### Trip GET Response — New Fields

```json
{
  "encodedPolyline": "a~l~Fjk~uOwHJy@P??fHzR...",
  "polylineUpdatedAt": "2026-03-01T14:30:00Z"
}
```

#### Computation Rules

1. **On trip update created**: Compute the new segment (prevLast→newLocation) and append to existing polyline. If no existing polyline, compute full route.
2. **On trip update deleted**: Recompute full polyline from remaining locations (sorted by timestamp).
3. **On trip created from plan**: Compute polyline from planned route waypoints.
4. **Locations must be sorted chronologically** (by `timestamp`, oldest first) before computing the route — this matches what the frontend detail screen shows.
5. **Use walking mode** for the Google Routes API calls (our trips are walking/hiking trips).

#### Encoding Format

Standard [Google Encoded Polyline Algorithm](https://developers.google.com/maps/documentation/utilities/polylinealgorithm):
- Precision: 1e-5 (5 decimal places)
- This is the same format returned by Google Routes API in `routes[0].polyline.encodedPolyline`
- The frontend can decode it for the interactive map and pass it directly to Static Maps API URLs

#### Edge Cases

| Case | Expected `encodedPolyline` |
|------|---------------------------|
| Trip with 0 locations | `null` |
| Trip with 1 location | `null` |
| Trip with 2+ locations | Encoded polyline string |
| Google Routes API failure | `null` (frontend falls back to client-side computation) |
| Computation in progress | `null` (frontend falls back) |

---

## 5. Migration Strategy

This can be rolled out **incrementally** with zero breaking changes:

### Phase 1: Backend computes + stores (no frontend changes)
- Backend starts computing polylines on trip update events
- Stores them in the database
- Includes `encodedPolyline` in Trip responses
- **Frontend ignores the field** (unknown fields are safely ignored in `fromJson`)

### Phase 2: Frontend reads backend polyline
- Frontend adds `encodedPolyline` to `Trip.fromJson`
- `TripRouteHelper.fetchEncodedPolyline` checks `trip.encodedPolyline` first
- Client-side computation becomes fallback only
- **Immediate benefits**: faster card rendering, fewer API calls, lower cost

### Phase 3: Backfill existing trips
- Run a one-time migration job to compute polylines for all existing trips with 2+ locations
- After backfill, the frontend fallback path is rarely hit

### Phase 4: (Optional) Remove frontend routing fallback
- Once all trips have backend-computed polylines, the frontend can optionally remove `DirectionsService` and `GoogleRoutesApiClient` routing code
- Keep only polyline decoding (`decodePolyline`) for rendering on the interactive map

---

## 6. Cost & Performance Impact

### Google Routes API Calls

| Scenario | Current (Frontend) | Proposed (Backend) |
|----------|-------------------|-------------------|
| Trip with 5 locations viewed by 50 users | 4 segments × 50 users = **200 calls** | 4 segments × 1 (backend) = **4 calls** |
| New location added to trip | 1 call per viewer who opens it | **1 call** (backend, on event) |
| Viewing finished trip | 4 calls per new app session | **0 calls** (cached in DB) |

**Estimated savings**: 95-99% reduction in Google Routes API calls for trips viewed by multiple users.

### Latency

| Scenario | Current | Proposed |
|----------|---------|----------|
| Trip card miniature render | 200-800ms (async route fetch) | **0ms** (polyline in JSON) |
| Trip detail map render | 200-800ms first visit | **0ms** (polyline in JSON) |
| New trip update added | N/A | Backend: ~200ms async (not blocking the user) |

---

## 7. Open Questions for Discussion

1. **Storage format**: Should the backend store the encoded polyline string directly, or store decoded points (as a JSON array of `[lat, lng]` pairs) and encode on serialization? Storing encoded is simpler; storing decoded makes appending easier.

2. **Async vs sync**: Should polyline computation block the trip update response, or happen asynchronously? We recommend async (don't block the 202 response).

3. **Retry/failure handling**: If the Google Routes API is temporarily unavailable, should the backend retry? How many times? Should it set a flag like `polylineStatus: "pending" | "computed" | "failed"`?

4. **Travel mode**: Currently we always use `WALK`. Should this be configurable per trip? If so, changing the travel mode would require a full recompute.

5. **Planned route polylines**: Should planned routes (from trip plans) also get pre-computed polylines? The trip plan card has the same miniature rendering issue.

6. **Rate limiting**: Does the backend need to rate-limit Google Routes API calls? (e.g., if 100 trips get updates simultaneously during a batch import)

---

## 8. References

- [Google Encoded Polyline Algorithm](https://developers.google.com/maps/documentation/utilities/polylinealgorithm)
- [Google Routes API v2 Documentation](https://developers.google.com/maps/documentation/routes)
- Frontend implementation: `lib/presentation/helpers/trip_route_helper.dart`
- Frontend segment caching: `lib/data/services/directions_service.dart`
- Frontend polyline encoding: `lib/data/client/google_routes_api_client.dart` (`encodePolyline` / `decodePolyline`)

