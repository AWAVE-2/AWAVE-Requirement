# Abschlussbericht: Session-Generator – Einzigartigkeit & Personalisierung

**Note:** The canonical English version of this report is [SESSION_GENERATOR_COMPLETION_REPORT.md](SESSION_GENERATOR_COMPLETION_REPORT.md). This file is kept for reference.

---

**Projekt:** AWAVE iOS (Swift)  
**Thema:** Einzigartige Category-Sessions, First-Time-Personalization-Drawer, Persistenz Anonymous/Registered  
**Stand:** Februar 2026

---

## 1. Übersicht der Änderungen

| # | Bereich | Datei | Art |
|---|--------|--------|-----|
| 1 | Generator | `AWAVE/AWAVE/Services/CategorySessionGenerator.swift` | Geändert |
| 2 | Generator | `AWAVE/AWAVE/Services/SessionGenerator.swift` | Geändert |
| 3 | Modell | `AWAVE/AWAVE/Models/SessionGeneratorPreferences.swift` | **Neu** |
| 4 | Persistenz | `AWAVE/AWAVE/Services/LocalCategorySessionStorage.swift` | **Neu** |
| 5 | ViewModel | `AWAVE/AWAVE/Features/Categories/CategorySessionsViewModel.swift` | Geändert |
| 6 | Drawer-UI | `AWAVE/AWAVE/Features/Categories/CategorySessionPersonalizationDrawerView.swift` | **Neu** |
| 7 | Block-UI | `AWAVE/AWAVE/Features/Categories/CategorySessionGeneratorBlock.swift` | Geändert |
| 8 | Preload | `AWAVE/AWAVE/Services/SessionPreloadService.swift` | Geändert |
| 9 | Tests | `AWAVE/Tests/Services/CategorySessionGeneratorTests.swift` | Geändert |
| 10 | Tests | `AWAVE/Tests/Features/Categories/CategorySessionsViewModelTests.swift` | Geändert |
| 11 | Docs | `docs/Requirements/APP-Feature Description/Category Screens/requirements.md` | Geändert |

---

## 2. Codeänderungen im Detail

### 2.1 CategorySessionGenerator.swift

**Ziel:** Stärkerer Zufalls-Seed + neue Überladung mit User-Preferences (Stimme, Länge, Frequenzen).

**Änderung 1 – Seed mit Entropie (Zeilen 12–14):**

```swift
// Vorher:
let baseSeed = UInt64(Date().timeIntervalSince1970)

// Nachher:
let timePart = UInt64(Date().timeIntervalSince1970 * 1000)
let entropyPart = UInt64.random(in: 0..<UInt64.max)
let baseSeed = timePart &+ entropyPart
```

**Änderung 2 – Neue Methode `generateSessions(for:preferences:)` (vollständig):**

```swift
/// Generate 5 varied sessions for a category using user preferences (voice, duration scale, frequency on/off).
static func generateSessions(for category: OnboardingCategory, preferences: SessionGeneratorPreferences) async -> [Session] {
    let topic = mapToSessionTopic(category)
    let voice = preferences.voice
    var sessions: [Session] = []
    let timePart = UInt64(Date().timeIntervalSince1970 * 1000)
    let entropyPart = UInt64.random(in: 0..<UInt64.max)
    let baseSeed = timePart &+ entropyPart

    var batchRng = FantasyJourneyManager.SeededRandomNumberGenerator(seed: baseSeed)
    let journeys = Array(FantasyJourneyManager.Journey.allCases.shuffled(using: &batchRng).prefix(5))
    let genrePool = topic.musicGenrePool
    let genres = Array(genrePool.shuffled(using: &batchRng).prefix(5))

    let defaultMinutes = 45
    let scale = preferences.durationScale(defaultMinutes: defaultMinutes)

    for i in 0..<5 {
        var sessionRng = FantasyJourneyManager.SeededRandomNumberGenerator(seed: baseSeed + UInt64(i * 1000))
        var session = await SessionGenerator.generate(
            topic: topic,
            voice: voice,
            journey: journeys[i],
            musicGenre: genres[i],
            textVariantIndex: i,
            frequencyVariantIndex: i,
            enableFrequency: preferences.frequenciesEnabled,
            using: &sessionRng
        )
        if abs(scale - 1.0) > 0.01 {
            session.phases = session.phases.map { phase in
                var p = phase
                p.duration *= scale
                return p
            }
            session.duration = session.phases.reduce(0) { $0 + $1.duration }
        }
        sessions.append(session)
    }

    return sessions
}
```

