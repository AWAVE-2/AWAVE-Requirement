# Recommended Architecture for AWAVE

## Executive Summary

AWAVE adopts a **Modular MVVM + Clean Architecture Hybrid** that prioritizes:
- SwiftUI-native development patterns
- Testability at every layer
- Pragmatic complexity management
- Future platform extensibility

---

## Architecture Blueprint

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            AWAVE iOS Architecture                                │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────────┐ │
│  │                           App Shell                                         │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────────────┐   │ │
│  │  │  AWAVEApp    │  │ AppDelegate  │  │  DependencyContainer           │   │ │
│  │  │  (@main)     │  │ (Lifecycle)  │  │  (Composition Root)            │   │ │
│  │  └──────────────┘  └──────────────┘  └────────────────────────────────┘   │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                                          │                                       │
│  ┌───────────────────────────────────────▼────────────────────────────────────┐ │
│  │                        Feature Modules                                      │ │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌──────────┐ │ │
│  │  │    Home    │ │   Player   │ │  Library   │ │  Profile   │ │ Premium  │ │ │
│  │  │   Feature  │ │   Feature  │ │   Feature  │ │   Feature  │ │ Feature  │ │ │
│  │  │            │ │            │ │            │ │            │ │          │ │ │
│  │  │ View       │ │ View       │ │ View       │ │ View       │ │ View     │ │ │
│  │  │ ViewModel  │ │ ViewModel  │ │ ViewModel  │ │ ViewModel  │ │ ViewModel│ │ │
│  │  └────────────┘ └────────────┘ └────────────┘ └────────────┘ └──────────┘ │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                                          │                                       │
│  ┌───────────────────────────────────────▼────────────────────────────────────┐ │
│  │                         Shared Modules                                      │ │
│  │  ┌────────────────┐  ┌────────────────┐  ┌────────────────────────────┐   │ │
│  │  │  DesignSystem  │  │   Navigation   │  │       Shared Views         │   │ │
│  │  │  (Components)  │  │  (Coordinator) │  │  (MiniPlayer, Search, etc) │   │ │
│  │  └────────────────┘  └────────────────┘  └────────────────────────────┘   │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                                          │                                       │
│  ┌───────────────────────────────────────▼────────────────────────────────────┐ │
│  │                          Domain Layer                                       │ │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────────────┐   │ │
│  │  │     Entities     │  │    Use Cases     │  │  Repository Protocols  │   │ │
│  │  │                  │  │                  │  │                        │   │ │
│  │  │ • Sound          │  │ • PlaySoundMix   │  │ • SoundRepository      │   │ │
│  │  │ • User           │  │ • TrackSession   │  │ • SessionRepository    │   │ │
│  │  │ • Session        │  │ • ManageFavorite │  │ • UserRepository       │   │ │
│  │  │ • Subscription   │  │ • SyncData       │  │ • FavoriteRepository   │   │ │
│  │  │ • MixerTrack     │  │ • VerifyPurchase │  │ • SubscriptionRepo     │   │ │
│  │  └──────────────────┘  └──────────────────┘  └────────────────────────┘   │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                                          │                                       │
│  ┌───────────────────────────────────────▼────────────────────────────────────┐ │
│  │                           Data Layer                                        │ │
│  │  ┌────────────────────────────────────────────────────────────────────┐   │ │
│  │  │                    Repository Implementations                       │   │ │
│  │  │  • FirestoreSoundRepository    • SwiftDataSessionRepository        │   │ │
│  │  │  • FirestoreUserRepository     • KeychainCredentialRepository      │   │ │
│  │  └────────────────────────────────────────────────────────────────────┘   │ │
│  │                                                                            │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │ │
│  │  │  SwiftData   │  │   Firestore  │  │   Keychain   │  │ FileManager  │  │ │
│  │  │   (Local)    │  │   (Remote)   │  │  (Secrets)   │  │   (Audio)    │  │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘  │ │
│  │                                                                            │ │
│  │  ┌────────────────────────────────────────────────────────────────────┐   │ │
│  │  │                        Sync Engine                                  │   │ │
│  │  │  • Offline Queue    • Conflict Resolution    • Background Sync     │   │ │
│  │  └────────────────────────────────────────────────────────────────────┘   │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                                          │                                       │
│  ┌───────────────────────────────────────▼────────────────────────────────────┐ │
│  │                         Core Services                                       │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │ │
│  │  │ AudioEngine  │  │ AuthService  │  │ Analytics    │  │ Networking   │   │ │
│  │  │ (AVFoundation)│ │ (Firebase)   │  │ (Firebase)   │  │ (URLSession) │   │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘   │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Layer Specifications

