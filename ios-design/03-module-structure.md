# Module Structure

## Swift Package Organization

AWAVE uses Swift Package Manager (SPM) for modular architecture, enabling:
- Faster incremental builds
- Clear dependency boundaries
- Reusability across targets (iOS, watchOS, widgets)
- Enforced access control

---

## Package Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         AWAVE Package Dependencies                               │
│                                                                                  │
│                              ┌─────────────────┐                                │
│                              │   AWAVE (App)   │                                │
│                              │    (Target)     │                                │
│                              └────────┬────────┘                                │
│                                       │                                          │
│           ┌───────────────────────────┼───────────────────────────┐             │
│           │                           │                           │             │
│           ▼                           ▼                           ▼             │
│  ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐       │
│  │  AWAVEFeatures  │       │  AWAVEDesign    │       │  AWAVEWidgets   │       │
│  │   (Package)     │       │   (Package)     │       │   (Extension)   │       │
│  │                 │       │                 │       │                 │       │
│  │ • HomeFeature   │       │ • Components    │       │ • QuickPlay     │       │
│  │ • PlayerFeature │       │ • Colors        │       │ • NowPlaying    │       │
│  │ • LibraryFeature│       │ • Typography    │       │                 │       │
│  │ • ProfileFeature│       │ • Modifiers     │       │                 │       │
│  └────────┬────────┘       └────────┬────────┘       └────────┬────────┘       │
│           │                         │                         │                 │
│           └─────────────────────────┼─────────────────────────┘                 │
│                                     │                                           │
│                                     ▼                                           │
│                          ┌─────────────────┐                                   │
│                          │   AWAVEDomain   │                                   │
│                          │   (Package)     │                                   │
│                          │                 │                                   │
│                          │ • Entities      │                                   │
│                          │ • Use Cases     │                                   │
│                          │ • Protocols     │                                   │
│                          └────────┬────────┘                                   │
│                                   │                                             │
│                    ┌──────────────┼──────────────┐                             │
│                    │              │              │                             │
│                    ▼              ▼              ▼                             │
│         ┌─────────────────┐ ┌─────────────┐ ┌─────────────────┐               │
│         │   AWAVEData     │ │ AWAVEAudio  │ │  AWAVENetwork   │               │
│         │   (Package)     │ │  (Package)  │ │   (Package)     │               │
│         │                 │ │             │ │                 │               │
│         │ • Repositories  │ │ • Engine    │ │ • APIClient     │               │
│         │ • SwiftData     │ │ • Player    │ │ • Firestore     │               │
│         │ • Sync Engine   │ │ • Generator │ │ • Auth          │               │
│         └────────┬────────┘ └──────┬──────┘ └────────┬────────┘               │
│                  │                 │                 │                         │
│                  └─────────────────┼─────────────────┘                         │
│                                    │                                           │
│                                    ▼                                           │
│                          ┌─────────────────┐                                   │
│                          │   AWAVECore     │                                   │
│                          │   (Package)     │                                   │
│                          │                 │                                   │
│                          │ • Extensions    │                                   │
│                          │ • Utilities     │                                   │
│                          │ • Logging       │                                   │
│                          │ • Keychain      │                                   │
│                          └─────────────────┘                                   │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Package Definitions

### AWAVECore (Foundation)

```swift
// Package.swift
let package = Package(
    name: "AWAVECore",
    platforms: [.iOS(.v17), .watchOS(.v10)],
    products: [
        .library(name: "AWAVECore", targets: ["AWAVECore"])
    ],
    targets: [
        .target(
            name: "AWAVECore",
            dependencies: []
        ),
        .testTarget(
            name: "AWAVECoreTests",
            dependencies: ["AWAVECore"]
        )
    ]
)
```

**Contents:**
```
AWAVECore/
├── Sources/AWAVECore/
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── String+Extensions.swift
│   │   ├── URL+Extensions.swift
│   │   └── Collection+Extensions.swift
│   ├── Utilities/
│   │   ├── Logger.swift
│   │   ├── Debouncer.swift
│   │   └── CancellableTask.swift
│   ├── Storage/
│   │   ├── KeychainService.swift
│   │   ├── UserDefaultsWrapper.swift
│   │   └── FileManagerExtensions.swift
│   └── Networking/
│       ├── HTTPMethod.swift
│       ├── NetworkError.swift
│       └── Endpoint.swift
└── Tests/AWAVECoreTests/
```

