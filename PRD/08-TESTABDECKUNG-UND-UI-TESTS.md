# 08 – Testabdeckung und UI-Testvorschläge

**Version:** 1.0  
**Status:** DRAFT  
**Datum:** 2026-02-04  

---

## 1. Zweck und Geltungsbereich

Dieses Dokument bündelt:

- eine **Analyse der aktuellen Testabdeckung** der AWAVE-iOS-App (gesamte App aus Testperspektive),
- **konkrete UI-Testvorschläge** für alle relevanten Screens und User Journeys inkl. Priorität und technischer Hinweise.

**Geltungsbereich:** Gesamte native iOS-App (AWAVE2-Swift).  
**Abgrenzung:**

- Detaillierte Akzeptanzszenarien (Given/When/Then) für F01–F16 liegen in [TEST_COVERAGE.md](../TEST_COVERAGE.md); dieses Dokument referenziert sie und ergänzt die Analyse sowie die fokussierten UI-Testvorschläge.
- Phasenplan und Ziele für Unit-Tests (Domain, Audio, SessionGenerator, CI) sind in [AWAVE-Test-Coverage-Plan.md](../../AWAVE-Test-Coverage-Plan.md) beschrieben; hier wird darauf verwiesen, nicht dupliziert.

---

## 2. Analyse der Testabdeckung

### 2.1 Zusammenfassung

| Art | Geschätzte Abdeckung | Anmerkung |
|----|----------------------|-----------|
| **Unit-Tests** | ~15–20 % | Domain, Audio, Auth, Category-Sessions, SessionGenerator; viele ViewModels/Services ohne Tests |
| **UI-Tests** | 0 % | Kein `AWAVEUITests`-Target vorhanden |
| **Integration** | 0 % | Keine automatisierten Tests für Firestore/Storage/Session Tracking |
| **Regression** | Manuell | Hohes Regressionsrisiko bei kritischen Flows |

### 2.2 Testabdeckung nach Modul/Feature

| Modul / Feature | Art | Status | Spec-Ref |
|-----------------|-----|--------|----------|
| AWAVEDomain (Entities) | Unit | Vorhanden | Session, PlaybackSession, UserStats, Sound, FrequencyType, NoiseType, ContentCategory, CustomMix, Favorite, etc. |
| AWAVECore | Unit | Vorhanden | KeychainService, HTTPClient, ColorHex, FoundationExtensions |
| AWAVEAudio | Unit | Vorhanden | FrequencyGenerator, ShepardEngine, PulseModulator, FrequencySweep, FrequencyModeEngine |
| AWAVEDesign / AWAVEFeatures / AWAVEData | Unit | Minimal / Platzhalter | — |
| Auth | Unit | Vorhanden | AuthViewModelTests |
| Category Screens (F04) | Unit | Vorhanden | CategorySessionsViewModel, CategorySessionGenerator |
| SessionGenerator (App) | Unit | Vorhanden | SessionGeneratorTests |
| SessionPreloadService | Unit | Vom Scheme ausgeschlossen | excludes in project.yml |
| Splash & Preloader (F01, F02) | UI/Unit | Fehlt | — |
| Main Menu & Navigation (F03) | UI/Unit | Fehlt | — |
| Onboarding | UI/Unit | Fehlt | — |
| Symptom Finder (F05) | UI/Unit | Fehlt | — |
| SOS Screen (F06) | UI/Unit | Fehlt | — |
| User Session Config (F07) | UI/Unit | Fehlt | — |
| Soundscapes / Explore (F08) | UI/Unit | Fehlt | — |
| Live Player (F09) | UI/Unit | Fehlt | — |
| After Session (F10) | UI/Unit | Fehlt | — |
| Favorites (F11) | UI/Unit | Fehlt | — |
| Profile, Support, Legal (F13) | UI/Unit | Fehlt | — |
| Upgrade / Subscription (F14) | UI/Unit | Fehlt | — |
| Dialog system (F16) | UI/Unit | Fehlt | — |
| HomeViewModel, LibraryViewModel, PlayerViewModel | Unit | Fehlt | — |
| OnboardingViewModel, SearchViewModel, SubscriptionViewModel | Unit | Fehlt | — |
| Firestore/Storage Repositories, Session Tracking | Integration | Fehlt | — |

### 2.3 Lücken

