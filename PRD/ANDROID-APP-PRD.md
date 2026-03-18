# AWAVE iOS Documentation Index

**Last Updated:** February 2026

---

## 🧭 Nordstern für die Android-App

**Die aktuelle iOS-App ist die verbindliche Baseline für die Android-Entwicklung.**

- 📄 [**ANDROID-NORDSTERN.md**](../../ANDROID-NORDSTERN.md) – Vollständiger Nordstern: implementierte Features, Tech-Stack (iOS → Android), Quick Reference zu allen Anforderungen und Handover-Docs. **Startpunkt für das Android-Team.** (File lives at `docs/ANDROID-NORDSTERN.md`.)
- Parity-Backlog (Features aus OLD-APP/Web noch nicht in iOS): `Requirements/APP-Feature Description/Backlog-Parity-OLD-APP-and-Web/README.md`
- Requirements-Update (Swift/Firebase statt React/Supabase): `Requirements/REQUIREMENTS_UPDATE_GUIDE.md`

---

## 📚 Recent Implementations

### February 2026: Category-Screens Schlaf-Parität (Flow & Ruhe) und Cleanup

**Status:** Implementiert – RuheScreen und ImFlussScreen entsprechen dem SchlafScreen (Hero → Full-Player, CategorySessionGeneratorBlock, Klangwelten mit Mixes, Favoriten, favorisierte Sessions). Verwaiste Screens (Session-Übersicht, Alle Sounds, Alle Kategorien) und zugehörige Views entfernt; project.pbxproj und UIRequiresFullScreen bereinigt.

**Dokumentation:**
- 📄 [**HANDOVER_CATEGORY_SCREENS_SCHLAF_PARITY_AND_CLEANUP.md**](./handovers/HANDOVER_CATEGORY_SCREENS_SCHLAF_PARITY_AND_CLEANUP.md) – Abschlussbericht, geänderte/gelöschte Dateien, Referenzen

---

### February 2026: Onboarding – Analytics-Consent als Toast

**Status:** Implementiert – Consent-Abfrage erscheint als Toast mit Ja/Nein nach dem Preloader während der OnboardingJourney; inline-Sektion auf dem Fragen-Screen entfernt.

**Dokumentation:**
- 📄 [**ONBOARDING-ANALYTICS-CONSENT-TOAST.md**](./ONBOARDING-ANALYTICS-CONSENT-TOAST.md) – Ablauf, geänderte Dateien, Technik

**Umsetzung:**
- **Neu:** `AnalyticsConsentToastView.swift` – Toast-UI mit Frage und Ja/Nein-Buttons (kein Auto-Dismiss)
- **OnboardingView:** State `showConsentToast`, Overlay oben; bei Ja/Nein Firestore-Update für eingeloggte User
- **CategorySelectionView:** Inline-Consent-Sektion und Parameter entfernt
- **Gelöscht:** `OnboardingAnalyticsConsentSection.swift`; danach `xcodegen generate` ausführen

---

### February 2026: Trial (7 Tage) – Erinnerung 48h & 12h (Push + E-Mail)

**Status:** Implementiert – StoreKit-Sync mit trialEndsAt/expiresAt; Cloud Function 48h/12h mit Push und E-Mail (Resend). Optional: E-Mail über Trigger Email from Firestore (SMTP).

**Dokumentation:**
- 📄 [**TRIAL-IMPLEMENTATION-SUMMARY.md**](./TRIAL-IMPLEMENTATION-SUMMARY.md) – Technische Zusammenfassung, geänderte Dateien, Option Trigger Email
- 📄 [**FIREBASE_TRIAL_REMINDER_SETUP.md**](./FIREBASE_TRIAL_REMINDER_SETUP.md) – Firebase-Einrichtung (Secrets, Resend oder Trigger Email/SMTP), Firestore-Struktur, Deploy

**Umsetzung:**
- **iOS:** `StoreKitManager.swift` – Trial/Expiration aus StoreKit 2, Cache für Firestore-Sync (`trialEndsAt`, `expiresAt`, `status`); `SubscriptionStateLogic` + Unit-Tests in `StoreKitManagerTests.swift`
- **Backend:** `functions/src/index.ts` – Scheduled Job alle 2 h, 48h- und 12h-Fenster, Push + E-Mail (Resend), Duplikat-Marker `trialReminder48hSentForTrialEndsAt` / `trialReminder12hSentForTrialEndsAt`

