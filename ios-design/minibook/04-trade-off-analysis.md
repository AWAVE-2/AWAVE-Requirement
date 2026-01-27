# Trade-Off Analysis

## Purpose

Every architectural decision involves trade-offs. This document explicitly documents what we gain and what we sacrifice with each major decision.

---

## Decision 1: MVVM + Clean over Pure TCA

### What We Chose
Modular MVVM with Clean Architecture principles (Use Cases, Repository Pattern)

### What We Gave Up
The Composable Architecture (TCA) with its predictable state, time-travel debugging, and rigorous effect handling

### Trade-Off Analysis

| Aspect | MVVM+Clean | TCA | Our Choice |
|--------|------------|-----|------------|
| State Predictability | Medium | Excellent | Accept lower |
| Debugging | Standard | Time-travel | Accept standard |
| Learning Curve | Medium | High | Benefit |
| Boilerplate | Low-Medium | High | Benefit |
| Team Velocity | Higher | Lower (initially) | Benefit |
| Effect Management | Implicit | Explicit | Accept implicit |
| Testing Rigor | Good | Excellent | Accept good |

### Why This Trade-Off

```
Arguments FOR MVVM+Clean:
├── Team can onboard faster
├── More familiar patterns for most iOS developers
├── Sufficient for app complexity
├── Better documentation/community resources
└── Pragmatic for startup velocity

Arguments AGAINST (what we lose):
├── No guaranteed state consistency
├── Effects can be scattered
├── Harder to trace state changes
└── More discipline required for consistency
```

### Mitigation Strategies

1. **State Consistency**: Enforce unidirectional data flow in ViewModels
2. **Effect Management**: Use Cases encapsulate side effects
3. **Debugging**: Comprehensive logging in state transitions
4. **Discipline**: Code review focus on architecture compliance

---

## Decision 2: @Observable over Combine

### What We Chose
Swift 5.9 Observation framework with @Observable macro

### What We Gave Up
Combine's explicit publishers, operators, and reactive streams

### Trade-Off Analysis

| Aspect | @Observable | Combine | Our Choice |
|--------|-------------|---------|------------|
| SwiftUI Integration | Native | Bridged | Benefit |
| Debugging | Simple | Complex | Benefit |
| Composability | Limited | Excellent | Accept limited |
| Learning Curve | Low | Medium | Benefit |
| Complex Async | Manual | Built-in operators | Accept manual |
| Cancellation | Manual | Built-in | Accept manual |

### Why This Trade-Off

```
@Observable Benefits:
├── Direct SwiftUI integration
├── Minimal boilerplate
├── Easier to understand
└── Modern Swift direction

What We Lose:
├── scan, combineLatest, debounce, etc.
├── Built-in backpressure
├── Declarative streams
└── AnyCancellable pattern

Mitigation:
├── Use async/await for complex async
├── AsyncStream where needed
├── Manual debouncing where critical
└── Can adopt Combine selectively
```

---

## Decision 3: SwiftData over Core Data

### What We Chose
SwiftData with its Swift-native API and automatic migrations

### What We Gave Up
Core Data's maturity, extensive documentation, and proven track record

### Trade-Off Analysis

| Aspect | SwiftData | Core Data | Our Choice |
|--------|-----------|-----------|------------|
| API Simplicity | Excellent | Complex | Benefit |
| Documentation | Limited | Extensive | Accept limited |
| Maturity | New (iOS 17) | 15+ years | Accept new |
| Edge Cases | Unknown | Well-documented | Risk |
| Migration | Automatic | Manual (powerful) | Benefit (risky) |
| Performance | Good | Excellent | Accept good |
| CloudKit Sync | Built-in | Manual setup | Benefit |

### Why This Trade-Off

```
SwiftData Benefits:
├── Swift-native, macro-based
├── Automatic schema migrations
├── Future-facing (Apple's direction)
├── Simpler mental model
└── Less boilerplate

What We Lose:
├── Proven stability
├── Community knowledge base
├── Complex migration control
├── Fine-grained performance tuning
└── NSFetchedResultsController equivalents

Mitigation:
├── Abstract behind repository protocol
├── Can fall back to Core Data if critical issues
├── Keep local data recoverable from Firestore
└── Comprehensive testing of persistence layer
```

### Escape Hatch

```swift
// Repository protocol allows swapping implementation
protocol SoundRepositoryProtocol {
    func getAll() async throws -> [Sound]
}

// Current: SwiftData
class SwiftDataSoundRepository: SoundRepositoryProtocol { }

// Fallback: Core Data (if needed)
class CoreDataSoundRepository: SoundRepositoryProtocol { }
```

---

## Decision 4: Firestore over PostgreSQL (Supabase)

### What We Chose
Google Cloud Firestore (NoSQL document database)

### What We Gave Up
Supabase PostgreSQL with relational queries, joins, and SQL power

### Trade-Off Analysis

| Aspect | Firestore | PostgreSQL | Our Choice |
|--------|-----------|------------|------------|
| Offline Sync | Excellent | Limited | Major benefit |
| Real-time | Built-in | Subscription-based | Benefit |
| Query Flexibility | Limited | Excellent | Accept limited |
| Joins | None | Native | Accept workarounds |
| Scalability | Automatic | Manual | Benefit |
| Cost at Scale | Higher | Lower | Accept higher |
| iOS SDK | Excellent | Good | Benefit |

### Why This Trade-Off

