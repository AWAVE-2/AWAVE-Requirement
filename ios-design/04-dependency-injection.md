# Dependency Injection

## Overview

AWAVE uses a combination of **Environment-based DI** (SwiftUI native) and **Factory pattern** for flexible, testable dependency management.

---

## DI Strategy Comparison

| Approach | Pros | Cons | Use In AWAVE |
|----------|------|------|--------------|
| Constructor Injection | Explicit, testable | Verbose, deep passing | Use Cases, Repositories |
| Property Injection | Flexible | Hidden dependencies | Avoid |
| Environment Injection | SwiftUI native | View-only | Views, ViewModels |
| Service Locator | Simple access | Hidden deps, hard to test | Avoid |
| Factory Pattern | Centralized, testable | More setup | Composition root |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       Dependency Injection Architecture                      │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                      Composition Root (App Entry)                       │ │
│  │                                                                         │ │
│  │    ┌─────────────────────────────────────────────────────────────┐    │ │
│  │    │               DependencyContainer                            │    │ │
│  │    │                                                              │    │ │
│  │    │  Creates and wires all dependencies at app launch           │    │ │
│  │    │  Provides .live, .preview, .test configurations             │    │ │
│  │    └─────────────────────────────────────────────────────────────┘    │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                       │
│                                      ▼                                       │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                       SwiftUI Environment                               │ │
│  │                                                                         │ │
│  │    @Environment(\.dependencies) var deps                              │ │
│  │                                                                         │ │
│  │    Available to all Views in hierarchy                                 │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                       │
│           ┌──────────────────────────┼──────────────────────────┐           │
│           ▼                          ▼                          ▼           │
│  ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐     │
│  │   ViewModels    │      │   ViewModels    │      │   ViewModels    │     │
│  │                 │      │                 │      │                 │     │
│  │  Receive deps   │      │  Receive deps   │      │  Receive deps   │     │
│  │  via init or    │      │  via init or    │      │  via init or    │     │
│  │  Environment    │      │  Environment    │      │  Environment    │     │
│  └─────────────────┘      └─────────────────┘      └─────────────────┘     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Implementation

### 1. Dependency Container

