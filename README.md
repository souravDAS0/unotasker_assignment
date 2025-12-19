# 📍 Location Tracker - Flutter Assignment

A cross-platform Flutter application that tracks user location at 5-minute intervals with persistent notifications and local storage. Built with **Clean Architecture** and **Riverpod** state management.

## Project Overview

This app was developed as part of the Unotasker Flutter assignment to demonstrate proficiency in Flutter development, background services, state management, and architectural design patterns.

**Key Features:**

- Dashboard with Start/Stop tracking controls
- GPS location fetching with reverse geocoding
- Local notifications every 30 seconds
- Persistent data storage using Hive
- Background service for continuous tracking
- Clean Architecture with separation of concerns

---

## Features

### Dashboard Screen

- **Start Tracking Button**: Initiates location tracking with immediate location fetch
- **Stop Tracking Button**: Halts background service and clears all data
- **ListView Display**: Shows all saved location records in reverse chronological order
- **Custom UI Components**: Gradient buttons, custom app bar, and animated empty states

### Location Tracking

- Fetches current latitude, longitude using `geolocator`
- Reverse geocodes coordinates to human-readable addresses using `geocoding`
- Updates every **30 seconds** via background service
- Displays real-time tracking status

### Local Notifications

- Shows notification on tracking start with initial location
- Updates notification every 30 seconds with latest location
- Persistent notification (non-dismissible during tracking)
- Displays latitude, longitude, and address in notification body

### Data Persistence

- All location records saved to **Hive** local database
- Data persists across app restarts
- Automatic synchronization between main app and background service
- All data **cleared** when tracking stops

### Background Service

- Uses `flutter_background_service` for reliable background execution
- Runs in foreground mode on Android (persistent notification)
- Timer-based periodic execution (5-minute intervals)
- Continues tracking even when app is in background

---

## Tech Stack

| Category                   | Technology                         | Version    |
| -------------------------- | ---------------------------------- | ---------- |
| **Framework**              | Flutter                            | SDK ^3.9.0 |
| **State Management**       | Riverpod                           | 2.4.0      |
| **Location Services**      | Geolocator                         | 10.1.0     |
| **Geocoding**              | Geocoding                          | 2.1.1      |
| **Local Storage**          | Hive                               | 2.2.3      |
|                            | Hive Flutter                       | 1.1.0      |
| **Background Service**     | flutter_background_service         | 5.1.0      |
|                            | flutter_background_service_android | 6.2.7      |
|                            | flutter_background_service_ios     | 5.0.2      |
| **Notifications**          | flutter_local_notifications        | 19.0.0     |
| **Permissions**            | permission_handler                 | 11.0.1     |
| **Functional Programming** | dartz                              | 0.10.1     |
| **Date Formatting**        | intl                               | 0.20.2     |

---

## Architecture

This project follows **Clean Architecture** principles with three distinct layers:

### **Domain Layer** (Business Logic)

Pure Dart code with zero dependencies on Flutter or external packages.

- **Entities**: `LocationRecord` - Core business object
- **Repository Interfaces**: `LocationRepository` - Contracts for data operations
- **Use Cases**: Single-responsibility business actions
  - `StartTracking` - Orchestrates tracking initiation
  - `StopTracking` - Handles tracking termination
  - `UpdateLocation` - Periodic location updates
  - `GetLocationRecords` - Retrieves saved records
  - `CheckTrackingStatus` - Verifies service status

### **Data Layer** (Implementation Details)

Implements domain contracts with platform-specific code.

- **Models**: `LocationRecordModel` - Extends entities with JSON serialization
- **Data Sources**:
  - `LocationLocalDataSource` - Hive CRUD operations
  - `LocationRemoteDataSource` - Geolocator + Geocoding
  - `NotificationDataSource` - flutter_local_notifications wrapper
  - `BackgroundServiceDataSource` - flutter_background_service wrapper
- **Repository Implementation**: `LocationRepositoryImpl` - Coordinates all data sources

### **Presentation Layer** (UI)

Handles user interface and state management.

- **State Management**: Riverpod `StateNotifier`
- **Providers**: `TrackingNotifier` - Manages tracking state
- **Screens**: `DashboardScreen` - Main UI
- **Widgets**: `CustomAppBar`, `GradientButton`, `LocationRecordTile`, `EmptyStateWidget`

### **Dependency Injection**

All dependencies managed via Riverpod providers in `injection_container.dart`

---

## File Structure

