# Session-Generierung Audio-Library-Refactoring – Summary Report

**Datum:** Februar 2026  
**Kontext:** Plan „Session Generation Audio Library Refactoring“ – Einzigartigkeit der Sessions, Anzeigenamen (Clannamen) im Mixer, Anbindung an die Audio-Bibliothek ohne Demo-Fallback. Nachträglich: Session-Generierung im Schlafscreen/Category-Screen (Drawer schließt nach Generierung, Sessions werden ersetzt).

---

## 1. Übersicht der Änderungen

| # | Bereich | Datei | Art |
|---|--------|--------|-----|
| 1 | Player | `AWAVE/AWAVE/Features/Player/PlayerViewModel.swift` | Geändert |
| 2 | Session-Playback | `AWAVE/AWAVE/Services/SessionPlayerService.swift` | Geändert |
| 3 | Audio-Engine | `AWAVE/Packages/AWAVEAudio/.../PhasePlayer.swift` | Geändert |
| 4 | Resolver | `AWAVE/AWAVE/Services/SessionContentResolver.swift` | **Neu** |
| 5 | Tests | `AWAVE/Tests/Services/SessionContentResolverTests.swift` | **Neu** |
| 6 | Docs | `docs/Requirements/.../Session Generation/base-dockuemtation.md` | Geändert |
| 7 | Docs | `docs/Requirements/.../Session Generation/Session-Content-IDs-Catalog.md` | **Neu** |
| 8 | Category Block | `AWAVE/AWAVE/Features/Categories/CategorySessionGeneratorBlock.swift` | Geändert |
| 9 | Personalization Drawer | `AWAVE/AWAVE/Features/Categories/CategorySessionPersonalizationDrawerView.swift` | Geändert |

---

## 2. Ziele (umgesetzt)

- **Kein kategoriebasierter Fallback:** Auflösung nur über `getSound(byContentId:)` und `SessionContentMapping`. Jede Session lädt nur Tracks aus der Bibliothek mit passendem `contentId`.
- **Anzeigenamen im Mixer:** Mixer zeigt `Sound.title` (z. B. „Wald“, „Ambient“, „Franca – Einleitung“) statt Dateiname oder Content-ID.
- **Testbare Auflösungslogik:** Resolver in `SessionContentResolver` ausgelagert, Unit-Tests für Katalog-Treffer und fehlende Treffer.
- **Session-Generierung im Schlafscreen:** User tippt „Neue Sessions generieren“ → Drawer öffnet → User wählt Zeit/Stimme/Frequenz und tippt „{Category}-Session generieren“ → Drawer bleibt mit Ladeanzeige offen → Nach Abschluss schließt der Drawer, die Sessions-Liste im Category-Screen wird durch die neu generierten Sessions ersetzt.

---

## 3. Codeänderungen im Detail

### 3.1 PlayerViewModel.swift

**Änderung 1 – loadSession: Nutzung von Resolution-Ergebnis mit URLs und displayNames**

```swift
// Vorher:
let preResolved = await preResolveSessionContentURLs(session, category: category)
let service = SessionPlayerService(audioEngine: engine, resolvedURLs: preResolved)

// Nachher:
let resolution = await preResolveSessionContentURLs(session, category: category)
let service = SessionPlayerService(audioEngine: engine, resolvedURLs: resolution.urls, displayNames: resolution.displayNames)
```

**Änderung 2 – Neues Result-Type und umgebaute preResolveSessionContentURLs**

- Rückgabetyp von `[String: URL]` auf `SessionContentResolution` (urls + displayNames).
- Auflösung delegiert an `SessionContentResolver.resolveSounds`; kein Fallback mehr über `getSounds(category:).first`.
- Nach dem Resolver: nur noch Download für aufgelöste Sounds und Befüllen von `urls`/`displayNames`; Logging für nicht aufgelöste Content-IDs.

**Eingefügter Snippet (SessionContentResolution + preResolveSessionContentURLs):**

