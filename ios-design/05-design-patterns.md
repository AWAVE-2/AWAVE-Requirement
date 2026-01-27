# Design Patterns for AWAVE iOS

## Overview

This document catalogs the design patterns used throughout AWAVE, explaining why each pattern was chosen and how it's implemented.

---

## Pattern Catalog

| Category | Pattern | Usage in AWAVE |
|----------|---------|----------------|
| Creational | Factory | DependencyContainer, ViewModelFactory |
| Creational | Builder | SoundMixBuilder, URLRequestBuilder |
| Structural | Repository | All data access |
| Structural | Adapter | Firestore ↔ Domain models |
| Structural | Facade | AudioEngine (wraps AVFoundation) |
| Structural | Composite | UI component hierarchies |
| Behavioral | Strategy | Sync strategies, error handling |
| Behavioral | Observer | @Observable, Combine publishers |
| Behavioral | Command | Use Cases |
| Behavioral | State | Player states, download states |
| iOS-Specific | Coordinator | Navigation management |
| iOS-Specific | Delegate | Audio session, downloads |

---

## Creational Patterns

### Factory Pattern

**Purpose**: Centralize object creation, enable configuration switching

```swift
// DependencyContainer as Factory
struct DependencyContainer {
    static var live: DependencyContainer {
        // Production configuration
    }

    static var preview: DependencyContainer {
        // SwiftUI preview configuration
    }

    static var test: DependencyContainer {
        // Test configuration with mocks
    }
}

// ViewModelFactory for dynamic creation
struct ViewModelFactory {
    let dependencies: DependencyContainer

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            soundRepository: dependencies.soundRepository,
            favoriteRepository: dependencies.favoriteRepository
        )
    }

    func makePlayerViewModel(for mix: SoundMix) -> PlayerViewModel {
        PlayerViewModel(
            mix: mix,
            playSoundMixUseCase: dependencies.playSoundMixUseCase,
            audioEngine: dependencies.audioEngine
        )
    }
}
```

### Builder Pattern

**Purpose**: Construct complex objects step-by-step

```swift
// SoundMixBuilder - Fluent interface for creating mixes
final class SoundMixBuilder {
    private var name: String = "Custom Mix"
    private var sounds: [(sound: Sound, volume: Float)] = []
    private var category: Sound.Category = .relax

    func named(_ name: String) -> Self {
        self.name = name
        return self
    }

    func addSound(_ sound: Sound, volume: Float = 0.8) -> Self {
        guard sounds.count < 7 else { return self }
        sounds.append((sound, volume))
        return self
    }

    func category(_ category: Sound.Category) -> Self {
        self.category = category
        return self
    }

    func build() -> SoundMix {
        SoundMix(
            id: UUID().uuidString,
            name: name,
            sounds: sounds.map { SoundMixItem(soundId: $0.sound.id, volume: $0.volume) },
            category: category.rawValue
        )
    }
}

// Usage
let mix = SoundMixBuilder()
    .named("Evening Calm")
    .addSound(oceanSound, volume: 0.7)
    .addSound(rainSound, volume: 0.5)
    .addSound(pianoSound, volume: 0.3)
    .category(.sleep)
    .build()
```

---

## Structural Patterns

### Repository Pattern

**Purpose**: Abstract data access, enable multiple data sources

```swift
// Protocol defines contract
protocol SoundRepositoryProtocol {
    func getAll() async throws -> [Sound]
    func get(id: String) async throws -> Sound?
    func getByCategory(_ category: Sound.Category) async throws -> [Sound]
}

// Firestore implementation
final class FirestoreSoundRepository: SoundRepositoryProtocol {
    private let firestore: Firestore
    private let cache: SoundCacheProtocol

    func getAll() async throws -> [Sound] {
        // Check cache first
        if let cached = await cache.getAll() {
            return cached
        }

        // Fetch from Firestore
        let snapshot = try await firestore.collection("sounds").getDocuments()
        let sounds = snapshot.documents.compactMap { try? $0.data(as: FirestoreSound.self).toDomain() }

        // Update cache
        await cache.set(sounds)

        return sounds
    }
}

// SwiftData implementation (for local-first)
@ModelActor
actor SwiftDataSoundRepository: SoundRepositoryProtocol {
    func getAll() async throws -> [Sound] {
        let descriptor = FetchDescriptor<SoundModel>()
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }
}

// Composite repository (combines local + remote)
final class SyncedSoundRepository: SoundRepositoryProtocol {
    private let local: SoundRepositoryProtocol
    private let remote: SoundRepositoryProtocol
    private let syncEngine: SyncEngineProtocol

    func getAll() async throws -> [Sound] {
        // Return local immediately
        let localSounds = try await local.getAll()

        // Sync in background
        Task {
            let remoteSounds = try? await remote.getAll()
            await syncEngine.merge(local: localSounds, remote: remoteSounds ?? [])
        }

        return localSounds
    }
}
```

### Adapter Pattern

**Purpose**: Convert between incompatible interfaces