### 1. App Shell

**Responsibility**: Application lifecycle, dependency injection, root navigation

```swift
// AWAVEApp.swift
@main
struct AWAVEApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var container = DependencyContainer.live

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.dependencies, container)
        }
    }
}

// DependencyContainer.swift
struct DependencyContainer {
    // Services
    let authService: AuthServiceProtocol
    let audioEngine: AudioEngineProtocol
    let analyticsService: AnalyticsServiceProtocol

    // Repositories
    let soundRepository: SoundRepositoryProtocol
    let sessionRepository: SessionRepositoryProtocol
    let userRepository: UserRepositoryProtocol
    let favoriteRepository: FavoriteRepositoryProtocol
    let subscriptionRepository: SubscriptionRepositoryProtocol

    // Use Cases
    let playSoundMixUseCase: PlaySoundMixUseCaseProtocol
    let trackSessionUseCase: TrackSessionUseCaseProtocol

    static let live = DependencyContainer(
        authService: FirebaseAuthService(),
        audioEngine: AWAVEAudioEngine(),
        analyticsService: FirebaseAnalyticsService(),
        soundRepository: FirestoreSoundRepository(),
        sessionRepository: SwiftDataSessionRepository(),
        userRepository: FirestoreUserRepository(),
        favoriteRepository: SyncedFavoriteRepository(),
        subscriptionRepository: StoreKitSubscriptionRepository(),
        playSoundMixUseCase: PlaySoundMixUseCase(/* ... */),
        trackSessionUseCase: TrackSessionUseCase(/* ... */)
    )

    static let preview = DependencyContainer(/* mocks */)
    static let test = DependencyContainer(/* mocks */)
}
```

### 2. Feature Modules

**Responsibility**: Self-contained features with View + ViewModel

```
Features/
├── Home/
│   ├── HomeView.swift
│   ├── HomeViewModel.swift
│   └── Components/
│       ├── CategoryCard.swift
│       ├── FeaturedSection.swift
│       └── SoundGrid.swift
├── Player/
│   ├── PlayerView.swift
│   ├── PlayerViewModel.swift
│   └── Components/
│       ├── MixerView.swift
│       ├── TrackSlider.swift
│       ├── WaveformCanvas.swift
│       └── PlaybackControls.swift
├── Library/
│   ├── LibraryView.swift
│   ├── LibraryViewModel.swift
│   └── Components/
│       ├── FavoritesSection.swift
│       ├── RecentSection.swift
│       └── DownloadsSection.swift
└── ...
```

**Feature Module Pattern**:

```swift
// PlayerView.swift
struct PlayerView: View {
    let mix: SoundMix
    @State private var viewModel: PlayerViewModel

    init(mix: SoundMix) {
        self.mix = mix
        _viewModel = State(initialValue: PlayerViewModel())
    }

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 24) {
                HeaderView(title: mix.name, onClose: { /* dismiss */ })

                WaveformCanvas(tracks: viewModel.tracks)
                    .frame(height: 200)

                TrackMixerList(
                    tracks: viewModel.tracks,
                    onVolumeChange: viewModel.setVolume,
                    onMuteToggle: viewModel.toggleMute,
                    onRemove: viewModel.removeTrack
                )

                Spacer()

                PlaybackControls(
                    isPlaying: viewModel.isPlaying,
                    currentTime: viewModel.currentTime,
                    duration: viewModel.duration,
                    onPlay: { Task { await viewModel.play() } },
                    onPause: viewModel.pause,
                    onSeek: viewModel.seek
                )
            }
            .padding()
        }
        .task {
            await viewModel.loadMix(mix)
        }
    }
}

// PlayerViewModel.swift
@Observable
final class PlayerViewModel {
    // MARK: - State
    private(set) var state: PlayerState = .idle
    private(set) var tracks: [MixerTrack] = []
    private(set) var isPlaying = false
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0

    // MARK: - Dependencies (injected via Environment or init)
    @ObservationIgnored
    private var playSoundMixUseCase: PlaySoundMixUseCaseProtocol!
    @ObservationIgnored
    private var audioEngine: AudioEngineProtocol!

    // MARK: - Actions

    func loadMix(_ mix: SoundMix) async {
        state = .loading
        do {
            tracks = try await playSoundMixUseCase.execute(mix: mix)
            duration = tracks.map(\.duration).max() ?? 0
            state = .ready
        } catch {
            state = .error(error)
        }
    }

    func play() async {
        guard state == .ready || state == .paused else { return }
        await audioEngine.play()
        isPlaying = true
        state = .playing
        startTimeUpdates()
    }

    func pause() {
        audioEngine.pause()
        isPlaying = false
        state = .paused
    }

    func setVolume(_ volume: Float, for track: MixerTrack) {
        audioEngine.setVolume(volume, for: track.id)
        updateTrack(track.id) { $0.volume = volume }
    }

    // MARK: - Private

    private func updateTrack(_ id: String, update: (inout MixerTrack) -> Void) {
        guard let index = tracks.firstIndex(where: { $0.id == id }) else { return }
        update(&tracks[index])
    }
}
```