```
lib/
├── main.dart                                    # App entry point + background service setup
├── injection_container.dart                     # Dependency injection (Riverpod providers)
│
├── core/                                        # Core utilities and constants
│   ├── constants/
│   │   ├── app_constants.dart                  # Tracking interval, notification IDs
│   │   └── app_theme.dart                      # App theme and colors
│   ├── errors/
│   │   ├── exceptions.dart                     # Custom exception classes
│   │   └── failures.dart                       # Failure classes for error handling
│   └── utils/
│       └── date_formatter.dart                 # Date/time formatting utilities
│
└── features/
    └── location_tracking/
        │
        ├── domain/                              # DOMAIN LAYER (Pure Dart)
        │   ├── entities/
        │   │   └── location_record.dart        # Core business entity
        │   ├── repositories/
        │   │   └── location_repository.dart    # Repository interface
        │   └── usecases/
        │       ├── start_tracking.dart         # Start tracking use case
        │       ├── stop_tracking.dart          # Stop tracking use case
        │       ├── update_location.dart        # Periodic update use case
        │       ├── get_location_records.dart   # Fetch records use case
        │       └── check_tracking_status.dart  # Status check use case
        │
        ├── data/                                # DATA LAYER (Implementation)
        │   ├── models/
        │   │   └── location_record_model.dart  # Model with JSON serialization
        │   ├── datasources/
        │   │   ├── location_local_datasource.dart       # Hive operations
        │   │   ├── location_remote_datasource.dart      # Geolocator + Geocoding
        │   │   ├── notification_datasource.dart         # Notification operations
        │   │   └── background_service_datasource.dart   # Background service
        │   └── repositories/
        │       └── location_repository_impl.dart        # Repository implementation
        │
        └── presentation/                        # PRESENTATION LAYER (UI)
            ├── providers/
            │   └── tracking_provider.dart       # Riverpod StateNotifier
            ├── state/
            │   └── tracking_state.dart          # UI state model
            ├── screens/
            │   └── dashboard_screen.dart        # Main dashboard screen
            └── widgets/
                ├── custom_app_bar.dart          # Custom app bar widget
                ├── gradient_button.dart         # Reusable gradient button
                ├── location_record_tile.dart    # ListView item widget
                └── empty_state_widget.dart      # Empty state display
```

---

## Key Implementation Details

### Background Service Configuration

- **Entry Point**: `@pragma('vm:entry-point')` function in `main.dart`
- **Isolate Independence**: Background service runs in separate isolate with own Hive instance
- **Timer-Based**: Uses `Timer.periodic` for exact 5-minute intervals
- **Foreground Mode**: Android service runs in foreground for reliability

### Hive JSON Storage Approach

- Uses `Box<String>` instead of typed `Box<LocationRecordModel>`
- Records serialized to JSON strings for better cross-isolate compatibility
- Avoids Hive TypeAdapter issues between isolates
- Manual JSON parsing with `toJsonString()` and `fromJsonString()` methods

### Cross-Isolate Data Synchronization

- Background service invokes `service.invoke('record_saved')` after each update
- Main isolate listens via `FlutterBackgroundService().on('record_saved')`
- Triggers `refreshBox()` method to close and reopen Hive box
- Forces fresh disk read to sync in-memory cache across isolates

### Notification System

- Notification channel created **before** service starts (critical for Android 8+)
- High priority, ongoing, non-dismissible notification
- Updates notification body with latest location data
- Notification ID: 1000 (constant across all operations)

### Permission Handling

- Requests location permission (fine/coarse)
- Requests background location permission for Android 10+
- Requests notification permission for Android 13+
- Graceful degradation if permissions denied

---

## Issues Faced & Solutions

### Issue 1: WorkManager 15-Minute Minimum Limitation

**Problem:**
The assignment required location updates every **30 seconds**, but `workmanager` package enforces a **15-minute minimum** for periodic tasks due to Android's battery optimization policies.

**Solution:**
Migrated to **`flutter_background_service`** which allows running a custom `Timer.periodic` with exact 5-minute intervals. This package enables true foreground service on Android, bypassing the 15-minute restriction.

**Trade-off:**
Foreground service requires persistent notification (which is actually a requirement), so this was the ideal solution.

---

### Issue 2: Dashboard Not Updating from Hive (Cross-Isolate Communication)

**Root Cause:**
The main app isolate and background service isolate each have their own Hive instance. When the background service writes location records to Hive, the main app's Hive instance maintains a stale in-memory cache and doesn't see the new data.

**Attempted Solutions:**

#### **Try 1: Listen to HiveBox using `watch()` method **

- **Approach**: Used Hive's `box.watch()` method to listen for changes
- **Result**: **Did not work**
- **Reason**: Hive's `watch()` only detects changes within the same isolate. Cross-isolate writes don't trigger watchers in other isolates.

#### **Try 2: Implement `service.invoke()` and `FlutterBackgroundService().on()` messaging **