```
Firestore Benefits:
├── First-class offline persistence
├── Automatic conflict resolution
├── Firebase Auth integration
├── Real-time listeners
├── No server management
└── Scales automatically

What We Lose:
├── SQL queries (joins, aggregations)
├── Relational integrity
├── Lower cost at scale
├── Flexibility in data modeling
└── Vendor independence

Mitigation:
├── Denormalize data for common queries
├── Use Cloud Functions for complex operations
├── BigQuery for analytics (SQL available)
└── Abstract behind repository for future flexibility
```

### Data Model Implications

```
// PostgreSQL approach (can't do in Firestore)
SELECT s.*, COUNT(f.id) as favorite_count
FROM sounds s
LEFT JOIN favorites f ON s.id = f.sound_id
GROUP BY s.id
ORDER BY favorite_count DESC;

// Firestore approach (denormalized)
sounds/{soundId}: {
    name: "Ocean Waves",
    favoriteCount: 142,  // Maintained via Cloud Function
    // ...
}
```

---

## Decision 5: Actor-based AudioEngine over Class

### What We Chose
Swift Actor for thread-safe audio management

### What We Gave Up
Simple class with manual synchronization (potentially better control)

### Trade-Off Analysis

| Aspect | Actor | Class + Locks | Our Choice |
|--------|-------|---------------|------------|
| Thread Safety | Automatic | Manual | Benefit |
| Performance | Good | Can be better | Accept good |
| Real-time Audio | Considerations | Full control | Risk |
| API Design | Async required | Flexible | Accept async |
| Debugging | Standard | Can be complex | Similar |

### Why This Trade-Off

```
Actor Benefits:
├── Thread safety by design
├── No data races possible
├── Modern Swift concurrency
├── Clear async boundaries
└── Less cognitive overhead

What We Lose:
├── Synchronous access when needed
├── Fine-grained lock control
├── Potentially lower latency paths
└── Easier real-time thread access

Mitigation:
├── Careful design of async boundaries
├── nonisolated methods where safe
├── Pre-load and cache audio data
└── Benchmark and optimize critical paths
```

### Critical Path Analysis

```swift
actor AWAVEAudioEngine {
    // ⚠️ Every call crosses actor boundary
    func setVolume(_ volume: Float, for trackId: String) {
        playerNodes[trackId]?.volume = volume
    }

    // Mitigation: batch operations where possible
    func setVolumes(_ volumes: [(trackId: String, volume: Float)]) {
        for (trackId, volume) in volumes {
            playerNodes[trackId]?.volume = volume
        }
    }
}
```

---

## Decision 6: Environment DI over Framework

### What We Chose
SwiftUI Environment + DependencyContainer factory pattern

### What We Gave Up
Type-safe DI frameworks like Swinject or Needle

### Trade-Off Analysis

| Aspect | Environment+Factory | Swinject | Our Choice |
|--------|---------------------|----------|------------|
| SwiftUI Integration | Native | Bridge needed | Benefit |
| Compile-time Safety | Good | Runtime | Similar |
| External Dependency | None | Framework | Benefit |
| Flexibility | Medium | High | Accept medium |
| Learning Curve | Low | Medium | Benefit |
| Circular Dependencies | Manual handling | Handled | Accept manual |

### Why This Trade-Off

```
Environment+Factory Benefits:
├── No external dependencies
├── SwiftUI-native approach
├── Explicit dependency graph
├── Easy preview/test configuration
└── Simple mental model

What We Lose:
├── Automatic dependency resolution
├── Scope management (per-feature, per-session)
├── Property wrapper injection
└── Circular dependency detection

Mitigation:
├── DependencyContainer is explicit
├── Manual scope management where needed
├── Clear factory methods
└── Compile-time checking via protocols
```

---

## Decision 7: SPM Packages over Tuist/Monolith

### What We Chose
Swift Package Manager for modular architecture

### What We Gave Up
Simpler monolith or more powerful Tuist generation

### Trade-Off Analysis

| Aspect | SPM Packages | Monolith | Tuist |
|--------|--------------|----------|-------|
| Build Time | Faster (incremental) | Slow | Fastest |
| Setup Complexity | Medium | None | High |
| Dependency Clarity | Enforced | None | Enforced |
| CI/CD Caching | Good | None | Excellent |
| Team Learning | Medium | None | High |
| Tooling Maturity | Good | N/A | Medium |

### Why This Trade-Off

```
SPM Benefits:
├── Apple-supported
├── Enforced module boundaries
├── Incremental builds
├── No external tooling
└── Good IDE support

What We Lose vs Tuist:
├── Project generation
├── Template management
├── Cache optimization
└── Team scaling features

What We Lose vs Monolith:
├── Simpler setup
├── No package configuration
└── Easier for small teams

Mitigation:
├── Clear package documentation
├── Template packages for new features
├── CI caching configuration
└── Can adopt Tuist later if needed
```

---

## Summary: Accepted Trade-Offs

| Decision | Main Benefit | Main Sacrifice | Risk Level |
|----------|--------------|----------------|------------|
| MVVM+Clean | Team velocity | State rigor | Low |
| @Observable | Simplicity | Combine operators | Low |
| SwiftData | Modern API | Maturity | Medium |
| Firestore | Offline sync | SQL flexibility | Low |
| Actor Audio | Thread safety | Sync control | Medium |
| Environment DI | Simplicity | Framework power | Low |
| SPM Packages | Build time | Tuist features | Low |

**Overall Risk Assessment**: Medium-Low

All trade-offs have mitigation strategies and escape hatches where needed.