- **Kein UI-Test-Target:** In `project.yml` existiert nur `AWAVETests` (Unit); ein **AWAVEUITests**-Target (XCUIApplication) ist nicht definiert. Ohne UI-Target können keine automatisierten UI- oder User-Flow-Tests ausgeführt werden.
- **ViewModels ohne Unit-Tests:** HomeViewModel, LibraryViewModel, PlayerViewModel, OnboardingViewModel, SearchViewModel, SubscriptionViewModel, DownsellViewModel und weitere sind nicht durch Unit-Tests abgedeckt.
- **Services/Integration:** Keine automatisierten Tests für Firestore-/Storage-Repositories, Session Tracking oder Audio-Download; Player- und Playback-Logik sind nicht getestet.
- **Accessibility für UI-Tests:** Nur vereinzelt `accessibilityIdentifier` / `accessibilityLabel` (z. B. MainTabView, SoundCarouselView, KlangweltenScreen). Systematische IDs für zentrale Buttons, Tabs und Listen fehlen und sind Voraussetzung für stabile UI-Tests.

**Referenzen:** Detaillierte Szenarien und Gap-Analyse siehe [TEST_COVERAGE.md](../TEST_COVERAGE.md). Phasen und Ziele für Unit-Tests siehe [AWAVE-Test-Coverage-Plan.md](../../AWAVE-Test-Coverage-Plan.md).

---

## 3. UI-Testvorschläge

### 3.1 Technische Voraussetzungen

- **AWAVEUITests-Target:** Ein neues UI-Test-Target (z. B. `AWAVEUITests`) in `project.yml` anlegen, das die App startet und über XCUIApplication steuert. Keine Implementierung in diesem Dokument; nur Empfehlung.
- **Accessibility-IDs:** Für stabile Selektoren sollten zentrale Elemente (Tab Bar, Hauptbuttons, Listen, Suchfeld, Player-Controls) mit `.accessibilityIdentifier()` versehen werden. Bestehende Verwendung: z. B. MainTabView, SoundCarouselView, KlangweltenScreen; auf weitere Bereiche ausweiten.
- **Backend/Mocks:** UI-Tests sollten möglichst unabhängig von Live-Firebase laufen (Firebase Emulator oder injizierte Mocks). Konkrete Implementierung bleibt der Umsetzungsphase vorbehalten.

### 3.2 Smoke-Tests und Critical User Journeys

Die folgenden IDs werden aus [TEST_COVERAGE.md](../TEST_COVERAGE.md) übernommen und bilden den Kern der UI-Testvorschläge.

**Smoke-Tests (zuerst umsetzen):**

| ID | Beschreibung | Priorität |
|----|--------------|-----------|
| SMOKE-01 | App startet; Preloader oder Haupt-UI sichtbar | Kritisch |
| SMOKE-02 | Nach Preloader: Onboarding oder Main Tabs erreichbar | Kritisch |
| SMOKE-03 | Alle Haupt-Tabs (Home, Explore, Library, Search, Profile) tappbar und laden ohne Crash | Kritisch |
| SMOKE-04 | Beim Öffnen jedes Tabs kein Crash | Kritisch |

**Critical User Journeys (CUJ):**

| ID | Journey | Priorität | Spec |
|----|---------|-----------|------|
| CUJ-01 | Onboarding: Preloader → Onboarding → Kategorieauswahl → Main Tabs | Hoch | F01, F02, §3.2 |
| CUJ-02 | Session: Topic/Kategorie wählen → Session generiert → Session Config → Playback starten | Kritisch | F04, F07, F09 |
| CUJ-03 | Audio: Play → Timer/Fortschritt → Pause → Resume → Exit (oder Restart) | Kritisch | F09 |
| CUJ-04 | Subscription: Paywall bei gesperrtem Inhalt; Restore sichtbar und nutzbar | Hoch | F14 |
| CUJ-05 | Suche → Session (ohne SOS): Suchdrawer → Text → Topic-Match → Session → Play | Hoch | F05, F07, F09 |
| CUJ-06 | Suche → SOS: Suchdrawer → SOS-Keyword → SOS-Screen → Call/Chat/Dismiss | Hoch | F05, F06 |
| CUJ-07 | Favoriten: Aus Player/Liste hinzufügen; aus Liste entfernen; Liste aktualisiert sich | Mittel | F11 |
| CUJ-08 | Kategorie: ≥5 Sessions sichtbar; „Neue Session generieren“ tappen → neue Session erscheint | Kritisch | F04, §3.4 |

### 3.3 UI-Testfälle nach Bereichen

#### 1. Launch & Onboarding (F01, F02)