- **Approach**:
  - Background service calls `service.invoke('record_saved')` after saving
  - Main isolate listens via `service.on('record_saved').listen(...)`
  - Trigger UI reload when message received
- **Result**: **Did not work reliably**
- **Reason**: Messages were delivered, but simply reloading records from the existing Hive box returned stale cached data. The in-memory cache wasn't being invalidated.
- **Note**: This implementation was kept for event notification purposes

#### **Try 3: Close and Reopen HiveBox to Force Fresh Disk Read **

- **Approach**: Created `refreshBox()` method in `LocationLocalDataSource`
  ```dart
  Future<void> refreshBox() async {
    await _box.close();           // Close box (flush cache)
    await Hive.openBox<String>(   // Reopen box (read from disk)
      AppConstants.locationBoxName
    );
  }
  ```
- **Result**: **SUCCESS!** ✅
- **Implementation Flow**:
  1. Background service writes to Hive and invokes `'record_saved'` message
  2. Main isolate receives message via `service.on('record_saved')`
  3. Main isolate calls `localDataSource.refreshBox()`
  4. Box closes (clearing in-memory cache) and reopens (forcing disk read)
  5. Main isolate calls `loadRecords()` which now gets fresh data
  6. UI updates with new location records

**Key Insight:**
Even with JSON storage in `Box<String>`, Hive's in-memory cache wasn't automatically syncing across isolates. Forcing the box to close and reopen on each update makes it read fresh data from disk, effectively treating the Hive file as the single source of truth for both isolates.

**Final Solution:**
Combination of `service.invoke()` messaging (for triggering) + `refreshBox()` cache invalidation (for data freshness) = reliable cross-isolate synchronization.

---

## Setup Instructions

### Prerequisites

- Flutter SDK ^3.9.0 or higher
- Dart SDK (included with Flutter)
- Android Studio / Xcode for platform development
- Physical device or emulator (location services required)

### Installation

1. **Clone the repository** (or download ZIP)

   ```bash
   cd unotasker_assignment
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure platform-specific permissions**

   #### Android (`android/app/src/main/AndroidManifest.xml`)

   Already configured with:

   - `ACCESS_FINE_LOCATION`
   - `ACCESS_COARSE_LOCATION`
   - `ACCESS_BACKGROUND_LOCATION`
   - `FOREGROUND_SERVICE`
   - `FOREGROUND_SERVICE_LOCATION`
   - `POST_NOTIFICATIONS`
   - `WAKE_LOCK`

   #### iOS (`ios/Runner/Info.plist`)

   Already configured with:

   - `NSLocationWhenInUseUsageDescription`
   - `NSLocationAlwaysAndWhenInUseUsageDescription`
   - `UIBackgroundModes` (location, fetch, processing)

4. **Run the app**

   ```bash
   flutter run
   ```

   Or for release build:

   ```bash
   flutter run --release
   ```

---

## How It Works

### Start Tracking Flow

1. User taps **"Start Tracking"** button
2. App requests location and notification permissions
3. `StartTracking` use case executes:
   - Fetches current GPS location (lat/lng)
   - Reverse geocodes to address
   - Creates `LocationRecord` entity
   - Saves to Hive local storage
   - Shows notification with location data
   - Starts background service
4. Background service begins `Timer.periodic` with 5-minute interval
5. UI updates to show tracking status and first record

### Background Service Operation

1. Every 30 seconds, `Timer.periodic` triggers
2. `UpdateLocation` use case executes in background isolate:
   - Fetches current location
   - Geocodes to address
   - Saves record to Hive
   - Updates notification with new location
   - Invokes `'record_saved'` message to main isolate
3. Main isolate receives message and refreshes UI

### Stop Tracking Flow

1. User taps **"Stop Tracking"** button
2. `StopTracking` use case executes:
   - Stops background service
   - Deletes **all** records from Hive
   - Clears notification
3. UI updates to show empty state

### Data Synchronization Mechanism

```
[Background Service Isolate]
    └─> Write to Hive (JSON string)
    └─> service.invoke('record_saved')
           ↓
[Main App Isolate]
    └─> service.on('record_saved').listen()
    └─> localDataSource.refreshBox()
          └─> box.close() + Hive.openBox()  [Force disk read]
    └─> loadRecords()
    └─> UI updates
