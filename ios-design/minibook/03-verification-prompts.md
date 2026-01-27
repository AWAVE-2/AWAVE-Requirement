# Verification Prompts

## How to Use

1. First, provide the context from `01-context.md` to the LLM
2. Then use these prompts to verify specific aspects
3. Document findings and action items

---

## Category 1: Overall Architecture

### Prompt 1.1: Architecture Appropriateness
```
Given the AWAVE context provided, evaluate whether the MVVM + Clean Architecture
hybrid is the appropriate choice. Consider:

1. Is this architecture suitable for a multi-track audio mixing application?
2. Does the complexity level match the project requirements?
3. Are there any architectural patterns that would be better suited?
4. What are the main risks of this architectural choice?

Please provide:
- Your assessment (Appropriate / Needs Changes / Not Recommended)
- Specific concerns if any
- Recommendations for improvement
```

### Prompt 1.2: Layer Separation
```
Analyze the layer separation in AWAVE (Presentation → Domain → Data → Core Services).

1. Are the boundaries between layers clear and appropriate?
2. Is the dependency direction correct (outer layers depend on inner)?
3. Are there any circular dependencies or improper dependencies?
4. Is the Domain layer truly independent of frameworks?

Provide specific examples of any violations you identify.
```

### Prompt 1.3: Scalability Assessment
```
Evaluate AWAVE's architecture for scalability:

1. Can the architecture support adding new features independently?
2. How well would it handle growing to 50+ features?
3. Is the modular package structure appropriate for team scaling?
4. What would need to change if the user base grew 100x?

Identify potential bottlenecks and suggest mitigations.
```

---

## Category 2: Pattern Verification

### Prompt 2.1: Repository Pattern
```
Review the Repository pattern implementation in AWAVE:

```swift
protocol SoundRepositoryProtocol: Sendable {
    func getAll() async throws -> [Sound]
    func get(id: String) async throws -> Sound?
    func getByCategory(_ category: Sound.Category) async throws -> [Sound]
}

final class FirestoreSoundRepository: SoundRepositoryProtocol {
    // Implementation using Firestore
}

final class SyncedSoundRepository: SoundRepositoryProtocol {
    private let local: SoundRepositoryProtocol
    private let remote: SoundRepositoryProtocol
    // Combines local + remote with sync
}
```

Verify:
1. Is the protocol design appropriate?
2. Is the composite (SyncedRepository) pattern correctly applied?
3. Does this properly abstract the data source?
4. How should caching be integrated?
```

### Prompt 2.2: Use Case Pattern
```
Evaluate the Use Case (Command) pattern implementation:

```swift
protocol PlaySoundMixUseCaseProtocol {
    func execute(mix: SoundMix) async throws -> [MixerTrack]
}

final class PlaySoundMixUseCase: PlaySoundMixUseCaseProtocol {
    private let audioEngine: AudioEngineProtocol
    private let downloadManager: DownloadManagerProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol

    func execute(mix: SoundMix) async throws -> [MixerTrack] {
        let urls = try await downloadManager.ensureDownloaded(mix.sounds)
        let tracks = try await audioEngine.prepareMix(sounds: mix.sounds, urls: urls)
        try await sessionRepository.startSession(mix: mix)
        analyticsService.track(.playbackStarted(mixId: mix.id))
        return tracks
    }
}
```

Verify:
1. Is this Use Case doing too much (SRP violation)?
2. Should any operations be split into separate Use Cases?
3. Is error handling appropriate?
4. How should this be tested?
```

### Prompt 2.3: Coordinator Pattern
```
Review the Navigation Coordinator implementation:

```swift
@Observable
final class AppCoordinator {
    var selectedTab: Tab = .home
    var homePath = NavigationPath()
    var presentedSheet: SheetDestination?
    var presentedFullScreen: FullScreenDestination?

    func navigate(to destination: Destination) {
        switch destination {
        case .category(let category): homePath.append(destination)
        case .player(let mix): presentedFullScreen = .player(mix)
        case .search: presentedSheet = .search
        // ...
        }
    }
}
```

Verify:
1. Is this Coordinator design appropriate for SwiftUI?
2. Should there be per-feature coordinators?
3. How well does this support deep linking?
4. Is the state management appropriate?
```

---

## Category 3: State Management

### Prompt 3.1: @Observable Usage
```
Evaluate the use of @Observable for ViewModels:

```swift
@Observable
final class PlayerViewModel {
    private(set) var state: PlayerState = .idle
    private(set) var tracks: [MixerTrack] = []
    private(set) var isPlaying = false
    private(set) var currentTime: TimeInterval = 0

    @ObservationIgnored
    private var audioEngine: AudioEngineProtocol!

    func play() async {
        guard state == .ready || state == .paused else { return }
        await audioEngine.play()
        isPlaying = true
        state = .playing
    }
}
```

Verify:
1. Is @Observable the right choice for this use case?
2. Are the access levels (private(set)) appropriate?
3. Is @ObservationIgnored used correctly for dependencies?
4. How does this compare to TCA for state management?
```

### Prompt 3.2: State Machine
```
Review the PlayerState state machine:

```swift
enum PlayerState: Equatable {
    case idle
    case loading
    case ready
    case playing
    case paused
    case error(AWAVEError)

    func canTransition(to newState: PlayerState) -> Bool {
        switch (self, newState) {
        case (.idle, .loading): return true
        case (.loading, .ready): return true
        case (.loading, .error): return true
        case (.ready, .playing): return true
        case (.playing, .paused): return true
        case (.paused, .playing): return true
        case (.playing, .idle): return true
        case (.error, .idle): return true
        default: return false
        }
    }
}
```

Verify:
1. Are all valid state transitions covered?
2. Are there any missing states?
3. Should state transitions be enforced at compile time?
4. How should state persistence be handled?
```