```swift
    /// Result of resolving session content IDs to local URLs and display names from the audio library.
    struct SessionContentResolution {
        var urls: [String: URL]
        var displayNames: [String: String]
    }

    /// Collects all content IDs from session phases and resolves each via catalog (SessionContentResolver), then resolves to local URLs.
    /// No category fallback: only catalog/mapping matches are used so each session loads unique library content.
    /// Returns URLs and display names (Sound.title) for mixer labels (e.g. "Wald", "Ambient" instead of file names).
    private func preResolveSessionContentURLs(_ session: Session, category: OnboardingCategory? = nil) async -> SessionContentResolution {
        let resolvedSounds = await SessionContentResolver.resolveSounds(session: session, soundRepository: soundRepository)

        var urls: [String: URL] = [:]
        var displayNames: [String: String] = [:]

        for (contentId, sound) in resolvedSounds {
            guard let remoteURL = URL(string: sound.fileURL) else {
                AWAVELogger.audio.warning("Pre-resolve failed for contentId '\(contentId)': invalid fileURL")
                continue
            }
            do {
                let localURL = try await AudioDownloadService.shared.getLocalURL(for: remoteURL)
                urls[contentId] = localURL
                displayNames[contentId] = sound.title
            } catch {
                AWAVELogger.audio.warning("Pre-resolve failed for contentId '\(contentId)': \(error)")
            }
        }

        var allContentIds = Set<String>()
        for phase in session.phases {
            if let c = phase.text?.content, !c.isEmpty { allContentIds.insert(c) }
            if let c = phase.music?.content, !c.isEmpty { allContentIds.insert(c) }
            if let c = phase.nature?.content, !c.isEmpty { allContentIds.insert(c) }
            if let c = phase.sound?.content, !c.isEmpty { allContentIds.insert(c) }
            if let noise = phase.noise { allContentIds.insert(noise.type.audioFileName) }
        }
        for contentId in allContentIds where resolvedSounds[contentId] == nil {
            AWAVELogger.audio.warning("Pre-resolve failed for contentId '\(contentId)': no sound or invalid fileURL in catalog or mapping")
        }

        return SessionContentResolution(urls: urls, displayNames: displayNames)
    }
```

**Entfernt:** Die komplette Inline-Auflösungslogik (getSound(byContentId), baseId-Varianten, SessionContentMapping) sowie der Block:

```swift
// ENTFERNT (kein Fallback mehr):
if sound == nil, let soundCategory = contentIdToType[contentId] {
    let byCategory = (try? await soundRepository.getSounds(category: soundCategory)) ?? []
    sound = byCategory.first { !$0.fileURL.isEmpty }
}
```

---

### 3.2 SessionPlayerService.swift

**Änderung 1 – displayNames im Init und als Property**

```swift
// Vorher:
private let audioEngine: AWAVEAudioEngine
private let resolvedURLs: [String: URL]
private var phasePlayer: PhasePlayer?

public init(audioEngine: AWAVEAudioEngine, resolvedURLs: [String: URL]) {
    self.audioEngine = audioEngine
    self.resolvedURLs = resolvedURLs
}

// Nachher:
private let audioEngine: AWAVEAudioEngine
private let resolvedURLs: [String: URL]
private let displayNames: [String: String]
private var phasePlayer: PhasePlayer?

/// Initialize with audio engine, pre-resolved content URLs, and optional display names for mixer track labels (e.g. from Sound.title).
public init(audioEngine: AWAVEAudioEngine, resolvedURLs: [String: URL], displayNames: [String: String] = [:]) {
    self.audioEngine = audioEngine
    self.resolvedURLs = resolvedURLs
    self.displayNames = displayNames
}
```

**Änderung 2 – Deprecated-Init angepasst**

```swift
@available(*, deprecated, message: "Use init(audioEngine:resolvedURLs:displayNames:) for better performance")
public init(audioEngine: AWAVEAudioEngine, resolveURL: @escaping (String) -> URL?) {
    self.audioEngine = audioEngine
    self.resolvedURLs = [:]
    self.displayNames = [:]
    fatalError("Use init(audioEngine:resolvedURLs:displayNames:) for better performance")
}
```

**Änderung 3 – loadCurrentPhase: displayNames an PhasePlayer übergeben**

```swift
// Vorher:
await player.load(
    phase: phase,
    engine: audioEngine,
    resolveURL: resolveURL,
    previousPhase: previousPhase,
    startOffset: offset
)

// Nachher:
await player.load(
    phase: phase,
    engine: audioEngine,
    resolveURL: resolveURL,
    displayNames: displayNames,
    previousPhase: previousPhase,
    startOffset: offset
)
```

