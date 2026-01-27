# Architecture Overview

## System Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              iOS Device                                       │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                         AWAVE iOS App                                   │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │  │
│  │  │   SwiftUI    │  │   Combine    │  │  @Observable │  │  SwiftData │  │  │
│  │  │    Views     │──│   Streams    │──│    State     │──│   Models   │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └────────────┘  │  │
│  │         │                                                      │        │  │
│  │  ┌──────▼─────────────────────────────────────────────────────▼─────┐  │  │
│  │  │                     Feature Modules                               │  │  │
│  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────┐ │  │  │
│  │  │  │  Home   │ │ Player  │ │ Library │ │ Profile │ │ Subscription│ │  │  │
│  │  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────────┘ │  │  │
│  │  └───────────────────────────────────────────────────────────────────┘  │  │
│  │         │                      │                        │               │  │
│  │  ┌──────▼──────────────────────▼────────────────────────▼────────────┐  │  │
│  │  │                      Core Services                                 │  │  │
│  │  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐  │  │  │
│  │  │  │AudioEngine  │ │DownloadMgr │ │ SyncEngine  │ │AnalyticsSvc │  │  │  │
│  │  │  │(AVFoundation│ │(URLSession) │ │ (Firestore) │ │(Firebase)   │  │  │  │
│  │  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘  │  │  │
│  │  └───────────────────────────────────────────────────────────────────┘  │  │
│  │         │                      │                        │               │  │
│  │  ┌──────▼──────────────────────▼────────────────────────▼────────────┐  │  │
│  │  │                      Data Layer                                    │  │  │
│  │  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐  │  │  │
│  │  │  │  SwiftData  │ │  FileManager│ │  Keychain   │ │  UserDefs   │  │  │  │
│  │  │  │  (SQLite)   │ │  (Audio)    │ │  (Secrets)  │ │  (Settings) │  │  │  │
│  │  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘  │  │  │
│  │  └───────────────────────────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTPS / WebSocket
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                          Google Cloud Platform                                │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                         Cloud CDN + Cloud Armor                        │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│         │                      │                        │                     │
│  ┌──────▼──────┐        ┌──────▼──────┐         ┌──────▼──────┐              │
│  │   Firebase  │        │   Cloud     │         │   Cloud     │              │
│  │    Auth     │        │  Functions  │         │   Storage   │              │
│  └─────────────┘        └─────────────┘         └─────────────┘              │
│         │                      │                        │                     │
│  ┌──────▼──────────────────────▼────────────────────────▼──────────────────┐ │
│  │                         Cloud Firestore                                  │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐           │ │
│  │  │  users  │ │sessions │ │favorites│ │ sounds  │ │analytics│           │ │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘           │ │
│  └──────────────────────────────────────────────────────────────────────────┘ │
│         │                                                                     │
│  ┌──────▼──────────────────────────────────────────────────────────────────┐ │
│  │                      BigQuery + Vertex AI                                │ │
│  │              (Analytics, ML Models, Recommendations)                     │ │
│  └──────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Layer Responsibilities

### 1. Presentation Layer (SwiftUI)

```swift
// View hierarchy follows feature-based organization
AWAVE/
├── App/
│   ├── AWAVEApp.swift              // @main entry point
│   ├── AppCoordinator.swift        // Navigation coordination
│   └── AppState.swift              // Global @Observable state
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── HomeViewModel.swift
│   │   └── Components/
│   ├── Player/
│   │   ├── PlayerView.swift
│   │   ├── MixerView.swift
│   │   └── WaveformView.swift
│   └── ...
└── Shared/
    ├── Components/
    ├── Extensions/
    └── Modifiers/
```

**Key Patterns:**
- **MVVM** with `@Observable` view models
- **Coordinator** pattern for navigation
- **Dependency injection** via Environment

### 2. Domain Layer (Business Logic)

```swift
// Pure Swift domain models and use cases
Domain/
├── Models/
│   ├── User.swift
│   ├── Sound.swift
│   ├── Session.swift
│   └── Subscription.swift
├── UseCases/
│   ├── PlaySoundMixUseCase.swift
│   ├── DownloadSoundUseCase.swift
│   ├── TrackSessionUseCase.swift
│   └── ManageSubscriptionUseCase.swift
└── Repositories/
    ├── SoundRepository.swift       // Protocol
    ├── UserRepository.swift        // Protocol
    └── SessionRepository.swift     // Protocol
```

**Key Patterns:**
- **Repository** pattern for data abstraction
- **Use Case** pattern for business operations
- Protocol-oriented design for testability

### 3. Data Layer (Persistence & Network)

```swift
// Concrete implementations of repository protocols
Data/
├── Local/
│   ├── SwiftData/
│   │   ├── LocalSoundRepository.swift
│   │   └── LocalSessionRepository.swift
│   ├── FileStorage/
│   │   └── AudioFileManager.swift
│   └── Keychain/
│       └── SecureStorage.swift
├── Remote/
│   ├── Firestore/
│   │   ├── FirestoreSoundRepository.swift
│   │   └── FirestoreUserRepository.swift
│   ├── CloudStorage/
│   │   └── AudioDownloadService.swift
│   └── Auth/
│       └── FirebaseAuthService.swift
└── Sync/
    └── SyncEngine.swift
```

---

## Data Flow

### Unidirectional Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│    ┌─────────┐      ┌─────────────┐      ┌───────────┐    │
│    │  View   │─────▶│  ViewModel  │─────▶│  UseCase  │    │
│    │(SwiftUI)│      │ (@Observable)│      │           │    │
│    └────▲────┘      └──────┬──────┘      └─────┬─────┘    │
│         │                  │                    │          │
│         │                  │                    ▼          │
│         │                  │            ┌───────────┐      │
│         │                  │            │Repository │      │
│         │                  │            │ (Protocol)│      │
│         │                  │            └─────┬─────┘      │
│         │                  │                  │            │
│         │                  ▼                  ▼            │
│         │           ┌─────────────────────────────┐        │
│         └───────────│         State               │        │
│                     │   (Published Properties)    │        │
│                     └─────────────────────────────┘        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Example: Playing a Sound Mix

```swift
// 1. User taps play button in View
Button("Play") {
    viewModel.playMix(sounds: selectedSounds)
}

// 2. ViewModel calls UseCase
@Observable
class PlayerViewModel {
    func playMix(sounds: [Sound]) {
        Task {
            state = .loading
            do {
                try await playSoundMixUseCase.execute(sounds: sounds)
                state = .playing
            } catch {
                state = .error(error)
            }
        }
    }
}

// 3. UseCase orchestrates business logic
class PlaySoundMixUseCase {
    func execute(sounds: [Sound]) async throws {
        // Ensure sounds are downloaded
        let localURLs = try await downloadRepository.ensureDownloaded(sounds)

        // Start audio engine
        try await audioEngine.playMix(urls: localURLs)

        // Track session
        try await sessionRepository.startSession(sounds: sounds)
    }
}

// 4. View updates reactively via @Observable
struct PlayerView: View {
    @State var viewModel: PlayerViewModel

    var body: some View {
        switch viewModel.state {
        case .loading: ProgressView()
        case .playing: WaveformView()
        case .error(let e): ErrorView(error: e)
        }
    }
}
```

---

## Module Dependencies

```
┌─────────────────────────────────────────────────────────────┐
│                       App Module                            │
│  (Composition root, dependency injection, app lifecycle)    │
└───────────────────────────┬─────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│    Features   │   │    Features   │   │    Features   │
│     (Home)    │   │   (Player)    │   │   (Profile)   │
└───────┬───────┘   └───────┬───────┘   └───────┬───────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            ▼
                ┌───────────────────────┐
                │      Domain Module    │
                │ (Models, Use Cases,   │
                │  Repository Protocols)│
                └───────────┬───────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  Data/Local   │   │  Data/Remote  │   │  Data/Sync    │
│  (SwiftData)  │   │  (Firestore)  │   │  (Engine)     │
└───────────────┘   └───────────────┘   └───────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            ▼
                ┌───────────────────────┐
                │      Core Module      │
                │ (Networking, Storage, │
                │  Keychain, Logging)   │
                └───────────────────────┘
```

---

## Key Architectural Decisions

### 1. SwiftUI + @Observable over UIKit
- **Rationale**: Declarative UI reduces boilerplate, better state management
- **Trade-off**: Less fine-grained control over view lifecycle
- **Mitigation**: Use `UIViewRepresentable` for complex audio visualizations

### 2. SwiftData over Core Data
- **Rationale**: Modern Swift-native persistence, automatic CloudKit sync
- **Trade-off**: iOS 17+ only, less mature
- **Mitigation**: Wrapper protocols allow fallback to Core Data if needed

### 3. Firestore over direct PostgreSQL
- **Rationale**: Real-time sync, offline persistence, Firebase Auth integration
- **Trade-off**: NoSQL limitations, vendor lock-in
- **Mitigation**: Repository pattern abstracts data source

### 4. Modular Architecture
- **Rationale**: Independent feature development, faster build times
- **Trade-off**: More initial setup complexity
- **Mitigation**: Swift Package Manager for module management

### 5. Protocol-Oriented Design
- **Rationale**: Testability, flexibility, Swift-idiomatic
- **Trade-off**: More types to manage
- **Mitigation**: Sensible defaults via protocol extensions

---

## Error Handling Strategy

```swift
// Domain-level errors
enum AWAVEError: Error, LocalizedError {
    case networkUnavailable
    case audioPlaybackFailed(underlying: Error)
    case downloadFailed(soundId: String)
    case subscriptionRequired
    case authenticationRequired

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection"
        case .audioPlaybackFailed:
            return "Unable to play audio"
        case .downloadFailed(let id):
            return "Failed to download sound: \(id)"
        case .subscriptionRequired:
            return "Premium subscription required"
        case .authenticationRequired:
            return "Please sign in to continue"
        }
    }
}

// Global error handling via Environment
struct ErrorHandler: EnvironmentKey {
    static let defaultValue = ErrorHandler()

    func handle(_ error: Error) {
        // Log to analytics
        Analytics.logError(error)

        // Show appropriate UI
        NotificationCenter.default.post(
            name: .showError,
            object: error
        )
    }
}
```

---

## Testing Strategy

| Layer | Test Type | Tools |
|-------|-----------|-------|
| Views | Snapshot | Swift Snapshot Testing |
| ViewModels | Unit | XCTest + async/await |
| Use Cases | Unit | XCTest + mocks |
| Repositories | Integration | XCTest + in-memory stores |
| End-to-End | UI | XCUITest |

```swift
// Example ViewModel test
@Test
func testPlayMixUpdatesState() async {
    // Given
    let mockUseCase = MockPlaySoundMixUseCase()
    let viewModel = PlayerViewModel(playSoundMixUseCase: mockUseCase)

    // When
    await viewModel.playMix(sounds: [.mock])

    // Then
    #expect(viewModel.state == .playing)
    #expect(mockUseCase.executeCalled)
}
```