---

### 2.2 SessionGenerator.swift

**Ziel:** Session optional ohne Frequenz-Layer (für Preferences „Frequenzen Aus“).

**Änderung 1 – Parameter in Signatur (Zeilen 16–25):**

```swift
/// When `enableFrequency` is false, session has no frequency layer (phases keep config but session.enableFrequency is false for playback).
static func generate<R: RandomNumberGenerator>(
    topic: SessionTopic,
    voice: Voice,
    journey: FantasyJourneyManager.Journey? = nil,
    musicGenre: String? = nil,
    textVariantIndex: Int? = nil,
    frequencyVariantIndex: Int? = nil,
    enableFrequency: Bool = true,   // NEU
    using rng: inout R
) async -> Session {
```

**Änderung 2 – Session-Erzeugung (Zeilen 118–126):**

```swift
return Session(
    name: nameEntry.name,
    duration: totalDuration,
    voice: voice,
    topic: topic.rawValue,
    type: .standard,
    enableFrequency: enableFrequency,   // war: true
    phases: phases,
    infoText: infoText
)
```

---

### 2.3 SessionGeneratorPreferences.swift (NEU)

**Vollständiger Inhalt:**

```swift
import Foundation
import AWAVEDomain

/// User preferences for category session generation (length, voice, frequencies).
/// Persisted per category: anonymous in UserDefaults, registered in UserDefaults keyed by userId.
public struct SessionGeneratorPreferences: Codable, Sendable, Equatable {

    /// Preferred total session duration in minutes (used to scale phase durations).
    /// Range typically 15–90 min (PRD ±50% around default).
    public var durationMinutes: Int

    /// Selected narrator voice for generated sessions.
    public var voice: Voice

    /// Whether frequency layer (binaural/isochronic etc.) is enabled.
    public var frequenciesEnabled: Bool

    public init(
        durationMinutes: Int = 45,
        voice: Voice = .franca,
        frequenciesEnabled: Bool = true
    ) {
        self.durationMinutes = min(90, max(15, durationMinutes))
        self.voice = voice
        self.frequenciesEnabled = frequenciesEnabled
    }

    /// Duration scale factor relative to a default (e.g. 45 min). 0.5–1.5 range.
    public func durationScale(defaultMinutes: Int = 45) -> Double {
        let clamped = min(90, max(15, durationMinutes))
        return Double(clamped) / Double(defaultMinutes)
    }
}
```

---

### 2.4 LocalCategorySessionStorage.swift (NEU)

**Vollständiger Inhalt:**

```swift
import Foundation
import AWAVEDomain

/// Persists category sessions and session generator preferences for anonymous users in UserDefaults.
/// For registered users, sessions use Firestore; preferences use UserDefaults keyed by userId until backend exists.
final class LocalCategorySessionStorage {

    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private static let sessionsKeyPrefix = "localCategorySessions_"
    private static let preferencesKeyPrefix = "sessionGeneratorPreferences_"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    // MARK: - Sessions (anonymous only)

    func loadSessions(category: OnboardingCategory) -> [Session] {
        let key = Self.sessionsKeyPrefix + category.rawValue
        guard let data = userDefaults.data(forKey: key) else { return [] }
        return (try? decoder.decode([Session].self, from: data)) ?? []
    }

    func saveSessions(_ sessions: [Session], category: OnboardingCategory) {
        let key = Self.sessionsKeyPrefix + category.rawValue
        guard let data = try? encoder.encode(sessions) else { return }
        userDefaults.set(data, forKey: key)
    }

    // MARK: - Preferences (anonymous or registered, keyed by userId for registered)

    func loadPreferences(category: OnboardingCategory, userId: String) -> SessionGeneratorPreferences? {
        let key = preferencesKey(category: category, userId: userId)
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? decoder.decode(SessionGeneratorPreferences.self, from: data)
    }

    func savePreferences(_ preferences: SessionGeneratorPreferences, category: OnboardingCategory, userId: String) {
        let key = preferencesKey(category: category, userId: userId)
        guard let data = try? encoder.encode(preferences) else { return }
        userDefaults.set(data, forKey: key)
    }

    private func preferencesKey(category: OnboardingCategory, userId: String) -> String {
        if userId == "anonymous" {
            return Self.preferencesKeyPrefix + category.rawValue
        }
        return Self.preferencesKeyPrefix + userId + "_" + category.rawValue
    }
}
```

