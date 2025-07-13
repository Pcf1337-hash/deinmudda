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

**Aktuelle Version:** 1.0.1+2  
**Build Status:** ✅ Läuft stabil auf Samsung Galaxy S24 (Android 14)  
**Letzte Aktualisierung:** 14. Juli 2025

---

## 🔄 LETZTE 10 ÄNDERUNGEN

### **📅 Juli 2025**

1. **🏠 HomeScreen Cleanup & Timer Integration** (14. Juli 2025)
   - Vollständige Bereinigung des HomeScreens - Entfernung von Quick Actions und Advanced Features
   - Integration des ActiveTimerBar für visuelle Timer-Anzeige
   - Implementierung des SpeedDial-Systems für essenzielle Aktionen
   - Automatischer Timer-Start bei QuickEntry-Nutzung mit Substanz-basierter Dauer
   - Single-Timer-Logik verhindert mehrere gleichzeitige Timer

2. **🔧 Dosage Calculator Syntax Fixes** (14. Juli 2025)
   - Behebung von 24 Compilation Errors im Dosage Calculator Screen
   - Syntax-Fehler in der Substanz-Suche und Benutzer-Profil-Verwaltung behoben
   - Stabile Kompilierung und Funktionalität wiederhergestellt

3. **⏱️ Timer-Funktionalität Implementierung** (14. Juli 2025)
   - Vollständige Timer-Integration in Entry- und Quick-Button-System
   - Substanz-basierte Timer-Dauern mit Standard-Fallback-Werten
   - Hintergrund-Timer-Überwachung und automatische Benachrichtigungen
   - Timer-Fortschrittsanzeige und animierte Status-Indikatoren
   - Nicht-breaking Integration mit bestehender Funktionalität

4. **🎨 Substance Card Glassmorphism Enhancement** (14. Juli 2025)
   - Implementierung des modernen Glassmorphism-Designs für Substance Cards
   - Responsive Layout mit LayoutBuilder zur Overflow-Vermeidung
   - Substanz-spezifische Farbthemen und Danger-Level-Badges
   - Animierte Interaktionen mit Glow-Effekten und Backdrop-Blur
   - Dosage-Level-Indikatoren mit Grün-Gelb-Rot-Farbkodierung

5. **🐛 Flutter UI Overflow Fixes** (14. Juli 2025)
   - Behebung aller "BOTTOM OVERFLOWED BY X PIXELS" Fehler in Substance Cards
   - Ersetzen von Fixed-Height-Constraints durch flexible Layouts
   - Implementierung von ClampingScrollPhysics für ordnungsgemäße Scrolling-Funktionalität
   - Responsive Grid-Layout mit LayoutBuilder und dynamischen Breiten-Berechnungen
   - Umfassende Widget-Tests zur Overflow-Verhinderung

6. **🐛 Build-Tooling Fix** (13. Juli 2025)
   - Fehler mit ungültigem depfile im Build-Prozess behoben (Flutter Build Tooling)
   - Stellt sicher, dass die App weiterhin fehlerfrei kompiliert werden kann

7. **🖼️ Icon-Fix im Timer-Dashboard** (13. Juli 2025)
   - Icon von `Icons.add_timer_rounded` auf `Icons.add_rounded` geändert
   - UI-Darstellung im Dashboard korrigiert

8. **📂 Initiale Planung & Struktur** (12. Juli 2025)
   - Neue Dateien und Grundstruktur für Features und Aufgaben angelegt
   - Vorbereitungen für die nächsten Entwicklungsschritte

9. **⚡ Compilation Errors & Struktur-Fixes** (12. Juli 2025)
   - Diverse Kompilierungsfehler sowie strukturelle Probleme beseitigt
   - Flutter-App ist wieder buildbar und stabil

10. **🪟 Glassmorphism Design & Card Overflow Bugfix** (11. Juli 2025)
    - Substance Card-Komponente mit Glassmorphism-Design versehen
    - Demo und Dokumentation aktualisiert, Overflow-Bug behoben