---

### AWAVEDomain (Business Logic)

```swift
// Package.swift
let package = Package(
    name: "AWAVEDomain",
    platforms: [.iOS(.v17), .watchOS(.v10)],
    products: [
        .library(name: "AWAVEDomain", targets: ["AWAVEDomain"])
    ],
    dependencies: [
        .package(path: "../AWAVECore")
    ],
    targets: [
        .target(
            name: "AWAVEDomain",
            dependencies: ["AWAVECore"]
        ),
        .testTarget(
            name: "AWAVEDomainTests",
            dependencies: ["AWAVEDomain"]
        )
    ]
)
```

**Contents:**
```
AWAVEDomain/
├── Sources/AWAVEDomain/
│   ├── Entities/
│   │   ├── Sound.swift
│   │   ├── User.swift
│   │   ├── Session.swift
│   │   ├── Subscription.swift
│   │   ├── MixerTrack.swift
│   │   ├── SoundMix.swift
│   │   └── Category.swift
│   ├── UseCases/
│   │   ├── Audio/
│   │   │   ├── PlaySoundMixUseCase.swift
│   │   │   └── GenerateProceduralSoundUseCase.swift
│   │   ├── Session/
│   │   │   ├── TrackSessionUseCase.swift
│   │   │   └── GetSessionStatsUseCase.swift
│   │   ├── Favorites/
│   │   │   ├── AddFavoriteUseCase.swift
│   │   │   └── RemoveFavoriteUseCase.swift
│   │   └── Subscription/
│   │       ├── VerifySubscriptionUseCase.swift
│   │       └── PurchaseSubscriptionUseCase.swift
│   └── Repositories/
│       ├── SoundRepositoryProtocol.swift
│       ├── SessionRepositoryProtocol.swift
│       ├── UserRepositoryProtocol.swift
│       ├── FavoriteRepositoryProtocol.swift
│       └── SubscriptionRepositoryProtocol.swift
└── Tests/AWAVEDomainTests/
```

---

### AWAVEData (Data Layer)

```swift
// Package.swift
let package = Package(
    name: "AWAVEData",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AWAVEData", targets: ["AWAVEData"])
    ],
    dependencies: [
        .package(path: "../AWAVECore"),
        .package(path: "../AWAVEDomain"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "AWAVEData",
            dependencies: [
                "AWAVECore",
                "AWAVEDomain",
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk")
            ]
        ),
        .testTarget(
            name: "AWAVEDataTests",
            dependencies: ["AWAVEData"]
        )
    ]
)
```

**Contents:**
```
AWAVEData/
├── Sources/AWAVEData/
│   ├── Remote/
│   │   ├── Firestore/
│   │   │   ├── FirestoreSoundRepository.swift
│   │   │   ├── FirestoreUserRepository.swift
│   │   │   ├── FirestoreSessionRepository.swift
│   │   │   └── Models/
│   │   │       ├── FirestoreSound.swift
│   │   │       ├── FirestoreUser.swift
│   │   │       └── FirestoreSession.swift
│   │   └── CloudStorage/
│   │       └── AudioStorageService.swift
│   ├── Local/
│   │   ├── SwiftData/
│   │   │   ├── Models/
│   │   │   │   ├── SoundModel.swift
│   │   │   │   ├── SessionModel.swift
│   │   │   │   └── FavoriteModel.swift
│   │   │   ├── SwiftDataContainer.swift
│   │   │   └── SwiftDataSessionRepository.swift
│   │   ├── Cache/
│   │   │   ├── SoundMetadataCache.swift
│   │   │   └── AudioFileCache.swift
│   │   └── FileStorage/
│   │       └── DownloadedAudioManager.swift
│   ├── Sync/
│   │   ├── SyncEngine.swift
│   │   ├── OfflineQueue.swift
│   │   └── ConflictResolver.swift
│   └── Auth/
│       └── FirebaseAuthService.swift
└── Tests/AWAVEDataTests/
```

---

### AWAVEAudio (Audio Engine)