**Hinweis:** `Sendable` wurde entfernt, da `UserDefaults` nicht `Sendable` ist und die Klasse nur aus dem `@MainActor`-ViewModel genutzt wird.

---

### 2.5 CategorySessionsViewModel.swift

**Änderung 1 – Eigenschaften und Init:**

```swift
private let sessionRepository: any SessionRepositoryProtocol
private let localStorage: LocalCategorySessionStorage

init(
    category: OnboardingCategory,
    effectiveUserIdProvider: @escaping () -> String,
    sessionRepository: any SessionRepositoryProtocol,
    localStorage: LocalCategorySessionStorage = LocalCategorySessionStorage()
) {
    self.category = category
    self.effectiveUserIdProvider = effectiveUserIdProvider
    self.sessionRepository = sessionRepository
    self.localStorage = localStorage
}
```

**Änderung 2 – loadSessions(): Anonymous nur aus lokalem Speicher, kein Auto-Generieren**

```swift
/// Load sessions: from local storage (anonymous) or Firestore (registered). Anonymous with no stored sessions shows empty state (no auto-generate).
func loadSessions() async {
    guard !isLoading else { return }

    await MainActor.run {
        isLoading = true
        error = nil
    }

    let userId = effectiveUserIdProvider()

    if userId == "anonymous" {
        let stored = localStorage.loadSessions(category: category)
        await MainActor.run {
            sessions = stored
            isLoading = false
        }
        return
    }
    // … Rest unverändert (Firestore fetch/generate für registriert)
}
```

**Änderung 3 – currentPreferences() (NEU):**

```swift
/// Current preferences for the category (from local storage), or default.
func currentPreferences() -> SessionGeneratorPreferences {
    let userId = effectiveUserIdProvider()
    return localStorage.loadPreferences(category: category, userId: userId) ?? SessionGeneratorPreferences()
}
```

**Änderung 4 – generateSessions(with:) (ersetzt generateSessions()):**

```swift
/// Generate new sessions with optional preferences, replacing existing ones. Persists preferences and sessions (local for anonymous, Firestore for registered).
func generateSessions(with preferences: SessionGeneratorPreferences? = nil) async {
    guard !isGenerating else { return }

    await MainActor.run {
        isGenerating = true
        error = nil
    }

    let userId = effectiveUserIdProvider()
    let prefs = preferences ?? localStorage.loadPreferences(category: category, userId: userId) ?? SessionGeneratorPreferences()
    localStorage.savePreferences(prefs, category: category, userId: userId)

    do {
        let newSessions = await CategorySessionGenerator.generateSessions(for: category, preferences: prefs)
        await MainActor.run { sessions = newSessions }

        if userId != "anonymous" {
            try await sessionRepository.deleteCategorySessions(
                userId: userId,
                category: category.rawValue
            )
            try await sessionRepository.saveCategorySessions(
                newSessions,
                userId: userId,
                category: category.rawValue
            )
        } else {
            localStorage.saveSessions(newSessions, category: category)
        }

        await MainActor.run { isGenerating = false }
    } catch {
        await MainActor.run {
            self.error = "Sessions wurden generiert, aber nicht gespeichert"
            isGenerating = false
        }
    }
}
```

---

### 2.6 CategorySessionPersonalizationDrawerView.swift (NEU)

**Vollständiger Inhalt:**

