# Statement of Work: Location Tracking Flutter App

## Project Overview
Build a cross-platform (Android & iOS) Flutter application that tracks user location at 5-minute intervals with persistent non-dismissible notifications and local storage.

---

## Functional Requirements

### 1. Dashboard Screen (Main UI)
**Components:**
- "Start Tracking" button
- "Stop Tracking" button  
- ListView displaying all saved tracking records

**Record Display Format:**
```
Time: 10:30 AM
Lat: 28.6139
Lng: 77.2090
Address: New Delhi, India
```

---

### 2. Start Tracking Flow

**Immediate Actions (on button press):**
1. Request location permissions (polished UI/UX)
2. Fetch current location (lat, lng)
3. Reverse geocode to get address
4. Save record to Hive local storage
5. Display persistent, non-dismissible notification with location data
6. Start background service using `workmanager`

**Ongoing Behavior (every 5 minutes):**
1. Fetch new location coordinates
2. Reverse geocode address
3. Save to Hive
4. Update persistent notification (replace, not stack)
5. Continue until explicitly stopped by user via app or notification action

**Notification Specifications:**
- **Type**: Persistent/ongoing, non-dismissible notification (foreground service on Android)
- **Update behavior**: Replace existing (single notification, constant ID)
- **Content**: "Lat: X, Lng: Y, Address: Z"
- **Actions**: "Stop Tracking" button embedded in notification
- **User Interaction**: 
  - User CANNOT swipe away/dismiss notification while tracking is active
  - Only way to stop: Tap "Stop Tracking" button in app OR notification action
  - Notification automatically removed only when tracking stops

---

### 3. Stop Tracking Flow

**Trigger Points:**
- User taps "Stop Tracking" button in app UI
- User taps "Stop Tracking" action button in notification

**Actions on Stop:**
1. Cancel workmanager tasks immediately
2. **Delete ALL records** from Hive storage (hard requirement - no history retention)
3. Clear ListView in UI (remove all displayed items)
4. Dismiss persistent notification
5. Reset app state to initial (tracking OFF)

---

### 4. Background Service Requirements

**Implementation:**
- Use `workmanager` package for background execution
- **Does NOT run when app is force-killed** (clarified limitation)
- Runs reliably when app is in background/minimized
- Configured for 5-minute periodic tasks
- Maintains foreground service notification on Android

**Platform-Specific Notes:**
- **Android**: Foreground service with persistent notification (required for background location)
- **iOS**: Background location updates (works with user-granted location permission)

---

### 5. Location & Geocoding

**Location Services:**
- Package: `geolocator`
- Accuracy: Best available (high accuracy mode)
- Fallback: Handle permission denial gracefully with user-friendly error messages

**Reverse Geocoding:**
- Package: `geocoding` 
- Uses native Android Geocoder / iOS CoreLocation
- **Error Handling**: If geocoding fails → save record with "Address unavailable"
- No retry logic required for this assignment
- Handles offline/network failure scenarios gracefully without crashing

---

### 6. Permissions Handling

**Requirements:**
- Polished permission request flow with clear rationale explanations
- **NOT handling all edge cases** (permanently denied, denied forever scenarios not required)
- Minimum viable permission handling for assignment scope

**Platform Behaviors:**
- **Android**: 
  - Request `ACCESS_FINE_LOCATION` permission
  - Request notification permission (Android 13+)
  - Request foreground service permission
- **iOS**: 
  - Support both "While Using App" and "Always Allow" based on user's choice
  - Background location capability enabled
- **If permission denied**: Display clear error message, disable tracking button

---

### 7. Data Storage

**Technology:** Hive (local NoSQL storage)

**Data Model:**
```dart
@HiveType(typeId: 0)
class LocationRecord extends HiveObject {
  @HiveField(0)
  late DateTime timestamp;
  
  @HiveField(1)
  late double latitude;
  
  @HiveField(2)
  late double longitude;
  
  @HiveField(3)
  late String address;
}
```

**Persistence Rules:**
- New record saved every 5 minutes while tracking is active
- **ALL records permanently deleted when tracking stops** (no history retention - hard requirement)
- Data persists across app restarts (until Stop Tracking is pressed)
- Records displayed in ListView in reverse chronological order (newest first)

---

## Technical Architecture

### State Management
**Riverpod** (StateNotifier pattern recommended)

**State Structure:**
```dart
- TrackingState (isTracking, locationRecords)
- LocationService (geolocator wrapper)
- NotificationService (local notifications)
- StorageService (Hive operations)
- WorkManagerService (background task scheduling)
```

### Key Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  
  # Location & Geocoding
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Background Work
  workmanager: ^0.5.2
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  
  # Permissions
  permission_handler: ^11.0.1

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

### Platform Support
- **Android**: Minimum SDK 24+ (Android 7.0) - Required for workmanager reliability
- **iOS**: Minimum iOS 12+
- Both platforms fully supported with feature parity

---

## Non-Functional Requirements

### 1. Performance
- Notification updates within 10 seconds of location fetch
- UI remains responsive during location operations
- Efficient battery usage (5-minute intervals, not continuous polling)
- ListView smooth scrolling even with 50+ records

### 2. Error Handling
- Graceful geocoding failures (display "Address unavailable")
- Handle location service disabled (show actionable error)
- Handle permission denial (clear user guidance)
- **Zero app crashes** under any error scenario
- Log errors for debugging (console logs acceptable)

### 3. UX Polish
- Permission requests with clear, user-friendly rationale text
- Loading indicators during initial location fetch
- Visual feedback for tracking state (button states, colors)
- Empty state message in ListView when no records exist
- Confirmation dialog before clearing all data (optional but recommended)