```swift
// Firestore model (external representation)
struct FirestoreSound: Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var category: String
    var duration: Double
    var fileUrl: String
    var thumbnailUrl: String?
    var isPremium: Bool
    var tags: [String]?
    @ServerTimestamp var createdAt: Date?
}

// Domain model (internal representation)
struct Sound: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let category: Category
    let duration: TimeInterval
    let fileURL: URL
    let thumbnailURL: URL?
    let isPremium: Bool
    let tags: [String]

    enum Category: String {
        case sleep, relax, flow, focus
    }
}

// Adapter: Firestore → Domain
extension FirestoreSound {
    func toDomain() -> Sound? {
        guard let id = id,
              let category = Sound.Category(rawValue: category),
              let fileURL = URL(string: fileUrl) else {
            return nil
        }

        return Sound(
            id: id,
            name: name,
            description: description,
            category: category,
            duration: duration,
            fileURL: fileURL,
            thumbnailURL: thumbnailUrl.flatMap(URL.init),
            isPremium: isPremium,
            tags: tags ?? []
        )
    }
}

// Adapter: Domain → Firestore
extension Sound {
    func toFirestore() -> FirestoreSound {
        FirestoreSound(
            id: id,
            name: name,
            description: description,
            category: category.rawValue,
            duration: duration,
            fileUrl: fileURL.absoluteString,
            thumbnailUrl: thumbnailURL?.absoluteString,
            isPremium: isPremium,
            tags: tags
        )
    }
}
```

### Facade Pattern

**Purpose**: Provide simple interface to complex subsystem

```swift
// AudioEngine as Facade over AVFoundation complexity
actor AWAVEAudioEngine: AudioEngineProtocol {
    // Internal complexity hidden
    private let engine = AVAudioEngine()
    private let mainMixer: AVAudioMixerNode
    private var playerNodes: [String: AVAudioPlayerNode] = [:]
    private var audioFiles: [String: AVAudioFile] = [:]

    // Simple public interface
    var isPlaying: Bool { /* ... */ }
    var currentTime: TimeInterval { /* ... */ }

    func prepareMix(sounds: [Sound], urls: [String: URL]) async throws -> [MixerTrack] {
        // Hides complexity of:
        // - Creating AVAudioPlayerNodes
        // - Connecting to mixer
        // - Scheduling audio files
        // - Configuring audio format
    }

    func play() async {
        // Hides complexity of:
        // - Starting AVAudioEngine
        // - Playing all nodes
        // - Updating Now Playing info
        // - Handling interruptions
    }

    func setVolume(_ volume: Float, for trackId: String) {
        // Simple volume change hides node management
        playerNodes[trackId]?.volume = volume
    }
}
```

---

## Behavioral Patterns

### Strategy Pattern

**Purpose**: Define family of algorithms, make them interchangeable

```swift
// Sync Strategy Protocol
protocol SyncStrategyProtocol {
    func sync(local: [Sound], remote: [Sound]) async throws -> SyncResult
}

// Strategy: Remote wins (server is source of truth)
struct RemoteWinsSyncStrategy: SyncStrategyProtocol {
    func sync(local: [Sound], remote: [Sound]) async throws -> SyncResult {
        // Remote data replaces local
        return SyncResult(
            toKeep: remote,
            toDelete: local.filter { localSound in
                !remote.contains { $0.id == localSound.id }
            }
        )
    }
}

// Strategy: Local wins (offline-first)
struct LocalWinsSyncStrategy: SyncStrategyProtocol {
    func sync(local: [Sound], remote: [Sound]) async throws -> SyncResult {
        // Keep local changes, merge new remote
        let newRemote = remote.filter { remoteSound in
            !local.contains { $0.id == remoteSound.id }
        }
        return SyncResult(
            toKeep: local + newRemote,
            toDelete: []
        )
    }
}

// Strategy: Timestamp-based merge
struct TimestampMergeSyncStrategy: SyncStrategyProtocol {
    func sync(local: [Sound], remote: [Sound]) async throws -> SyncResult {
        // Keep whichever is newer per item
        // ...
    }
}

// Context uses strategy
class SyncEngine {
    var strategy: SyncStrategyProtocol = RemoteWinsSyncStrategy()

    func performSync(local: [Sound], remote: [Sound]) async throws -> SyncResult {
        try await strategy.sync(local: local, remote: remote)
    }
}
```

### State Pattern

**Purpose**: Object behavior changes based on internal state