---

### 3.3 PhasePlayer.swift (AWAVEAudio)

**Änderung 1 – load(…) um displayNames erweitert und Namen an loadTrack übergeben**

```swift
// Vorher (Signatur):
public func load(
    phase: SessionPhase,
    engine: AWAVEAudioEngine,
    resolveURL: @escaping (String) -> URL?,
    previousPhase: SessionPhase? = nil,
    startOffset: TimeInterval = 0
) async {

// Nachher (Signatur):
/// Display names from the audio library (e.g. "Wald", "Ambient") are shown in the mixer instead of file names.
public func load(
    phase: SessionPhase,
    engine: AWAVEAudioEngine,
    resolveURL: @escaping (String) -> URL?,
    displayNames: [String: String] = [:],
    previousPhase: SessionPhase? = nil,
    startOffset: TimeInterval = 0
) async {
```

**Änderung 2 – Track laden mit Anzeigenamen**

```swift
// Vorher:
guard let url = resolveURL(config.content) else { ... }
do {
    let track = try await engine.loadTrack(url: url, at: trackType.slotIndex)
    ...
}

// Nachher:
guard let url = resolveURL(config.content) else { ... }

let trackDisplayName = displayNames[config.content] ?? config.content

do {
    let track = try await engine.loadTrack(url: url, at: trackType.slotIndex, name: trackDisplayName)
    ...
}
```

---

### 3.4 SessionContentResolver.swift (NEU)

**Vollständiger Inhalt:**

```swift
import Foundation
import AWAVEDomain

/// Resolves session phase content IDs to catalog sounds via getSound(byContentId) and SessionContentMapping only.
/// No category fallback: ensures each session uses unique library content. Used by PlayerViewModel before downloading.
enum SessionContentResolver {

    /// Resolves all content IDs from session phases to Sound objects.
    /// Resolution order: (1) getSound(byContentId), (2) SessionContentMapping then getSound(id:).
    /// Returns a map of contentId → Sound only for IDs that resolve; unresolved IDs are omitted.
    static func resolveSounds(
        session: Session,
        soundRepository: any SoundRepositoryProtocol
    ) async -> [String: Sound] {
        var contentIdToType: [String: Sound.SoundCategory] = [:]
        for phase in session.phases {
            if let c = phase.text?.content, !c.isEmpty { contentIdToType[c] = .text }
            if let c = phase.music?.content, !c.isEmpty { contentIdToType[c] = .music }
            if let c = phase.nature?.content, !c.isEmpty { contentIdToType[c] = .nature }
            if let c = phase.sound?.content, !c.isEmpty { contentIdToType[c] = .sound }
        }
        var noiseIds: Set<String> = []
        for phase in session.phases {
            if let noise = phase.noise { noiseIds.insert(noise.type.audioFileName) }
        }

        var result: [String: Sound] = [:]
        let allContentIds = Set(contentIdToType.keys).union(noiseIds)

        for contentId in allContentIds {
            var sound: Sound?
            if let s = try? await soundRepository.getSound(byContentId: contentId) {
                sound = s
            }
            if sound == nil, contentId.contains("/v") {
                let baseId = contentId.split(separator: "/").dropLast().joined(separator: "/")
                if !baseId.isEmpty, let s = try? await soundRepository.getSound(byContentId: baseId) {
                    sound = s
                }
            }
            if sound == nil, let mappedId = SessionContentMapping.soundId(for: contentId),
                      let s = try? await soundRepository.getSound(id: mappedId) {
                sound = s
            }
            if sound == nil, contentId.contains("/v") {
                let baseId = contentId.split(separator: "/").dropLast().joined(separator: "/")
                if !baseId.isEmpty, let mappedId = SessionContentMapping.soundId(for: baseId),
                   let s = try? await soundRepository.getSound(id: mappedId) {
                    sound = s
                }
            }
            guard let resolved = sound, !resolved.fileURL.isEmpty else { continue }
            result[contentId] = resolved
        }
        return result
    }
}
```

---

### 3.5 SessionContentResolverTests.swift (NEU)

**Struktur:** Suite „SessionContentResolver Tests“ mit Mock `ResolverTestSoundRepository` (konfigurierbar für `getSound(byContentId:)`).

**Tests:**