```swift
// App/DependencyContainer.swift

/// Central container for all application dependencies
/// Created once at app launch, passed through Environment
struct DependencyContainer {
    // MARK: - Core Services
    let authService: AuthServiceProtocol
    let audioEngine: AudioEngineProtocol
    let analyticsService: AnalyticsServiceProtocol
    let networkMonitor: NetworkMonitorProtocol

    // MARK: - Repositories
    let soundRepository: SoundRepositoryProtocol
    let sessionRepository: SessionRepositoryProtocol
    let userRepository: UserRepositoryProtocol
    let favoriteRepository: FavoriteRepositoryProtocol
    let subscriptionRepository: SubscriptionRepositoryProtocol

    // MARK: - Use Cases
    let playSoundMixUseCase: PlaySoundMixUseCaseProtocol
    let trackSessionUseCase: TrackSessionUseCaseProtocol
    let manageFavoriteUseCase: ManageFavoriteUseCaseProtocol
    let syncDataUseCase: SyncDataUseCaseProtocol

    // MARK: - Managers
    let downloadManager: DownloadManagerProtocol
    let cacheManager: CacheManagerProtocol
}

// MARK: - Factory Methods

extension DependencyContainer {
    /// Production dependencies
    static var live: DependencyContainer {
        // Core services
        let authService = FirebaseAuthService()
        let audioEngine = AWAVEAudioEngine()
        let analyticsService = FirebaseAnalyticsService()
        let networkMonitor = NetworkMonitor()

        // Data layer
        let firestore = Firestore.firestore()
        let swiftDataContainer = try! SwiftDataContainer.create()

        // Repositories
        let soundRepository = FirestoreSoundRepository(firestore: firestore)
        let sessionRepository = SwiftDataSessionRepository(container: swiftDataContainer)
        let userRepository = FirestoreUserRepository(firestore: firestore)
        let favoriteRepository = SyncedFavoriteRepository(
            local: SwiftDataFavoriteRepository(container: swiftDataContainer),
            remote: FirestoreFavoriteRepository(firestore: firestore)
        )
        let subscriptionRepository = StoreKitSubscriptionRepository()

        // Managers
        let downloadManager = AudioDownloadManager()
        let cacheManager = LRUCacheManager(maxSize: 2_000_000_000) // 2GB

        // Use Cases
        let playSoundMixUseCase = PlaySoundMixUseCase(
            audioEngine: audioEngine,
            downloadManager: downloadManager,
            sessionRepository: sessionRepository,
            analyticsService: analyticsService
        )

        let trackSessionUseCase = TrackSessionUseCase(
            sessionRepository: sessionRepository,
            analyticsService: analyticsService
        )

        let manageFavoriteUseCase = ManageFavoriteUseCase(
            favoriteRepository: favoriteRepository
        )

        let syncDataUseCase = SyncDataUseCase(
            soundRepository: soundRepository,
            sessionRepository: sessionRepository,
            favoriteRepository: favoriteRepository,
            networkMonitor: networkMonitor
        )

        return DependencyContainer(
            authService: authService,
            audioEngine: audioEngine,
            analyticsService: analyticsService,
            networkMonitor: networkMonitor,
            soundRepository: soundRepository,
            sessionRepository: sessionRepository,
            userRepository: userRepository,
            favoriteRepository: favoriteRepository,
            subscriptionRepository: subscriptionRepository,
            playSoundMixUseCase: playSoundMixUseCase,
            trackSessionUseCase: trackSessionUseCase,
            manageFavoriteUseCase: manageFavoriteUseCase,
            syncDataUseCase: syncDataUseCase,
            downloadManager: downloadManager,
            cacheManager: cacheManager
        )
    }

    /// Preview dependencies with mock data
    static var preview: DependencyContainer {
        DependencyContainer(
            authService: MockAuthService(user: .preview),
            audioEngine: MockAudioEngine(),
            analyticsService: MockAnalyticsService(),
            networkMonitor: MockNetworkMonitor(isConnected: true),
            soundRepository: MockSoundRepository(sounds: Sound.previewSounds),
            sessionRepository: MockSessionRepository(),
            userRepository: MockUserRepository(user: .preview),
            favoriteRepository: MockFavoriteRepository(),
            subscriptionRepository: MockSubscriptionRepository(status: .active),
            playSoundMixUseCase: MockPlaySoundMixUseCase(),
            trackSessionUseCase: MockTrackSessionUseCase(),
            manageFavoriteUseCase: MockManageFavoriteUseCase(),
            syncDataUseCase: MockSyncDataUseCase(),
            downloadManager: MockDownloadManager(),
            cacheManager: MockCacheManager()
        )
    }

    /// Test dependencies with controllable mocks
    static func test(
        authService: AuthServiceProtocol = MockAuthService(),
        audioEngine: AudioEngineProtocol = MockAudioEngine(),
        soundRepository: SoundRepositoryProtocol = MockSoundRepository()
        // ... other overrides
    ) -> DependencyContainer {
        DependencyContainer(
            authService: authService,
            audioEngine: audioEngine,
            // ... use passed or default mocks
        )
    }
}
```

### 2. Environment Key

```swift
// App/Environment+Dependencies.swift

private struct DependenciesKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.live
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}

// Convenience accessors for common dependencies
extension EnvironmentValues {
    var audioEngine: AudioEngineProtocol {
        dependencies.audioEngine
    }

    var soundRepository: SoundRepositoryProtocol {
        dependencies.soundRepository
    }
}
```

### 3. App Entry Point

```swift
// AWAVEApp.swift

@main
struct AWAVEApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var dependencies = DependencyContainer.live
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.dependencies, dependencies)
                .environment(appState)
                .task {
                    await appState.initialize(with: dependencies)
                }
        }
    }
}
```

### 4. View Usage