---

## Category 4: Concurrency & Performance

### Prompt 4.1: Actor Usage
```
Evaluate the Actor-based AudioEngine:

```swift
actor AWAVEAudioEngine: AudioEngineProtocol {
    private let engine = AVAudioEngine()
    private var playerNodes: [String: AVAudioPlayerNode] = [:]

    var isPlaying: Bool { /* ... */ }
    var currentTime: TimeInterval { /* ... */ }

    func prepareMix(sounds: [Sound], urls: [String: URL]) async throws -> [MixerTrack] {
        // Thread-safe preparation
    }

    func play() async {
        // Start all player nodes
    }

    func setVolume(_ volume: Float, for trackId: String) {
        // Modify node volume
    }
}
```

Verify:
1. Is Actor the right concurrency primitive here?
2. Are there potential performance issues with Actor isolation?
3. Should any methods be nonisolated?
4. How should real-time audio updates be handled?
```

### Prompt 4.2: Memory Management
```
For a multi-track audio app with 7 simultaneous tracks, evaluate:

1. How should audio buffers be managed to avoid memory spikes?
2. What's the expected memory footprint for 7 tracks?
3. How should waveform data be loaded efficiently?
4. When should audio files be released from memory?

Consider the constraint that total memory should stay under 100MB.
```

### Prompt 4.3: Background Performance
```
Evaluate background audio handling:

1. How should the app handle audio when backgrounded?
2. What's the battery impact of 7-track playback?
3. How should interrupted playback be resumed?
4. What optimizations are possible for background mode?
```

---

## Category 5: Testing

### Prompt 5.1: Testability Assessment
```
Assess the testability of AWAVE's architecture:

1. Can ViewModels be unit tested in isolation?
2. Can Use Cases be tested without real services?
3. How should the AudioEngine be mocked?
4. What's the appropriate test coverage strategy?

Provide specific examples of how tests should be structured.
```

### Prompt 5.2: Mock Design
```
Review this mock implementation:

```swift
final class MockAudioEngine: AudioEngineProtocol {
    var isPlaying = false
    var currentTime: TimeInterval = 0

    private(set) var playCallCount = 0
    private(set) var prepareMixCallCount = 0

    func prepareMix(sounds: [Sound], urls: [String: URL]) async throws -> [MixerTrack] {
        prepareMixCallCount += 1
        return sounds.map { MixerTrack.mock(from: $0) }
    }

    func play() async {
        playCallCount += 1
        isPlaying = true
    }
}
```

Verify:
1. Is this mock design appropriate?
2. Should there be error injection capabilities?
3. How should async behavior be simulated?
4. Is the call tracking sufficient for verification?
```

---

## Category 6: SOLID Principles

### Prompt 6.1: Single Responsibility
```
Evaluate SRP compliance in AWAVE:

1. Does PlayerViewModel have a single responsibility?
2. Does PlaySoundMixUseCase do only one thing?
3. Is the DependencyContainer responsible for too much?
4. Identify any classes that should be split.
```

### Prompt 6.2: Dependency Inversion
```
Verify Dependency Inversion in AWAVE:

1. Do high-level modules depend only on abstractions?
2. Are all external frameworks wrapped behind protocols?
3. Is the Domain layer truly independent?
4. Identify any DIP violations.

Example to verify:
```swift
// Domain layer
protocol AudioEngineProtocol { }

// Data layer (implements)
actor AWAVEAudioEngine: AudioEngineProtocol { }

// Presentation layer (uses)
class PlayerViewModel {
    private var audioEngine: AudioEngineProtocol  // Protocol, not concrete
}
```
```

### Prompt 6.3: Open/Closed
```
Evaluate Open/Closed Principle compliance:

1. Can new categories be added without modifying existing code?
2. Can new sync strategies be added without changes?
3. Can new audio effects be added cleanly?
4. Identify areas that need extension points.
```

---

## Category 7: Error Handling

### Prompt 7.1: Error Strategy
```
Review the error handling approach:

```swift
enum AWAVEError: Error, LocalizedError {
    case networkUnavailable
    case audioPlaybackFailed(underlying: Error)
    case audioFileNotFound(soundId: String)
    case subscriptionRequired
    case authenticationRequired

    var errorDescription: String? {
        switch self {
        case .networkUnavailable: return String(localized: "error.network")
        // ...
        }
    }
}
```

Verify:
1. Is this error hierarchy appropriate?
2. Should errors be more granular?
3. How should errors be propagated through layers?
4. What recovery mechanisms should exist?
```

---

## Category 8: Security

### Prompt 8.1: Data Security
```
Evaluate security considerations:

1. Is Keychain used appropriately for sensitive data?
2. Are API tokens handled securely?
3. Is user data properly encrypted at rest?
4. Are there any obvious security vulnerabilities?

Consider the data flow:
Firebase Auth → JWT Token → Keychain → API Requests
```

---

## Output Template

After running verification prompts, document findings:

```markdown
## Verification: [Prompt Name]

### Date: [Date]
### LLM Used: [Model]

### Findings
- [Finding 1]
- [Finding 2]

### Issues Identified
- [ ] Issue 1 (Severity: High/Medium/Low)
- [ ] Issue 2

### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]

### Action Items
- [ ] Action 1 (Owner: ___, Due: ___)
- [ ] Action 2
```