1. **resolveUsesCatalogMatch** – Bei Treffer aus `getSound(byContentId:)` ist der Sound im Ergebnis (inkl. title/id).
2. **resolveOmitsWhenNoMatch** – Bei nil und ohne Mapping ist die Content-ID nicht im Ergebnis, Ergebnis leer.
3. **resolveIncludesDisplayNameFromSoundTitle** – `result[contentId]?.title` entspricht dem Katalog-Titel („Deep Dreaming“).
4. **resolveVariantViaBaseId** – contentId `franca/sleep/intro/v0` wird über baseId `franca/sleep/intro` aufgelöst; Titel „Franca – Einleitung“.

**Ausschnitt (Mock + ein Test):**

```swift
private final class ResolverTestSoundRepository: SoundRepositoryProtocol, @unchecked Sendable {
    private let contentIdToSound: [String: Sound]
    private let soundsById: [String: Sound]

    init(contentIdToSound: [String: Sound]) {
        self.contentIdToSound = contentIdToSound
        self.soundsById = Dictionary(uniqueKeysWithValues: contentIdToSound.values.map { ($0.id, $0) })
    }
    // getSound(byContentId:) → contentIdToSound[contentId], getSound(id:) → soundsById[id], ...
}

@Test("Resolve returns sound when getSound(byContentId:) returns a match")
func resolveUsesCatalogMatch() async throws {
    let sound = Sound(id: "sound-1", title: "Wald", category: .nature, duration: 300, fileURL: "https://example.com/wald.mp3")
    let repo = ResolverTestSoundRepository(contentIdToSound: ["Wald": sound])
    let phase = SessionPhase(name: "Fantasy", duration: 300, nature: MediaConfig(content: "Wald", volume: 0.5))
    let session = Session(name: "Test", duration: 300, topic: "sleep", phases: [phase])
    let result = await SessionContentResolver.resolveSounds(session: session, soundRepository: repo)
    #expect(result["Wald"] != nil)
    #expect(result["Wald"]?.title == "Wald")
    #expect(result["Wald"]?.id == "sound-1")
}
```

---

### 3.6 CategorySessionGeneratorBlock.swift (Session-Generierung auslösen)

**Ziel:** Im Schlafscreen (und allen Category-Screens) soll nach Auswahl im Drawer und Tipp auf „{Category}-Session generieren“ die Generierung zuverlässig ausgelöst werden und der Drawer erst nach Abschluss schließen; die angezeigte Sessions-Liste wird durch die neuen Sessions ersetzt.

**Änderung – Sheet: onGenerate führt Generierung aus und schließt Drawer danach**

```swift
// Vorher:
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

// Nachher:
.sheet(isPresented: $showPersonalizationDrawer) {
    if let viewModel = viewModel {
        CategorySessionPersonalizationDrawerView(
            category: category,
            initialPreferences: viewModel.currentPreferences(),
            isGenerating: viewModel.isGenerating,
            onGenerate: { prefs in
                Task { @MainActor in
                    await viewModel.generateSessions(with: prefs)
                    showPersonalizationDrawer = false
                }
            },
            onDismiss: { showPersonalizationDrawer = false }
        )
    }
}
```

- `onGenerate` schließt den Drawer erst **nach** `await viewModel.generateSessions(with: prefs)`, damit derselbe ViewModel die Liste aktualisiert und der Nutzer die neuen Sessions sieht.
- `isGenerating` wird an den Drawer übergeben, damit dort „Sessions werden generiert…“ angezeigt werden kann.

---

### 3.7 CategorySessionPersonalizationDrawerView.swift (Drawer mit Ladezustand)

**Ziel:** Drawer zeigt während der Generierung einen Ladezustand; Schließen übernimmt der aufrufende Block nach Abschluss (nicht sofort beim Tipp auf „Generieren“).

**Änderung 1 – Neuer Parameter `isGenerating` und Ladebereich**

```swift
// Neu: Parameter und Abschnitt
let isGenerating: Bool

init(
    category: OnboardingCategory,
    initialPreferences: SessionGeneratorPreferences,
    isGenerating: Bool = false,
    onGenerate: @escaping (SessionGeneratorPreferences) -> Void,
    onDismiss: @escaping () -> Void
) { ... }

// Im body: bei isGenerating einen Ladeabschnitt anzeigen
if isGenerating {
    generatingSection
}

private var generatingSection: some View {
    HStack(spacing: AWAVESpacing.sm) {
        ProgressView()
            .tint(AWAVEColors.primary)
        Text(String(localized: "Sessions werden generiert…"))
            .font(AWAVEFonts.caption)
            .foregroundColor(AWAVEColors.mutedForeground)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, AWAVESpacing.sm)
}
```