```swift
import SwiftUI
import AWAVEDesign
import AWAVEDomain

/// Drawer for personalizing category session generation: length (slider), voice (picker), frequencies (on/off).
/// Headline: "Individualisiere deine {Category}-Session". Primary action: "{Category}-Session generieren".
struct CategorySessionPersonalizationDrawerView: View {
    let category: OnboardingCategory
    let initialPreferences: SessionGeneratorPreferences
    let onGenerate: (SessionGeneratorPreferences) -> Void
    let onDismiss: () -> Void

    @State private var durationMinutes: Double
    @State private var voice: Voice
    @State private var frequenciesEnabled: Bool

    private let durationRange: ClosedRange<Double> = 15...90

    init(
        category: OnboardingCategory,
        initialPreferences: SessionGeneratorPreferences,
        onGenerate: @escaping (SessionGeneratorPreferences) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.category = category
        self.initialPreferences = initialPreferences
        self.onGenerate = onGenerate
        self.onDismiss = onDismiss
        _durationMinutes = State(initialValue: Double(min(90, max(15, initialPreferences.durationMinutes))))
        _voice = State(initialValue: initialPreferences.voice)
        _frequenciesEnabled = State(initialValue: initialPreferences.frequenciesEnabled)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AWAVESpacing.sectionSpacing) {
                    headline
                    lengthSection
                    voiceSection
                    frequenciesSection
                    generateButton
                }
                .padding(.horizontal, AWAVESpacing.appPaddingX)
                .padding(.vertical, AWAVESpacing.lg)
            }
            .scrollContentBackground(.hidden)
            .background(AWAVEColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Abbrechen")) { onDismiss() }
                        .foregroundColor(AWAVEColors.foreground)
                }
            }
        }
    }

    private var headline: some View {
        Text(String(localized: "Individualisiere deine \(category.title)-Session"))
            .font(AWAVEFonts.title2)
            .foregroundColor(AWAVEColors.foreground)
    }

    private var lengthSection: some View {
        VStack(alignment: .leading, spacing: AWAVESpacing.sm) {
            Text(String(localized: "Länge"))
                .font(AWAVEFonts.headline)
                .foregroundColor(AWAVEColors.foreground)
            Slider(value: $durationMinutes, in: durationRange, step: 5)
                .tint(AWAVEColors.primary)
            Text("\(Int(durationMinutes)) \(String(localized: "Min"))")
                .font(AWAVEFonts.caption)
                .foregroundColor(AWAVEColors.mutedForeground)
        }
    }

    private var voiceSection: some View {
        VStack(alignment: .leading, spacing: AWAVESpacing.sm) {
            Text(String(localized: "Stimme"))
                .font(AWAVEFonts.headline)
                .foregroundColor(AWAVEColors.foreground)
            Picker(String(localized: "Stimme"), selection: $voice) {
                ForEach(Voice.allCases, id: \.rawValue) { v in
                    Text(v.rawValue).tag(v)
                }
            }
            .pickerStyle(.menu)
            .tint(AWAVEColors.foreground)
        }
    }

    private var frequenciesSection: some View {
        VStack(alignment: .leading, spacing: AWAVESpacing.sm) {
            Text(String(localized: "Frequenzen"))
                .font(AWAVEFonts.headline)
                .foregroundColor(AWAVEColors.foreground)
            Picker(String(localized: "Frequenzen"), selection: $frequenciesEnabled) {
                Text(String(localized: "Ein")).tag(true)
                Text(String(localized: "Aus")).tag(false)
            }
            .pickerStyle(.segmented)
        }
    }

    private var generateButton: some View {
        Button {
            let prefs = SessionGeneratorPreferences(
                durationMinutes: Int(durationMinutes),
                voice: voice,
                frequenciesEnabled: frequenciesEnabled
            )
            onGenerate(prefs)
            onDismiss()
        } label: {
            Text("\(category.title)-Session \(String(localized: "generieren"))")
                .font(AWAVEFonts.callout)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AWAVESpacing.md)
        }
        .buttonStyle(.borderedProminent)
        .tint(AWAVEColors.primary)
    }
}
```

---

### 2.7 CategorySessionGeneratorBlock.swift

**Änderung 1 – State und leerer Zustand:**

```swift
@State private var viewModel: CategorySessionsViewModel?
@State private var showPersonalizationDrawer = false
```

- Bedingung für leeren Zustand: `viewModel.sessions.isEmpty, viewModel.error == nil` → Anzeige von `firstSessionCTA(viewModel:)` statt `emptyPlaceholder`.