- **Beschreibung:** Preloader, Content Check, Onboarding-Slides, Kategorieauswahl, Routing First-Time vs. Returning User.
- **Testfälle (Beispiele):**
  - **Given** App wird gestartet **When** Preloader angezeigt **Then** Logo/Branding sichtbar, nach ca. 3 s Fade-Out und Navigation.
  - **Given** Onboarding nicht abgeschlossen **When** Preloader endet **Then** Navigation zu Onboarding (volle Slides).
  - **Given** Onboarding abgeschlossen **When** Preloader endet **Then** Navigation zu Main Tabs; initialer Tab ggf. nach Kategorie.
  - **Given** Erstnutzer **When** letzte Slide (Kategorie) **Then** Kategorie wählbar, „Get Started“ erst nach Auswahl aktiv; Tap → Main Tabs.
  - **Given** Nutzer hat Onboarding abgeschlossen **When** App neu startet **Then** kein Onboarding, direkter Einstieg Main Tabs.
- **Priorität:** Hoch (CUJ-01).

#### 2. Main Navigation (F03)

- **Beschreibung:** TabBar sichtbar, alle Tabs tappbar, Wechsel ohne Crash, initialer Tab nach Onboarding.
- **Testfälle:**
  - **Given** Nutzer auf Main Tabs **Then** Tabs Home, Explore, Library, Search, Profile sichtbar und aktiv deutlich.
  - **Given** Nutzer auf Main Tabs **When** anderer Tab gewählt **Then** zugehöriger Screen erscheint; beim Zurückwechseln Zustand erhalten.
  - **Given** Nutzer kommt von Onboarding mit gewählter Kategorie **When** Main Tabs laden **Then** initialer Tab entspricht Kategorie wo vorgesehen.
  - **Given** Nutzer in Detail-Screen eines Tabs **When** Back/Geste **Then** zurück zum vorherigen Screen, Navigation konsistent.
- **Priorität:** Kritisch (Smoke, CUJ).

#### 3. Kategorien (F04)

- **Beschreibung:** Schlaf, Stress, Im Fluss: Session-Liste, „Neue Session generieren“, Navigation zu Session Config.
- **Testfälle:**
  - **Given** Nutzer auf Kategorie-Screen (z. B. Schlafen) **Then** mind. 5 Sessions sichtbar, Button „Neue Session generieren“ (oder Äquivalent) sichtbar.
  - **Given** Nutzer auf Kategorie-Screen **When** „Neue Session generieren“ getappt **Then** kurzer Lade-Indikator, neue Session in Liste, Liste aktualisiert.
  - **Given** Nutzer hat Sessions in einer Kategorie **When** zu Home und zurück zur Kategorie **Then** bisherige Sessions weiter sichtbar (kein unerwarteter Reset).
  - **Given** Nutzer auf Kategorie-Screen **When** Session getappt **Then** Navigation zu User Session Config (oder Session-Detail); Start/Regenerieren von dort möglich.
- **Priorität:** Kritisch (CUJ-02, CUJ-08).

#### 4. Suche & SOS (F05, F06)

- **Beschreibung:** Suchdrawer öffnen, Texteingabe, Topic-Match → Session; SOS-Keywords → SOS-Screen, Call/Chat, Dismiss.
- **Testfälle:**
  - **Given** Suchdrawer geöffnet **When** Text eingegeben (z. B. „Ich kann nicht einschlafen“) **Then** Eingabe akzeptiert, Keyword-Matching läuft (ggf. mit Debounce).
  - **Given** Text passt zu Topic **When** Match fertig **Then** Session wird erzeugt, Nutzer kann zu Config/Playback.
  - **Given** Text passt zu keinem Topic **When** Match fertig **Then** Fehler- oder „Topic wählen“-Dialog/Meldung; Korrektur/manuelle Auswahl möglich.
  - **Given** Text enthält keine SOS-Keywords **When** Suche läuft **Then** SOS-Screen erscheint nicht, normaler Such-/Session-Flow.
  - **Given** Text enthält SOS-Keyword **When** Suche läuft **Then** SOS-Screen erscheint zeitnah; Call-Button mit Nummer, ggf. Chat-Button; Dismiss schließt und setzt Zustand zurück.
- **Priorität:** Hoch (CUJ-05, CUJ-06).

#### 5. Session Config & Player (F07, F09)

