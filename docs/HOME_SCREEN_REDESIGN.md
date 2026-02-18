# Home Screen Redesign - Implementation Guide

## Overview
Complete UI/UX overhaul of the Home Screen with personalized feed, visibility badges, and intelligent prioritization.

## New Features

### 1. **Badge Components**
- **VisibilityBadge**: Shows trip visibility (Public/Protected/Private) with color-coded icons
- **StatusBadge**: Displays trip status with live pulsing indicator for IN_PROGRESS trips
- **RelationshipBadge**: Indicates relationship with trip owner (Friend/Following)

### 2. **Tabbed Navigation**
Three main tabs organize trips based on user relationship and purpose:

#### **My Trips Tab**
Organized by status with section headers:
- 🟢 Active Trips (IN_PROGRESS)
- ⏸️ Paused Trips
- 📝 Draft Trips (CREATED)
- ✅ Completed Trips (FINISHED)

#### **Feed Tab**
Personalized feed with intelligent prioritization:
- ⚡ Live Now (IN_PROGRESS trips from friends/following)
- 👥 Friends' Trips (PUBLIC + PROTECTED from friends)
- 👤 Following (PUBLIC from users you follow)

Priority Order:
1. Live trips from friends
2. Live trips from following
3. Recent trips from friends
4. Recent trips from following

#### **Discover Tab**
- 🌍 All public trips from the community
- Sorted by most recent

### 3. **Smart Filtering**
Filter chips for:
- **Status**: All / Live / Paused / Completed / Draft
- **Visibility** (My Trips only): Public / Protected / Private
- Real-time search across trip names and usernames

### 4. **Enhanced Trip Cards**
The new `EnhancedTripCard` widget displays:
- Map preview (actual locations or planned route)
- Status badge with live pulsing indicator
- Visibility badge
- Relationship badge (when viewing others' trips)
- Trip metadata (name, author, date, comments)
- Delete button (owner only)

### 5. **Visibility Rules**
| Visibility | Who Can See |
|------------|-------------|
| **PUBLIC** | Everyone |
| **PROTECTED** | Trip owner + Friends only |
| **PRIVATE** | Trip owner only |

## UI Components

### Badge Widgets
```dart
VisibilityBadge(visibility: Visibility.PUBLIC)
StatusBadge(status: TripStatus.IN_PROGRESS)
RelationshipBadge(type: RelationshipType.friend)
```

All badges support `compact: true` mode for showing icons only.

### Section Headers
```dart
FeedSectionHeader(
  title: 'Live Now',
  icon: Icons.flash_on,
  count: liveTrips.length,
  subtitle: 'Happening right now',
)
```

### Enhanced Trip Cards
```dart
EnhancedTripCard(
  trip: trip,
  onTap: () => navigateToDetail(trip),
  onDelete: () => deleteTrip(trip),
  relationship: RelationshipType.friend,
  showAllBadges: true,
)
```

## Data Layer Enhancements

### HomeRepository Extensions
New methods for relationship-based filtering:
- `getFriendsIds()`: Returns Set<String> of friend user IDs
- `getFollowingIds()`: Returns Set<String> of followed user IDs
- `getMyTrips()`: Returns user's own trips
- `getPublicTrips()`: Returns public trips for discovery

## Testing

New widget tests added:
- `test/widgets/home/visibility_badge_test.dart`
- `test/widgets/home/status_badge_test.dart`
- `test/widgets/home/relationship_badge_test.dart`

Run tests with:
```bash
flutter test test/widgets/home/
```

## Real-time Updates

WebSocket integration maintained:
- Trip status changes
- Trip updates (created/updated/deleted)
- Automatic re-categorization on status changes
- Live indicator pulsing animation

## Responsive Design

Grid layout adapts to screen width:
- **Mobile** (< 600px): 1 column
- **Tablet** (600-800px): 2 columns
- **Desktop** (800-1200px): 3 columns
- **Large Desktop** (> 1200px): 4 columns

## Empty States

Friendly empty states for:
- No trips yet (My Trips)
- Empty feed (follow users to populate)
- No public trips (Discover)
- Search with no results

## Not Logged In Experience

Users who are not logged in see:
- Welcome message with login button
- Discover tab showing public trips
- Encouragement to log in for personalized features

## Future Enhancements

While `getPersonalizedFeed()` API endpoint is not yet implemented on the backend, the UI is structured to easily integrate it when available. The current implementation uses:
- `loadTrips()` → `getAvailableTrips()` for logged-in users
- Client-side filtering by friends/following relationships
- Smart prioritization based on status and relationship

When backend implements `getPersonalizedFeed()`, simply replace the trip loading logic in `_loadTrips()` with a single API call.

## Color Scheme

### Status Colors
- **Live (IN_PROGRESS)**: Green (#4CAF50)
- **Paused**: Orange (#FF9800)
- **Completed**: Blue (#2196F3)
- **Draft**: Grey (#9E9E9E)

### Visibility Colors
- **Public**: Green
- **Protected**: Orange
- **Private**: Red

### Relationship Colors
- **Friend**: Blue
- **Following**: Purple

## Accessibility

All badges include:
- Descriptive icons
- Text labels (can be hidden in compact mode)
- Color AND icon for information (not color alone)
- Proper semantic structure
