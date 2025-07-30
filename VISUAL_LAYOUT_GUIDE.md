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

### RESPONSIVE MULTIPLE TIMER VIEW
```
┌─────────────────────────────────────────────────┐
│ 📱 3 aktive Timer                     [Alle] │ ← Compact header
├─────────────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ →        │
│ │ ⏰ LSD   │ │ ⏰ MDMA  │ │ ⏰ Weed  │ scroll  │ ← Horizontal scroll
│ │ [●●●○○○] │ │ [●●●●●○] │ │ [●○○○○○] │         │
│ │ 2h15m   │ │ 45m     │ │ 3h30m   │         │ ← Compact text
│ │ 50% ⚡  │ │ 85% 🔥  │ │ 15% 🌱  │         │
│ └─────────┘ └─────────┘ └─────────┘         │
└─────────────────────────────────────────────────┘
     ↑            ↑            ↑
   160px       160px       160px
(40% screen width, clamped 140-180px)
```

## Responsive Breakpoints

### Small Screen (320px width)
```
Single Timer Card: 48px height (320 * 0.15 = 48, clamped to 60px minimum)
Tile Width: 128px (320 * 0.4 = 128, clamped to 140px minimum)
Font Sizes: 12px title, 10px body
```

### Medium Screen (400px width)  
```
Single Timer Card: 60px height (400 * 0.15 = 60px)
Tile Width: 160px (400 * 0.4 = 160px)
Font Sizes: 14px title, 12px body
```

### Large Screen (600px width)
```
Single Timer Card: 90px height (600 * 0.15 = 90, clamped to maximum)
Tile Width: 180px (600 * 0.4 = 240, clamped to 180px maximum)  
Font Sizes: 16px title, 14px body
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