# Software Engineering Principles Checklist

## Purpose

This checklist verifies AWAVE's architecture against established software engineering principles. Use it for self-assessment and LLM verification.

---

## SOLID Principles

### S - Single Responsibility Principle

> "A class should have only one reason to change"

| Component | Responsibility | Compliant? | Notes |
|-----------|----------------|------------|-------|
| `PlayerViewModel` | Manage player UI state | ✅ | Single screen's state |
| `PlaySoundMixUseCase` | Orchestrate playback start | ⚠️ | Does 4 things - consider splitting |
| `FirestoreSoundRepository` | Firestore data access | ✅ | Only Firestore operations |
| `AWAVEAudioEngine` | Audio playback | ✅ | Facade over AVFoundation |
| `AppCoordinator` | Navigation management | ✅ | Only navigation |
| `DependencyContainer` | Dependency creation | ⚠️ | Large but acceptable |

**Verification Prompt:**
```
Review these AWAVE components for SRP compliance:
1. PlayerViewModel - handles UI state for player screen
2. PlaySoundMixUseCase - downloads, prepares audio, starts session, tracks analytics
3. DependencyContainer - creates all app dependencies

Which violate SRP and how should they be refactored?
```

---

### O - Open/Closed Principle

> "Open for extension, closed for modification"

| Feature | Extensible? | How? |
|---------|-------------|------|
| Add new sound category | ✅ | Add enum case, no core changes |
| Add new repository | ✅ | Implement protocol |
| Add new audio effect | ⚠️ | May need AudioEngine changes |
| Add new auth provider | ✅ | Firebase Auth handles |
| Add new sync strategy | ✅ | Implement SyncStrategy protocol |
| Add new analytics event | ✅ | Add to event enum |

**Extension Points:**
```swift
// ✅ Good: Protocol allows extension
protocol SyncStrategyProtocol {
    func sync(local: [Sound], remote: [Sound]) async throws -> SyncResult
}

// Can add new strategies without modifying existing code
struct LastWriteWinsSyncStrategy: SyncStrategyProtocol { }
struct MergeWithConflictResolutionSyncStrategy: SyncStrategyProtocol { }
```

**Verification Prompt:**
```
Analyze AWAVE's extension points. Can we add:
1. A new sound category (e.g., "meditation")
2. A new data source (e.g., CloudKit)
3. A new audio processor (e.g., reverb)

Without modifying existing code? What changes would be needed?
```

---

### L - Liskov Substitution Principle

> "Subtypes must be substitutable for their base types"

| Protocol | Implementations | Substitutable? |
|----------|-----------------|----------------|
| `SoundRepositoryProtocol` | Firestore, SwiftData, Mock | ✅ |
| `AudioEngineProtocol` | AWAVEAudioEngine, Mock | ✅ |
| `AuthServiceProtocol` | FirebaseAuth, Mock | ✅ |
| `SessionRepositoryProtocol` | SwiftData, Firestore, Mock | ✅ |

**Verification:**
```swift
// All implementations must satisfy the contract
func testRepositorySubstitution<R: SoundRepositoryProtocol>(_ repo: R) async throws {
    let sounds = try await repo.getAll()
    // Must return valid [Sound], not throw unexpected errors
}

// Should work with any implementation
testRepositorySubstitution(FirestoreSoundRepository())
testRepositorySubstitution(SwiftDataSoundRepository())
testRepositorySubstitution(MockSoundRepository())
```

---

### I - Interface Segregation Principle

> "Clients should not depend on interfaces they don't use"

| Protocol | Methods | Segregated? | Suggestion |
|----------|---------|-------------|------------|
| `SoundRepositoryProtocol` | 4 methods | ✅ | Appropriately sized |
| `AudioEngineProtocol` | 10+ methods | ⚠️ | Consider splitting |
| `AuthServiceProtocol` | 6 methods | ✅ | Reasonable |

**Potential Split:**
```swift
// Current: One large protocol
protocol AudioEngineProtocol {
    func prepareMix() async throws
    func play()
    func pause()
    func stop()
    func setVolume()
    func addTrack()
    func removeTrack()
    // ...
}

// Better: Segregated protocols
protocol AudioPlaybackProtocol {
    func play()
    func pause()
    func stop()
}

protocol AudioMixingProtocol {
    func setVolume(_ volume: Float, for trackId: String)
    func addTrack(_ sound: Sound) async throws
    func removeTrack(_ trackId: String)
}

protocol AudioPreparationProtocol {
    func prepareMix(sounds: [Sound]) async throws -> [MixerTrack]
}
```

---

### D - Dependency Inversion Principle

> "Depend on abstractions, not concretions"

| Layer | Depends On | Correct? |
|-------|------------|----------|
| Views | ViewModels (concrete) | ⚠️ But SwiftUI standard |
| ViewModels | Protocols | ✅ |
| Use Cases | Protocols | ✅ |
| Repositories | Domain entities | ✅ |
| Domain | Nothing external | ✅ |

**Dependency Graph:**
```
Presentation    →    Domain    ←    Data
    │                   ▲            │
    └───────────────────┼────────────┘
                        │
              (Protocols defined here)
```

**Verification Prompt:**
```
Verify Dependency Inversion in AWAVE:
1. Does PlayerViewModel depend on AudioEngineProtocol (abstraction) or AWAVEAudioEngine (concrete)?
2. Can Domain layer compile without Data layer?
3. Are all external frameworks wrapped behind protocols?
```

---

## DRY - Don't Repeat Yourself

