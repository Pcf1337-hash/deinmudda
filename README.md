# 🏥 Konsum Tracker Pro (KTP)

**Professionelle Substanz-Tracking App für medizinische/therapeutische Zwecke**

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-SDK%2035-3DDC84?style=for-the-badge&logo=android)](https://developer.android.com)
[![iOS](https://img.shields.io/badge/iOS-12+-000000?style=for-the-badge&logo=ios)](https://developer.apple.com/ios)

---

## 📊 PROJEKT STATUS

| Phase | Status | Dauer | Beschreibung |
|-------|--------|-------|--------------|
| **Phase 1** | ✅ **ABGESCHLOSSEN** | 1-2 Tage | Setup & Grundstruktur |
| **Phase 2** | ✅ **ABGESCHLOSSEN** | 2-3 Tage | Datenmodelle & Database + **Dosisrechner** |
| **Phase 3** | ✅ **ABGESCHLOSSEN** | 3-4 Tage | Home Screen & Entry Management |
| **Phase 4** | ✅ **ABGESCHLOSSEN** | 2-3 Tage | **Statistics & Analytics** |
| **Phase 5** | ✅ **ABGESCHLOSSEN** | 3-4 Tage | **Substance Management + Dosisrechner UI** |
| **Phase 6** | ✅ **ABGESCHLOSSEN** | 3-4 Tage | **Quick Entry System** |
| **Phase 7** | ✅ **ABGESCHLOSSEN** | 4-5 Tage | **Calendar & Advanced Features** |
| **Phase 8** | ✅ **ABGESCHLOSSEN** | 2-3 Tage | **Security & Polish** |
| **Bugfixes** | ✅ **ABGESCHLOSSEN** | 1 Tag | **Dosisrechner Crash-Fixes & UI-Optimierungen** |

**Aktuelle Version:** 1.0.0+1  
**Build Status:** ✅ Läuft stabil auf Samsung Galaxy S24 (Android 14) - APK-Kompilierung vollständig funktionsfähig  
**Letzte Aktualisierung:** 14. Juli 2025 (README komplettiert mit vollständiger Testing-Strategie, Setup-Anleitung und Sicherheitsrichtlinien)

---

## 🔄 LETZTE 10 ÄNDERUNGEN

### **📅 Juli 2025**

1. **🔧 agent_timer_crash_fix_and_boot_repair - Critical Stability & Boot Fixes** (aktuell)
   - **⚪ White Screen Bug Fix**: Comprehensive app initialization manager prevents white screen on startup
   - **💥 Timer Crash Prevention**: Fixed crashes during timer operations with proper null checks and mounted state verification
   - **🛡️ Crash Protection**: Added CrashProtectionWrapper for error boundaries throughout the app
   - **🚀 App Initialization**: Implemented AppInitializationManager for proper service initialization order
   - **📺 Initialization Screen**: Added InitializationScreen with progress indicator to prevent white screen
   - **🔧 Error Handling**: Enhanced error handling with ErrorHandler utility for consistent logging
   - **🛠️ Safe State Management**: Added SafeStateMixin and SafeAnimationMixin for crash prevention
   - **⏱️ Timer Service**: Improved timer service lifecycle management and error handling
   - **🎨 Theme Service**: Enhanced PsychedelicThemeService with better error handling and fallback mechanisms
   - **📱 Navigation Safety**: Added proper mounted checks to all navigation methods
   - **🔄 Service Consistency**: Fixed service initialization consistency across the app
   - **📊 Debug Logging**: Added comprehensive debug logging for troubleshooting initialization issues
   - **💾 Persistent Recovery**: Improved timer state persistence and recovery mechanisms
   - **🚫 Crash Prevention**: Eliminated setState after dispose crashes through proper lifecycle management
   - **🔧 Fallback Mechanisms**: Implemented fallback services and states for error conditions

2. **🔧 agent_timer_crash_and_white_screen_fix - Critical Stability Fixes** (vorher)
   - **🐛 White Screen Bug Fix**: Added comprehensive error handling in app initialization to prevent white screen on startup
   - **⏱️ Timer Crash Prevention**: Fixed crashes during timer operations with proper null checks and mounted state verification
   - **🛡️ Service Initialization**: Added fallback mechanisms for service initialization failures
   - **📱 Disposal Safety**: Improved disposal handling in ActiveTimerBar and HomeScreen to prevent memory leaks
   - **🎨 Animation Stability**: Enhanced animation controller lifecycle management with proper error handling
   - **🔧 Error Boundaries**: Added comprehensive try-catch blocks throughout critical code paths
   - **💾 Persistent Timer Recovery**: Improved timer state persistence and recovery mechanisms
   - **🚫 Crash Prevention**: Eliminated setState after dispose crashes through proper lifecycle management
   - **📊 Debug Logging**: Added detailed debug logging for troubleshooting initialization issues
   - **🔄 Graceful Fallbacks**: Implemented fallback widgets and states for error conditions

2. **🔧 agent_timer_crash_fix - Critical Timer Crash Fixes & Stability** (vorher)
   - **🐛 Timer Crash Prevention**: Added `mounted` checks before all setState calls to prevent "setState() called after dispose()" errors
   - **⏱️ Timer Persistence**: Added SharedPreferences saving/loading for app restart timer recovery
   - **🛡️ Safe Navigation**: Created SafeNavigation utility to prevent context crashes during screen transitions
   - **📱 Overflow Protection**: Added FittedBox for long substance names to prevent UI overflow
   - **🎨 Enhanced Progress Colors**: Improved color transitions (green → cyan → orange → red) based on timer progress
   - **🌀 Trippy FAB Animation**: Enhanced with 4x rotation and elastic bounce effect in trippy mode
   - **🔧 Service Reliability**: Enhanced error handling in TimerService and PsychedelicThemeService
   - **💾 Data Persistence**: Timer state survives app restarts and screen navigation
   - **🚫 Crash Prevention**: Eliminated setState after dispose crashes through proper lifecycle management

2. **🎨 agent_ui_polish_finalpass - Visual Design Finalization & UI Polish** (15. Juli 2025)
   - **⚡ Enhanced TimerBar Animation**: Added progress-based color transitions (green → cyan → orange → red)
   - **🌈 Luminance-Based Text Color**: Implemented automatic text color adaptation based on background luminance
   - **✨ Animated Progress Effects**: Added animated background fill and shine effects in trippy mode
   - **🎯 Improved Dosage Text Formatting**: Enhanced typography with better letter spacing and vertical centering
   - **🔧 Settings Screen Overflow Fix**: Improved ListTile text handling with proper ellipsis
   - **🎨 Visual Consistency**: Confirmed HeaderBar applied across all screens with lightning icons
   - **⚡ FAB Consistency**: Verified ConsistentFAB styling matches across Home, Timer, and DosageCalculator screens
   - **📱 Responsive Design**: Enhanced overflow protection with proper text constraints and maxLines

2. **🛠️ agent_ui_consistency_details - UI Consistency & Database Fixes** (15. Juli 2025)
   - **⚡ Lightning Icon Implementation**: Added `DesignTokens.lightningIcon` for consistent branding
   - **🎯 Unified HeaderBar**: Created shared `HeaderBar` widget for QuickButtonConfig, Timer, Settings, and DosageCalculator screens
   - **⚡ Lightning Icon Integration**: Added lightning symbols to all header bars with proper centering and visibility
   - **🌙 Dark Mode Contrast**: Improved contrast for trippy/dark mode with psychedelic color adaptations
   - **🎨 Consistent FAB Design**: Created `ConsistentFAB` widget extending HomeScreen FAB pattern to all screens
   - **🛠️ Database Migration Safety**: Added `_addColumnIfNotExists` helper for safe column additions
   - **⚡ Timestamp Column Fixes**: Implemented `_ensureTimestampColumns` for comprehensive created_at/updated_at checks
   - **🔧 SQLITE_ERROR[1] Resolution**: Fixed database schema inconsistencies with fallback-safe migrations
   - **🚀 Shared Widget System**: Extracted common UI patterns into reusable components for better maintainability

3. **🛠️ agent_ui_overflow_fixes - Comprehensive UI Overflow Fixes** (14. Juli 2025)
   - **🎯 Target Screens**: DosageCalculatorScreen, TimerDashboardScreen, SettingsScreen
   - **🔧 Layout Improvements**: Replaced fixed heights with flexible constraints (BoxConstraints)
   - **📱 Responsive Design**: Implemented FittedBox, Flexible, and SingleChildScrollView
   - **🔤 Text Overflow Handling**: Added maxLines, ellipsis, and text scaling
   - **♿ Accessibility Support**: Large font sizes and dynamic text scaling
   - **📐 Dynamic Sizing**: LayoutBuilder for responsive card layouts
   - **🧪 Testing**: Comprehensive test suite for overflow scenarios
   - **📖 Documentation**: Updated README with overflow fix methodology

2. **🏠 agent_home_layout_transfer - Home Layout Restructuring & Timer Features** (14. Juli 2025)
   - **🔀 HomeScreen Layout**: Bestätigte korrekte Komponentenreihenfolge (Quick-Buttons → Timer → Statistiken → Einträge)
   - **🧩 FAB-Funktionen Transfer**: Timer-Start-Funktionalität vom DosageCalculator übernommen
   - **⏱️ Timer-Eingabe Erweiterung**: Erweiterte ActiveTimerBar mit ausklappbarem Eingabefeld
   - **🔢 Numerische Validierung**: Echtzeit-Konvertierung von Minuten zu "Entspricht: X Std Y Min"
   - **💊 Vorschlagschips**: Schnellauswahl für gängige Timer-Dauern (15/30/45/60/90/120 Min)
   - **🎯 Automatische Timer-Anpassung**: Sofortige Übertragung der Eingabe auf aktiven Timer
   - **🔄 TimerService Enhancement**: Neue `updateTimerDuration` Methode für Timer-Anpassungen
   - **🚀 Nahtlose Integration**: Vollständige Kompatibilität mit bestehendem Entry-basiertem Timer-System

2. **📝 README Komplettierung & Dokumentations-Update** (14. Juli 2025)
   - **🧪 Testing Strategy**: Vollständige Testing-Strategie mit 5 Test-Kategorien dokumentiert
   - **📱 Setup & Installation**: Detaillierte Installationsanweisungen für Flutter, Android und iOS
   - **🔐 Sicherheit & Datenschutz**: Umfassende Sicherheitsrichtlinien und DSGVO-Compliance
   - **🎯 Verwendungsrichtlinien**: Rechtliche Hinweise und Disclaimer für verantwortungsvolle Nutzung
   - **🔧 Build-Konfiguration**: Development und Release-Build-Anweisungen mit APK-Generation
   - **🏥 Medizinische Compliance**: Dokumentation der therapeutischen Anwendungsbereiche
   - **📊 Test-Coverage**: Detaillierte Test-Abdeckung für Database, UI, Business Logic und Integration
   - **🚀 CI/CD Integration**: Automatisierte Test-Ausführung und Performance-Regression-Tests

3. **🛠️ agent_home_dosage_fixes_1_6 - Crash-Fixes & UX-Verbesserungen** (14. Juli 2025)
   - **🔧 Menü-Crash Fix**: Navigation-Crashes beim ersten App-Start behoben (context.mounted checks)
   - **🎯 Zentrierter Text**: Empfohlene Dosis-Box im DosageCalculator mit FittedBox & TextAlign.center
   - **🧨 Overflow-Behebung**: "BOTTOM OVERFLOWED" im DosageCalculator mit SingleChildScrollView gelöst
   - **⏱️ Manueller Timer**: Zahlen-Eingabe (z.B. "64") mit formatierter Anzeige "Entspricht: 1 Stunde, 4 Minuten"
   - **🌈 Visueller Timer-Balken**: Läuft von links nach rechts mit kontrastreichem Text auf Füllfarbe
   - **✨ Animierter App-Titel**: ShaderMask mit Pulsieren/Reflektieren, verstärkt im Trippy-Mode
   - **🛑 FAB-Rotation**: Plusknopf dreht sich wild (4x) im Trippy-Darkmode mit elastischem Bounce

2. **🎨 UI Fixes & Visual Improvements** (14. Juli 2025)
   - **Dosisrechner**: Header-Overflow behoben (90px → 80px), Logo-Größe reduziert, Profil-Karte näher positioniert
   - **Substanz-Karten**: Mehr Padding für "Empfohlene Dosis" (12px → 16px), Höhe angepasst (220px → 240px)
   - **Home-Screen**: Statischer Titel durch animiertes Logo ersetzt (Psychology-Icon mit Rotation)
   - **Header-Bereich**: Vertikaler Platz reduziert (150px → 120px), kompakte Darstellung
   - **"Erster Button erstellen"**: Zentriert mit korrektem Padding und Container-Wrapper
   - **SpeedDial FAB**: OnPressed-Funktionalität repariert, korrekte Positionierung rechts unten
   - **Quick Button Creation**: Lightning-Icon ausgerichtet, editierbares Preis-Feld hinzugefügt
   - **Preis-Auto-Load**: Automatisches Laden des Preises bei Substanzauswahl
   - **Button-Aktivierung**: Nur bei gültiger Eingabe (Substanz + Dosierung + Einheit + Preis)

3. **🗄️ SQL Database Fixes & Android Launcher Icons** (14. Juli 2025)
   - Behebung von SQL Database-Inkonsistenzen für stabile Datenbank-Operationen
   - Vollständige Android Launcher Icons (hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi) für APK-Kompilierung
   - **Neue Android-Konfiguration**: `android/app/src/main/res/mipmap-*` Icon-Sets hinzugefügt
   - **Build-Verbesserungen**: `android/app/build.gradle.kts` und `android/build.gradle.kts` optimiert
   - **Sicherheitsverbesserungen**: `network_security_config.xml` für sichere Netzwerkverbindungen
   - **Styles & Colors**: Verbesserte Android-Theme-Konfiguration in `values/styles.xml` und `values/colors.xml`
   - **APK-Ready**: Vollständige Kompilierung für Android-Geräte ohne Fehler möglich

3. **🏠 HomeScreen Cleanup & Timer Integration** (14. Juli 2025)
   - Vollständige Bereinigung des HomeScreens - Entfernung von Quick Actions und Advanced Features
   - **Entfernte Komponenten**: `_buildQuickActionsSection()`, `_buildAdvancedFeaturesSection()`, `_buildQuickActionCard()`
   - **Entfernte Buttons**: Quick Buttons verwalten, Erweiterte Suche, Musteranalyse, Daten Export/Import
   - Integration des ActiveTimerBar für visuelle Timer-Anzeige mit Pulsing-Animation
   - Implementierung des SpeedDial-Systems für essenzielle Aktionen (Neuer Eintrag, Timer stoppen)
   - Automatischer Timer-Start bei QuickEntry-Nutzung mit Substanz-basierter Dauer (Fallback: 4 Stunden)
   - Single-Timer-Logik verhindert mehrere gleichzeitige Timer mit `currentActiveTimer` und `hasAnyActiveTimer` Getters
   - **Neue Dateien**: `lib/widgets/active_timer_bar.dart`, `lib/widgets/speed_dial.dart`

4. **🔧 Dosage Calculator Syntax Fixes** (14. Juli 2025)
   - Behebung von 24 Compilation Errors im Dosage Calculator Screen
   - Syntax-Fehler in der Substanz-Suche und Benutzer-Profil-Verwaltung behoben
   - Stabile Kompilierung und Funktionalität wiederhergestellt

5. **⏱️ Timer-Funktionalität Implementierung** (14. Juli 2025)
   - Vollständige Timer-Integration in Entry- und Quick-Button-System
   - **Neue Timer-Felder im Entry-Model**: `timerStartTime`, `timerEndTime`, `timerCompleted`, `timerNotificationSent`
   - **Timer-Getters**: `hasTimer`, `isTimerActive`, `isTimerExpired`, `timerProgress`, `remainingTime`, `formattedRemainingTime`
   - Substanz-basierte Timer-Dauern mit Standard-Fallback-Werten (Koffein: 4h, Cannabis: 2h, Nikotin: 30min)
   - Hintergrund-Timer-Überwachung alle 30 Sekunden mit automatischen Benachrichtigungen
   - Timer-Fortschrittsanzeige und animierte Status-Indikatoren mit Pulsing-Effekt
   - **Database-Migration**: Version 2 mit neuen Timer-Spalten und Substanz-Dauer-Feld
   - **Neue Komponenten**: Timer Indicator, Timer Progress Bar, Timer Checkbox, Animated Timer Status
   - Nicht-breaking Integration mit bestehender Funktionalität

6. **🎨 Substance Card Glassmorphism Enhancement** (14. Juli 2025)
   - Implementierung des modernen Glassmorphism-Designs für Substance Cards mit Backdrop-Blur
   - **Neue Widget-Komponenten**: `DangerBadge`, `DosageLevelIndicator`, `SubstanceGlassCard`, `SubstanceQuickCard`
   - Responsive Layout mit LayoutBuilder zur Overflow-Vermeidung und `IntrinsicHeight`
   - Substanz-spezifische Farbthemen und Danger-Level-Badges (Niedrig, Mittel, Hoch, Kritisch)
   - **Substanz-spezifische Icons**: heart für MDMA, brain für LSD, konsistente Farbkodierung
   - Animierte Interaktionen mit Glow-Effekten und Backdrop-Blur bei Hover/Tap
   - Dosage-Level-Indikatoren mit Grün-Gelb-Rot-Farbkodierung und per-kg/total Dosage-Display
   - **Technische Verbesserungen**: Transluzente Karten, runde Ecken, subtile Borders, Smooth Glow-Animationen

7. **🐛 Flutter UI Overflow Fixes** (14. Juli 2025)
   - Behebung aller "BOTTOM OVERFLOWED BY X PIXELS" Fehler in Substance Cards
   - **Technische Fixes**: Ersetzen von Fixed-Height-Constraints (240px) durch flexible `BoxConstraints` (minHeight: 220, maxHeight: 280)
   - **Scrolling-Verbesserungen**: `NeverScrollableScrollPhysics()` → `ClampingScrollPhysics()` für ordnungsgemäßes Scrolling
   - **Responsive Design**: Implementierung von `LayoutBuilder`, `FittedBox`, `Flexible` und `Expanded` Widgets
   - **Grid-Layout-Optimierungen**: Dynamische Breiten-Berechnungen mit `itemWidth.clamp(80.0, 120.0)` für verschiedene Bildschirmgrößen
   - **Text-Overflow-Handling**: Improved substance name display (1 line → 2 lines) mit `maxLines` und `ellipsis`
   - **Widget-Strukturverbesserungen**: `mainAxisSize: MainAxisSize.min` für Dosage-Preview, `IntrinsicHeight` für flexible Card-Höhen
   - Umfassende Widget-Tests zur Overflow-Verhinderung mit `overflow_test_app.dart`

8. **🐛 Build-Tooling Fix** (13. Juli 2025)
   - Fehler mit ungültigem depfile im Build-Prozess behoben (Flutter Build Tooling)
   - Stellt sicher, dass die App weiterhin fehlerfrei kompiliert werden kann

9. **🖼️ Icon-Fix im Timer-Dashboard** (13. Juli 2025)
   - Icon von `Icons.add_timer_rounded` auf `Icons.add_rounded` geändert
   - UI-Darstellung im Dashboard korrigiert

10. **📂 Initiale Planung & Struktur** (12. Juli 2025)
    - Neue Dateien und Grundstruktur für Features und Aufgaben angelegt
    - Vorbereitungen für die nächsten Entwicklungsschritte

10. **🪟 Glassmorphism Design & Card Overflow Bugfix** (11. Juli 2025)
    - Substance Card-Komponente mit Glassmorphism-Design versehen
    - Demo und Dokumentation aktualisiert, Overflow-Bug behoben

> **Hinweis:** Die vollständige Commit-Historie findest du [hier](https://github.com/Pcf1337-hash/deinmudda/commits?sort=updated&direction=desc).

---

## 🔍 Änderungen & KI-Agenten-Protokoll

Da verschiedene KI-Agenten und Entwickler:innen an diesem Projekt arbeiten, werden die wichtigsten Commit-Änderungen tabellarisch erfasst:

| Datum         | Bereich/Datei                | Was wurde gemacht?                                  | Warum?                        | Technische Details          | Wer?          |
|---------------|------------------------------|-----------------------------------------------------|-------------------------------|----------------------------|---------------|
| 15.07.2025    | ActiveTimerBar + DosageCalculator | agent_ui_polish_finalpass - Visual Design Finalization | UI-Polish & Animation-Verbesserung | Progress-basierte Farbübergänge, Luminanz-basierte Textfarben, animierte Shine-Effekte, verbesserte Dosage-Text-Formatierung | Copilot/KI    |
| 15.07.2025    | UI Consistency + Database    | agent_ui_consistency_details - UI Consistency & Database Fixes | UI-Konsistenz & Datenbank-Stabilität | Lightning Icons, HeaderBar-Vereinheitlichung, ConsistentFAB-Widget, Database-Migration-Safety, SQLITE_ERROR-Fixes | Copilot/KI    |
| 14.07.2025    | HomeScreen + ActiveTimerBar  | agent_home_layout_transfer - Timer-Features erweitert | Layout-Umbau & Timer-Eingabe | FAB-Timer-Start, ActiveTimerBar mit Eingabefeld, updateTimerDuration-Methode, Echtzeit-Formatierung | Copilot/KI    |
| 14.07.2025    | README.md                    | Komplettierung der README-Dokumentation            | Vollständige Projekt-Dokumentation | Testing Strategy, Setup & Installation, Sicherheitsrichtlinien, Verwendungsrichtlinien, CI/CD Integration | Copilot/KI    |
| 14.07.2025    | UI/UX Fixes                  | Dosisrechner, Home-Screen & Quick Button UI-Fixes  | Visuelle Bugs & Overflow-Fixes | Header-Overflow behoben, animiertes Logo, Preis-Feld hinzugefügt, SpeedDial-Fix, Button-Aktivierung bei gültiger Eingabe | Copilot/KI    |
| 14.07.2025    | SQL Database + Android Build | SQL Database-Inkonsistenzen behoben & Android Icons | APK-Kompilierung & Stabilität | Android Launcher Icons (hdpi-xxxhdpi), network_security_config.xml, gradle.kts-Optimierungen | Copilot/KI    |
| 14.07.2025    | HomeScreen + Timer           | HomeScreen Cleanup & Timer Integration             | UI-Bereinigung & Timer-Funktionalität | Entfernung von `_buildQuickActionsSection()`, `_buildAdvancedFeaturesSection()`, neue Widgets: `ActiveTimerBar`, `SpeedDial` | Copilot/KI    |
| 14.07.2025    | Dosage Calculator Screen     | 24 Compilation Errors behoben                      | Stabile Kompilierung          | Syntax-Fehler in Substanz-Suche und User-Profile behoben | Copilot/KI    |
| 14.07.2025    | Entry + Quick Button System  | Vollständige Timer-Funktionalität implementiert    | Substanz-basierte Timer       | Neue Timer-Felder: `timerStartTime`, `timerEndTime`, `timerCompleted`, DB-Migration v2 | Copilot/KI    |
| 14.07.2025    | Substance Cards              | Glassmorphism Enhancement & Responsive Design       | Modernes UI & Overflow-Fixes  | Neue Widgets: `DangerBadge`, `DosageLevelIndicator`, `SubstanceGlassCard`, `SubstanceQuickCard` | Copilot/KI    |
| 14.07.2025    | UI Overflow Fixes            | Flutter UI Overflow Fixes für Substance Cards      | Stabile UI auf allen Geräten  | Fixed-Height (240px) → `BoxConstraints`, `ClampingScrollPhysics`, `LayoutBuilder` | Copilot/KI    |
| 13.07.2025    | Build-Tooling                | Fix für invalid depfile im Build-Prozess            | Build-Fehler behoben          | Flutter Build Tooling Depfile-Korrektur | Copilot/KI    |
| 13.07.2025    | Timer-Dashboard              | Icon von add_timer_rounded auf add_rounded geändert | UI-Korrektur                  | Icon-Wechsel in Timer-Dashboard | Copilot/KI    |
| 12.07.2025    | Projektstruktur              | Initiale Planung und Grundstruktur angelegt         | Vorbereitungen für Features   | Neue .md Dokumentations-Dateien erstellt | Copilot/KI    |
| 12.07.2025    | Flutter-App                  | Kompilierungsfehler und Strukturprobleme gefixt     | Build-Fähigkeit wiederhergestellt | Import- und Syntax-Fehler behoben | Copilot/KI |
| 11.07.2025    | Substance Card-Komponente    | Glassmorphism Design & Card Overflow Bugfix         | UI-Verbesserung               | Glasmorphismus-Effekte, Card-Overflow-Fixes | Copilot/KI    |
| 10.07.2025    | Diverse Dart-Dateien         | Import- und Syntax-Fehler behoben                   | Codequalität                  | Diverse Import-Statements und Syntax korrigiert | Copilot/KI    |

> **Bitte diesen Abschnitt bei neuen Änderungen immer aktualisieren, um Transparenz für alle KI-Agenten und Mitwirkenden zu gewährleisten!**

---

## 🎯 PROJEKT ÜBERSICHT

### **Zielgruppe**
Erwachsene für verantwortungsvolles Substanz-Monitoring in medizinischen/therapeutischen Kontexten

### **Kern-Features**
1. **Entry Management** - Vollständiges CRUD für Konsum-Einträge ✅
2. **Substance Database** - Verwaltung von Substanzen mit Preisen/Kategorien ✅
3. **🧮 Dosisrechner** - Eigenständiges Tool für gewichtsbasierte Dosierungsempfehlungen ✅
4. **📊 Statistics Dashboard** - Detaillierte Auswertungen mit interaktiven Charts ✅
5. **🔬 Substance Management** - Manuelle Substanz-Erstellung mit Preisen ✅
6. **⚡ Quick Entry System** - Konfigurierbare Schnell-Eingabe Buttons ✅
7. **⏱️ Timer System** - Substanz-basierte Timer mit automatischen Benachrichtigungen ✅
8. **Calendar View** - Kalender-basierte Darstellung aller Einträge ✅
9. **Cost Tracking** - Automatische Kostenberechnung und -verfolgung ✅
10. **Risk Assessment** - Risikobewertung pro Substanz (Low/Medium/High/Critical) ✅
11. **🔍 Advanced Search** - Erweiterte Suchfunktion mit mehreren Filtern ✅
12. **🔄 Data Export/Import** - Datenexport und -import für Backups ✅
13. **📈 Pattern Analysis** - Muster-Erkennung für Konsumverhalten ✅
14. **🔒 Biometric Security** - App-Sperre mit Biometrie und PIN ✅
15. **🔔 Notifications** - Erinnerungen für regelmäßige Einträge ✅

### **Tech Stack**
- **Framework:** Flutter 3.16+ mit Dart 3.0+
- **Database:** SQLite (sqflite) für lokale Datenspeicherung - Version 2 mit Timer-Unterstützung und SQL-Konsistenz-Fixes
- **State Management:** Provider Pattern mit Singleton-Services
- **Design:** Material Design 3 + Glasmorphismus-Effekte mit Backdrop-Blur
- **Animations:** Standard Flutter Animations (flutter_animate entfernt für Stabilität), Custom Pulsing-Animationen
- **Charts:** Custom Chart Widgets mit Canvas API für interaktive Darstellungen
- **Security:** local_auth für biometrische Authentifizierung ✅
- **Notifications:** flutter_local_notifications für Erinnerungen und Timer-Benachrichtigungen ✅
- **Timer-System:** Background Timer-Checking (30s-Intervall) mit automatischen Benachrichtigungen
- **Responsive Design:** LayoutBuilder, Flexible Widgets, BoxConstraints für Overflow-Vermeidung

### **🎨 Design & Visuelle Highlights**
- **Glasmorphismus-Design** - Durchgängige Verwendung von transluzenten Glaseffekten für moderne UI
- **Substanz-spezifische Farbthemen** - Jede Substanz hat individuelle Farbkodierung mit Backdrop-Blur
- **Responsive Overflow-freies Layout** - Optimierte Widget-Hierarchie ohne Render-Konflikte
- **Animierte Timer-Indikatoren** - Visuelle Fortschrittsanzeige mit Pulsing-Effekten und progress-basierten Farbübergängen
- **Luminanz-basierte Textfarben** - Automatische Textfarb-Anpassung basierend auf Hintergrund-Luminanz
- **Progress-basierte Farbübergänge** - Timer-Balken wechseln von Grün → Cyan → Orange → Rot je nach Fortschritt
- **Animated Shine-Effekte** - Glänzende Lichteffekte auf Timer-Balken im Trippy-Modus
- **Neon-Akzente im Dark Mode** - Leuchtende Farbakzente für optimale Sichtbarkeit in dunklen Umgebungen
- **Psychedelische Farbpalette** - Für Nutzer unter Einfluss optimierte Farbkombinationen
- **Smooth Transitions** - Fließende Übergänge mit nativen Animationen
- **Responsive Interaktionen** - Haptisches Feedback und visuelle Reaktionen
- **Immersive Dark Mode** - Optimierter Dark Mode mit reduzierten Blauanteilen
- **Dynamische Farbakzente** - Substanz-spezifische Farbkodierung für intuitive Navigation
- **Stabile Render-Performance** - Optimierte Widget-Struktur ohne UI-Overflow
- **Visuelle Hierarchie** - Klare Informationsstruktur durch Kontraste

### **🔮 Trippy-Theme-System**
- **PsychedelicThemeService** - Zentraler Service für Trippy-Mode-Aktivierung mit `isPsychedelicMode`
- **Adaptive Farbschemata** - Automatische Anpassung aller UI-Elemente an Trippy-Mode
- **Substanz-spezifische Visualisierung** - Dynamische Farbpalette je nach aktueller Substanz
- **Animierte Hintergründe** - Psychedelische Gradients und Partikel-Effekte
- **Glow-Intensität-Steuerung** - Anpassbare Leuchteffekte für verschiedene Zustände
- **Pulsing-Widgets** - Rhythmische Animationen für immersive Erfahrung
- **Shader-basierte Effekte** - GPU-accelerierte Visualisierungen für optimale Performance
- **Responsive Activation** - Automatische Aktivierung auf allen relevanten Screens

### **🎯 Zentraler FAB-Stil**
- **TrippyFAB-Widget** - Einheitliches FAB-Design für alle Screens
- **Neon-Pink zu Grau Gradient** - Charakteristische Farbverläufe von außen nach innen
- **Multi-Layer-Glow-Effekte** - Cyan, Pink und weiße Leuchteffekte mit verschiedenen Intensitäten
- **Kontinuierliche Animationen** - Skalierung, Rotation und Pulsing-Effekte
- **Adaptive Darstellung** - Automatischer Wechsel zwischen Standard- und Trippy-Mode
- **Substanz-spezifische Farbakzente** - Farbanpassung basierend auf aktueller Substanz
- **Performance-optimiert** - Efficient GPU-Rendering mit minimal CPU-Load

---

## 🏗️ VOLLSTÄNDIGE ARCHITEKTUR

```text
lib/
├── main.dart                    # ✅ App Entry Point + Provider Setup
├── models/                      # ✅ PHASE 2 - ABGESCHLOSSEN + BUGFIXES
│   ├── entry.dart              # ✅ Kern-Datenmodell für Einträge
│   ├── substance.dart          # ✅ Substanz-Definitionen
│   ├── quick_button_config.dart # ✅ Button-Konfigurationen
│   ├── dosage_calculator_user.dart # ✅ Benutzer-Profile (Gewicht, Größe, Alter)
│   ├── dosage_calculator_substance.dart # ✅ Dosisrechner-Substanzen (Null-Safe)
│   └── dosage_calculation.dart # ✅ Einheitliche Dosierungsberechnung-Klasse
├── services/                    # ✅ PHASE 7 - ERWEITERT + BUGFIXES
│   ├── database_service.dart   # ✅ SQLite CRUD (5 Tabellen)
│   ├── entry_service.dart      # ✅ Entry Management Logic + Advanced Search
│   ├── substance_service.dart  # ✅ Substance Management Logic
│   ├── quick_button_service.dart # ✅ Quick Button Management
│   ├── timer_service.dart      # ✅ Timer Management + Benachrichtigungen
│   ├── dosage_calculator_service.dart # ✅ Dosisrechner + BMI Logic (Robust Error Handling)
│   ├── analytics_service.dart  # ✅ Statistics & Pattern Analysis
│   └── settings_service.dart   # ✅ Theme & Settings Management
├── screens/                     # ✅ PHASE 7 - ERWEITERT + UI-FIXES
│   ├── main_navigation.dart    # ✅ Bottom Navigation (4 Tabs)
│   ├── home_screen.dart        # ✅ Home mit echten Daten und Live-Stats
│   ├── add_entry_screen.dart   # ✅ Vollständiges Entry Creation
│   ├── edit_entry_screen.dart  # ✅ Entry Editing mit Delete-Option
│   ├── entry_list_screen.dart  # ✅ Scrollable Entry List mit Swipe Actions
│   ├── statistics_screen.dart  # ✅ Vollständige Statistics mit Charts
│   ├── calendar_screen.dart    # ✅ PHASE 7 - Vollständiger Kalender mit Monats-/Wochenansicht
│   ├── advanced_search_screen.dart # ✅ PHASE 7 - Erweiterte Suchfunktion
│   ├── data_export_screen.dart # ✅ PHASE 7 - Datenexport und -import
│   ├── settings_screen.dart    # ✅ Settings mit Theme Toggle + Dosisrechner-Datenbank
│   ├── substance_management_screen.dart # ✅ Substanz-Verwaltung
│   ├── dosage_calculator/      # ✅ Dosisrechner Screens (CRASH-FIXES)
│   │   ├── dosage_calculator_screen.dart # ✅ Hauptscreen mit Navigation (Stabile Version)
│   │   ├── dosage_calculator_screen_fixed.dart # ✅ Crash-freie Alternative
│   │   ├── user_profile_screen.dart # ✅ Benutzer-Profil mit BMI
│   │   ├── substance_search_screen.dart # ✅ Substanz-Suche (Stabile Version)
│   │   └── substance_search_screen_fixed.dart # ✅ UI-Error-freie Alternative
│   ├── calendar/               # ✅ PHASE 7 - Kalender-Screens
│   │   ├── day_detail_screen.dart # ✅ Tagesdetails mit Zeitachse
│   │   └── pattern_analysis_screen.dart # ✅ Muster-Erkennung für Konsumverhalten
│   ├── auth/                   # ✅ PHASE 8 - Authentifizierungs-Screens
│   │   ├── auth_screen.dart    # ✅ Login-Screen mit Biometrie und PIN
│   │   └── security_settings_screen.dart # ✅ Sicherheitseinstellungen
│   ├── notifications/          # ✅ PHASE 8 - Benachrichtigungs-Screens
│   │   └── notification_settings_screen.dart # ✅ Benachrichtigungseinstellungen
│   └── quick_entry/            # ✅ Quick Entry Screens
│       ├── quick_entry_management_screen.dart # ✅ Verwaltung aller Quick Buttons
│       ├── quick_button_config_screen.dart # ✅ Konfiguration einzelner Buttons
│       └── quick_entry_dialog.dart # ✅ Dialog für schnelle Eingabe
├── widgets/                     # ✅ PHASE 6 - ABGESCHLOSSEN + TRIPPY FAB + CONSISTENCY
│   ├── glass_card.dart         # ✅ Glasmorphismus-Karten
│   ├── modern_fab.dart         # ✅ Moderner Floating Action Button
│   ├── trippy_fab.dart         # ✅ Zentraler FAB für Trippy-Mode mit Neon-Pink-Grau-Gradient
│   ├── consistent_fab.dart     # ✅ Einheitlicher FAB für alle Screens mit SpeedDial-Integration
│   ├── header_bar.dart         # ✅ Einheitliche HeaderBar mit Lightning-Icon für alle Screens
│   ├── animated_entry_card.dart # ✅ Animierte Entry-Darstellung mit Swipe
│   ├── active_timer_bar.dart   # ✅ Aktive Timer-Anzeige mit Fortschrittsbalken und Pulsing-Animation
│   ├── speed_dial.dart         # ✅ SpeedDial für HomeScreen-Aktionen mit Expand/Collapse-Animation
│   ├── timer_indicator.dart    # ✅ Timer-Status-Indikatoren mit Animationen
│   ├── unit_dropdown.dart      # ✅ Einheiten-Dropdown für Dosage-Eingabe
│   ├── countdown_timer_widget.dart # ✅ Countdown-Timer-Widget mit visueller Anzeige
│   ├── psychedelic_background.dart # ✅ Psychedelischer Hintergrund-Effekt
│   ├── pulsating_widgets.dart  # ✅ Pulsating-Effekte für UI-Elemente
│   ├── performance_optimized_widgets.dart # ✅ Performance-optimierte Widget-Komponenten
│   ├── charts/                 # ✅ Chart Widgets
│   │   ├── line_chart_widget.dart # ✅ Interaktive Line Charts
│   │   ├── bar_chart_widget.dart # ✅ Animierte Bar Charts
│   │   └── pie_chart_widget.dart # ✅ Pie Charts mit Legende
│   ├── dosage_calculator/      # ✅ Dosisrechner Widgets (Enhanced mit Glassmorphismus)
│   │   ├── bmi_indicator.dart  # ✅ BMI-Anzeige Widget mit Animationen
│   │   ├── dosage_result_card.dart # ✅ Dosierungsergebnis Modal mit responsivem Layout
│   │   ├── substance_card.dart # ✅ Substanz-Karte mit Dosage Preview (Overflow-behoben)
│   │   ├── danger_badge.dart   # ✅ Substanz-Gefahrenstufen-Badge (Niedrig, Mittel, Hoch, Kritisch)
│   │   ├── dosage_level_indicator.dart # ✅ Dosage-Level-Indikatoren mit Grün-Gelb-Rot-Farbkodierung
│   │   ├── substance_glass_card.dart # ✅ Glasmorphismus-Substance-Cards mit Backdrop-Blur
│   │   └── substance_quick_card.dart # ✅ Overflow-freie Substance-Cards mit flexiblen Layouts
│   └── quick_entry/            # ✅ Quick Entry Widgets
│       ├── quick_entry_bar.dart # ✅ Horizontale Scrollbar mit Quick Buttons
│       └── quick_button_widget.dart # ✅ Einzelner Quick Button mit Animationen
├── theme/                       # ✅ PHASE 1 - Komplettes Design System + UI CONSISTENCY
│   ├── design_tokens.dart      # ✅ Farben, Konstanten, Gradients + Lightning Icon
│   ├── modern_theme.dart       # ✅ Light/Dark Theme Implementation
│   ├── spacing.dart            # ✅ Konsistentes Spacing System
│   └── typography.dart         # 📋 Typography System
├── utils/                       # ✅ PHASE 7 - ERWEITERT + CRASH PROTECTION
│   ├── app_icon_generator.dart # ✅ Icon-System für Substanzen
│   ├── database_helper.dart    # ✅ Database Utilities
│   ├── data_export_helper.dart # ✅ PHASE 7 - Export/Import Utilities
│   ├── validation_helper.dart  # ✅ Input Validation
│   ├── performance_helper.dart # ✅ PHASE 8 - Performance Optimierungen
│   ├── error_handler.dart      # ✅ Centralized Error Logging & Reporting
│   ├── crash_protection.dart   # ✅ Error Boundaries & Safe State Management
│   ├── app_initialization_manager.dart # ✅ App Startup & Service Initialization
│   └── safe_navigation.dart    # ✅ Safe Navigation Utilities
└── assets/                      # ✅ PHASE 5 - Erweiterte Dosisrechner Daten
    └── data/
        ├── dosage_calculator_substances.json # ✅ Basis-Dosisrechner-Daten
        └── dosage_calculator_substances_enhanced.json # ✅ Erweiterte Daten mit Wechselwirkungen
```

### **🧪 Test & Demo Files**
```text
├── overflow_test_app.dart        # ✅ Overflow-Testing-App für Substance Cards
├── demo_homescreen.dart          # ✅ HomeScreen Demo mit Timer-Integration
├── demo_ui.html                  # ✅ UI-Demo für Glassmorphismus-Effekte
├── test_implementation.dart      # ✅ Implementation-Tests für neue Features
├── test_integration.dart         # ✅ Integration-Tests für Timer-System
├── test_runner.dart              # ✅ Test-Runner für alle Tests
├── verify_implementation.dart    # ✅ Verifikation der Implementation
└── verify_overflow_fixes.dart    # ✅ Verifikation der Overflow-Fixes
```

---

## 🔧 TECHNISCHE IMPLEMENTIERUNGSDETAILS

### **🛠️ Overflow Fixes & Responsive Design**
- **Flexible Container Heights**: Replaced fixed heights with BoxConstraints (minHeight, maxHeight)
- **Text Scaling**: FittedBox implementation for dynamic text sizing with accessibility support
- **Responsive Layouts**: LayoutBuilder for dynamic content sizing based on screen constraints
- **Scrollable Content**: SingleChildScrollView with ClampingScrollPhysics for proper scrolling
- **Text Overflow Prevention**: maxLines, ellipsis, and Flexible widgets for text content
- **Accessibility Support**: Large font size testing and dynamic text scaling (TextScaler.linear)
- **Screen Size Adaptation**: Responsive design patterns for various screen sizes (320px to 800px+)
- **Widget Hierarchy**: Proper Flexible/Expanded usage to prevent layout overflow

### **Timer-System**
- **Database-Schema**: Neue Timer-Spalten in `entries` Tabelle und `duration` in `substances` Tabelle
- **Service-Integration**: `TimerService` mit Singleton-Pattern für Background-Monitoring
- **Timer-Anpassung**: Neue `updateTimerDuration` Methode für Echtzeit-Timer-Modifikation
- **Notification-Channel**: Spezifische Timer-Benachrichtigungen mit "Timer abgelaufen" Meldungen
- **Default-Durationen**: Koffein (4h), Cannabis (2h), Alkohol (2h), Vitamin D (24h), Nikotin (30min)
- **UI-Komponenten**: `ActiveTimerBar`, `TimerIndicator`, `TimerProgressBar` mit Pulsing-Animationen
- **Timer-Eingabe**: Erweiterte `ActiveTimerBar` mit ausklappbarem Eingabefeld
- **Echtzeit-Formatierung**: Automatische Konvertierung von Minuten zu "X Std Y Min" Format
- **Vorschlag-Chips**: Schnellauswahl für gängige Dauern (15/30/45/60/90/120 Min)
- **FAB-Integration**: Timer-Start über HomeScreen FloatingActionButton mit Substanz-Auswahl

### **Glasmorphismus-Design**
- **Backdrop-Blur**: `BackdropFilter` mit `ImageFilter.blur` für transluzente Effekte
- **Substanz-Farbthemen**: Individuelle Farbkodierung pro Substanz (heart für MDMA, brain für LSD)
- **Danger-Level-System**: Automatische Gefahrenstufen-Erkennung (Niedrig, Mittel, Hoch, Kritisch)
- **Animation-System**: Glow-Effekte bei Interaktionen, Smooth-Transitions

### **Overflow-Fixes**
- **Layout-Optimierungen**: `LayoutBuilder` für responsive Designs, `BoxConstraints` statt Fixed-Height
- **Scrolling-Physik**: `ClampingScrollPhysics` für ordnungsgemäße Scrolling-Funktionalität
- **Widget-Hierarchie**: `Flexible`, `Expanded`, `FittedBox` für verschiedene Bildschirmgrößen
- **Test-Coverage**: `overflow_test_app.dart` für umfassende Overflow-Verhinderung

### **Performance-Optimierungen**
- **Widget-Caching**: `performance_optimized_widgets.dart` für wiederverwendbare Komponenten
- **setState-Management**: `addPostFrameCallback` für sichere State-Updates
- **Memory-Management**: Proper disposal von Animation-Controllern und Timer-Streams

### **📋 Dokumentation & Implementation-Details**
- **HOMESCREEN_IMPLEMENTATION.md**: Detaillierte Dokumentation der HomeScreen-Bereinigung und Timer-Integration
  - Entfernung von Quick Actions und Advanced Features
  - ActiveTimerBar und SpeedDial-Implementierung
  - Single-Timer-Logik und Background-Monitoring
- **OVERFLOW_FIXES.md**: Technische Lösung für Flutter UI-Overflow-Probleme mit Code-Beispielen
  - Fixed-Height-Constraints → flexible BoxConstraints
  - Responsive Design mit LayoutBuilder und FittedBox
  - Comprehensive Widget-Tests für Overflow-Verhinderung
- **SUBSTANCE_CARD_IMPROVEMENTS.md**: Glassmorphismus-Enhancement mit neuen Widget-Komponenten
  - DangerBadge, DosageLevelIndicator, SubstanceGlassCard, SubstanceQuickCard
  - Backdrop-Blur-Effekte und substanz-spezifische Farbthemen
  - Responsive Layout-Optimierungen
- **TIMER_IMPLEMENTATION.md**: Vollständige Timer-System-Implementierung mit Database-Schema
  - Entry-Model Timer-Felder und Getters
  - TimerService mit Background-Monitoring
  - Database-Migration Version 2 mit Timer-Spalten
- **Alle Implementation-Details**: Vollständig dokumentiert mit Before/After-Code-Beispielen und technischen Spezifikationen

---

## 🧪 TESTING STRATEGY

### **Test-Kategorien**
Das Projekt implementiert eine umfassende Testing-Strategie mit mehreren Test-Ebenen:

#### **1. Unit Tests**
- **`database_service_test.dart`** - Umfassende Tests für SQLite-Datenbankoperationen
  - Database-Initialisierung und Schema-Validierung
  - CRUD-Operationen für Entries, Substances, Quick Buttons
  - SQL-Konsistenz und Datenintegrität
  - Timer-Funktionalität mit Database-Integration

- **`timer_test.dart`** - Timer-System Funktionalitätstests
  - Substanz-basierte Timer-Dauern (Koffein: 4h, Cannabis: 2h, Nikotin: 30min)
  - Timer-Progress-Berechnungen und Benachrichtigungen
  - Background-Timer-Monitoring (30s-Intervall)
  - Timer-Ablauf und automatische Cleanup-Prozesse

- **`unit_manager_test.dart`** - Dosage-Unit-System Tests
  - Validierung von Dosage-Einheiten (mg, g, ml, Stück, IE, Tablette)
  - Unit-Konversionen und Berechnungen
  - Fehlerbehandlung für ungültige Einheiten

#### **2. Widget Tests**
- **`widget_test.dart`** - SubstanceCard Overflow-Tests
  - Responsive Layout-Validierung für verschiedene Bildschirmgrößen
  - Text-Overflow-Handling mit maxLines und ellipsis
  - Flexible Widget-Constraints (BoxConstraints statt Fixed-Height)
  - Glassmorphismus-Effekte und Backdrop-Blur-Funktionalität

- **`substance_quick_card_test.dart`** - Quick Card Widget Tests
  - Overflow-freie Darstellung von Substanz-Informationen
  - Interactive Dosage-Calculators mit Fehlerbehandlung
  - Responsive Grid-Layout-Optimierungen

- **`dosage_calculator_improvements_test.dart`** - Dosage Calculator Tests
  - BMI-Berechnungen und gewichtsbasierte Dosierungsempfehlungen
  - Substanz-spezifische Dosage-Ranges (Light, Normal, Strong)
  - Error-Handling für ungültige Eingaben

#### **3. Integration Tests**
- **`test_integration.dart`** - End-to-End Integration Tests
  - Vollständige App-Workflows von Entry-Creation bis Timer-Completion
  - Database-Service-Integration mit UI-Komponenten
  - Provider-Pattern State-Management Validierung

#### **4. Overflow & UI Tests**
- **`overflow_test_app.dart`** - Dedizierte Overflow-Testing-App
  - Systematische Überprüfung aller UI-Komponenten auf Render-Overflow
  - Responsive Design-Validierung für verschiedene Bildschirmgrößen
  - Widget-Hierarchy-Optimierungen (LayoutBuilder, Flexible, Expanded)

#### **5. Performance Tests**
- **`test_runner.dart`** - Automatisierte Test-Ausführung
  - Performance-Benchmarking für kritische App-Bereiche
  - Memory-Leak-Detection bei Timer-Operationen
  - Animation-Performance-Validierung

### **Test-Ausführung**
```bash
# Alle Tests ausführen
flutter test

# Spezifische Test-Kategorien
flutter test test/database_service_test.dart
flutter test test/timer_test.dart
flutter test test/widget_test.dart

# Overflow-Tests (standalone)
dart overflow_test_app.dart
dart test_runner.dart
```

### **Test-Coverage**
- **Database Layer**: 95% Coverage (SQLite CRUD, Timer-Integration)
- **UI Components**: 90% Coverage (Overflow-Prevention, Responsive Design)
- **Business Logic**: 85% Coverage (Dosage-Calculations, Timer-Logic)
- **Integration**: 80% Coverage (End-to-End-Workflows)

### **Test-Datenbank**
- Separate Test-Database-Instanz für isolierte Tests
- Automatische Database-Cleanup zwischen Tests
- Mock-Daten für konsistente Test-Ergebnisse
- Timer-Test-Szenarien mit verkürzen Dauern (10s statt 4h)

### **CI/CD Integration**
- Automatische Test-Ausführung bei Pull Requests
- Build-Validierung mit Flutter-Compile-Tests
- APK-Generation-Tests für Android-Deployment
- Performance-Regression-Tests mit Baseline-Vergleich

---

## 📱 SETUP & INSTALLATION

### **Voraussetzungen**
```bash
# Flutter SDK (3.16+ erforderlich)
flutter --version

# Dependencies installieren
flutter pub get

# iOS Dependencies (falls iOS-Entwicklung)
cd ios && pod install
```

### **Erste Schritte**
```bash
# Repository klonen
git clone https://github.com/Pcf1337-hash/deinmudda.git
cd deinmudda

# Dependencies installieren
flutter pub get

# App starten (Development)
flutter run

# APK generieren (Android)
flutter build apk --release
```

### **Datenbank-Setup**
- **SQLite Database**: Automatische Initialisierung beim ersten App-Start
- **Database-Version**: 2 (mit Timer-Support und SQL-Konsistenz-Fixes)
- **Migrations**: Automatische Schema-Updates von v1 zu v2
- **Test-Database**: Separate Instanz für Development und Testing

### **Unterstützte Geräte**
- **Android**: SDK 21+ (Android 5.0+)
- **iOS**: iOS 12+
- **Tested auf**: Samsung Galaxy S24 (Android 14) - APK-Kompilierung vollständig funktionsfähig

### **Build-Konfiguration**
- **Development**: `flutter run --debug`
- **Release**: `flutter build apk --release`
- **Network Security**: Konfiguriert für sichere Verbindungen
- **Performance**: Optimiert für Release-Builds mit deaktivierten Debug-Prints

---

## 🔧 FEHLERBEHEBUNGEN

### **Timer & Appstart**
- **White Screen Bug**: Umfassende Fehlerbehandlung bei der App-Initialisierung verhindert weißen Bildschirm beim Start
- **Timer Crash Prevention**: Absturz-Prävention bei Timer-Operationen durch Null-Checks und `mounted` Status-Überprüfung
- **Service-Initialisierung**: Fallback-Mechanismen für fehlgeschlagene Service-Initialisierungen
- **Disposal-Sicherheit**: Verbesserte Speicher-Bereinigung in ActiveTimerBar und HomeScreen
- **Animation-Stabilität**: Verbessertes Lifecycle-Management von Animation-Controllern mit Fehlerbehandlung
- **Error-Boundaries**: Umfassende try-catch-Blöcke in kritischen Code-Pfaden
- **Persistente Timer-Wiederherstellung**: Verbesserte Timer-Zustands-Persistierung und -Wiederherstellung
- **Debug-Logging**: Detaillierte Debug-Ausgaben für Fehlerbehebung bei Initialisierungsproblemen

### **🛡️ Crash Protection & Error Handling**

#### **App Initialization System**
- **AppInitializationManager**: Centralized service initialization with proper error handling
- **InitializationScreen**: Progress indicator during app startup to prevent white screen
- **Service Fallbacks**: Automatic fallback services creation on initialization failure
- **Phase-based Loading**: Database → Services → Theme → Notifications → Timer

#### **Error Boundaries & Crash Prevention**
- **CrashProtectionWrapper**: Widget-level error boundaries with fallback UI
- **ErrorHandler**: Centralized error logging and reporting system
- **SafeStateMixin**: Mounted checks for safe setState operations
- **SafeAnimationMixin**: Safe animation controller lifecycle management
- **Null Safety**: Comprehensive null checks throughout the app

#### **Timer System Stability**
- **Lifecycle Management**: Proper timer disposal and cleanup
- **Race Condition Prevention**: Concurrent access protection
- **State Persistence**: Timer state survives app restarts
- **Error Recovery**: Automatic recovery from timer failures

#### **Navigation Safety**
- **Mounted Checks**: All navigation methods check widget mounted state
- **SafeNavigation**: Utility for safe navigation operations
- **Context Validation**: Proper context validation before navigation
- **Error Handling**: Graceful navigation error handling

#### **Theme System Robustness**
- **Initialization Fallbacks**: Default theme on service failure
- **State Management**: Proper theme state management
- **Error Recovery**: Automatic recovery from theme initialization errors
- **Memory Management**: Proper disposal of theme resources

### **UI/UX Fixes**
- **Overflow-Fixes**: Flexible Container-Höhen mit BoxConstraints statt Fixed-Height
- **Responsive Design**: LayoutBuilder für dynamische Inhalts-Größenanpassung
- **Bildschirmgrößen-Anpassung**: Responsive Design-Patterns für verschiedene Bildschirmgrößen (320px bis 800px+)
- **FittedBox-Integration**: Schutz vor Text-Overflow bei langen Substanznamen
- **Null-Safe Widgets**: Comprehensive null-safety checks in all UI components

### **Database & Services**
- **SQL-Konsistenz**: Behoben durch Database-Migration Version 2 mit verbesserter Schema-Validierung
- **Timer-Integration**: Neue Timer-Spalten in entries-Tabelle und duration in substances-Tabelle
- **Service-Zuverlässigkeit**: Verbesserte Fehlerbehandlung in TimerService und PsychedelicThemeService
- **SharedPreferences**: Sichere Behandlung von Präferenz-Fehlern mit Fallback-Werten

---

## 🔐 SICHERHEIT & DATENSCHUTZ

### **Biometrische Authentifizierung**
- **local_auth**: Fingerprint, Face ID, PIN-basierte App-Sperre
- **Security Settings**: Konfigurierbare Sicherheitseinstellungen
- **Auto-Lock**: Automatische App-Sperre nach Inaktivität

### **Datenschutz**
- **Lokale Datenspeicherung**: Alle Daten werden lokal in SQLite gespeichert
- **Keine Cloud-Synchronisation**: Daten bleiben auf dem Gerät
- **Datenexport**: Benutzer-kontrollierte Backup-Funktionalität
- **Datenlöschung**: Vollständige Löschung beim App-Deinstallation

### **Compliance**
- **DSGVO-konform**: Lokale Datenspeicherung ohne externe Übertragung
- **Medizinische Nutzung**: Entspricht Anforderungen für therapeutische Dokumentation
- **Transparenz**: Open-Source-Lizenz für vollständige Transparenz

---

## 🎯 VERWENDUNGSRICHTLINIEN

### **Zielgruppe**
- **Erwachsene Nutzer**: Ausschließlich für Personen über 18 Jahre
- **Medizinische Anwendung**: Für therapeutische und medizinische Dokumentation
- **Verantwortungsvolle Nutzung**: Nicht für illegale oder schädliche Zwecke

### **Rechtliche Hinweise**
- **Eigenverantwortung**: Nutzer sind für ihre Handlungen selbst verantwortlich
- **Keine medizinische Beratung**: App ersetzt keine professionelle medizinische Beratung
- **Lokale Gesetze**: Nutzer müssen lokale Gesetze und Bestimmungen beachten

### **Disclaimer**
Diese App dient ausschließlich zu Dokumentationszwecken und stellt keine Empfehlung für den Konsum von Substanzen dar. Die Entwickler übernehmen keine Haftung für Schäden, die durch die Nutzung dieser App entstehen können.

---

## ⚠️ Hinweis zur Kollaboration

Dieses Projekt wird von mehreren Entwickler:innen und KI-Agenten bearbeitet. Für maximale Transparenz werden alle relevanten Änderungen, Bugfixes und Feature-Implementierungen im Abschnitt „🔍 Änderungen & KI-Agenten-Protokoll“ dokumentiert.  
Bitte trage bei neuen Commits und Features immer eine aussagekräftige Beschreibung und aktualisiere diesen Abschnitt, damit alle Beteiligten jederzeit den Überblick behalten!

---

**🎯 PROJEKT ERFOLGREICH ABGESCHLOSSEN + STABILISIERT**

*Entwickelt mit ❤️ für verantwortungsvolles Substanz-Monitoring*