```

---

## Permissions Required

### Android

| Permission                    | Purpose                                  |
| ----------------------------- | ---------------------------------------- |
| `ACCESS_FINE_LOCATION`        | High-accuracy GPS location               |
| `ACCESS_COARSE_LOCATION`      | Network-based location                   |
| `ACCESS_BACKGROUND_LOCATION`  | Location access when app in background   |
| `FOREGROUND_SERVICE`          | Run background service with notification |
| `FOREGROUND_SERVICE_LOCATION` | Foreground service for location tracking |
| `POST_NOTIFICATIONS`          | Show notifications (Android 13+)         |
| `WAKE_LOCK`                   | Keep service running                     |

### iOS

| Key                                            | Purpose                          |
| ---------------------------------------------- | -------------------------------- |
| `NSLocationWhenInUseUsageDescription`          | Location access when app is open |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | Location access in background    |
| `UIBackgroundModes` (location)                 | Background location updates      |

---

## Testing

### Test Location Tracking

1. Launch app on physical device (emulator may not support background location)
2. Grant all required permissions
3. Tap **"Start Tracking"**
4. Observe notification appears with current location
5. Wait 30 seconds (or use developer options to simulate time)
6. Verify notification updates with new location
7. Open app to see all records in ListView

### Test Background Service

1. Start tracking
2. Press Home button (minimize app)
3. Wait 30 seconds
4. Check notification updates
5. Reopen app - verify new records are visible

### Test Notifications

1. Start tracking
2. Pull down notification shade
3. Verify notification shows:
   - Title: "Tracking started @ HH:MM" or "Continuing tracking @ HH:MM"
   - Body: Lat/Lng + Address
4. Verify notification is persistent (cannot swipe away)
   - Although, in android 14+ true persistent notifications are gone, notifications with ongoing:true can also be swiped away

### Test Data Persistence

1. Start tracking, wait for few records
2. Close app
3. Reopen app
4. Verify tracking status is synced (status shows correctly)
5. Verify all records are still present

### Test Stop Functionality

1. Start tracking with multiple records
2. Tap **"Stop Tracking"**
3. Verify:
   - Notification disappears
   - All records cleared from UI
   - Background service stops
4. Reopen app - verify no records exist

---

## Known Limitations

| Limitation                        | Explanation                                                                                                                                 |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **No tracking when force-killed** | When user force-kills app from recent apps, OS terminates all services. This is by design on both Android and iOS for battery preservation. |
| **Geocoding requires internet**   | Address lookup needs network connection. Shows "Address unavailable" when offline.                                                          |
| **5-minute drift**                | OS battery optimization may delay timer execution by few seconds. Actual interval may be 5-10 minutes.                                      |
| **iOS background restrictions**   | iOS has stricter background execution policies than Android. May pause tracking when app is inactive for extended periods.                  |
| **Battery drain**                 | Continuous GPS tracking is battery-intensive. Expected behavior for location tracking apps.                                                 |

---

## Assignment Requirements Checklist

### Dashboard Screen

- [✓] Button: "Start Tracking"
- [✓] Button: "Stop Tracking"
- [✓] ListView: Showing saved tracking data
- [✓] Display format: Time, Lat, Lng, Address

### ON Tracking Behavior

- [✓] Immediately fetch: Latitude, Longitude, Address
- [✓] Send local notification on start
- [✓] Notification shows: Lat, Lng, Address
- [✓] Save data to local storage (Hive)
- [✓] Continue sending notification every 30 seconds
- [✓] **BONUS**: Uses `flutter_background_service`
- [✓] Each 30 seconds: Fetch → Save → Notify

### OFF Tracking Behavior

- [✓] Stop background timer/service
- [✓] Clear all saved tracking data
- [✓] Remove all displayed records from UI
- [✓] Stop notifications

### Bonus Features Implemented

- [✓] `flutter_background_service` (instead of basic Timer.periodic)
- [✓] Clean Architecture implementation
- [✓] Riverpod state management
- [✓] Custom UI with animations and gradient buttons
- [✓] Advanced cross-isolate Hive synchronization

---

## Developer Notes

**Assignment Context**: Developed for **Unotasker** Flutter Assignment

### Development Approach

- **Architecture First**: Started with domain layer (entities, use cases) before implementation
- **Separation of Concerns**: Each layer has clear responsibilities with dependency inversion
- **Error Handling**: Type-safe error handling using `Either<Failure, Success>` pattern
- **Testability**: Business logic isolated in use cases for easy unit testing
- **Scalability**: Clean architecture allows easy feature addition without coupling

### Clean Architecture Benefits

1. **Testable**: Domain layer can be tested without UI or databases
2. **Maintainable**: Changes in one layer don't affect others
3. **Flexible**: Easy to swap implementations (e.g., replace Hive with SQLite)
4. **Understandable**: Clear structure makes codebase easy to navigate

---

## License

This project is developed as an assignment for Unotasker. All rights reserved.

---

<!-- ## Acknowledgments

- Flutter team for excellent documentation
- Unotasker for the assignment opportunity
- Clean Architecture principles by Robert C. Martin (Uncle Bob)

--- -->

**Built with ❤️ using Flutter**