| Area | Duplication? | Resolution |
|------|--------------|------------|
| Error messages | ⚠️ | Use localized strings |
| API endpoints | ✅ | Centralized in Firestore service |
| UI components | ✅ | AWAVEDesign package |
| Validation logic | ⚠️ | Create shared validators |
| Date formatting | ✅ | Extensions in AWAVECore |

**DRY Violations to Fix:**
```swift
// ❌ Repeated validation
class HomeViewModel {
    func loadSounds() async {
        guard networkMonitor.isConnected else { return }
        // ...
    }
}

class LibraryViewModel {
    func loadFavorites() async {
        guard networkMonitor.isConnected else { return }
        // ...
    }
}

// ✅ Extracted to shared utility
extension ViewModel {
    func withNetworkCheck<T>(_ operation: () async throws -> T) async throws -> T {
        guard networkMonitor.isConnected else {
            throw AWAVEError.networkUnavailable
        }
        return try await operation()
    }
}
```

---

## KISS - Keep It Simple, Stupid

| Component | Complexity | Justified? |
|-----------|------------|------------|
| DependencyContainer | Medium | ✅ Centralized, clear purpose |
| PlayerViewModel | Low | ✅ Simple state machine |
| SyncEngine | High | ⚠️ Review for simplification |
| AudioEngine | High | ✅ Necessary complexity |
| Navigation | Medium | ✅ Coordinator simplifies |

**Complexity Check:**
```
Questions to ask:
├── Can a new developer understand this in 15 minutes?
├── Are there simpler alternatives?
├── Is the complexity solving a real problem?
└── Can we defer complexity to later?
```

---

## YAGNI - You Ain't Gonna Need It

| Feature | Implemented | Needed Now? |
|---------|-------------|-------------|
| Multi-language support | ✅ | ⚠️ German only at launch |
| visionOS support | ❌ | ❌ Not yet |
| watchOS support | ❌ | ❌ Phase 2 |
| AI recommendations | ❌ | ❌ Phase 3 |
| Real-time collaboration | ❌ | ❌ Never planned |

**YAGNI Violations Found:**
```swift
// ❌ Over-engineering for hypothetical futures
protocol AudioEngine {
    func applyEffect(_ effect: AudioEffect) // No effects planned
    func enableSpatialAudio() // visionOS not in scope
}

// ✅ Build for current needs
protocol AudioEngine {
    func prepareMix(sounds: [Sound]) async throws -> [MixerTrack]
    func play()
    func setVolume(_ volume: Float, for trackId: String)
}
```

---

## Composition Over Inheritance

| Pattern | Usage | Correct? |
|---------|-------|----------|
| Protocol composition | ✅ Used throughout | ✅ |
| Class inheritance | ❌ Avoided | ✅ |
| Value types | ✅ Structs for models | ✅ |

**Good Example:**
```swift
// ✅ Composition via protocols
protocol Playable { func play() }
protocol Pausable { func pause() }
protocol VolumeControllable { func setVolume(_ volume: Float) }

// Compose capabilities
protocol AudioControlling: Playable, Pausable, VolumeControllable { }
```

---

## Fail Fast

| Area | Fails Fast? | How |
|------|-------------|-----|
| Invalid state transitions | ✅ | Assertion in debug |
| Missing dependencies | ✅ | Crash at launch (caught early) |
| Invalid API responses | ✅ | Throws errors |
| Invalid user input | ⚠️ | Validate at entry |

**Implementation:**
```swift
// ✅ Fail fast on invalid state
private func transition(to newState: PlayerState) {
    guard state.canTransition(to: newState) else {
        assertionFailure("Invalid transition: \(state) → \(newState)")
        return
    }
    state = newState
}

// ✅ Fail fast on missing config
guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] else {
    fatalError("API_KEY not configured in Info.plist")
}
```

---

## Separation of Concerns

| Concern | Location | Correct? |
|---------|----------|----------|
| UI rendering | SwiftUI Views | ✅ |
| UI state | ViewModels | ✅ |
| Business logic | Use Cases | ✅ |
| Data access | Repositories | ✅ |
| Navigation | Coordinator | ✅ |
| Audio playback | AudioEngine | ✅ |

---

## Law of Demeter

> "Only talk to your immediate friends"

| Violation Check | Example | Correct? |
|-----------------|---------|----------|
| View → ViewModel → UseCase | `viewModel.playSoundMixUseCase.execute()` | ❌ |
| View → ViewModel | `viewModel.play()` | ✅ |
| ViewModel → UseCase | `useCase.execute()` | ✅ |

**Fix Violations:**
```swift
// ❌ Law of Demeter violation
view.viewModel.useCase.repository.getAll()

// ✅ Proper encapsulation
view.viewModel.loadSounds() // ViewModel handles internally
```

---

## Checklist Summary

| Principle | Status | Action Needed |
|-----------|--------|---------------|
| Single Responsibility | ⚠️ | Review PlaySoundMixUseCase |
| Open/Closed | ✅ | - |
| Liskov Substitution | ✅ | - |
| Interface Segregation | ⚠️ | Consider splitting AudioEngine |
| Dependency Inversion | ✅ | - |
| DRY | ⚠️ | Extract repeated patterns |
| KISS | ⚠️ | Simplify SyncEngine |
| YAGNI | ✅ | - |
| Composition over Inheritance | ✅ | - |
| Fail Fast | ✅ | - |
| Separation of Concerns | ✅ | - |
| Law of Demeter | ✅ | - |

**Overall Compliance: 83%**