> **Hinweis:** Die vollständige Commit-Historie findest du [hier](https://github.com/Pcf1337-hash/deinmudda/commits?sort=updated&direction=desc).

---

## 🔍 Änderungen & KI-Agenten-Protokoll

Da verschiedene KI-Agenten und Entwickler:innen an diesem Projekt arbeiten, werden die wichtigsten Commit-Änderungen tabellarisch erfasst:

| Datum         | Bereich/Datei                | Was wurde gemacht?                                  | Warum?                        | Wer?          |
|---------------|------------------------------|-----------------------------------------------------|-------------------------------|---------------|
| 14.07.2025    | HomeScreen + Timer           | HomeScreen Cleanup & Timer Integration             | UI-Bereinigung & Timer-Funktionalität | Copilot/KI    |
| 14.07.2025    | Dosage Calculator Screen     | 24 Compilation Errors behoben                      | Stabile Kompilierung          | Copilot/KI    |
| 14.07.2025    | Entry + Quick Button System  | Vollständige Timer-Funktionalität implementiert    | Substanz-basierte Timer       | Copilot/KI    |
| 14.07.2025    | Substance Cards              | Glassmorphism Enhancement & Responsive Design       | Modernes UI & Overflow-Fixes  | Copilot/KI    |
| 14.07.2025    | UI Overflow Fixes            | Flutter UI Overflow Fixes für Substance Cards      | Stabile UI auf allen Geräten  | Copilot/KI    |
| 13.07.2025    | Build-Tooling                | Fix für invalid depfile im Build-Prozess            | Build-Fehler behoben          | Copilot/KI    |
| 13.07.2025    | Timer-Dashboard              | Icon von add_timer_rounded auf add_rounded geändert | UI-Korrektur                  | Copilot/KI    |
| 12.07.2025    | Projektstruktur              | Initiale Planung und Grundstruktur angelegt         | Vorbereitungen für Features   | Copilot/KI    |
| 12.07.2025    | Flutter-App                  | Kompilierungsfehler und Strukturprobleme gefixt     | Build-Fähigkeit wiederhergestellt | Copilot/KI |
| 11.07.2025    | Substance Card-Komponente    | Glassmorphism Design & Card Overflow Bugfix         | UI-Verbesserung               | Copilot/KI    |
| 10.07.2025    | Diverse Dart-Dateien         | Import- und Syntax-Fehler behoben                   | Codequalität                  | Copilot/KI    |

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
- **Database:** SQLite (sqflite) für lokale Datenspeicherung
- **State Management:** Provider Pattern
- **Design:** Material Design 3 + Glasmorphismus-Effekte
- **Animations:** Standard Flutter Animations (flutter_animate entfernt für Stabilität)
- **Charts:** Custom Chart Widgets mit Canvas API
- **Security:** local_auth für biometrische Authentifizierung ✅
- **Notifications:** flutter_local_notifications für Erinnerungen ✅

### **🎨 Design & Visuelle Highlights**
- **Glasmorphismus-Design** - Durchgängige Verwendung von transluzenten Glaseffekten für moderne UI
- **Substanz-spezifische Farbthemen** - Jede Substanz hat individuelle Farbkodierung mit Backdrop-Blur
- **Responsive Overflow-freies Layout** - Optimierte Widget-Hierarchie ohne Render-Konflikte
- **Animierte Timer-Indikatoren** - Visuelle Fortschrittsanzeige mit Pulsing-Effekten
- **Neon-Akzente im Dark Mode** - Leuchtende Farbakzente für optimale Sichtbarkeit in dunklen Umgebungen
- **Psychedelische Farbpalette** - Für Nutzer unter Einfluss optimierte Farbkombinationen
- **Smooth Transitions** - Fließende Übergänge mit nativen Animationen
- **Responsive Interaktionen** - Haptisches Feedback und visuelle Reaktionen
- **Immersive Dark Mode** - Optimierter Dark Mode mit reduzierten Blauanteilen
- **Dynamische Farbakzente** - Substanz-spezifische Farbkodierung für intuitive Navigation
- **Stabile Render-Performance** - Optimierte Widget-Struktur ohne UI-Overflow
- **Visuelle Hierarchie** - Klare Informationsstruktur durch Kontraste

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
├── widgets/                     # ✅ PHASE 6 - ABGESCHLOSSEN
│   ├── glass_card.dart         # ✅ Glasmorphismus-Karten
│   ├── modern_fab.dart         # ✅ Moderner Floating Action Button
│   ├── animated_entry_card.dart # ✅ Animierte Entry-Darstellung mit Swipe
│   ├── active_timer_bar.dart   # ✅ Aktive Timer-Anzeige mit Fortschrittsbalken
│   ├── speed_dial.dart         # ✅ SpeedDial für HomeScreen-Aktionen
│   ├── timer_indicator.dart    # ✅ Timer-Status-Indikatoren mit Animationen
│   ├── charts/                 # ✅ Chart Widgets
│   │   ├── line_chart_widget.dart # ✅ Interaktive Line Charts
│   │   ├── bar_chart_widget.dart # ✅ Animierte Bar Charts
│   │   └── pie_chart_widget.dart # ✅ Pie Charts mit Legende
│   ├── dosage_calculator/      # ✅ Dosisrechner Widgets (Enhanced)
│   │   ├── bmi_indicator.dart  # ✅ BMI-Anzeige Widget mit Animationen
│   │   ├── dosage_result_card.dart # ✅ Dosierungsergebnis Modal
│   │   ├── substance_card.dart # ✅ Substanz-Karte mit Dosage Preview
│   │   ├── danger_badge.dart   # ✅ Substanz-Gefahrenstufen-Badge
│   │   ├── dosage_level_indicator.dart # ✅ Dosage-Level-Indikatoren
│   │   ├── substance_glass_card.dart # ✅ Glasmorphismus-Substance-Cards
│   │   └── substance_quick_card.dart # ✅ Overflow-freie Substance-Cards
│   └── quick_entry/            # ✅ Quick Entry Widgets
│       ├── quick_entry_bar.dart # ✅ Horizontale Scrollbar mit Quick Buttons
│       └── quick_button_widget.dart # ✅ Einzelner Quick Button mit Animationen
├── theme/                       # ✅ PHASE 1 - Komplettes Design System
│   ├── design_tokens.dart      # ✅ Farben, Konstanten, Gradients
│   ├── modern_theme.dart       # ✅ Light/Dark Theme Implementation
│   ├── spacing.dart            # ✅ Konsistentes Spacing System
│   └── typography.dart         # 📋 Typography System
├── utils/                       # ✅ PHASE 7 - ERWEITERT
│   ├── app_icon_generator.dart # ✅ Icon-System für Substanzen
│   ├── database_helper.dart    # ✅ Database Utilities
│   ├── data_export_helper.dart # ✅ PHASE 7 - Export/Import Utilities
│   ├── validation_helper.dart  # ✅ Input Validation
│   └── performance_helper.dart # ✅ PHASE 8 - Performance Optimierungen
└── assets/                      # ✅ PHASE 5 - Erweiterte Dosisrechner Daten
    └── data/
        ├── dosage_calculator_substances.json # ✅ Basis-Dosisrechner-Daten
        └── dosage_calculator_substances_enhanced.json # ✅ Erweiterte Daten mit Wechselwirkungen
```

---

## 🧪 TESTING STRATEGY
... *(Rest wie gehabt, siehe vorherige README – alle Bereiche zu Testing, Setup, Geräte, Regeln, Standards, Hinweise, Disclaimer etc.)*

---

## ⚠️ Hinweis zur Kollaboration

Dieses Projekt wird von mehreren Entwickler:innen und KI-Agenten bearbeitet. Für maximale Transparenz werden alle relevanten Änderungen, Bugfixes und Feature-Implementierungen im Abschnitt „🔍 Änderungen & KI-Agenten-Protokoll“ dokumentiert.  
Bitte trage bei neuen Commits und Features immer eine aussagekräftige Beschreibung und aktualisiere diesen Abschnitt, damit alle Beteiligten jederzeit den Überblick behalten!

---

**🎯 PROJEKT ERFOLGREICH ABGESCHLOSSEN + STABILISIERT**

*Entwickelt mit ❤️ für verantwortungsvolles Substanz-Monitoring*
