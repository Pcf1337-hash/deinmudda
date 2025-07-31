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

### OPTIMIZED MULTIPLE TIMER VIEW (Updated Layout)
```
┌─────────────────────────────────────────────────┐
│ 📱 3 aktive Timer                     [Alle] │ ← Compact header
├─────────────────────────────────────────────────┤
│ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ →   │
│ │ ⏰ LSD │ │ ⏰MDMA│ │ ⏰Weed│ │ ⏰Caff│ scroll│ ← More tiles fit
│ │ [●●●○○]│ │[●●●●●]│ │[●○○○○]│ │[●●○○○]│     │
│ │ 2h15m │ │ 45m  │ │3h30m │ │1h15m │     │ ← Compact layout
│ │ 50% ⚡│ │ 85%🔥│ │ 15%🌱│ │ 35%☕│     │
│ └───────┘ └───────┘ └───────┘ └───────┘     │
└─────────────────────────────────────────────────┘
     ↑        ↑        ↑        ↑
   95-130px  95-130px  95-130px  95-130px
(25% screen width, clamped 95-130px for more side-by-side display)
```
```

## Responsive Breakpoints

### Small Screen (320px width)
```
Single Timer Card: 48px height (320 * 0.15 = 48, clamped to 60px minimum)
Tile Width: 95px (320 * 0.25 = 80, clamped to 95px minimum) ← More compact
Font Sizes: 11px title, 9px body ← Optimized for readability
```

### Medium Screen (400px width)  
```
Single Timer Card: 60px height (400 * 0.15 = 60px)
Tile Width: 100px (400 * 0.25 = 100px) ← Better side-by-side fit
Font Sizes: 13px title, 11px body
```

### Large Screen (600px width)
```
Single Timer Card: 90px height (600 * 0.15 = 90, clamped to maximum)
Tile Width: 130px (600 * 0.25 = 150, clamped to 130px maximum) ← Allows 4+ tiles  
Font Sizes: 15px title, 13px body
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