```swift
// Package.swift
let package = Package(
    name: "AWAVEAudio",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AWAVEAudio", targets: ["AWAVEAudio"])
    ],
    dependencies: [
        .package(path: "../AWAVECore"),
        .package(path: "../AWAVEDomain")
    ],
    targets: [
        .target(
            name: "AWAVEAudio",
            dependencies: ["AWAVECore", "AWAVEDomain"]
        ),
        .testTarget(
            name: "AWAVEAudioTests",
            dependencies: ["AWAVEAudio"]
        )
    ]
)
```

**Contents:**
```
AWAVEAudio/
├── Sources/AWAVEAudio/
│   ├── Engine/
│   │   ├── AWAVEAudioEngine.swift
│   │   ├── AudioEngineProtocol.swift
│   │   ├── TrackNode.swift
│   │   └── MasterMixer.swift
│   ├── Playback/
│   │   ├── AudioPlayer.swift
│   │   ├── LoopingPlayer.swift
│   │   └── CrossfadeManager.swift
│   ├── Procedural/
│   │   ├── ProceduralGenerator.swift
│   │   ├── NoiseGenerator.swift
│   │   ├── WaveGenerator.swift
│   │   └── BinauralBeatGenerator.swift
│   ├── Processing/
│   │   ├── WaveformAnalyzer.swift
│   │   ├── VolumeNormalizer.swift
│   │   └── AudioEffects.swift
│   ├── Background/
│   │   ├── BackgroundAudioHandler.swift
│   │   ├── NowPlayingManager.swift
│   │   └── RemoteCommandHandler.swift
│   └── Download/
│       ├── AudioDownloadManager.swift
│       └── DownloadTask.swift
└── Tests/AWAVEAudioTests/
```

---

### AWAVEDesign (Design System)

```swift
// Package.swift
let package = Package(
    name: "AWAVEDesign",
    platforms: [.iOS(.v17), .watchOS(.v10)],
    products: [
        .library(name: "AWAVEDesign", targets: ["AWAVEDesign"])
    ],
    targets: [
        .target(
            name: "AWAVEDesign",
            dependencies: [],
            resources: [.process("Resources")]
        )
    ]
)
```

**Contents:**
```
AWAVEDesign/
├── Sources/AWAVEDesign/
│   ├── Colors/
│   │   ├── AWAVEColors.swift
│   │   └── ColorScheme+AWAVE.swift
│   ├── Typography/
│   │   ├── AWAVEFonts.swift
│   │   └── TextStyles.swift
│   ├── Components/
│   │   ├── Buttons/
│   │   │   ├── AWAVEButton.swift
│   │   │   ├── PlayButton.swift
│   │   │   └── IconButton.swift
│   │   ├── Cards/
│   │   │   ├── SoundCard.swift
│   │   │   ├── CategoryCard.swift
│   │   │   └── SessionCard.swift
│   │   ├── Inputs/
│   │   │   ├── VolumeSlider.swift
│   │   │   ├── SearchField.swift
│   │   │   └── ProgressSlider.swift
│   │   ├── Feedback/
│   │   │   ├── LoadingView.swift
│   │   │   ├── ErrorView.swift
│   │   │   └── EmptyStateView.swift
│   │   └── Layout/
│   │       ├── GradientBackground.swift
│   │       ├── CardContainer.swift
│   │       └── SectionHeader.swift
│   ├── Modifiers/
│   │   ├── CardStyle.swift
│   │   ├── GlowEffect.swift
│   │   └── ShakeEffect.swift
│   ├── Animations/
│   │   ├── WaveformAnimation.swift
│   │   └── PulseAnimation.swift
│   └── Resources/
│       ├── Assets.xcassets
│       └── Localizable.xcstrings
└── Tests/AWAVEDesignTests/
```

---

### AWAVEFeatures (Feature Modules)

