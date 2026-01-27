# Architecture Decision Records (ADRs)

## Purpose

This document captures key architectural decisions, their context, and rationale. ADRs provide historical context for why certain choices were made.

---

## ADR-001: Use MVVM + Clean Architecture Hybrid

**Status**: Accepted
**Date**: 2024-01
**Deciders**: Architecture Team

### Context
AWAVE needs an architecture that supports:
- Complex multi-track audio mixing
- Offline-first data synchronization
- SwiftUI declarative UI
- Testable business logic
- Team scalability

### Decision
Adopt a hybrid MVVM + Clean Architecture approach:
- **Presentation**: SwiftUI Views + @Observable ViewModels
- **Domain**: Entities, Use Cases, Repository Protocols
- **Data**: Repository Implementations, SwiftData, Firestore

### Consequences
**Positive:**
- Clear layer separation
- Testable business logic via Use Cases
- SwiftUI-native state management
- Familiar patterns for iOS developers

**Negative:**
- More structure than simple MVVM
- Use Cases may feel like boilerplate for simple operations
- Team needs to understand layer boundaries

### Alternatives Considered
- **Pure MVVM**: Simpler but less scalable
- **TCA**: Excellent but steep learning curve
- **VIPER**: Too verbose for SwiftUI

---

## ADR-002: Use @Observable for State Management

**Status**: Accepted
**Date**: 2024-01
**Deciders**: iOS Team

### Context
Need reactive state management that:
- Integrates well with SwiftUI
- Is simple to understand
- Supports async operations
- Enables testing

### Decision
Use Swift 5.9's @Observable macro for ViewModels instead of Combine or TCA.

```swift
@Observable
class PlayerViewModel {
    var isPlaying = false
    var tracks: [MixerTrack] = []
}
```