**Änderung 2 – firstSessionCTA (NEU):**

```swift
private func firstSessionCTA(viewModel: CategorySessionsViewModel) -> some View {
    Button {
        showPersonalizationDrawer = true
    } label: {
        HStack(spacing: AWAVESpacing.sm) {
            Image(systemName: "sparkles")
                .font(.callout)
            Text(String(localized: "Generiere deine erste Session"))
                .font(AWAVEFonts.callout)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AWAVESpacing.md)
        .glassMorphism()
    }
    .buttonStyle(.plain)
}
```

**Änderung 3 – "Neue Sessions generieren" öffnet Drawer:**

```swift
Button {
    showPersonalizationDrawer = true
} label: {
    HStack(spacing: AWAVESpacing.sm) {
        Image(systemName: "arrow.clockwise")
        Text(String(localized: "Neue Sessions generieren"))
        // ...
    }
}
```

**Änderung 4 – Sheet mit Drawer:**

```swift
.sheet(isPresented: $showPersonalizationDrawer) {
    if let viewModel = viewModel {
        CategorySessionPersonalizationDrawerView(
            category: category,
            initialPreferences: viewModel.currentPreferences(),
            onGenerate: { prefs in
                Task { await viewModel.generateSessions(with: prefs) }
            },
            onDismiss: { showPersonalizationDrawer = false }
        )
    }
}
```

**Änderung 5 – Lade-Overlay-Text:**

```swift
Text("Deine \(category.title)-Sessions \(String(localized: "werden jetzt generiert"))")
```

---

### 2.8 SessionPreloadService.swift

**Änderung – Preload nur für registrierte Nutzer:**

```swift
/// Pre-generate sessions for all categories on first app launch (registered users only).
/// Anonymous users see the empty state and personalization drawer instead.
func preloadSessionsIfNeeded(
    sessionRepository: any SessionRepositoryProtocol,
    authService: any AuthServiceProtocol
) async {
    guard !hasPreloaded else { return }
    guard let userId = await authService.currentUserId, userId != "anonymous" else { return }

    let categories = OnboardingCategory.allCases

    for category in categories {
        let sessions = await CategorySessionGenerator.generateSessions(for: category)
        try? await sessionRepository.saveCategorySessions(
            sessions,
            userId: userId,
            category: category.rawValue
        )
    }

    userDefaults.set(true, forKey: hasPreloadedKey)
}
```

---

### 2.9 CategorySessionGeneratorTests.swift

**Neue Tests (Preferences-Überladung):**

```swift
// MARK: - Preferences Overload

@Test("generateSessions with preferences uses single voice for all slots")
func preferencesSingleVoice() async {
    let prefs = SessionGeneratorPreferences(durationMinutes: 45, voice: .marion, frequenciesEnabled: true)
    let sessions = await CategorySessionGenerator.generateSessions(for: .sleep, preferences: prefs)
    #expect(sessions.count == 5)
    #expect(sessions.allSatisfy { $0.voice == .marion })
}

@Test("generateSessions with preferences frequenciesEnabled false sets enableFrequency false")
func preferencesFrequencyOff() async {
    let prefs = SessionGeneratorPreferences(durationMinutes: 45, voice: .franca, frequenciesEnabled: false)
    let sessions = await CategorySessionGenerator.generateSessions(for: .sleep, preferences: prefs)
    #expect(sessions.count == 5)
    #expect(sessions.allSatisfy { $0.enableFrequency == false })
}

@Test("generateSessions with preferences scales duration")
func preferencesDurationScale() async {
    let prefsShort = SessionGeneratorPreferences(durationMinutes: 30, voice: .franca, frequenciesEnabled: true)
    let prefsLong = SessionGeneratorPreferences(durationMinutes: 60, voice: .franca, frequenciesEnabled: true)
    let sessionsShort = await CategorySessionGenerator.generateSessions(for: .sleep, preferences: prefsShort)
    let sessionsLong = await CategorySessionGenerator.generateSessions(for: .sleep, preferences: prefsLong)
    let avgShort = sessionsShort.map(\.duration).reduce(0, +) / Double(sessionsShort.count)
    let avgLong = sessionsLong.map(\.duration).reduce(0, +) / Double(sessionsLong.count)
    #expect(avgLong > avgShort, "60 min preference should produce longer sessions than 30 min")
}
```

