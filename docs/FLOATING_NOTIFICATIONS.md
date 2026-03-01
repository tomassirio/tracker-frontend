# Floating Notification System

## Overview

The app now uses floating pill-shaped notifications instead of traditional SnackBars. These notifications appear at the bottom of the screen with a smooth slide-up animation and auto-dismiss after a configurable duration.

## Design

- **Shape**: Pill-shaped (fully rounded corners)
- **Colors**: Orange tones matching the app theme
- **Position**: Bottom of screen (80px from bottom)
- **Animation**: Slide up from bottom with fade-in
- **Auto-dismiss**: Configurable duration (default 2-3 seconds)

## Notification Types

### Success Notification
- **Color**: `#FF8C42` (Standard orange)
- **Icon**: ✓ check_circle
- **Duration**: 2 seconds
- **Usage**: Successful operations (trip created, comment added, settings saved)

### Error Notification
- **Color**: `#E85D3A` (Darker orange/red)
- **Icon**: ⚠ error
- **Duration**: 3 seconds
- **Usage**: Failed operations (network errors, validation errors, permission denied)

### Info Notification
- **Color**: `#FFB366` (Lighter orange)
- **Icon**: ℹ info
- **Duration**: 2 seconds
- **Usage**: Informational messages (feature not yet implemented, placeholder content)

### Warning Notification
- **Color**: `#FF9F5A` (Medium orange)
- **Icon**: ⚠ warning
- **Duration**: 2 seconds
- **Usage**: Warnings (minimum interval validation, data limitations)

## Implementation

### Basic Usage

```dart
// Success notification
UiHelpers.showSuccessMessage(context, 'Trip created successfully!');

// Error notification
UiHelpers.showErrorMessage(context, 'Failed to load data');

// Info notification
UiHelpers.showInfoMessage(context, 'Feature coming soon!');

// Custom duration
FloatingNotification.show(
  context,
  'Custom message',
  NotificationType.warning,
  duration: Duration(seconds: 5),
);
```

### Where Notifications Are Used

#### Trip Operations
- Create trip: Success/Error
- Delete trip: Success/Error
- Update trip: Success/Error
- Change trip status: Success/Error
- Update trip settings: Success/Error
- Send location update: Success/Error

#### User Operations
- Follow/unfollow user: Success/Error
- Send/cancel friend request: Success/Error
- Accept/decline friend request: Success/Error
- Update profile: Success/Error

#### Comments & Reactions
- Add comment: Success/Error
- Add reaction: Success/Error
- Delete comment: Success/Error

#### Admin Operations
- Promote/demote user: Success/Error
- Delete user: Success/Error
- Promote/unpromote trip: Success/Error

#### Other
- Not implemented features: Info
- Validation errors: Error/Warning

## Migration from SnackBar

All existing `ScaffoldMessenger.of(context).showSnackBar()` calls have been replaced with the new floating notification system through the `UiHelpers` class. This ensures consistent notification appearance across the entire app.

## Testing

Widget tests are available in `test/widgets/floating_notification_test.dart` that verify:
- Correct icon and color for each notification type
- Message display
- Auto-dismiss functionality
- Animation behavior