**Änderung 2 – Generate-Button: nur onGenerate, kein onDismiss; bei isGenerating deaktiviert**

```swift
// Vorher:
Button {
    let prefs = SessionGeneratorPreferences(...)
    onGenerate(prefs)
    onDismiss()
} label: { ... }

// Nachher:
Button {
    guard !isGenerating else { return }
    let prefs = SessionGeneratorPreferences(...)
    onGenerate(prefs)
} label: { ... }
.disabled(isGenerating)
```

- „Abbrechen“ wird bei `isGenerating` deaktiviert (`.disabled(isGenerating)`), damit während der Generierung nicht versehentlich geschlossen wird.

---

## 4. Dokumentation

### 4.1 base-dockuemtation.md

**Ersetzter Absatz (Content-IDs für iOS Session-Playback):**

```markdown
**Auflösungsreihenfolge (Stand Refactoring 2026):** (1) `getSound(byContentId:)`, (2) `SessionContentMapping.soundId(for:)`. Es gibt **keinen** kategoriebasierten Fallback mehr („erster Sound der Kategorie“), damit jede Session nur Inhalte aus der Audio-Bibliothek mit passendem `contentId` lädt und nicht immer derselbe Demo-Track. Fehlgeschlagene Auflösungen werden geloggt (`AWAVELogger.audio.warning`). Ohne passende Firestore-`contentId`-Einträge oder SessionContentMapping spielen nur Frequency und ggf. Noise.

**Mixer-Anzeige:** Die aus der Bibliothek aufgelösten Tracks werden im Mixer mit dem **Anzeigenamen** (`Sound.title`) angezeigt (z. B. „Wald“, „Ambient“, „Franca – Einleitung“), nicht mit Dateiname oder Content-ID. Dafür liefert `preResolveSessionContentURLs` neben den URLs eine Map `contentId → displayName` und PhasePlayer übergibt diesen Namen an die Audio-Engine.
```

### 4.2 Session-Content-IDs-Catalog.md (NEU)

Neue Datei mit:

- Zweck: Abgleich Katalog/Firestore mit den vom Session-Generator ausgegebenen Content-IDs.
- Abschnitte: Text (voice/topic/stage[/vN]), Musik (Genre), Natur (FantasyJourneyManager), Sound (z. B. Glockenspiel), Noise (audioFileName).
- Katalog-Check: `content_id` in sound_metadata, `contentId` in Firestore; optional SessionContentMapping.

(Vollständiger Inhalt siehe Datei im Repo.)

---

## 5. Ablage

- **Dieser Report:** `docs/SESSION_GENERATION_AUDIO_LIBRARY_REFACTORING_REPORT.md`
- **Plan:** Session Generation Audio Library Refactoring (Orchestrator-Plan)
- **Katalog-Doku:** `docs/Requirements/APP-Feature Description/Session Generation/Session-Content-IDs-Catalog.md`
- **Basis-Doku:** `docs/Requirements/APP-Feature Description/Session Generation/base-dockuemtation.md`

---

## 6. Verhalten (Kurz)

- **Auflösung:** Nur noch Katalog (`getSound(byContentId:)`) und `SessionContentMapping`. Kein „erster Sound der Kategorie“.
- **Mixer:** Track-Namen = `Sound.title` aus der Auflösung (Clannamen), Fallback Anzeige = contentId wenn kein displayName.
- **Tests:** SessionContentResolver wird mit Mock-Repository getestet (Treffer, kein Treffer, Anzeigename, baseId-Variante).
- **Schlafscreen / Category-Screen:** „Neue Sessions generieren“ → Drawer öffnet → Nutzer wählt Länge/Stimme/Frequenzen und tippt „{Category}-Session generieren“ → Drawer zeigt „Sessions werden generiert…“, schließt erst nach Abschluss → Sessions-Liste im Block zeigt die neu generierten Sessions (ersetzt die bisherigen).