---

### 2.10 CategorySessionsViewModelTests.swift

**Ersetzte/angepasste Tests:**

- `testLoadSessionsWhenNotAuthenticated` → **testLoadSessionsWhenAnonymousShowsEmptyState**: erwartet `sessions.count == 0`, keine Firestore-Calls.
- **testLoadSessionsWhenAnonymousAfterGenerateLoadsFromLocalStorage** (neu): erst `generateSessions()`, dann `loadSessions()` → 5 Sessions aus lokalem Speicher.
- `testGenerateSessionsWhenNotAuthenticated` → **testGenerateSessionsWhenAnonymous**: gleiche Assertions, umbenannt.
- **testGenerateSessionsWithPreferencesUsesThem** (neu): `generateSessions(with: prefs)` mit Marion und Frequenzen aus → alle Sessions mit dieser Stimme und `enableFrequency == false`.

Snippet für die neuen/angepassten Tests:

```swift
func testLoadSessionsWhenAnonymousShowsEmptyState() async throws {
    await viewModel.loadSessions()
    XCTAssertEqual(viewModel.sessions.count, 0)
    XCTAssertEqual(mockRepository.fetchCallCount, 0)
    XCTAssertEqual(mockRepository.saveCallCount, 0)
}

func testLoadSessionsWhenAnonymousAfterGenerateLoadsFromLocalStorage() async throws {
    await viewModel.generateSessions()
    XCTAssertEqual(viewModel.sessions.count, 5)
    await viewModel.loadSessions()
    XCTAssertEqual(viewModel.sessions.count, 5)
    XCTAssertEqual(mockRepository.fetchCallCount, 0)
}

func testGenerateSessionsWithPreferencesUsesThem() async throws {
    let prefs = SessionGeneratorPreferences(durationMinutes: 30, voice: .marion, frequenciesEnabled: false)
    await viewModel.generateSessions(with: prefs)
    XCTAssertEqual(viewModel.sessions.count, 5)
    XCTAssertTrue(viewModel.sessions.allSatisfy { $0.voice == .marion })
    XCTAssertTrue(viewModel.sessions.allSatisfy { $0.enableFrequency == false })
}
```

---

### 2.11 Category Screens requirements.md

**Neuer Abschnitt (nach „Data Structure“):**

```markdown
#### Session Generation (Category Block)
- [x] First-time / empty state: "Generiere deine erste Session" CTA opens personalization drawer (no auto-generate)
- [x] Personalization drawer: headline "Individualisiere deine {Category}-Session", length (slider 15–90 min), voice (picker), frequencies (Ein/Aus)
- [x] Primary action: "{Category}-Session generieren"; on tap: save preferences, close drawer, generate with preferences, show "Deine {Category}-Sessions werden jetzt generiert"
- [x] "Neue Sessions generieren" opens same drawer (pre-filled from saved preferences); existing sessions replaced after generation
- [x] Anonymous: sessions and preferences persisted in local storage (UserDefaults); no preload on first launch
- [x] Registered: sessions in Firestore; preferences in UserDefaults keyed by userId (or Firestore when backend ready)
```

---

## 3. Verhalten (Kurz)

- **Anonymous, keine Sessions:** Leerzustand mit „Generiere deine erste Session“ → Drawer → Personalisierung → Generation → Persistenz in UserDefaults.
- **Anonymous, mit Sessions:** Liste + „Neue Sessions generieren“ → Drawer → ggf. neue Preferences → Generation → Ersetzen + lokales Speichern.
- **Registriert:** Sessions wie bisher in Firestore; Preferences in UserDefaults (pro userId); Preload nur bei registriertem Nutzer.
- **Klangwelten:** Unverändert; SchlafScreen nur indirekt über den Block betroffen.

---

## 4. Ablage

- **Abschlussbericht (diese Datei):** `docs/SESSION_GENERATOR_ABSCHLUSSBERICHT.md`
- **Plan:** `.cursor/plans/session_generator_uniqueness_and_personalization_56dfa582.plan.md`
- **Requirements-Update:** `docs/Requirements/APP-Feature Description/Category Screens/requirements.md`