**Nächste Schritte (optional):** Cloud Function auf Firestore-Collection `mail` umstellen, wenn Trigger Email from Firestore (SMTP) genutzt wird; siehe FIREBASE_TRIAL_REMINDER_SETUP.md (Variante B).

---

### February 2026: Home Screen Refactoring

**Status:** ✅ Abgeschlossen – Handover und Abschlussbericht erstellt.

**Dokumentation:**
- 📄 [**HANDOVER_HOME_SCREEN_REFACTORING.md**](./homescreen/HANDOVER_HOME_SCREEN_REFACTORING.md) – Handover: Navigation, Tabs, wichtige Dateien, Build, Rollback
- 📄 [**ABSCHLUSSBERICHT_HOME_SCREEN_REFACTORING.md**](./homescreen/ABSCHLUSSBERICHT_HOME_SCREEN_REFACTORING.md) – Vollständiger Abschlussbericht mit allen bearbeiteten Dateien und Code-Snippets
- 📋 [**home-screen-regactoring.md**](./homescreen/home-screen-regactoring.md) – Ursprünglicher Plan

**Umsetzung:** Navigation auf Home/Kategorien/Klänge/Suche/Profil umgestellt; Category Overview → Detail (Schlaf/Ruhe/Im Fluss); generierte Sessions auf Home; Flugmodus-Icon und Offline-Toast auf Session-Kacheln; Klangwelten aus Category-Screens entfernt und als eigener Tab. Backup: `backup/` + `backup/README.md`.

**Nächste Schritte (optional):** Home-Favoriten gruppiert nach Kategorie; QA für Navigation, Offline und Download.

---

### February 2026: Category Management & Navigation Refactoring

**Status:** ✅ Complete - Ready for Integration Testing

**Key Documents:**
1. 📋 [**Implementation Summary**](./IMPLEMENTATION-SUMMARY-Feb-2026.md) - Quick overview of what was done
2. 🤝 [**Handover Documentation**](./HANDOVER-Category-Management-Implementation.md) - Comprehensive technical handover
3. 📖 [**Navigation Requirements**](./Requirements/APP-Feature%20Description/Navigation/requirements.md) - Updated with category management features

**What Was Implemented:**
- 5-tab category-based navigation (Sleep/Stress/Flow/Search/Profile)
- Production UI for changing home category (exceeds React app!)
- Full authentication flow integration (sign-in/sign-out/registration)
- Tab switching auto-saves category preference
- Search drawer with history stacking
- Developer tools for testing

**Files Created:**
- `TabSelectionService.swift` - Initial tab determination
- `CategorySelectionSheet.swift` - Category change UI
- `SchlafScreen.swift`, `RuheScreen.swift`, `ImFlussScreen.swift` - Category screens
- Documentation: Handover, Summary, Requirements updates

**Next Steps:**
- Backend team: Implement category sync API
- QA team: Integration testing with backend
- Development team: Clean up old view files

---

### Cursor & XcodeBuildMCP (February 2026)

**Status:** Konfiguriert – Cursor-Agent kann Xcode-Builds und Simulator per MCP steuern.

**Dokumentation:**
- 📄 [**CURSOR-XCODEBUILD-MCP-SETUP.md**](./CURSOR-XCODEBUILD-MCP-SETUP.md) – Setup, Konfiguration (.cursor/mcp.json), optional Xcode/Codex, Skill, Nutzung

**Relevante Dateien:** `.cursor/mcp.json`, optional `.codex/config.toml` für Xcode-Agent.

---

### Build/Simulator-Session & iOS 26 Deployment Target (February 2026)

**Status:** Abgeschlossen – Projekt einheitlich auf iOS 26 ausgerichtet; Build/Simulator per CLI getestet.

**Dokumentation:**
- 📄 [**SESSION-SUMMARY-BUILD-AND-IOS26.md**](./SESSION-SUMMARY-BUILD-AND-IOS26.md) – Session-Zusammenfassung: Clean/Build/Run per Terminal, Deployment-Target-Konflikt behoben, finale Ausrichtung auf iOS 26.