- **Beschreibung:** Session-Übersicht, Start, Live Player: Play/Pause, Fortschritt/Timer, Exit/Restart; ggf. Mini-Player.
- **Testfälle:**
  - **Given** Nutzer auf Session Config **Then** Sessionname und Dauer (oder Übersicht) sichtbar, Button „Start“/„Session starten“ sichtbar.
  - **Given** Session mit Stimme **When** auf Config **Then** Stimmenauswahl (z. B. Franca, Flo, Marion, Corinna) verfügbar; ggf. Vorschau.
  - **Given** Session mit Frequenz **When** auf Config **Then** Frequenz-An/Aus-Toggle; Auswahl wird beim Start übernommen.
  - **Given** Nutzer auf Session Config **When** „Session starten“ getappt **Then** Playback startet, Navigation zu Live Player; Play → Pause-Wechsel, Timer/Fortschritt sichtbar.
  - **Given** Playback läuft **When** Pause getappt **Then** Audio pausiert; Play wieder **Then** Fortsetzung an gleicher Position.
  - **Given** Nutzer im Live Player **When** Exit getappt **Then** ggf. Bestätigung, dann Rückkehr zum vorherigen Screen; Restart startet Session von vorn.
  - **Given** Playback läuft **When** zu anderem Tab gewechselt **Then** Mini-Player/Strip sichtbar, Pause/Resume und Rückkehr zum Full-Player möglich.
- **Priorität:** Kritisch (CUJ-02, CUJ-03).

#### 6. After Session & Favoriten (F10, F11)

- **Beschreibung:** Abschluss-/Abbruch-Message, „In Favoriten speichern“; Favoriten-Liste, Leerzustand, Hinzufügen/Entfernen, Session laden.
- **Testfälle:**
  - **Given** Session normal beendet **When** After-Session-Screen **Then** Abschluss-Message (z. B. „Session erfolgreich abgeschlossen“), Optionen z. B. In Favoriten speichern, Beenden.
  - **Given** Session abgebrochen **When** After-Session-Screen **Then** Abbruch-Message, gleiche Aktionsbuttons wie bei Abschluss.
  - **Given** After-Session-Screen **When** „In Favoriten speichern“ getappt **Then** ggf. Namenabfrage oder Default, Speichern und Bestätigung.
  - **Given** Nutzer hat Favoriten **When** Favoriten-Liste (z. B. Library) geöffnet **Then** gespeicherte Sessions (z. B. neueste zuerst), Laden/Löschen wie spezifiziert.
  - **Given** Keine Favoriten **When** Favoriten-Liste geöffnet **Then** Leerzustand (z. B. „Keine Favoriten vorhanden“), Hinweis auf Hinzufügen (z. B. aus Player).
  - **Given** Favoriten-Liste **When** Favorit gelöscht (Swipe/Button) **Then** ggf. Bestätigung, Eintrag verschwindet.
  - **Given** Favoriten-Liste **When** Favorit getappt **Then** Session geladen, Playback oder Bearbeitung (Pro) möglich.
- **Priorität:** Mittel bis Hoch (CUJ-07).

#### 7. Soundscapes / Explore (F08) & Library

- **Beschreibung:** Kategorien/Listen auf Explore; Tap zu Detail/Player. Library: Favorites, All Mixes, History.
- **Testfälle:**
  - **Given** Nutzer auf Explore/Soundscapes **Then** Kategorien (z. B. Music, Nature, Frequency, Noise) sichtbar, Tapp auf Kategorie öffnet Detail.
  - **Given** Soundscape-Kategorie geöffnet **When** Item in Grid/Liste getappt **Then** Session erstellt/konfiguriert, Navigation zu Live Player oder Config.
  - **Given** Nutzer in Soundscape-Detail **When** Back getappt **Then** Rückkehr zu Explore/Main.
  - **Given** Nutzer auf Library-Tab **Then** Favorites, All Mixes, History (oder Äquivalent) erreichbar; Listen zeigen korrekte Einträge.
  - **Given** Nutzer in Library-Liste **When** Eintrag getappt **Then** Navigation zu Mix/Session-Detail oder Player.
- **Priorität:** Mittel.

#### 8. Profile, Support, Legal (F13)

- **Beschreibung:** Profile, Account, Support, Legal, Version/Upgrade verlinkt.
- **Testfälle:**
  - **Given** Nutzer auf Profile-Tab **Then** Account Settings, Support, Legal, Datenschutz (wie implementiert) erreichbar; Unterseiten zeigen korrekten Inhalt.
  - **Given** Info-Menü/Profile geöffnet **Then** Einträge z. B. Vorbereitung, Brainwave, AGB, Datenschutz, Impressum, Haftungsausschluss, Support, Version vorhanden; Tapp öffnet jeweiligen Screen/Inhalt.
  - **Given** Version/Upgrade geöffnet **Then** Upgrade/Subscription-Optionen (Demo/User) oder Pro-Panel (Pro) wie designed.
