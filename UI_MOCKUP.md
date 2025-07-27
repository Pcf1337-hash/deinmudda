# DosageCard UI Visual Mockup

## Layout Overview (2x2 Grid)

```
┌─────────────────────────────────────────────────────────────┐
│                    Substanz-Übersicht                      │
│         Dosis-Informationen mit modernem                   │
│              Glassmorphism-Design                          │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────┐    ┌──────────────────────┐
│ ❤️  MDMA             │    │ 🧠  LSD              │
│                      │    │                      │
│                      │    │                      │
│                      │    │                      │
│ 85.0 mg              │    │ 150 µg               │
│ 4–6 Stunden          │    │ 8–12 Stunden         │
│ [Oral]               │    │ [Oral]               │
└──────────────────────┘    └──────────────────────┘

┌──────────────────────┐    ┌──────────────────────┐
│ ☁️  Ketamin          │    │ ⚡ Kokain            │
│                      │    │                      │
│                      │    │                      │
│                      │    │                      │
│ 50.0 mg              │    │ 30.0 mg              │
│ 45–90 Min            │    │ 15–30 Min            │
│ [Nasal]              │    │ [Nasal]              │
└──────────────────────┘    └──────────────────────┘
```

## Visual Design Features

### Glassmorphism Effect
```
Original Background
    ↓
┌─────────────────┐
│ Gradient Layer  │  ← Base gradient colors
├─────────────────┤
│ Blur Filter     │  ← BackdropFilter with sigma 10
├─────────────────┤
│ Glass Overlay   │  ← Semi-transparent white layer
├─────────────────┤
│ Content Layer   │  ← Icons, text, and indicators
└─────────────────┘
```

### Color Schemes

**Oral Administration (Warm Tones):**
- MDMA: Pink/Deep Pink with orange tint
- LSD: Purple/Deep Purple with orange tint

**Nasal Administration (Cool Tones):**
- Ketamin: Electric Blue/Deep Blue with blue tint
- Kokain: Gold/Dark Orange with blue tint

### Interactive Elements

**Normal State:**
```
┌──────────────────────┐
│ ❤️  MDMA             │  ← Scale: 1.0
│ [glassmorphism blur] │
│ 85.0 mg              │
│ 4–6 Stunden          │
│ [Oral]               │
└──────────────────────┘
```

**Pressed State:**
```
┌─────────────────────┐
│ ❤️  MDMA            │   ← Scale: 0.95
│ [shimmer overlay]   │   ← Additional white overlay
│ 85.0 mg             │
│ 4–6 Stunden         │
│ [Oral]              │
└─────────────────────┘
```

## Typography Hierarchy

```
MDMA                    ← Title: 16px, Weight 600
                         
85.0 mg                 ← Dose: 24px, Weight 700
4–6 Stunden             ← Duration: 14px, Medium weight
[Oral]                  ← Route: 12px, Weight 500, in pill-shaped container
```

## Responsive Behavior

**Large Screens (>500px):**
- GridView with 2 columns
- Cards scale proportionally
- Fixed aspect ratio 0.85

**Small Screens (≤500px):**
- Wrap layout for flexibility
- Cards maintain minimum size
- Scrollable content

## Dark Mode Adaptations

**Light Mode:**
- Full color saturation
- White glass overlay (20% opacity)
- High contrast text

**Dark Mode:**
- Reduced color saturation (70% opacity)
- Darker glass overlay (10% opacity)
- Softer contrast for comfortable viewing

This visual implementation provides a modern, accessible, and performant user interface that meets all the specified requirements for glassmorphism design with Material 3 principles.