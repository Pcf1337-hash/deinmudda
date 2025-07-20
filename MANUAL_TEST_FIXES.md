# Manual Testing Guide for Bug Fixes

## Issue 1: Home Screen Crash with Quick Buttons and Running Timers

### Problem
- Pressing a quick button while a timer is running causes the home screen to crash
- Only becomes accessible again when stopping the timer via timer menu

### Fix Applied
- Modified `TimerService.startTimer()` to allow multiple concurrent timers
- Removed logic that automatically stops existing timers when starting new ones
- Added proper concurrent timer logging

### How to Test
1. Start a timer for any substance (e.g., via add entry with timer)
2. Go to home screen
3. Press any quick button to create a new entry with timer
4. Verify home screen does not crash
5. Check timer dashboard - should show multiple active timers
6. Both timers should work independently

### Expected Result
- No crashes when using quick buttons with active timers
- Multiple timers can run simultaneously
- Home screen remains stable

---

## Issue 2: UI Overflow in Timer Dashboard

### Problem
- Timer dashboard window doesn't fit properly
- Container in middle-right is cut off

### Fix Applied
- Fixed progress bar width calculation in `CountdownTimerWidget`
- Changed from `MediaQuery.of(context).size.width` to `LayoutBuilder` with `constraints.maxWidth`
- Added proper constraints to timer dashboard list items
- Wrapped timer widgets in containers with `maxWidth` constraints

### How to Test
1. Navigate to Timer Dashboard screen
2. Start multiple timers to create entries
3. Verify all timer widgets fit within screen bounds
4. Check progress bars don't overflow on the right side
5. Test on different screen sizes if possible

### Expected Result
- All timer elements fit within screen boundaries
- No horizontal overflow or cut-off content
- Progress bars scale properly to available width

---

## Issue 3: Missing Cost Tracking for Quick Button Entries

### Problem
- Money/cost entries from quick buttons not tracked in statistics
- Quick button entries created with cost = 0.0

### Fix Applied
- Added `cost` field to `QuickButtonConfig` model
- Updated database schema to include cost column in quick_buttons table
- Modified quick entry flow to pass cost from config to entry
- Updated quick button configuration screen to save cost values
- Added database migration for existing installations

### How to Test
1. Create or edit a quick button configuration
2. Set a cost value in the price field
3. Save the quick button
4. Use the quick button to create an entry
5. Go to statistics screen
6. Verify the cost is included in financial tracking

### Expected Result
- Quick button configs can store cost information
- Entries created via quick buttons include proper cost values
- Statistics reflect money spent through quick button entries

---

## Additional Verification Points

### Database Schema
- New installations: quick_buttons table includes cost column
- Existing installations: migration adds cost column automatically
- All existing quick buttons get cost = 0.0 by default

### Timer Service
- `_activeTimers` list can contain multiple entries
- No automatic timer stopping when starting new timers
- Proper cleanup when timers expire or are manually stopped

### UI Constraints
- All layout builders use available width instead of screen width
- Proper container constraints prevent overflow
- Responsive design works on different screen sizes

---

## Code Changes Summary

### Files Modified
1. `lib/services/timer_service.dart` - Allow concurrent timers
2. `lib/models/quick_button_config.dart` - Add cost field
3. `lib/services/database_service.dart` - Add cost column migration
4. `lib/screens/home_screen.dart` - Pass cost from config to entry
5. `lib/screens/quick_entry/quick_button_config_screen.dart` - Save cost values
6. `lib/widgets/countdown_timer_widget.dart` - Fix progress bar constraints
7. `lib/screens/timer_dashboard_screen.dart` - Add layout constraints

### Backward Compatibility
- Database migration ensures existing installations work
- Existing quick buttons get default cost = 0.0
- All changes are non-breaking for existing functionality