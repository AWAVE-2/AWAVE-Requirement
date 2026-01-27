# AWAVE iOS Architecture Context

> **Note**: This document provides complete context for LLM-based architecture verification. Copy this entire document as the first message when starting a verification session.

---

## Project Overview

**AWAVE** is a meditation and wellness iOS application with a unique technical differentiator: **multi-track audio mixing** that allows users to combine up to 7 simultaneous sound tracks to create personalized soundscapes.

### Key Statistics
- **Sound Library**: 3000+ audio files
- **Simultaneous Tracks**: Up to 7
- **Categories**: Sleep, Relax, Flow, Focus
- **Target Platforms**: iOS 17+, watchOS 10+, visionOS (future)
- **Backend**: Google Cloud Platform (Firestore, Cloud Storage, Cloud Functions)
- **Authentication**: Firebase Auth (Apple, Google, Email)

---

## Technical Requirements

### Functional Requirements
1. Multi-track audio mixing with independent volume control per track
2. Real-time waveform visualization synchronized with audio
3. Offline-first operation with cloud sync
4. Session tracking and user statistics
5. Subscription management (freemium model)
6. Background audio playback with system controls
7. Procedural sound generation (waves, rain, noise, binaural beats)

### Non-Functional Requirements
1. Audio latency < 50ms
2. Cold start < 1.5 seconds
3. Memory usage < 100MB
4. 60fps animations
5. Crash-free rate > 99.9%
6. Offline functionality for downloaded content

---

## Chosen Architecture: MVVM + Clean Architecture Hybrid

### Layer Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  SwiftUI Views ←→ @Observable ViewModels ←→ Coordinator     │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                      Domain Layer                            │
│  Entities ←→ Use Cases ←→ Repository Protocols              │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                       Data Layer                             │
│  SwiftData (Local) ←→ Firestore (Remote) ←→ Sync Engine     │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                     Core Services                            │
│  AudioEngine ←→ AuthService ←→ Analytics ←→ Networking      │
└─────────────────────────────────────────────────────────────┘
```

### Package Structure

```
Packages/
├── AWAVECore/          # Extensions, utilities, keychain
├── AWAVEDomain/        # Entities, use cases, repository protocols
├── AWAVEData/          # Repository implementations, SwiftData, Firestore
├── AWAVEAudio/         # AVFoundation audio engine, procedural generation
├── AWAVEDesign/        # Design system, components, colors, typography
├── AWAVEFeatures/      # Feature modules (Home, Player, Library, Profile)
└── AWAVENetwork/       # API client, Firestore service
```

---

## Key Architectural Decisions

### 1. State Management: @Observable over Combine/TCA

**Decision**: Use Swift's native `@Observable` macro for state management

**Rationale**:
- Native SwiftUI integration
- Simpler mental model than Combine
- Less boilerplate than TCA
- Sufficient for AWAVE's complexity level

**Trade-off**: Less explicit state transitions than TCA, but acceptable for medium-complexity app

### 2. Navigation: Coordinator Pattern

**Decision**: Centralized `AppCoordinator` manages all navigation

**Rationale**:
- Testable navigation logic
- Separation of navigation from views
- Supports deep linking
- Works with NavigationStack

### 3. Data Access: Repository Pattern with Sync Engine

**Decision**: Protocol-based repositories with local-first sync

**Rationale**:
- Abstracts Firestore/SwiftData implementation
- Enables offline-first architecture
- Testable with mock repositories
- Flexible sync strategies

### 4. Audio System: Actor-based AudioEngine

**Decision**: Single `actor AWAVEAudioEngine` wraps all AVFoundation complexity

**Rationale**:
- Thread-safe by design
- Simplified API for multi-track mixing
- Encapsulates AVAudioEngine complexity
- Testable via protocol

### 5. Dependency Injection: Environment + Factory

**Decision**: `DependencyContainer` injected via SwiftUI Environment

**Rationale**:
- SwiftUI-native approach
- Supports live/preview/test configurations
- No external DI framework needed
- Explicit dependency graph

---

## Core Domain Entities

```swift
// Sound - A single audio item
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

    enum Category: String, CaseIterable {
        case sleep, relax, flow, focus
    }
}

// SoundMix - A combination of sounds with volumes
struct SoundMix: Identifiable, Sendable {
    let id: String
    let name: String
    let sounds: [SoundMixItem]
    let category: String
}