### 3. Domain Layer

**Responsibility**: Business logic, entities, use case orchestration

```swift
// Domain/Entities/Sound.swift
struct Sound: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let description: String
    let category: Category
    let duration: TimeInterval
    let fileURL: URL
    let thumbnailURL: URL?
    let isPremium: Bool
    let tags: [String]

    enum Category: String, CaseIterable, Sendable {
        case sleep = "schlaf"
        case relax = "ruhe"
        case flow = "imfluss"
        case focus = "fokus"
    }
}

// Domain/UseCases/PlaySoundMixUseCase.swift
protocol PlaySoundMixUseCaseProtocol {
    func execute(mix: SoundMix) async throws -> [MixerTrack]
}

final class PlaySoundMixUseCase: PlaySoundMixUseCaseProtocol {
    private let audioEngine: AudioEngineProtocol
    private let downloadManager: DownloadManagerProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol

    init(
        audioEngine: AudioEngineProtocol,
        downloadManager: DownloadManagerProtocol,
        sessionRepository: SessionRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.audioEngine = audioEngine
        self.downloadManager = downloadManager
        self.sessionRepository = sessionRepository
        self.analyticsService = analyticsService
    }

    func execute(mix: SoundMix) async throws -> [MixerTrack] {
        // Step 1: Ensure all sounds are available locally
        let downloadResults = try await downloadManager.ensureDownloaded(mix.sounds)

        // Step 2: Prepare audio engine with local files
        let tracks = try await audioEngine.prepareMix(
            sounds: mix.sounds,
            localURLs: downloadResults
        )

        // Step 3: Start session tracking
        let session = Session(
            id: UUID().uuidString,
            sounds: mix.sounds,
            startedAt: Date()
        )
        try await sessionRepository.save(session)

        // Step 4: Track analytics
        analyticsService.track(.playbackStarted(
            mixId: mix.id,
            soundCount: mix.sounds.count,
            category: mix.sounds.first?.category.rawValue ?? "mixed"
        ))

        return tracks
    }
}

// Domain/Repositories/SoundRepository.swift (Protocol)
protocol SoundRepositoryProtocol: Sendable {
    func getAll() async throws -> [Sound]
    func get(id: String) async throws -> Sound?
    func getByCategory(_ category: Sound.Category) async throws -> [Sound]
    func search(query: String) async throws -> [Sound]
}
```

### 4. Data Layer

**Responsibility**: Data persistence, network communication, caching

```swift
// Data/Repositories/FirestoreSoundRepository.swift
final class FirestoreSoundRepository: SoundRepositoryProtocol {
    private let firestore: Firestore
    private let cache: SoundCacheProtocol

    init(firestore: Firestore = Firestore.firestore(), cache: SoundCacheProtocol) {
        self.firestore = firestore
        self.cache = cache
    }

    func getAll() async throws -> [Sound] {
        // Check cache first
        if let cached = await cache.getAllSounds(), !cached.isEmpty {
            return cached
        }

        // Fetch from Firestore
        let snapshot = try await firestore
            .collection("sounds")
            .order(by: "playCount", descending: true)
            .getDocuments()

        let sounds = snapshot.documents.compactMap { doc -> Sound? in
            try? doc.data(as: FirestoreSound.self).toDomain()
        }

        // Update cache
        await cache.setSounds(sounds)

        return sounds
    }

    func getByCategory(_ category: Sound.Category) async throws -> [Sound] {
        let snapshot = try await firestore
            .collection("sounds")
            .whereField("category", isEqualTo: category.rawValue)
            .order(by: "playCount", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc -> Sound? in
            try? doc.data(as: FirestoreSound.self).toDomain()
        }
    }

    func search(query: String) async throws -> [Sound] {
        // Use cached sounds for fast search
        let allSounds = try await getAll()

        let lowercased = query.lowercased()
        return allSounds.filter { sound in
            sound.name.lowercased().contains(lowercased) ||
            sound.description.lowercased().contains(lowercased) ||
            sound.tags.contains { $0.lowercased().contains(lowercased) }
        }
    }
}

// Data/Local/SwiftDataSessionRepository.swift
@ModelActor
actor SwiftDataSessionRepository: SessionRepositoryProtocol {
    func save(_ session: Session) async throws {
        let model = SessionModel(from: session)
        modelContext.insert(model)
        try modelContext.save()
    }

    func getRecent(limit: Int) async throws -> [Session] {
        let descriptor = FetchDescriptor<SessionModel>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit

        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }
}
```