**Geänderte Codebase:** Keine App-Code-Änderungen. `AWAVE/project.yml` bereits iOS 26.2; alle sechs lokalen SPM-Pakete (`Packages/*/Package.swift`) mit `platforms: [.iOS(.v26)]`. Docs: SETUP.md, README.md (Min-iOS auf 26), DOCUMENTATION-INDEX (dieser Eintrag).

---

### Session-Generierung: Dauer-Cap & keine Demo-Texte (February 2026)

**Status:** Implemented – Sessionlänge überschreitet die Nutzerauswahl nicht mehr; Voice-Content-IDs haben keinen Demo-Fallback.

**Änderungen:**
- **Dauer:** `CategorySessionGenerator` skaliert anhand der **tatsächlichen** Session-Gesamtdauer; `scale = min(1.0, targetSeconds / totalUnscaled)`. Gewählte Maximaldauer (z. B. 30 min) wird strikt eingehalten.
- **Voice:** `SessionContentMapping` liefert für Voice-IDs (z. B. `franca/sleep/intro`) nur noch Werte aus Bundle-JSON oder Firestore – keine Demo-Konvention mehr. Unaufgelöste IDs → offlineError.

**Geänderte/neu Dateien:** `CategorySessionGenerator.swift`, `SessionContentMapping.swift`, `CategorySessionGeneratorTests.swift`, `SessionContentMappingTests.swift` (neu). Handover-Update: `HANDOVER-Session-Sounds-Player-Mixer.md`.

**Zusammenfassung:** [docs/SESSION-GENERATION-FIX-SUMMARY.md](./SESSION-GENERATION-FIX-SUMMARY.md).

---

### Session-Sounds (Franca & weitere) in Player/Mixer (February 2026)

**Status:** Implemented – SessionContentMapping (bundle JSON + Noise-Konvention; **kein** Voice-Demo-Fallback mehr), pre-resolve validation, offlineError for unresolved content IDs. Guided Sessions: Sounds per ID, offlineError bei fehlender Stimme.

**Abschlussbericht (Handover, Zusammenfassung, Aufräumen):**
- 📄 [**HANDOVER-ABSCHLUSSBERICHT-Session-Sounds-Player-Mixer.md**](./HANDOVER-ABSCHLUSSBERICHT-Session-Sounds-Player-Mixer.md) – **Abschlussbericht:** Lösungsthemen, geänderte Dateien, Referenzen, Arbeitsplatz aufgeräumt, offene Punkte.

**Handover & Analyse:**
- 📄 [**HANDOVER-Session-Sounds-Player-Mixer.md**](./HANDOVER-Session-Sounds-Player-Mixer.md) – Detail-Handover: Anforderung, Plan, Implementierungsstand, Content-ID-Schema, offene Aufgaben.
- 📄 [**ANALYSIS-Session-Audio-Database-Relationships.md**](./ANALYSIS-Session-Audio-Database-Relationships.md) – Systeme, Audiodaten ↔ Firestore, keine Demo-Texte, Text-Auflösung ohne Loading-Errors.

**Changed/added files:** `SessionContentMapping.swift`, `PlayerViewModel.swift`, `SessionContentMapping.json`, `GuidedSessionDetailView.swift`; Tests; `ANALYSIS-Session-Audio-Database-Relationships.md`, Handover-Updates. Kein Voice→Demo-Fallback; Text nur über Firestore contentId oder explizites JSON-Mapping.

---

### Transport-Leiste Refactor: Session generieren + Favoriten, Overlay entfernt (February 2026)

**Status:** Abgeschlossen – Stop-Button entfernt; Transport-Leiste: links Session generieren (Major) / Zurück zur Auswahl (Klangwelten), Mitte Play, rechts Favoriten. Vertikales Icon-Overlay (Remix, Favoriten, Teilen) und Share entfernt; `PlayerActionIconsView.swift` gelöscht.

**Zusammenfassung:**
- 📄 [**TRANSPORT-BAR-REFACTOR-SUMMARY.md**](./TRANSPORT-BAR-REFACTOR-SUMMARY.md) – Geänderte Dateien, Layout-Tabelle, Referenzen

**Geänderte Dateien:** `FullPlayerView.swift`, `KlangweltenSoundDrawerView.swift`, `KlangweltenScreen.swift`; gelöscht: `PlayerActionIconsView.swift`. Nach Löschen: `cd AWAVE && xcodegen generate` ausführen.