struct SoundMixItem: Sendable {
    let soundId: String
    let volume: Float  // 0.0 - 1.0
}

// MixerTrack - Active track in the player
struct MixerTrack: Identifiable {
    let id: String
    let soundId: String
    let name: String
    var volume: Float
    var isMuted: Bool
    let duration: TimeInterval
    let color: Color
    let waveformData: [Float]
}

// Session - A playback session for analytics
struct Session: Identifiable {
    let id: String
    let userId: String
    let sounds: [Sound]
    let startedAt: Date
    var endedAt: Date?
    var duration: Int
    var completed: Bool
    var rating: Int?
}

// User - User profile
struct User: Identifiable {
    let id: String
    let email: String
    let displayName: String
    let avatarURL: URL?
    var preferences: Preferences
    var stats: Stats
}

// Subscription - Premium status
struct Subscription {
    let userId: String
    let status: Status
    let expiresAt: Date?

    enum Status { case active, expired, cancelled, trial }
}
```

---

## Key Protocols

```swift
// Repository Protocols
protocol SoundRepositoryProtocol: Sendable {
    func getAll() async throws -> [Sound]
    func get(id: String) async throws -> Sound?
    func getByCategory(_ category: Sound.Category) async throws -> [Sound]
    func search(query: String) async throws -> [Sound]
}

protocol SessionRepositoryProtocol: Sendable {
    func save(_ session: Session) async throws
    func getRecent(limit: Int) async throws -> [Session]
    func getStats() async throws -> SessionStats
}

// Service Protocols
protocol AudioEngineProtocol: Actor {
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }

    func prepareMix(sounds: [Sound], urls: [String: URL]) async throws -> [MixerTrack]
    func play() async
    func pause()
    func stop()
    func setVolume(_ volume: Float, for trackId: String)
}

protocol AuthServiceProtocol: Sendable {
    var currentUser: User? { get async }
    func signInWithApple() async throws -> User
    func signOut() async throws
}

// Use Case Protocols
protocol PlaySoundMixUseCaseProtocol {
    func execute(mix: SoundMix) async throws -> [MixerTrack]
}
```

---

## Data Flow Example

```
User taps "Play" on a SoundMix
    │
    ▼
PlayerView calls viewModel.playMix(mix)
    │
    ▼
PlayerViewModel:
    1. Sets state = .loading
    2. Calls playSoundMixUseCase.execute(mix)
    │
    ▼
PlaySoundMixUseCase:
    1. downloadManager.ensureDownloaded(mix.sounds)
    2. audioEngine.prepareMix(sounds, urls)
    3. sessionRepository.startSession(mix)
    4. analyticsService.track(.playbackStarted)
    5. Returns [MixerTrack]
    │
    ▼
PlayerViewModel:
    1. Sets tracks = result
    2. Sets state = .ready
    3. Calls audioEngine.play()
    4. Sets isPlaying = true
    │
    ▼
SwiftUI observes @Observable changes
    │
    ▼
PlayerView re-renders with playing state
```

---

## Technology Stack

| Layer | Technology |
|-------|------------|
| UI | SwiftUI, @Observable |
| Navigation | NavigationStack, Coordinator |
| State | @Observable, @State, @Environment |
| Audio | AVFoundation, AVAudioEngine |
| Local DB | SwiftData |
| Remote DB | Cloud Firestore |
| Auth | Firebase Auth |
| Storage | Cloud Storage |
| Analytics | Firebase Analytics |
| Networking | URLSession, async/await |

---

## Constraints & Considerations

1. **iOS 17+ minimum** - Enables SwiftData, @Observable, latest SwiftUI
2. **Offline-first** - Core functionality must work without network
3. **Memory constraints** - 7 audio tracks simultaneously loaded
4. **Battery efficiency** - Background audio shouldn't drain battery
5. **Premium content** - Must enforce subscription for premium sounds
6. **German primary market** - German localization is primary
7. **Future platforms** - Architecture should support watchOS, visionOS

---

## Verification Questions to Consider

When analyzing this architecture, please consider:

1. Is the layer separation appropriate for the complexity?
2. Are the patterns correctly applied?
3. Are there potential performance bottlenecks?
4. Is the dependency injection approach scalable?
5. How well does this support testing?
6. Are there any SOLID principle violations?
7. What are the main risks of this architecture?
8. What would you change or improve?