```swift
// Player State Machine
enum PlayerState: Equatable {
    case idle
    case loading
    case ready
    case playing
    case paused
    case error(AWAVEError)

    // Valid transitions
    func canTransition(to newState: PlayerState) -> Bool {
        switch (self, newState) {
        case (.idle, .loading): return true
        case (.loading, .ready): return true
        case (.loading, .error): return true
        case (.ready, .playing): return true
        case (.playing, .paused): return true
        case (.paused, .playing): return true
        case (.playing, .idle): return true // stop
        case (.paused, .idle): return true  // stop
        case (.error, .idle): return true   // reset
        default: return false
        }
    }
}

@Observable
class PlayerViewModel {
    private(set) var state: PlayerState = .idle

    private func transition(to newState: PlayerState) {
        guard state.canTransition(to: newState) else {
            assertionFailure("Invalid state transition: \(state) → \(newState)")
            return
        }
        state = newState
    }

    func loadMix(_ mix: SoundMix) async {
        transition(to: .loading)
        do {
            tracks = try await playSoundMixUseCase.execute(mix: mix)
            transition(to: .ready)
        } catch let error as AWAVEError {
            transition(to: .error(error))
        } catch {
            transition(to: .error(.audioPlaybackFailed(underlying: error)))
        }
    }

    func play() async {
        guard state == .ready || state == .paused else { return }
        await audioEngine.play()
        transition(to: .playing)
    }

    func pause() {
        guard state == .playing else { return }
        audioEngine.pause()
        transition(to: .paused)
    }
}
```

### Command Pattern (Use Cases)

**Purpose**: Encapsulate request as object, parameterize operations

```swift
// Use Case as Command
protocol UseCaseProtocol {
    associatedtype Input
    associatedtype Output
    func execute(input: Input) async throws -> Output
}

// Concrete Use Case
struct PlaySoundMixUseCase: UseCaseProtocol {
    typealias Input = SoundMix
    typealias Output = [MixerTrack]

    private let audioEngine: AudioEngineProtocol
    private let downloadManager: DownloadManagerProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol

    func execute(input mix: SoundMix) async throws -> [MixerTrack] {
        // Command encapsulates all the logic
        let urls = try await downloadManager.ensureDownloaded(mix.sounds)
        let tracks = try await audioEngine.prepareMix(sounds: mix.sounds, urls: urls)
        try await sessionRepository.startSession(mix: mix)
        analyticsService.track(.playbackStarted(mixId: mix.id))
        return tracks
    }
}

// Use Cases can be composed
struct PlayAndTrackUseCase {
    let playUseCase: PlaySoundMixUseCase
    let trackUseCase: TrackSessionUseCase

    func execute(mix: SoundMix) async throws {
        let tracks = try await playUseCase.execute(input: mix)
        try await trackUseCase.execute(input: .init(tracks: tracks))
    }
}
```

---

## iOS-Specific Patterns

### Coordinator Pattern

**Purpose**: Centralize navigation logic, separate from views

```swift
// Navigation Coordinator
@Observable
final class AppCoordinator {
    // State
    var selectedTab: Tab = .home
    var homePath = NavigationPath()
    var presentedSheet: SheetDestination?
    var presentedFullScreen: FullScreenDestination?

    // Navigation actions
    func showPlayer(for mix: SoundMix) {
        presentedFullScreen = .player(mix)
    }

    func showSearch() {
        presentedSheet = .search
    }

    func showCategory(_ category: Sound.Category) {
        homePath.append(Destination.category(category))
    }

    func showSound(_ sound: Sound) {
        homePath.append(Destination.sound(sound))
    }

    func dismiss() {
        if presentedFullScreen != nil {
            presentedFullScreen = nil
        } else if presentedSheet != nil {
            presentedSheet = nil
        } else if !homePath.isEmpty {
            homePath.removeLast()
        }
    }

    func popToRoot() {
        homePath = NavigationPath()
    }
}

// Usage in View
struct HomeView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        NavigationStack(path: $coordinator.homePath) {
            HomeContent()
                .navigationDestination(for: Destination.self) { destination in
                    destinationView(for: destination)
                }
        }
        .sheet(item: $coordinator.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
        .fullScreenCover(item: $coordinator.presentedFullScreen) { cover in
            fullScreenView(for: cover)
        }
    }
}
```

### Observer Pattern (@Observable + Combine)

**Purpose**: Notify dependents of state changes

```swift
// @Observable for SwiftUI (preferred)
@Observable
class PlayerViewModel {
    var isPlaying = false  // Changes automatically update views
    var tracks: [MixerTrack] = []
    var currentTime: TimeInterval = 0
}

// Combine for complex async streams
class AudioSessionObserver {
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] notification in
                self?.handleInterruption(notification)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
            .sink { [weak self] notification in
                self?.handleRouteChange(notification)
            }
            .store(in: &cancellables)
    }
}

// AsyncStream for custom event streams
extension AudioEngine {
    var timeUpdates: AsyncStream<TimeInterval> {
        AsyncStream { continuation in
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                continuation.yield(self.currentTime)
            }
            continuation.onTermination = { _ in
                timer.invalidate()
            }
        }
    }
}
```

---

## Pattern Selection Guide

| Situation | Recommended Pattern |
|-----------|---------------------|
| Need different implementations | Strategy |
| Complex object creation | Factory / Builder |
| Data access abstraction | Repository |
| Convert between formats | Adapter |
| Simplify complex API | Facade |
| Object behavior varies by state | State |
| Encapsulate business operation | Command (Use Case) |
| Manage navigation | Coordinator |
| React to changes | Observer (@Observable) |
| Compose UI hierarchies | Composite |
