# Timer Functionality Implementation

## Overview
The timer functionality has been successfully implemented as an extension to the existing Entry and Quick-Button system. This feature allows users to set a timer based on the substance's duration and receive notifications when the timer expires.

## Key Features

### 1. **Duration-based Timer**
- Each substance now has an optional `duration` field
- Duration is used to automatically calculate timer end time
- Default durations are provided for common substances:
  - Koffein: 4 hours
  - Cannabis: 2 hours
  - Alkohol: 2 hours
  - Vitamin D: 24 hours
  - Ibuprofen: 6 hours
  - Nikotin: 30 minutes
  - Melatonin: 8 hours
  - Paracetamol: 4 hours

### 2. **Timer in Entry Model**
- New timer fields in Entry model:
  - `timerStartTime`: When the timer was started
  - `timerEndTime`: When the timer will expire
  - `timerCompleted`: Whether the timer has been completed
  - `timerNotificationSent`: Whether notification has been sent
- Timer-related getters:
  - `hasTimer`: Check if entry has an active timer
  - `isTimerActive`: Check if timer is currently running
  - `isTimerExpired`: Check if timer has expired
  - `timerProgress`: Get completion progress (0.0 to 1.0)
  - `remainingTime`: Get remaining time as Duration
  - `formattedRemainingTime`: Get formatted remaining time string

### 3. **Timer Service**
- Centralized timer management
- Background timer checking every 30 seconds
- Automatic notification sending on timer expiry
- Timer start/stop functionality
- Duration parsing from various formats

### 4. **Enhanced UI Components**
- **Timer Indicator**: Shows current timer status with animated progress
- **Timer Progress Bar**: Visual progress bar for timer completion
- **Timer Checkbox**: Option to enable/disable timer when creating entries
- **Animated Timer Status**: Pulsing animation for active timers

### 5. **Notification Integration**
- Timer-specific notification channel
- Automatic notifications when timer expires
- Notification titles: "Timer abgelaufen"
- Notification body: "Die Wirkdauer von [Substanz] ist vorüber."

## Usage Examples

### Quick Entry with Timer
```dart
// User selects substance with duration
final substance = await substanceService.getSubstanceByName('Koffein');

// Create entry with timer automatically enabled
final entry = Entry.create(
  substanceId: substance.id,
  substanceName: substance.name,
  dosage: 100.0,
  unit: 'mg',
  dateTime: DateTime.now(),
);

// Start timer using duration from substance
await entryService.createEntryWithTimer(entry);
```

### Manual Timer Control
```dart
// Start timer manually
final timerService = TimerService();
final entryWithTimer = await timerService.startTimer(entry, 
  customDuration: Duration(hours: 3));

// Stop timer
await timerService.stopTimer(entryWithTimer);
```

## Database Schema Updates

### Entries Table
```sql
ALTER TABLE entries ADD COLUMN timerStartTime TEXT;
ALTER TABLE entries ADD COLUMN timerEndTime TEXT;
ALTER TABLE entries ADD COLUMN timerCompleted INTEGER NOT NULL DEFAULT 0;
ALTER TABLE entries ADD COLUMN timerNotificationSent INTEGER NOT NULL DEFAULT 0;
```

### Substances Table
```sql
ALTER TABLE substances ADD COLUMN duration INTEGER; -- Duration in minutes
```

## Technical Implementation

### 1. **Non-Breaking Changes**
- All existing functionality is preserved
- Timer fields are optional and default to null/false
- Backward compatibility maintained

### 2. **Database Migration**
- Database version incremented to 2
- Automatic migration adds new columns
- Default durations populated for existing substances

### 3. **Service Integration**
- Timer service initialized on app startup
- Integrated with existing notification service
- Background timer checking for expired timers

### 4. **UI Integration**
- Timer indicators added to entry cards
- Timer options in quick entry dialog
- Timer section in add entry screen

## Testing

A test file is provided to verify timer functionality:
```bash
dart test/timer_test.dart
```

## Future Enhancements

1. **Custom Timer Durations**: Allow users to set custom timer durations
2. **Multiple Timers**: Support for multiple concurrent timers
3. **Timer History**: Track timer completion history
4. **Advanced Notifications**: Rich notifications with actions
5. **Timer Statistics**: Analytics on timer usage and completion rates

## Files Modified

- `lib/models/entry.dart` - Added timer fields and methods
- `lib/models/substance.dart` - Added duration field
- `lib/services/timer_service.dart` - New timer management service
- `lib/services/notification_service.dart` - Added timer notifications
- `lib/services/database_service.dart` - Database schema updates
- `lib/services/entry_service.dart` - Timer-enabled entry creation
- `lib/widgets/timer_indicator.dart` - New timer UI components
- `lib/widgets/animated_entry_card.dart` - Timer indicators in cards
- `lib/screens/quick_entry/quick_entry_dialog.dart` - Timer options
- `lib/screens/add_entry_screen.dart` - Timer section in form
- `lib/main.dart` - Timer service initialization

This implementation provides a robust, user-friendly timer system that enhances the existing substance tracking functionality while maintaining all existing features.