- **Priorität:** Mittel.

#### 9. Subscription / Sales (F14)

- **Beschreibung:** Plan-Anzeige, Subscribe, Restore; Paywall bei gesperrtem Inhalt.
- **Testfälle:**
  - **Given** Nutzer auf Subscription/Upgrade-Screen **Then** Pläne (z. B. wöchentlich, monatlich, jährlich) sichtbar, Preise und ggf. Ersparnis, ggf. Empfehlung.
  - **Given** Nutzer auf Subscription-Screen **When** Subscribe (für einen Plan) getappt **Then** nativer Kauf-Flow (StoreKit) wird ausgelöst; „Käufe wiederherstellen“ sichtbar und funktional, Feedback bei Restore.
  - **Given** Demo oder nicht abonniert **When** gesperrter Inhalt aufgerufen **Then** Paywall/Upgrade-Prompt, Subscribe oder Restore von dort möglich.
- **Priorität:** Hoch (CUJ-04).

#### 10. Dialoge (F16)

- **Beschreibung:** Bestätigungsdialoge (z. B. Exit Session, Favorit löschen), Fehlerdialoge.
- **Testfälle:**
  - **Given** Aktion erfordert Bestätigung (z. B. Favorit löschen, Session beenden) **When** Aktion ausgelöst **Then** Modal mit Bestätigen/Abbrechen; Bestätigen führt Aktion aus und schließt; Abbrechen schließt ohne Aktion.
  - **Given** Speichern einer Session mit Namenpflicht **When** Speichern-Flow **Then** Dialog mit optionalem Textfeld und Bestätigen/Abbrechen; eingegebener Name wird verwendet.
  - **Given** Fehler (z. B. Netzwerk, Speicher) **When** Fehler an Nutzer **Then** Fehlerdialog oder -meldung, Dismiss und Weiter nutzbar.
- **Priorität:** Mittel.

---

## 4. Priorisierung und nächste Schritte

**Sofort (Basis für UI-Tests):**

1. **AWAVEUITests-Target** in `project.yml` anlegen.
2. **Smoke-Tests** umsetzen: SMOKE-01 bis SMOKE-04 (Launch, Preloader/Onboarding oder Main Tabs, alle Tabs tappbar, kein Crash).
3. **Accessibility-IDs** für Tab Bar und zentrale Buttons (z. B. Start, Neue Session generieren, Play/Pause) setzen, damit UI-Tests stabil laufen.

**Kritische User Journeys (danach):**

- CUJ-02 (Session generieren → Config → Play), CUJ-03 (Playback), CUJ-08 (Kategorie, Neue Session generieren).
- Anschließend CUJ-01 (Onboarding), CUJ-04 (Subscription), CUJ-05/CUJ-06 (Suche/SOS), CUJ-07 (Favoriten).

**Weitere Bereiche:**

- UI-Testfälle aus Abschnitt 3.3 nach Priorität und Ressourcen umsetzen (Launch/Onboarding, Navigation, dann Kategorien, Suche/SOS, Player, Favoriten, Explore/Library, Profile, Subscription, Dialoge).
- Unit-Tests für fehlende ViewModels und Services wie in [AWAVE-Test-Coverage-Plan.md](../../AWAVE-Test-Coverage-Plan.md) und [TEST_COVERAGE.md](../TEST_COVERAGE.md) beschrieben ausbauen.

---

## 5. Referenzen

| Dokument | Inhalt |
|---------|--------|
| [01-PRD.md](01-PRD.md) | Produkt- und Navigationsüberblick |
| [02-FEATURE-SPECS.md](02-FEATURE-SPECS.md) | Screen-Specs F01–F16 |
| [TEST_COVERAGE.md](../TEST_COVERAGE.md) | Szenario-Coverage F01–F16, Smoke/CUJ/Regression, Gap-Analyse, detaillierte Given/When/Then |
| [AWAVE-Test-Coverage-Plan.md](../../AWAVE-Test-Coverage-Plan.md) | Phasenplan Unit-Tests (Domain, Audio, SessionGenerator, CI), Coverage-Ziele |
| [TESTING_IMPLEMENTATION_SUMMARY.md](../../handovers/TESTING_IMPLEMENTATION_SUMMARY.md) | Umgesetzte Category-Sessions-Tests (ViewModel + Generator) |