### Consequences
**Positive:**
- Native SwiftUI integration
- Minimal boilerplate
- Simple mental model
- Future-proof (Apple's direction)

**Negative:**
- Less explicit than TCA
- No built-in effect management
- Fewer operators than Combine

### Alternatives Considered
- **Combine**: Being de-emphasized
- **TCA**: Higher learning curve
- **Custom ObservableObject**: @Observable is better

---

## ADR-003: Use SwiftData for Local Persistence

**Status**: Accepted
**Date**: 2024-01
**Deciders**: Architecture Team

### Context
Need local data persistence for:
- Caching sound metadata
- Storing session history
- Managing favorites offline
- User preferences

### Decision
Use SwiftData (iOS 17+) instead of Core Data.

```swift
@Model
class SessionModel {
    var id: String
    var startedAt: Date
    var sounds: [String]
}
```

### Consequences
**Positive:**
- Modern Swift-native API
- Automatic schema migration
- Less boilerplate than Core Data
- Potential CloudKit integration

**Negative:**
- iOS 17+ only (acceptable for new app)
- Less mature than Core Data
- Fewer community resources
- Some edge cases undocumented

### Alternatives Considered
- **Core Data**: More mature but complex
- **Realm**: Third-party dependency
- **SQLite**: Too low-level

### Mitigation
Abstract behind repository protocol to allow swapping if issues arise.

---

## ADR-004: Use Firestore for Remote Data

**Status**: Accepted
**Date**: 2024-01
**Deciders**: Architecture Team

### Context
Need remote database with:
- Real-time sync
- Offline persistence
- Scalability
- Firebase Auth integration

### Decision
Use Google Cloud Firestore as the primary remote database.

### Consequences
**Positive:**
- Excellent offline support
- Real-time listeners
- Firebase ecosystem integration
- Automatic scaling

**Negative:**
- NoSQL limitations (no joins)
- Higher cost at scale than SQL
- Vendor lock-in to GCP
- Query limitations

### Alternatives Considered
- **Supabase**: Better SQL but weaker offline
- **CloudKit**: Apple lock-in
- **Custom API**: More work, more flexibility

---

## ADR-005: Use Actor for Audio Engine

**Status**: Accepted
**Date**: 2024-01
**Deciders**: iOS Team

### Context
Multi-track audio engine needs:
- Thread-safe state management
- Concurrent access handling
- Clear async boundaries
- Performance for real-time audio

### Decision
Implement AudioEngine as a Swift Actor.

```swift
actor AWAVEAudioEngine: AudioEngineProtocol {
    private let engine = AVAudioEngine()
    private var playerNodes: [String: AVAudioPlayerNode] = [:]

    func play() async { /* ... */ }
}
```

### Consequences
**Positive:**
- Thread safety by design
- No manual locking
- Modern Swift concurrency
- Clear ownership model

**Negative:**
- All access is async
- Potential performance overhead
- Less control than manual synchronization
- May complicate real-time requirements

### Alternatives Considered
- **Class + DispatchQueue**: More control, more bugs
- **Class + Locks**: Complex, error-prone
- **MainActor**: Not suitable for audio work

---

## ADR-006: Use Environment-based Dependency Injection

**Status**: Accepted
**Date**: 2024-01
**Deciders**: Architecture Team

### Context
Need dependency injection that:
- Works with SwiftUI
- Supports testing
- Is type-safe
- Doesn't require external frameworks

### Decision
Use SwiftUI Environment with a custom DependencyContainer.

```swift
struct DependencyContainer {
    let authService: AuthServiceProtocol
    let audioEngine: AudioEngineProtocol
    // ...

    static var live: DependencyContainer { /* ... */ }
    static var preview: DependencyContainer { /* ... */ }
}

// Injected via Environment
.environment(\.dependencies, DependencyContainer.live)
```

### Consequences
**Positive:**
- SwiftUI native
- No external dependencies
- Clear configuration switching
- Type-safe

**Negative:**
- Manual wiring
- No automatic resolution
- All dependencies centralized

### Alternatives Considered
- **Swinject**: External dependency, runtime resolution
- **Needle**: Complex setup
- **Factory**: Simpler but less SwiftUI integration

---

## ADR-007: Use Coordinator Pattern for Navigation

**Status**: Accepted
**Date**: 2024-01
**Deciders**: iOS Team

### Context
Need navigation management that:
- Separates navigation from views
- Supports deep linking
- Is testable
- Works with NavigationStack

### Decision
Implement centralized AppCoordinator with @Observable.

```swift
@Observable
class AppCoordinator {
    var homePath = NavigationPath()
    var presentedSheet: SheetDestination?

    func navigate(to destination: Destination) {
        // Centralized navigation logic
    }
}
```

### Consequences
**Positive:**
- Testable navigation
- Centralized logic
- Deep linking support
- Clear navigation state

**Negative:**
- Additional abstraction
- Must sync with NavigationStack
- May not fit all patterns

### Alternatives Considered
- **Direct NavigationStack**: Less testable
- **Router pattern**: Similar, less SwiftUI-native
- **Per-feature coordinators**: More complex

---

## ADR-008: Use Swift Package Manager for Modularity

**Status**: Accepted
**Date**: 2024-01
**Deciders**: Architecture Team

### Context
Need modular architecture for:
- Faster builds
- Clear boundaries
- Team scalability
- Code reuse across targets

### Decision
Organize code into SPM packages:
- AWAVECore
- AWAVEDomain
- AWAVEData
- AWAVEAudio
- AWAVEDesign
- AWAVEFeatures

### Consequences
**Positive:**
- Enforced boundaries
- Parallel compilation
- Clear dependencies
- Reusable for watchOS, widgets

**Negative:**
- More configuration
- Package maintenance overhead
- Some IDE quirks

### Alternatives Considered
- **Monolith**: Simpler but slower builds
- **Tuist**: More powerful but complex setup
- **Xcode targets**: Less enforcement

---

## ADR-009: Offline-First Data Strategy

**Status**: Accepted
**Date**: 2024-01
**Deciders**: Architecture Team

### Context
Users need to:
- Play downloaded sounds offline
- See favorites without network
- Have sessions tracked offline
- Sync when reconnected

### Decision
Implement offline-first with background sync:
1. Local SwiftData as source of truth for user data
2. Firestore for sync and server data
3. SyncEngine for background reconciliation
4. OfflineQueue for pending operations

### Consequences
**Positive:**
- App works without network
- Better user experience
- Resilient to connectivity issues

**Negative:**
- Sync complexity
- Conflict resolution needed
- Debugging harder

---

## ADR-010: iOS 17+ Minimum Deployment

**Status**: Accepted
**Date**: 2024-01
**Deciders**: Product Team

### Context
Need to decide minimum iOS version.

### Decision
Target iOS 17+ minimum deployment.

### Consequences
**Positive:**
- Access to @Observable
- Access to SwiftData
- Latest SwiftUI features
- Modern concurrency

**Negative:**
- Excludes ~15% of iOS users
- No iOS 16 support

### Rationale
New app can afford higher minimum. Features enabled are worth the trade-off.

---

## Decision Log Summary

| ADR | Decision | Status | Risk |
|-----|----------|--------|------|
| 001 | MVVM + Clean Hybrid | Accepted | Low |
| 002 | @Observable | Accepted | Low |
| 003 | SwiftData | Accepted | Medium |
| 004 | Firestore | Accepted | Low |
| 005 | Actor AudioEngine | Accepted | Medium |
| 006 | Environment DI | Accepted | Low |
| 007 | Coordinator Navigation | Accepted | Low |
| 008 | SPM Modularity | Accepted | Low |
| 009 | Offline-First | Accepted | Medium |
| 010 | iOS 17+ Minimum | Accepted | Low |

---

## Template for New ADRs

```markdown
## ADR-XXX: [Title]

**Status**: [Proposed | Accepted | Deprecated | Superseded]
**Date**: [YYYY-MM]
**Deciders**: [Who made this decision]

### Context
[Why is this decision needed?]

### Decision
[What is the change being proposed/decided?]

### Consequences
**Positive:**
- [Benefit 1]
- [Benefit 2]

**Negative:**
- [Drawback 1]
- [Drawback 2]

### Alternatives Considered
- **[Alternative 1]**: [Why not chosen]
- **[Alternative 2]**: [Why not chosen]
```