---

### Mix speichern, Herz-Drawer, Kategorie-Favorit (February 2026)

**Status:** Implementiert – Ein Drawer für „Mix speichern“ und Herz (Major-Player + Klangwelten); Toast nach Speichern; Mix wird in der Kategorie als Favorit persistiert und erscheint im Kategorie-Screen. Hinweis: Favoriten-/Herz-Button liegt nach Transport-Leiste-Refactor in der Transport-Leiste (rechts neben Play), nicht mehr im Overlay.

**Handover (geänderte Codebase, Datenfluss, Checkliste):**
- 📄 [**HANDOVER-Mix-Speichern-Herz-Drawer-Kategorie.md**](./HANDOVER-Mix-Speichern-Herz-Drawer-Kategorie.md)

**Geänderte Dateien:**
- `AWAVE/AWAVE/Features/Player/FullPlayerView.swift` – Favoriten-Button in transportSection (rechts); MixerEmbeddedView mit onMixSavedInPlayer (Drawer schließen + Toast).
- `AWAVE/AWAVE/Features/Player/MixerSheetView.swift` – MixerEmbeddedView: onMixSavedInPlayer, favoriteCategoryRaw; saveMix() ruft addFavoriteSession auf und nutzt Rückgabewert (mix.id).
- `AWAVE/AWAVE/Features/Klangwelten/KlangweltenSoundDrawerView.swift` – Herz öffnet Mixer-Drawer, MixerEmbeddedView mit Callback und favoriteCategoryRaw (category?.rawValue).
- `AWAVE/AWAVE/Resources/Localizable.xcstrings` – Toast „Deine Session wurde in der Kategorie %@ gespeichert.“ (en: „Your session was saved in the category %@.“).

---

### Klangwelten-Mixer: Trennung und Transport-Leiste (February 2026)

**Status:** Implementiert – Klangwelten nutzt nur die dedizierte Soundbibliothek (Musik, Natur, Sound); keine Texte/geführten Meditationen im Picker. Transport-Leiste bleibt nach Mixer-Nutzung sichtbar.

**Zusammenfassung:**
- 📄 [**KLANGWELTEN-MIXER-SEPARATION-SUMMARY.md**](./KLANGWELTEN-MIXER-SEPARATION-SUMMARY.md) – Parameter, Aufrufer, geänderte Dateien, Hinweis zum Offline-Dialog

**Umsetzung:**
- `MixerEmbeddedView`: Parameter `restrictToKlangweltenCatalog`; bei true alle drei Slots „Sound hinzufügen“, Picker mit `restrictToKlangwelten: true`.
- `SoundPickerView`: Parameter `restrictToKlangwelten`; bei true nur .music, .nature, .sound (Filter + loadSounds).
- Aufrufer: KlangweltenSoundDrawerView und MixerSheetView mit `true`; FullPlayerView mit `player.playbackMode == .klangwelten`.
- KlangweltenSoundDrawerView: Transportzeile `.id("klangweltenTransport")`, nach Mixer-Schließen Scroll zu `klangweltenTransport`.

**Geänderte Dateien:** `MixerSheetView.swift`, `SoundPickerView.swift`, `KlangweltenSoundDrawerView.swift`, `FullPlayerView.swift`.

---

### Migration, Catalog, Audio & Supabase Retirement (February 2026)

**Status:** Documentation and scripts completed; open: link audio files in Firebase (upload + catalog JSON + run migration).

**Central handover (all files referenced, remaining work):**
- 📄 [**HANDOVER-MIGRATION-KATALOG-AUDIO-VOLLSTAENDIG.md**](./HANDOVER-MIGRATION-KATALOG-AUDIO-VOLLSTAENDIG.md) – Complete documentation: what was done, all referenced files, what remains (including linking audio files with Firebase).

**Core docs:**
- [seed-replaced-by-migration.md](guides/seed-replaced-by-migration.md) – Catalog migration, app/TestFlight verification
- [audio-to-firebase-handover.md](guides/audio-to-firebase-handover.md) – Audio → awave-app-bucket, fileURL
- [migration/catalog-format.md](migration/catalog-format.md) – JSON format for sound_metadata, sos_config
- [FIRESTORE_SCHEMA.md](FIRESTORE_SCHEMA.md) – Firestore schema, seeding