```swift
// Features/Home/HomeView.swift

struct HomeView: View {
    @Environment(\.dependencies) private var deps
    @State private var viewModel: HomeViewModel?

    var body: some View {
        Group {
            if let viewModel {
                HomeContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            viewModel = HomeViewModel(
                soundRepository: deps.soundRepository,
                favoriteRepository: deps.favoriteRepository
            )
            await viewModel?.loadInitialData()
        }
    }
}

// Alternative: ViewModel receives dependencies via Environment
struct HomeView: View {
    @Environment(\.dependencies) private var deps
    @State private var viewModel = HomeViewModel()

    var body: some View {
        HomeContent(viewModel: viewModel)
            .task {
                viewModel.configure(with: deps)
                await viewModel.loadInitialData()
            }
    }
}
```

### 5. ViewModel with Dependencies

```swift
// Features/Player/PlayerViewModel.swift

@Observable
final class PlayerViewModel {
    // MARK: - State
    private(set) var state: PlayerState = .idle
    private(set) var tracks: [MixerTrack] = []
    private(set) var isPlaying = false

    // MARK: - Dependencies
    @ObservationIgnored
    private var playSoundMixUseCase: PlaySoundMixUseCaseProtocol!
    @ObservationIgnored
    private var trackSessionUseCase: TrackSessionUseCaseProtocol!
    @ObservationIgnored
    private var audioEngine: AudioEngineProtocol!

    // MARK: - Initialization

    /// Configure with dependencies from Environment
    func configure(with dependencies: DependencyContainer) {
        self.playSoundMixUseCase = dependencies.playSoundMixUseCase
        self.trackSessionUseCase = dependencies.trackSessionUseCase
        self.audioEngine = dependencies.audioEngine
    }

    /// Direct initialization for testing
    init(
        playSoundMixUseCase: PlaySoundMixUseCaseProtocol,
        trackSessionUseCase: TrackSessionUseCaseProtocol,
        audioEngine: AudioEngineProtocol
    ) {
        self.playSoundMixUseCase = playSoundMixUseCase
        self.trackSessionUseCase = trackSessionUseCase
        self.audioEngine = audioEngine
    }

    /// Default init (requires configure() call)
    init() {}

    // MARK: - Actions

    func loadMix(_ mix: SoundMix) async {
        state = .loading
        do {
            tracks = try await playSoundMixUseCase.execute(mix: mix)
            state = .ready
        } catch {
            state = .error(error)
        }
    }
}
```

---

## Protocol Definitions

### Service Protocols

```swift
// Domain/Protocols/Services/AuthServiceProtocol.swift

protocol AuthServiceProtocol: Sendable {
    var currentUser: User? { get async }
    var isAuthenticated: Bool { get async }

    func signInWithApple() async throws -> User
    func signInWithGoogle() async throws -> User
    func signInWithEmail(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() async throws
    func deleteAccount() async throws
}

// Domain/Protocols/Services/AudioEngineProtocol.swift

protocol AudioEngineProtocol: Actor {
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }

    func prepareMix(sounds: [Sound], urls: [String: URL]) async throws -> [MixerTrack]
    func play() async
    func pause()
    func stop()
    func seek(to time: TimeInterval)
    func setVolume(_ volume: Float, for trackId: String)
    func setMuted(_ muted: Bool, for trackId: String)
    func addTrack(_ sound: Sound, url: URL) async throws -> MixerTrack
    func removeTrack(_ trackId: String)
}
```

### Repository Protocols

```swift
// Domain/Protocols/Repositories/SoundRepositoryProtocol.swift

protocol SoundRepositoryProtocol: Sendable {
    func getAll() async throws -> [Sound]
    func get(id: String) async throws -> Sound?
    func getByCategory(_ category: Sound.Category) async throws -> [Sound]
    func search(query: String) async throws -> [Sound]
    func getFeatured() async throws -> [Sound]
}

// Domain/Protocols/Repositories/SessionRepositoryProtocol.swift

protocol SessionRepositoryProtocol: Sendable {
    func save(_ session: Session) async throws
    func update(_ session: Session) async throws
    func getRecent(limit: Int) async throws -> [Session]
    func getStats() async throws -> SessionStats
}
```

---

## Mock Implementations