### 5. Core Services

**Responsibility**: Platform services, third-party integrations

```swift
// Core/Services/AudioEngine/AudioEngineProtocol.swift
protocol AudioEngineProtocol: Actor {
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }

    func prepareMix(sounds: [Sound], localURLs: [String: URL]) async throws -> [MixerTrack]
    func play() async
    func pause()
    func stop()
    func seek(to time: TimeInterval)
    func setVolume(_ volume: Float, for trackId: String)
    func addTrack(_ sound: Sound) async throws -> MixerTrack
    func removeTrack(_ trackId: String)
}

// Core/Services/Auth/AuthServiceProtocol.swift
protocol AuthServiceProtocol: Sendable {
    var currentUser: User? { get async }
    var authStatePublisher: AnyPublisher<User?, Never> { get }

    func signInWithApple() async throws -> User
    func signInWithGoogle() async throws -> User
    func signInWithEmail(email: String, password: String) async throws -> User
    func signOut() async throws
    func deleteAccount() async throws
}
```

---

## Data Flow

### Unidirectional Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Data Flow Diagram                                   │
│                                                                              │
│    User Action                                                               │
│        │                                                                     │
│        ▼                                                                     │
│    ┌───────────┐     Intent      ┌─────────────┐    Command    ┌─────────┐ │
│    │   View    │ ───────────────▶│  ViewModel  │──────────────▶│Use Case │ │
│    │ (SwiftUI) │                 │ (@Observable)│               │         │ │
│    └───────────┘                 └─────────────┘               └────┬────┘ │
│         ▲                              │                            │       │
│         │                              │                            ▼       │
│         │         State Update         │                     ┌───────────┐ │
│         └──────────────────────────────┘                     │Repository │ │
│                                                              └─────┬─────┘ │
│                                                                    │       │
│                                              ┌─────────────────────┴──┐    │
│                                              ▼                        ▼    │
│                                        ┌──────────┐            ┌──────────┐│
│                                        │  Local   │            │  Remote  ││
│                                        │SwiftData │            │Firestore ││
│                                        └──────────┘            └──────────┘│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Example: Playing a Sound Mix

```
1. User taps "Play" button
   │
   ▼
2. PlayerView calls viewModel.play()
   │
   ▼
3. PlayerViewModel.play() {
   │  - Sets state = .loading
   │  - Calls playSoundMixUseCase.execute(mix)
   │
   ▼
4. PlaySoundMixUseCase.execute(mix) {
   │  - downloadManager.ensureDownloaded(sounds)
   │  - audioEngine.prepareMix(sounds, urls)
   │  - sessionRepository.save(session)
   │  - analyticsService.track(.playbackStarted)
   │
   ▼
5. Returns [MixerTrack] to ViewModel
   │
   ▼
6. PlayerViewModel {
   │  - Sets tracks = result
   │  - Sets state = .playing
   │  - Sets isPlaying = true
   │
   ▼
7. SwiftUI observes @Observable changes
   │  - Re-renders PlayerView with new state
   │
   ▼
8. User sees playing state with waveform
```

---

## Navigation Architecture

### Coordinator Pattern