---

## Platform-Specific Implementation Details

### Android Configuration

**AndroidManifest.xml Requirements:**
```xml
<!-- Location Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Foreground Service -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />

<!-- Notifications (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Wake Lock for background work -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

**Foreground Service:**
- Required for persistent non-dismissible notification
- Notification channel: High priority
- Service type: `location` (Android 14+)

### iOS Configuration

**Info.plist Requirements:**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track and save your position every 5 minutes.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need continuous location access to track your position in the background every 5 minutes.</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
    <string>processing</string>
</array>
```

**Capabilities:**
- Enable Background Modes: Location updates
- Enable Background fetch

---

## Out of Scope

❌ Tracking when app is force-killed by user/OS  
❌ Comprehensive edge case handling (permission permanently denied recovery flows)  
❌ Data retention/history after Stop Tracking  
❌ Export data functionality (CSV, JSON)  
❌ Map visualization of tracking points  
❌ Location accuracy configuration options  
❌ Custom notification sounds/vibration patterns  
❌ Multi-user support  
❌ Cloud sync/backup  
❌ Tracking statistics/analytics  
❌ Geofencing capabilities  

---

## Deliverables

### 1. Complete Flutter Project
- Clean, maintainable code following Flutter best practices
- Riverpod state management implementation
- Proper error handling throughout
- Code comments for complex logic
- Working on both Android & iOS physical devices

### 2. Platform Configurations
- **Android**: 
  - Properly configured AndroidManifest.xml
  - Foreground service implementation
  - Notification channels setup
  - ProGuard rules (if needed)
  
- **iOS**: 
  - Info.plist with all required keys
  - Background modes enabled
  - Proper capability configuration

### 3. Documentation
- README.md with setup instructions
- Platform-specific setup notes
- Known limitations clearly documented

### 4. Testing Evidence
- Manual testing performed on both platforms
- Test scenarios:
  - Permission grant/denial
  - Geocoding failure
  - Background execution
  - Notification interaction
  - Data persistence across app restarts
  - Stop tracking data cleanup

---

## Development Approach

### Architecture Pattern
```
lib/
├── main.dart
├── models/
│   └── location_record.dart (Hive model)
├── providers/
│   ├── tracking_provider.dart
│   ├── location_provider.dart
│   └── storage_provider.dart
├── services/
│   ├── location_service.dart
│   ├── notification_service.dart
│   ├── storage_service.dart
│   └── workmanager_service.dart
├── screens/
│   └── dashboard_screen.dart
└── widgets/
    ├── tracking_button.dart
    └── location_record_tile.dart
```

### State Management Flow
```
User Action → Provider → Service Layer → Update State → UI Rebuilds
```

---

## Critical Implementation Notes

### Android Considerations
1. **Foreground Service Mandatory**: Required for non-dismissible notification
2. **Battery Optimization**: May need to guide users to whitelist app
3. **Doze Mode**: Workmanager handles this, but 5-min interval might drift
4. **Android 14+**: Requires explicit foreground service type declaration

### iOS Considerations  
1. **Background Location**: Only works if user grants "Always Allow" permission
2. **Significant Location Changes**: iOS may batch location updates to save battery
3. **Background Execution Limits**: iOS restricts background time; workmanager may be delayed
4. **App Store Review**: Background location requires clear justification in review

### Workmanager Behavior
- **Not guaranteed exact 5-minute intervals** (OS may delay for battery optimization)
- Approximate intervals: 5-10 minutes in practice
- **Will NOT run if app is force-killed** (by design, clarified requirement)
- Android: More reliable than iOS for background tasks

### Notification Persistence
- **Android**: Achieved via foreground service (cannot be dismissed while service runs)
- **iOS**: Notifications can technically be dismissed, but tracking continues independently
- Notification shows "Tracking Active" status with latest location data

---

## Known Limitations & Constraints

1. **App Force-Kill**: Tracking stops completely (by design)
2. **Exact Timing**: 5-minute intervals are approximate due to OS battery optimization
3. **Geocoding**: 
   - Rate limits exist but unlikely at 5-min intervals
   - Requires internet connection
   - May fail in remote areas with poor data coverage
4. **iOS Background**: Less reliable than Android due to OS restrictions
5. **Battery Impact**: Continuous location tracking drains battery (expected behavior)
6. **No Data History**: All data deleted on stop (cannot be recovered)

---

## Success Criteria

### Functional
✅ Start Tracking initiates location fetching and notifications  
✅ Location updates every ~5 minutes while tracking  
✅ Persistent, non-dismissible notification displayed  
✅ All data saved to Hive successfully  
✅ Stop Tracking clears all data and stops service  
✅ ListView displays all saved records correctly  
✅ Works on both Android and iOS  

### Technical
✅ No crashes or ANRs  
✅ Proper permission handling  
✅ Graceful error handling  
✅ Clean Riverpod state management  
✅ Notification action triggers stop correctly  

---

## Timeline Estimate (For Reference)

**Development Time**: 12-16 hours
- UI & Riverpod setup: 2 hours
- Location & Geocoding integration: 3 hours
- Workmanager background service: 4 hours
- Notification system: 3 hours
- Hive storage & data management: 2 hours
- Testing & bug fixes: 2-4 hours

---

**This SOW is built exactly to specification with no assumptions. The persistent non-dismissible notification requirement is clear, as is the complete data deletion on stop. Riverpod state management is locked in. Build exactly this.**