**Script:** `AWAVE/scripts/migrate-catalog-to-firestore.js` (catalog JSON → Firestore). Supabase references have been removed from the project.

---

## 📂 Documentation Structure

### Requirements Documentation
PRD docs are aligned with **iOS 26.2 / Swift 6.2** and reference the **Android North Star** ([ANDROID-NORDSTERN.md](../../ANDROID-NORDSTERN.md)).
```
docs/Requirements/
├── PRD/
│   ├── 01-PRD.md (✅ Feb 2026: platform, Android baseline)
│   ├── 02-FEATURE-SPECS.md (✅ Feb 2026: implementation context)
│   ├── 04-AUDIO-ARCHITECTURE.md (✅ Feb 2026: baseline note)
│   ├── 05-REQUIREMENTS-SUMMARY.md (✅ Feb 2026: ADR-05, Android ref)
│   ├── 06-PROJECT-INTEGRATION-PLAN.md (✅ Feb 2026: platform, baseline)
│   ├── 07-PRODUCTION-READY-OVERVIEW.md (✅ Feb 2026: baseline)
│   └── 08-TEST-COVERAGE-AND-UI-TESTS.md (✅ Feb 2026: scope)
│
└── APP-Feature Description/
    ├── Navigation/
    │   ├── README.md (✅ Updated Feb 2026)
    │   ├── requirements.md (✅ Updated Feb 2026)
    │   ├── technical-spec.md
    │   ├── user-flows.md
    │   ├── components.md
    │   └── services.md
    │
    ├── Authentication/
    ├── Onboarding/
    ├── Profile/
    └── [38 other features...]
```

### Implementation Documentation
```
docs/
├── ANDROID-NORDSTERN.md (at docs/; Nordstern für Android ✅)
├── IMPLEMENTATION-SUMMARY-Feb-2026.md (NEW ✅)
├── HANDOVER-Category-Management-Implementation.md (NEW ✅)
├── HANDOVER-Mix-Speichern-Herz-Drawer-Kategorie.md (Feb 2026 ✅)
├── HANDOVER-ABSCHLUSSBERICHT-Session-Sounds-Player-Mixer.md (Abschlussbericht Feb 2026 ✅)
├── HANDOVER-Session-Sounds-Player-Mixer.md | ANALYSIS-Session-Audio-Database-Relationships.md
├── DOCUMENTATION-INDEX.md (NEW ✅)
├── AWAVE-iOS-Documentation.md
├── AWAVE-Investigation-Report-v3.md
└── [other documentation files...]
```

---

## 🔍 Quick Reference

### Android (Nordstern)
- **Nordstern-Dokument:** [ANDROID-NORDSTERN.md](../../ANDROID-NORDSTERN.md) – Baseline für Android, alle implementierten Features, Tech-Mapping, Referenzen
- **Parity-Backlog:** `Requirements/APP-Feature Description/Backlog-Parity-OLD-APP-and-Web/README.md`

### Finding Information

**Navigation System:**
- Overview: `Requirements/APP-Feature Description/Navigation/README.md`
- Requirements: `Requirements/APP-Feature Description/Navigation/requirements.md`
- User Flows: `Requirements/APP-Feature Description/Navigation/user-flows.md`

**Category Management:**
- Handover: `HANDOVER-Category-Management-Implementation.md`
- Implementation: `IMPLEMENTATION-SUMMARY-Feb-2026.md`

**Transport-Leiste (Remix, Play, Favoriten):**
- Zusammenfassung: `TRANSPORT-BAR-REFACTOR-SUMMARY.md`

**Mix speichern, Herz-Drawer, Kategorie-Favorit:**
- Handover (Codebase, Datenfluss, Checkliste): `HANDOVER-Mix-Speichern-Herz-Drawer-Kategorie.md`
- Code: `FullPlayerView.swift`, `MixerSheetView.swift` (MixerEmbeddedView), `KlangweltenSoundDrawerView.swift`

**Session-Sounds, Guided Sessions, keine Demo-Texte:**
- Abschlussbericht (Handover): `HANDOVER-ABSCHLUSSBERICHT-Session-Sounds-Player-Mixer.md`
- Detail-Handover: `HANDOVER-Session-Sounds-Player-Mixer.md` | Analyse: `ANALYSIS-Session-Audio-Database-Relationships.md`