```swift
// Navigation/AppCoordinator.swift
@Observable
final class AppCoordinator {
    // Tab state
    var selectedTab: Tab = .home

    // Navigation stacks per tab
    var homePath = NavigationPath()
    var libraryPath = NavigationPath()
    var profilePath = NavigationPath()

    // Modal presentations
    var presentedSheet: SheetDestination?
    var presentedFullScreen: FullScreenDestination?

    // MARK: - Navigation

    func navigate(to destination: Destination) {
        switch destination {
        case .category(let category):
            currentPath.append(destination)

        case .sound(let sound):
            currentPath.append(destination)

        case .player(let mix):
            presentedFullScreen = .player(mix)

        case .search:
            presentedSheet = .search

        case .settings:
            presentedSheet = .settings

        case .subscription:
            presentedSheet = .subscription
        }
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    func dismissFullScreen() {
        presentedFullScreen = nil
    }

    func popToRoot() {
        switch selectedTab {
        case .home: homePath = NavigationPath()
        case .library: libraryPath = NavigationPath()
        case .profile: profilePath = NavigationPath()
        }
    }

    private var currentPath: NavigationPath {
        get {
            switch selectedTab {
            case .home: return homePath
            case .library: return libraryPath
            case .profile: return profilePath
            }
        }
        set {
            switch selectedTab {
            case .home: homePath = newValue
            case .library: libraryPath = newValue
            case .profile: profilePath = newValue
            }
        }
    }
}

// Navigation/Destinations.swift
enum Tab: String, CaseIterable {
    case home, library, profile
}

enum Destination: Hashable {
    case category(Sound.Category)
    case sound(Sound)
    case session(Session)
    case player(SoundMix)
    case search
    case settings
    case subscription
}

enum SheetDestination: Identifiable {
    case search
    case settings
    case subscription
    case addToFavorites(Sound)

    var id: String { /* ... */ }
}

enum FullScreenDestination: Identifiable {
    case player(SoundMix)
    case sos
    case onboarding

    var id: String { /* ... */ }
}
```

---

## Error Handling Strategy

```swift
// Domain/Errors/AWAVEError.swift
enum AWAVEError: Error, LocalizedError {
    // Network
    case networkUnavailable
    case serverError(statusCode: Int)
    case timeout

    // Audio
    case audioPlaybackFailed(underlying: Error)
    case audioFileNotFound(soundId: String)
    case audioEngineFailed

    // Data
    case dataCorrupted
    case syncFailed(underlying: Error)

    // Auth
    case authenticationRequired
    case authenticationFailed(underlying: Error)

    // Subscription
    case subscriptionRequired
    case purchaseFailed(underlying: Error)
    case receiptValidationFailed

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return String(localized: "error.network.unavailable")
        case .audioPlaybackFailed:
            return String(localized: "error.audio.playback")
        // ...
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return String(localized: "error.network.suggestion")
        // ...
        }
    }
}

// Presentation/Shared/ErrorHandler.swift
@Observable
final class ErrorHandler {
    var currentError: AWAVEError?
    var showError = false

    func handle(_ error: Error) {
        if let awaveError = error as? AWAVEError {
            currentError = awaveError
        } else {
            currentError = .serverError(statusCode: -1)
        }
        showError = true

        // Log to analytics
        AnalyticsService.shared.track(.errorOccurred(
            type: String(describing: error),
            message: error.localizedDescription
        ))
    }
}
```

---

## Testing Strategy Overview

| Layer | Test Type | Coverage Target |
|-------|-----------|-----------------|
| ViewModels | Unit | 90% |
| Use Cases | Unit | 95% |
| Repositories | Integration | 80% |
| Views | Snapshot | Critical paths |
| E2E | UI Tests | Happy paths |

```swift
// Tests/UnitTests/PlayerViewModelTests.swift
@Test
func testPlayUpdatesState() async {
    // Given
    let mockUseCase = MockPlaySoundMixUseCase()
    mockUseCase.result = [MixerTrack.mock]
    let viewModel = PlayerViewModel(playSoundMixUseCase: mockUseCase)

    // When
    await viewModel.loadMix(.mock)
    await viewModel.play()

    // Then
    #expect(viewModel.state == .playing)
    #expect(viewModel.isPlaying == true)
    #expect(mockUseCase.executeCallCount == 1)
}
```

---

## Key Architectural Principles

### 1. Dependency Inversion
```
High-level modules (ViewModels, Use Cases) depend on abstractions (Protocols)
Low-level modules (Repositories, Services) implement those abstractions
```

### 2. Single Source of Truth
```
Each piece of data has one owner
State flows down, events flow up
```

### 3. Composition Over Inheritance
```
Prefer protocol composition to class hierarchies
Use value types (structs) where possible
```

### 4. Fail Fast
```
Validate inputs early
Throw meaningful errors
Don't hide failures
```

### 5. Testability First
```
Design for testing from the start
Inject dependencies
Avoid singletons (except at composition root)
```