```swift
// Package.swift
let package = Package(
    name: "AWAVEFeatures",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "HomeFeature", targets: ["HomeFeature"]),
        .library(name: "PlayerFeature", targets: ["PlayerFeature"]),
        .library(name: "LibraryFeature", targets: ["LibraryFeature"]),
        .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
        .library(name: "SubscriptionFeature", targets: ["SubscriptionFeature"]),
        .library(name: "OnboardingFeature", targets: ["OnboardingFeature"])
    ],
    dependencies: [
        .package(path: "../AWAVECore"),
        .package(path: "../AWAVEDomain"),
        .package(path: "../AWAVEDesign")
    ],
    targets: [
        .target(name: "HomeFeature", dependencies: ["AWAVECore", "AWAVEDomain", "AWAVEDesign"]),
        .target(name: "PlayerFeature", dependencies: ["AWAVECore", "AWAVEDomain", "AWAVEDesign"]),
        .target(name: "LibraryFeature", dependencies: ["AWAVECore", "AWAVEDomain", "AWAVEDesign"]),
        .target(name: "ProfileFeature", dependencies: ["AWAVECore", "AWAVEDomain", "AWAVEDesign"]),
        .target(name: "SubscriptionFeature", dependencies: ["AWAVECore", "AWAVEDomain", "AWAVEDesign"]),
        .target(name: "OnboardingFeature", dependencies: ["AWAVECore", "AWAVEDomain", "AWAVEDesign"]),
        // Test targets...
    ]
)
```

**Feature Module Structure (each):**
```
HomeFeature/
├── HomeView.swift
├── HomeViewModel.swift
└── Components/
    ├── CategorySection.swift
    ├── FeaturedCarousel.swift
    └── QuickPlayGrid.swift
```

---

## Access Control Guidelines

| Scope | Usage | Modifier |
|-------|-------|----------|
| Public API | Types/methods used by other packages | `public` |
| Internal | Package-internal implementation | `internal` (default) |
| Private | Type-internal implementation | `private` |
| File-private | File-scoped helpers | `fileprivate` |

```swift
// Public: Used by other packages
public protocol SoundRepositoryProtocol {
    func getAll() async throws -> [Sound]
}

// Internal: Implementation detail within package
final class FirestoreSoundRepository: SoundRepositoryProtocol {
    internal func getAll() async throws -> [Sound] {
        // ...
    }

    // Private: Class-internal helper
    private func mapToEntity(_ document: FirestoreSound) -> Sound {
        // ...
    }
}
```

---

## Build Configuration

### Main App Target

```swift
// AWAVE (Main App) dependencies
.target(
    name: "AWAVE",
    dependencies: [
        .product(name: "HomeFeature", package: "AWAVEFeatures"),
        .product(name: "PlayerFeature", package: "AWAVEFeatures"),
        .product(name: "LibraryFeature", package: "AWAVEFeatures"),
        .product(name: "ProfileFeature", package: "AWAVEFeatures"),
        .product(name: "SubscriptionFeature", package: "AWAVEFeatures"),
        .product(name: "OnboardingFeature", package: "AWAVEFeatures"),
        .product(name: "AWAVEData", package: "AWAVEData"),
        .product(name: "AWAVEAudio", package: "AWAVEAudio"),
        .product(name: "AWAVEDesign", package: "AWAVEDesign"),
    ]
)
```

### Build Order

```
1. AWAVECore          (no dependencies)
2. AWAVEDomain        (depends on Core)
3. AWAVEDesign        (no dependencies)
4. AWAVEData          (depends on Core, Domain)
5. AWAVEAudio         (depends on Core, Domain)
6. AWAVENetwork       (depends on Core)
7. AWAVEFeatures      (depends on Core, Domain, Design)
8. AWAVE (App)        (depends on all)
```

---

## Module Boundaries

### What Can Import What

| Module | Can Import |
|--------|------------|
| AWAVECore | Nothing (foundation) |
| AWAVEDomain | AWAVECore |
| AWAVEDesign | Nothing (UI only) |
| AWAVEData | AWAVECore, AWAVEDomain |
| AWAVEAudio | AWAVECore, AWAVEDomain |
| AWAVEFeatures | AWAVECore, AWAVEDomain, AWAVEDesign |
| AWAVE (App) | All packages |

### Circular Dependency Prevention

```
✅ Allowed:
Domain → Core
Data → Domain → Core
Features → Domain → Core

❌ Not Allowed:
Core → Domain (reverse)
Domain → Data (implementation detail)
Data → Features (presentation detail)
```