**Migration, Catalog & Audio (full handover):**
- Handover (all files, remaining work): `HANDOVER-MIGRATION-KATALOG-AUDIO-VOLLSTAENDIG.md`
- Katalog-Migration: `guides/seed-replaced-by-migration.md`, `migration/catalog-format.md`
- Audio → Firebase: `guides/audio-to-firebase-handover.md`, `guides/audio-transfer-to-firebase-storage.md`

**Cursor & XcodeBuildMCP:**
- Setup und Nutzung: `CURSOR-XCODEBUILD-MCP-SETUP.md`
- Config: `.cursor/mcp.json`, optional `.codex/config.toml`

**Trial (7 Tage) – Erinnerung & E-Mail:**
- Implementierung: `TRIAL-IMPLEMENTATION-SUMMARY.md`
- Firebase-Einrichtung (Resend oder Trigger Email/SMTP): `FIREBASE_TRIAL_REMINDER_SETUP.md`
- Code: `AWAVE/AWAVE/Managers/StoreKitManager.swift`, `AWAVE/functions/src/index.ts`

**Auth & E-Mail-Verifizierung (Registrierung):**
- Handover (Config, Emulator-Test, Scripts): [handovers/HANDOVER_EMAIL_VERIFICATION_AND_FIREBASE_MAIL.md](handovers/HANDOVER_EMAIL_VERIFICATION_AND_FIREBASE_MAIL.md)
- E-Mail-Testing ohne Dummy-Adressen: `FIREBASE_AUTH_EMAIL_TESTING.md`
- Auth-Setup & Fehlerbehebung: `FIREBASE_AUTH_SETUP.md`

**Onboarding & Analytics-Consent (Toast):**
- Handover: `ONBOARDING-ANALYTICS-CONSENT-TOAST.md`
- Code: `AWAVE/AWAVE/Features/Onboarding/` (OnboardingView, AnalyticsConsentToastView, CategorySelectionView)

**Code Location:**
- Navigation: `AWAVE/AWAVE/Navigation/`
- Onboarding: `AWAVE/AWAVE/Features/Onboarding/`
- Category Screens: `AWAVE/AWAVE/Features/Categories/`
- Profile: `AWAVE/AWAVE/Features/Profile/`
- Services: `AWAVE/AWAVE/Services/`

---

## ✅ Completed Features (Navigation)

- [x] Stack navigation with 20+ screens
- [x] Custom 5-tab navigation
- [x] Category-based tabs (Sleep/Stress/Flow)
- [x] Search tab with drawer
- [x] Profile tab
- [x] Tab state persistence
- [x] Initial tab from onboarding
- [x] Deep linking support
- [x] Route protection
- [x] **Category change UI (Production)** ✨ NEW
- [x] **Category auto-save on tab switch** ✨ NEW
- [x] **Search history stacking** ✨ NEW
- [x] **Sign-out resets category** ✨ NEW
- [x] **Dev tools for onboarding reset** ✨ NEW

---

## 🚧 TODO Items

### Backend Integration (High Priority)
- [ ] Implement category sync API endpoint
- [ ] Add category_preference field to user schema
- [ ] Sign-in category restore
- [ ] Registration category transfer
- [ ] Multi-device sync

### Code Cleanup
- [ ] Remove old HomeView.swift
- [ ] Remove old HomeViewModel.swift
- [ ] Remove old ExploreView.swift
- [ ] Remove old LibraryView.swift

### Testing
- [ ] Integration tests with backend
- [ ] Edge case testing
- [ ] Accessibility testing
- [ ] Performance benchmarks

### Documentation
- [ ] Update user guide
- [ ] Create video tutorials
- [ ] Update FAQ
- [ ] Migration guide for users

---

## 📞 Support

**Questions about implementation?**
- Read: `HANDOVER-Category-Management-Implementation.md`
- Summary: `IMPLEMENTATION-SUMMARY-Feb-2026.md`

**Questions about requirements?**
- Navigation: `Requirements/APP-Feature Description/Navigation/`
- Other features: `Requirements/APP-Feature Description/`

**Archived Plans:**
- `~/.claude/plans/completed/generic-jingling-quill-category-management-Feb-2026.md`

---

**Documentation Maintained By:** Development Team
**Last Review:** February 2026
**Next Review:** After backend integration testing

