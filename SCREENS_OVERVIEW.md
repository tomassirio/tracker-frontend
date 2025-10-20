# UI Screens Overview

This document provides a visual description of the implemented UI screens.

## 1. Home Screen

**Purpose**: Main screen showing all user trips

**Layout**:
- App bar with "My Trips" title
- List of trip cards showing:
  - Status icon (color-coded)
  - Trip title (bold)
  - Description (truncated to 2 lines)
  - Status chip (PLANNED, ONGOING, PAUSED, FINISHED)
  - Visibility chip (PRIVATE, PROTECTED, PUBLIC)
  - Chevron right icon to indicate tap-ability
- Floating action button with "Create Trip" label
- Empty state when no trips exist (large explore icon + message)
- Pull-to-refresh functionality
- Error state with retry button

**Interactions**:
- Tap a trip card → Navigate to Trip Detail Screen
- Tap FAB → Navigate to Create Trip Screen
- Pull down → Refresh trips list

**Status Colors**:
- 🟢 Green: ONGOING
- 🔵 Blue: PLANNED
- 🟠 Orange: PAUSED
- ⚪ Grey: FINISHED

---

## 2. Create Trip Screen

**Purpose**: Form to create a new trip

**Layout**:
- App bar with "Create New Trip" title and back button
- Scrollable form with:
  
  **Trip Title** (Required)
  - Text field with icon
  - Validation: Cannot be empty
  - Hint: "e.g., European Summer Adventure"
  
  **Description** (Optional)
  - Multi-line text field (3 lines)
  - Hint: "Tell us about your trip..."
  
  **Visibility** (Required)
  - Segmented button control with 3 options:
    - 🔒 Private: "Only you can see this trip"
    - 👥 Protected: "Followers or users with a shared link can view"
    - 🌐 Public: "Everyone can see this trip"
  - Description text below showing selected visibility explanation
  
  **Dates** (Optional)
  - Start Date card with calendar icon
    - Shows selected date or "Not set"
    - Clear button (X) when date is set
    - Tap to open date picker
  - End Date card with event icon
    - Shows selected date or "Not set"
    - Clear button (X) when date is set
    - Tap to open date picker
  
  **Create Button**
  - Full-width elevated button at bottom
  - Shows "Creating..." with spinner when loading
  - Disabled while loading

**Interactions**:
- Fill form fields → Validation feedback
- Tap visibility option → Update selection
- Tap date card → Open date picker
- Tap Create → Validate and submit
- Success → Show success snackbar and return to home
- Error → Show error snackbar

---

## 3. Trip Detail Screen

**Purpose**: View trip details and manage location updates on an interactive map

**Layout**:

**App Bar**:
- Title: Trip name
- Back button
- Three-dot menu with status options:
  - ▶️ Start Trip (ONGOING)
  - ⏸️ Pause Trip (PAUSED)
  - ✅ Finish Trip (FINISHED)

**Trip Info Card**:
- Description text (if available)
- Status chip with icon
- Visibility chip with icon
- Location update count

**Interactive Map** (Expanded):
- Google Maps view showing:
  - Red markers for all location updates (numbered)
  - Green marker for most recent location
  - Blue polyline connecting all locations in order
  - "My Location" button to center on current position
  - Zoom controls
  - Tap marker → Show info window with update message

**Add Location Section** (Fixed at bottom):
- Shadow overlay for depth
- Optional message text field
  - Multi-line (2 lines)
  - Hint: "Add a message (optional)..."
  - Message icon prefix
- "Add Current Location" button
  - Full-width elevated button
  - Location pin icon
  - Shows "Getting location..." with spinner when loading
  - Requests location permission if needed

**Interactions**:
- Tap status menu → Change trip status
- Pan/zoom map → Explore locations
- Tap marker → View update info
- Enter message → Optional text for location
- Tap Add Location → Get GPS coordinates and submit
- Success → Update map with new marker and polyline
- Error → Show error snackbar

**Map Features**:
- Smooth camera animations when adding new locations
- Automatic zoom to show all markers when trip loads
- Route visualization with connected polylines
- Info windows showing update messages
- Current location indicator

---

## Color Scheme

The app uses Material 3 design with:
- **Primary Color**: Deep Purple (from ColorScheme.fromSeed)
- **App Bar**: Inverse primary color
- **Cards**: Material surface color with elevation
- **Success**: Green snackbars
- **Error**: Red snackbars
- **Status Colors**: As defined in Home Screen section

## Typography

- **Titles**: Bold, larger font
- **Descriptions**: Regular weight, truncated with ellipsis
- **Chips**: Small font (11sp)
- **Body text**: Default Material theme

## Navigation

```
HomeScreen
├─→ CreateTripScreen (push)
│   └─→ HomeScreen (pop with result)
└─→ TripDetailScreen (push)
```

## Responsive Design

- All screens adapt to different screen sizes
- Scrollable content to prevent overflow
- Form fields expand to fill available width
- Map takes maximum available space
- Bottom sheets and dialogs are properly sized

## Accessibility

- All interactive elements have sufficient tap targets
- Icons include semantic labels
- Form fields have labels and hints
- Error messages are descriptive
- Loading states are indicated clearly

## Empty States

**Home Screen Empty State**:
- Large explore icon (grey)
- "No trips yet" heading
- "Create your first trip to get started!" message

**No Locations on Map**:
- Map centered on default location (NYC)
- Zoomed out view
- "Add Current Location" prompt still visible

## Error Handling

- Network errors show error UI with retry button
- Form validation errors show inline
- Permission denials show explanatory snackbars
- API errors display user-friendly messages