```swift
// Tests/Mocks/MockSoundRepository.swift

final class MockSoundRepository: SoundRepositoryProtocol, @unchecked Sendable {
    // Configurable behavior
    var sounds: [Sound] = []
    var error: Error?
    var delay: Duration = .zero

    // Call tracking
    private(set) var getAllCallCount = 0
    private(set) var searchQueries: [String] = []

    func getAll() async throws -> [Sound] {
        getAllCallCount += 1
        if delay > .zero { try await Task.sleep(for: delay) }
        if let error { throw error }
        return sounds
    }

    func get(id: String) async throws -> Sound? {
        if let error { throw error }
        return sounds.first { $0.id == id }
    }

    func getByCategory(_ category: Sound.Category) async throws -> [Sound] {
        if let error { throw error }
        return sounds.filter { $0.category == category }
    }

    func search(query: String) async throws -> [Sound] {
        searchQueries.append(query)
        if let error { throw error }
        return sounds.filter { $0.name.contains(query) }
    }

    func getFeatured() async throws -> [Sound] {
        if let error { throw error }
        return Array(sounds.prefix(5))
    }
}

// Tests/Mocks/MockAudioEngine.swift

actor MockAudioEngine: AudioEngineProtocol {
    var isPlaying = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 300

    // Call tracking
    private(set) var playCallCount = 0
    private(set) var pauseCallCount = 0
    private(set) var preparedMixes: [SoundMix] = []

    func prepareMix(sounds: [Sound], urls: [String: URL]) async throws -> [MixerTrack] {
        sounds.map { sound in
            MixerTrack(
                id: sound.id,
                soundId: sound.id,
                name: sound.name,
                volume: 0.8,
                isMuted: false,
                duration: sound.duration,
                color: .blue,
                waveformData: []
            )
        }
    }

    func play() async {
        playCallCount += 1
        isPlaying = true
    }

    func pause() {
        pauseCallCount += 1
        isPlaying = false
    }

    // ... other implementations
}
```

---

## Testing with DI

```swift
// Tests/PlayerViewModelTests.swift

import Testing
@testable import PlayerFeature

@Test
func testPlayMixSuccess() async {
    // Arrange
    let mockAudioEngine = MockAudioEngine()
    let mockUseCase = MockPlaySoundMixUseCase()
    mockUseCase.result = [.mock]

    let viewModel = PlayerViewModel(
        playSoundMixUseCase: mockUseCase,
        trackSessionUseCase: MockTrackSessionUseCase(),
        audioEngine: mockAudioEngine
    )

    // Act
    await viewModel.loadMix(.mock)
    await viewModel.play()

    // Assert
    #expect(viewModel.state == .playing)
    #expect(viewModel.isPlaying == true)
    #expect(await mockAudioEngine.playCallCount == 1)
}

@Test
func testPlayMixFailure() async {
    // Arrange
    let mockUseCase = MockPlaySoundMixUseCase()
    mockUseCase.error = AWAVEError.audioPlaybackFailed(underlying: TestError.mock)

    let viewModel = PlayerViewModel(
        playSoundMixUseCase: mockUseCase,
        trackSessionUseCase: MockTrackSessionUseCase(),
        audioEngine: MockAudioEngine()
    )

    // Act
    await viewModel.loadMix(.mock)

    // Assert
    if case .error = viewModel.state {
        // Expected
    } else {
        Issue.record("Expected error state")
    }
}
```

---

## Best Practices

### Do's

```swift
// ✅ Use protocols for dependencies
protocol SoundRepositoryProtocol { }

// ✅ Inject via constructor or configure method
init(repository: SoundRepositoryProtocol)

// ✅ Use Environment for SwiftUI integration
@Environment(\.dependencies) private var deps

// ✅ Create factory methods for different configurations
static var live: DependencyContainer { }
static var preview: DependencyContainer { }
static var test: DependencyContainer { }
```

### Don'ts

```swift
// ❌ Don't use singletons (except at composition root)
class AudioEngine {
    static let shared = AudioEngine() // Avoid
}

// ❌ Don't access dependencies directly
let sounds = FirestoreSoundRepository().getAll() // Avoid

// ❌ Don't create dependencies inside ViewModels
class HomeViewModel {
    let repo = FirestoreSoundRepository() // Avoid
}

// ❌ Don't use service locator pattern
Container.resolve(SoundRepositoryProtocol.self) // Avoid
```
