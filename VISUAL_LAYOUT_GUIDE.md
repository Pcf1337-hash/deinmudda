# Timer Tile Visual Layout Guide

## Before vs After Comparison

### BEFORE (Problems)
```
┌─────────────────────────────────────────────────┐
│ Home Screen                                     │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │ LARGE TIMER TILE (Fixed 120px height)      │ │ ← Too large
│ │ ✓ Active Timer: Cannabis - 2h 30min        │ │
│ │ [████████░░] 80%                           │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ EXPIRED TIMER TILE (Still showing!)        │ │ ← Should be hidden
│ │ ❌ EXPIRED: LSD - Timer abgelaufen          │ │
│ │ [██████████] 100%                          │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ⚠️  BOTTOM OVERFLOW ERROR                      │ ← Layout breaks
│                                                 │
├─────────────────────────────────────────────────┤
│ Recent Entries (Empty - expired timers         │
│ not moved here)                                 │
└─────────────────────────────────────────────────┘
```

### AFTER (Improved)
```
┌─────────────────────────────────────────────────┐
│ Home Screen                                     │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │ 📱 RESPONSIVE TIMER CARD (60-90px)          │ │ ← Right size
│ │ ⏰ Cannabis - 2h30m             [●●●●●○] │ │
│ │ 🟢 Active • 80% complete                   │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ✅ No expired timers shown (auto-hidden)       │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ Quick Entry Bar (Properly spaced)           │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ✅ No overflow - smooth scrolling               │
│                                                 │
├─────────────────────────────────────────────────┤
│ Recent Entries                                  │
│ • LSD - Timer completed (3 min ago)            │ ← Expired timer here
│ • MDMA - Added yesterday                        │
└─────────────────────────────────────────────────┘
```

## Multiple Active Timers Layout

### RESPONSIVE MULTIPLE TIMER VIEW (OPTIMIZED)
```
┌─────────────────────────────────────────────────┐
│ 📱 3 aktive Timer                     [Alle] │ ← Compact header
├─────────────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ →        │
│ │ ⏰ LSD   │ │ ⏰ MDMA  │ │⏰Cannabis│ scroll │ ← Horizontal scroll
│ │ Dimen.  │ │ Complex │ │ Sativa  │        │ ← Better name visibility
│ │ [●●●○○○] │ │ [●●●●●○] │ │ [●○○○○○] │        │
│ │ 2h15m   │ │ 45m     │ │ 3h30m   │        │ ← Compact info
│ │ 50%     │ │ 85%     │ │ 15%     │        │
│ └─────────┘ └─────────┘ └─────────┘        │
└─────────────────────────────────────────────────┘
     ↑            ↑            ↑
   128px       128px       128px
(32% screen width, clamped 115-160px with optimized spacing)
```

## Responsive Breakpoints

### Small Screen (320px width)
```
Single Timer Card: 48px height (320 * 0.15 = 48, clamped to 60px minimum)
Tile Width: 115px (320 * 0.32 = 102.4, clamped to 115px minimum)
Font Sizes: 11px title, 9px body (optimized for text visibility)
```

### Medium Screen (400px width)  
```
Single Timer Card: 60px height (400 * 0.15 = 60px)
Tile Width: 128px (400 * 0.32 = 128px)
Font Sizes: 13px title, 11px body (balanced visibility)
```

### Large Screen (600px width)
```
Single Timer Card: 90px height (600 * 0.15 = 90, clamped to maximum)
Tile Width: 160px (600 * 0.32 = 192, clamped to 160px maximum)  
Font Sizes: 15px title, 13px body (optimal readability)
```

## Material Design 3 Color System

### Progress-Based Color Transitions
```
🟢 0-20%: Success Green    (rgba(76, 175, 80, 0.12))
🔵 20-40%: Cyan Accent     (rgba(0, 188, 212, 0.12))  
🟡 40-60%: Warning Yellow  (rgba(255, 193, 7, 0.12))
🟠 60-80%: Warning Orange  (rgba(255, 152, 0, 0.12))
🔴 80-100%: Error Red      (rgba(244, 67, 54, 0.12))
```

### Psychedelic Mode Enhancements
```
✨ Additional glow effects
🌈 Enhanced color saturation  
💫 Pulsating animations
🎨 Rainbow progress indicators
```

## Accessibility Features

### Text Contrast
- Automatic light/dark text based on background luminance
- Minimum 4.5:1 contrast ratio compliance
- Scalable fonts for accessibility settings

### Touch Targets
- Minimum 48px touch targets for interactive elements
- Proper spacing between actionable items
- Clear visual feedback on interaction

### Screen Reader Support
- Semantic labels for timer states
- Progress announcements
- Clear hierarchy with proper heading structure

This visual guide demonstrates how the responsive design adapts to different screen sizes while maintaining optimal usability and following Material Design 3 principles.