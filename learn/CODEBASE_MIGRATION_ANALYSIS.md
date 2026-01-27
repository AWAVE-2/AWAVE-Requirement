# AWAVE Advanced: Behind the Scenes - Migration Analysis

> **Source**: React Native 0.76.9 + Supabase + Custom Native Audio Module
> **Target**: Native iOS (Swift/SwiftUI) + Google Cloud
> **Scope**: Complete native rewrite preserving business logic

---

## Table of Contents

1. [Current Architecture Overview](#current-architecture-overview)
2. [Technology Stack Mapping](#technology-stack-mapping)
3. [What Transfers vs What Gets Rewritten](#what-transfers-vs-what-gets-rewritten)
4. [Feature-by-Feature Migration Plan](#feature-by-feature-migration-plan)
5. [Native Audio Module Analysis](#native-audio-module-analysis)
6. [Backend Migration: Supabase → Google Cloud](#backend-migration-supabase--google-cloud)
7. [Data Model Translations](#data-model-translations)
8. [State Management Translation](#state-management-translation)
9. [Risk Analysis & Mitigation](#risk-analysis--mitigation)
10. [Migration Phases](#migration-phases)

---

## Current Architecture Overview

### High-Level System Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AWAVE Advanced (Current)                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     React Native UI Layer                            │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │   │
│  │  │  24 Screens  │  │132 Components│  │  Navigation  │               │   │
│  │  │              │  │              │  │  (RN Nav 6)  │               │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    State Management Layer                            │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │   │
│  │  │React Context │  │ React Query  │  │ AsyncStorage │               │   │
│  │  │  (4 ctxs)    │  │  (cache)     │  │  (persist)   │               │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      Service Layer (36 Services)                     │   │
│  │  ┌──────────┐ ┌────────────┐ ┌──────────────┐ ┌──────────────┐      │   │
│  │  │  Auth    │ │  Session   │ │ Subscription │ │   Search     │      │   │
│  │  │ Service  │ │  Tracking  │ │   Service    │ │   Service    │      │   │
│  │  └──────────┘ └────────────┘ └──────────────┘ └──────────────┘      │   │
│  │  ┌──────────┐ ┌────────────┐ ┌──────────────┐ ┌──────────────┐      │   │
│  │  │  IAP     │ │  Offline   │ │   OAuth      │ │   Audio      │      │   │
│  │  │ Service  │ │   Queue    │ │   Service    │ │   Service    │      │   │
│  │  └──────────┘ └────────────┘ └──────────────┘ └──────────────┘      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│            ┌───────────────────────┼───────────────────────┐               │
│            ▼                       ▼                       ▼               │
│  ┌────────────────┐    ┌────────────────────┐    ┌─────────────────┐      │
│  │  AWAVEAudio    │    │   Supabase Client  │    │  react-native   │      │
│  │  Module (ObjC) │    │   (JS SDK)         │    │  -iap           │      │
│  │  AVAudioEngine │    │                    │    │                 │      │
│  └────────────────┘    └────────────────────┘    └─────────────────┘      │
│                                    │                                        │
└────────────────────────────────────┼────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Supabase Backend                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │    Auth     │  │  PostgreSQL │  │   Storage   │  │  Functions  │        │
│  │   (PKCE)    │  │  (12 tbls)  │  │   (Audio)   │  │  (Edge)     │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Metrics

| Metric | Value | Notes |
|--------|-------|-------|
| **Total Source** | 2.7MB | TypeScript/TSX |
| **Screens** | 24 | Full feature set |
| **Components** | 132 | Reusable UI |
| **Services** | 36 | ~10K LOC business logic |
| **Hooks** | 26 | Custom React hooks |
| **Native Module** | 1 | AWAVEAudioModule (Obj-C) |
| **Database Tables** | 12 | PostgreSQL via Supabase |

---

## Technology Stack Mapping

### React Native → Native iOS Equivalents

| RN Component | iOS Equivalent | Migration Complexity |
|--------------|----------------|---------------------|
| **React Native** | Swift/SwiftUI | High (full rewrite) |
| **React Navigation** | NavigationStack + TabView | Medium |
| **React Context** | ObservableObject + @Published | Medium |
| **React Query** | Custom cache + URLSession | Medium |
| **AsyncStorage** | UserDefaults + Keychain | Low |
| **Reanimated** | SwiftUI animations + Core Animation | Medium |
| **react-native-track-player** | Keep native AVAudioEngine | Low (already native) |
| **Supabase JS SDK** | URLSession + Codable | Medium |
| **react-native-iap** | StoreKit 2 | Medium |
| **Google Sign-In** | GoogleSignIn SDK | Low |
| **Apple Sign-In** | AuthenticationServices | Low (native API) |

### Backend: Supabase → Google Cloud

| Supabase Service | Google Cloud Equivalent | Migration Path |
|------------------|------------------------|----------------|
| **PostgreSQL** | Cloud SQL (PostgreSQL) | Direct migration |
| **Auth (GoTrue)** | Firebase Auth OR Identity Platform | Rebuild |
| **Storage** | Cloud Storage | Direct migration |
| **Edge Functions** | Cloud Functions | Port Deno → Node.js |
| **Realtime** | Firestore OR Pub/Sub | Architecture decision |
| **Row-Level Security** | Cloud SQL + IAM | Custom middleware |

---

## What Transfers vs What Gets Rewritten

### Transfers Directly (Preserve)

```
✅ Database Schema (PostgreSQL → Cloud SQL)
   └── 12 tables, all relationships, JSONB fields

✅ Business Logic (TypeScript → Swift)
   └── 36 services: auth, sessions, subscriptions, etc.
   └── All algorithms and data flows

✅ Audio Engine (Already Objective-C)
   └── AWAVEAudioModule: AVAudioEngine, effects, mixing
   └── Just needs Swift wrapper, not rewrite

✅ API Contracts
   └── All endpoint structures
   └── Request/response shapes
   └── Error codes and handling

✅ Data Models
   └── TypeScript interfaces → Swift Codable structs
   └── Validation rules (Zod → Swift validation)

✅ OAuth Flows
   └── Google/Apple Sign-In patterns
   └── Session management logic
```

### Requires Full Rewrite

```
🔄 UI Layer (132 components → SwiftUI)
   └── All screens, layouts, styling
   └── But SAME behavior and flows

🔄 Navigation (React Navigation → SwiftUI)
   └── Tab structure, stack navigation
   └── Deep linking, modal presentations

🔄 State Management
   └── React Context → @Observable / @Published
   └── React Query → Custom caching layer
   └── Hooks → Property wrappers + extensions

🔄 Animations
   └── Reanimated → SwiftUI animations
   └── Gesture handling → UIGestureRecognizer

🔄 Tests
   └── Jest → XCTest
   └── Detox → XCUITest
```

---

## Feature-by-Feature Migration Plan

### Priority Matrix

```
PHASE 1 - Core (Week 1-4)
├── Authentication (Email, OAuth)
├── Main Tab Navigation (4 categories)
├── Audio Player (basic playback)
└── User Profile

PHASE 2 - Essential (Week 5-8)
├── Full Audio Player (effects, mixing)
├── Library & Search
├── Favorites System
├── Session Tracking

PHASE 3 - Monetization (Week 9-10)
├── Subscription System (StoreKit 2)
├── Premium Content Gating
├── Trial Management
└── Downsell Flows

PHASE 4 - Polish (Week 11-12)
├── Stats Dashboard
├── Settings & Preferences
├── Notifications
├── Offline Support
└── SOS Feature
```

### Screen Migration Checklist

| Screen | RN Location | iOS Priority | Complexity |
|--------|-------------|--------------|------------|
| **IndexScreen** | `screens/Index.tsx` | P0 | Low |
| **AuthScreen** | `screens/Auth.tsx` | P0 | Medium |
| **SignupScreen** | `screens/Signup.tsx` | P0 | Medium |
| **SchläfScreen** | `screens/Schlafen.tsx` | P0 | Medium |
| **RuheScreen** | `screens/Ruhe.tsx` | P0 | Medium |
| **ImFlussScreen** | `screens/ImFluss.tsx` | P0 | Medium |
| **ProfileScreen** | `screens/Profile.tsx` | P0 | Medium |
| **AudioPlayerScreen** | `screens/AudioPlayer.tsx` | P1 | High |
| **LibraryScreen** | `screens/Library.tsx` | P1 | Medium |
| **SearchDrawer** | `components/SearchDrawer.tsx` | P1 | Medium |
| **SubscribeScreen** | `screens/Subscribe.tsx` | P2 | High |
| **DownsellScreen** | `screens/Downsell.tsx` | P2 | Medium |
| **StatsScreen** | `screens/Stats.tsx` | P3 | Medium |
| **AccountSettingsScreen** | `screens/AccountSettings.tsx` | P3 | Low |
| **NotificationPreferencesScreen** | `screens/NotificationPreferences.tsx` | P3 | Low |
| **LegalScreen** | `screens/Legal.tsx` | P3 | Low |
| **SupportScreen** | `screens/Support.tsx` | P3 | Low |
| **OnboardingSlidesScreen** | `screens/OnboardingSlides.tsx` | P1 | Medium |
| **EmailVerificationScreen** | `screens/EmailVerification.tsx` | P1 | Low |
| **ForgotPasswordScreen** | `screens/ForgotPassword.tsx` | P2 | Low |
| **TermsScreen** | `screens/Terms.tsx` | P3 | Low |
| **PrivacyPolicyScreen** | `screens/PrivacyPolicy.tsx` | P3 | Low |
| **DataPrivacyScreen** | `screens/DataPrivacy.tsx` | P3 | Low |
| **KlangweltenScreen** | `screens/Klangwelten.tsx` | P1 | Medium |

---

## Native Audio Module Analysis

### Current AWAVEAudioModule (Objective-C)

**Location**: `ios/AWAVEAdvanced/NativeModules/AWAVEAudioModule.m`

```objc
// Core Architecture
AVAudioEngine *audioEngine;          // Central audio graph
NSMutableDictionary *playerNodes;    // Track ID → AVAudioPlayerNode
NSMutableDictionary *audioBuffers;   // Track ID → AVAudioPCMBuffer
NSMutableDictionary *effectNodes;    // Track ID → Effect chains

// Effect Types Supported
- AVAudioUnitReverb
- AVAudioUnitDelay
- AVAudioUnitDistortion
- AVAudioUnitEQ (3-band)
- AVAudioUnitCompressor
```

### Migration Strategy: Wrap, Don't Rewrite

```swift
// Option A: Create Swift wrapper around existing Obj-C
@MainActor
class AudioEngineManager: ObservableObject {
    private let audioModule = AWAVEAudioModule()

    @Published var isPlaying = false
    @Published var currentTrack: Track?
    @Published var volume: Float = 1.0

    func loadTrack(_ track: Track) async throws {
        try await audioModule.loadAudioFile(track.filePath, trackId: track.id)
    }

    func play() {
        audioModule.playAudio(currentTrack?.id)
        isPlaying = true
    }
}

// Option B: Rewrite in pure Swift (more work, cleaner)
actor AudioEngine {
    private var engine = AVAudioEngine()
    private var players: [String: AVAudioPlayerNode] = [:]

    func loadTrack(_ url: URL, id: String) async throws {
        let file = try AVAudioFile(forReading: url)
        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: file.processingFormat)
        players[id] = player
    }
}
```

**Recommendation**: Start with Option A (wrap existing), optimize later.

### Audio Effects Mapping

| Current (RN Bridge) | Native Swift Implementation |
|--------------------|-----------------------------|
| `applyReverb(trackId, roomSize, ...)` | `AVAudioUnitReverb` with presets |
| `applyDelay(trackId, time, feedback)` | `AVAudioUnitDelay` parameters |
| `applyCompressor(trackId, ...)` | `AVAudioUnitDynamicsProcessor` |
| `applyFilter(trackId, freq, q, type)` | `AVAudioUnitEQ` bands |
| `setMasterEQ(low, mid, high)` | `AVAudioUnitEQ` on mixer |

---

## Backend Migration: Supabase → Google Cloud

### Current Supabase Architecture

```
Production URL: https://api.dripin.ai

Services:
├── Auth: /auth/v1/
│   └── PKCE flow, magic links, OAuth
├── Database: /rest/v1/
│   └── PostgREST API over PostgreSQL
├── Storage: /storage/v1/
│   └── Audio files (~2GB library)
├── Realtime: wss://.../realtime/v1/
│   └── WebSocket subscriptions
└── Functions: /functions/v1/
    └── Deno edge functions
```

### Google Cloud Target Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Google Cloud Platform                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────┐      ┌─────────────────────┐                   │
│  │   Firebase Auth     │      │    Cloud Functions  │                   │
│  │   - Email/Password  │      │    - API endpoints  │                   │
│  │   - Google Sign-In  │      │    - Webhooks       │                   │
│  │   - Apple Sign-In   │      │    - Stripe hooks   │                   │
│  └─────────────────────┘      └─────────────────────┘                   │
│            │                           │                                 │
│            ▼                           ▼                                 │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                        Cloud SQL (PostgreSQL)                    │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │   │
│  │  │user_profiles │  │ user_sessions│  │ subscriptions│          │   │
│  │  │user_favorites│  │sound_metadata│  │ custom_sounds│          │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─────────────────────┐      ┌─────────────────────┐                   │
│  │   Cloud Storage     │      │   Cloud Pub/Sub     │                   │
│  │   - Audio files     │      │   - Real-time sync  │                   │
│  │   - User avatars    │      │   - Event streaming │                   │
│  │   - Exports         │      │                     │                   │
│  └─────────────────────┘      └─────────────────────┘                   │
│                                                                          │
│  ┌─────────────────────┐      ┌─────────────────────┐                   │
│  │   Cloud CDN         │      │   Secret Manager    │                   │
│  │   - Audio delivery  │      │   - API keys        │                   │
│  │   - Static assets   │      │   - Credentials     │                   │
│  └─────────────────────┘      └─────────────────────┘                   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Migration Steps

```
Phase 1: Infrastructure Setup
├── Create GCP project
├── Enable Cloud SQL, Functions, Storage, Auth
├── Set up VPC and security rules
└── Configure CI/CD (Cloud Build)

Phase 2: Database Migration
├── Export Supabase PostgreSQL dump
├── Import to Cloud SQL
├── Verify schema and data integrity
├── Set up connection pooling

Phase 3: Storage Migration
├── Export Supabase storage buckets
├── Upload to Cloud Storage
├── Update audio file URLs
├── Configure CDN

Phase 4: Auth Migration
├── Set up Firebase Auth
├── Configure OAuth providers
├── Migrate user accounts
├── Update client auth flow

Phase 5: API Layer
├── Rewrite Edge Functions as Cloud Functions
├── Implement REST API endpoints
├── Add authentication middleware
├── Set up rate limiting

Phase 6: Real-time Features
├── Implement Pub/Sub for sync
├── Or use Firestore for real-time updates
├── Update client subscriptions
```

---

## Data Model Translations

### TypeScript → Swift Codable

```typescript
// Current TypeScript (src/types/database.ts)
interface User {
  id: string;
  email: string;
  first_name?: string;
  last_name?: string;
  display_name?: string;
  avatar_url?: string;
  timezone?: string;
  preferred_language: string;
  onboarding_completed: boolean;
  created_at: string;
  updated_at: string;
}
```

```swift
// Swift Equivalent
struct User: Codable, Identifiable, Sendable {
    let id: String
    let email: String
    var firstName: String?
    var lastName: String?
    var displayName: String?
    var avatarURL: URL?
    var timezone: String?
    var preferredLanguage: String
    var onboardingCompleted: Bool
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, email, timezone
        case firstName = "first_name"
        case lastName = "last_name"
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case preferredLanguage = "preferred_language"
        case onboardingCompleted = "onboarding_completed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

### All Core Models

```swift
// MARK: - Subscription
struct Subscription: Codable, Identifiable {
    let id: String
    let userId: String
    var planType: PlanType
    var status: SubscriptionStatus
    var trialStart: Date?
    var trialEnd: Date?
    var currentPeriodStart: Date
    var currentPeriodEnd: Date
    var stripeCustomerId: String?

    enum PlanType: String, Codable {
        case freeTrial = "free_trial"
        case monthly
        case yearly
    }

    enum SubscriptionStatus: String, Codable {
        case active, cancelled, pastDue = "past_due", expired, trialing
    }

    var trialDaysRemaining: Int {
        guard let trialEnd else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: trialEnd).day ?? 0
    }
}

// MARK: - Session
struct UserSession: Codable, Identifiable {
    let id: String
    let userId: String
    let sessionStart: Date
    var sessionEnd: Date?
    var durationMinutes: Int?
    var sessionType: SessionType
    var soundsPlayed: [SessionSound]
    var deviceInfo: DeviceInfo
    var completed: Bool

    enum SessionType: String, Codable {
        case meditation, sleep, focus, custom
    }
}

// MARK: - Sound
struct SoundMetadata: Codable, Identifiable {
    let id: String
    var title: String
    var description: String?
    let categoryId: String
    var duration: Int
    var fileURL: URL
    var filePath: String
    var isPremium: Bool
    var isActive: Bool
    var tags: [String]
    var metadata: [String: AnyCodable]
}

// MARK: - Custom Sound Session (Mixer)
struct CustomSoundSession: Codable, Identifiable {
    let id: String
    let userId: String
    var title: String
    var tracksConfig: TracksConfig
    let createdAt: Date
    var updatedAt: Date

    struct TracksConfig: Codable {
        var tracks: [MixerTrack]
        var masterVolume: Float
    }

    struct MixerTrack: Codable, Identifiable {
        let id: String
        var title: String
        var fileURL: URL
        var volume: Float  // 0-100
        var pan: Float?    // -100 to 100
        var effects: AudioEffects?
    }
}

// MARK: - Favorite
struct UserFavorite: Codable, Identifiable {
    let id: String
    let userId: String
    let soundId: String
    var title: String
    var description: String?
    let dateAdded: Date
    var lastUsed: Date?
    var useCount: Int
    var tracks: [MixerTrack]?
}
```

---

## State Management Translation

### React Context → SwiftUI Observable

```typescript
// Current: src/contexts/AuthContext.tsx
export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const signIn = async (email: string, password: string) => { ... };
  const signOut = async () => { ... };

  return (
    <AuthContext.Provider value={{ user, isLoading, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}
```

```swift
// Swift Equivalent
@MainActor
@Observable
final class AuthManager {
    private(set) var user: User?
    private(set) var isLoading = true

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        Task { await checkSession() }
    }

    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        user = try await authService.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await authService.signOut()
        user = nil
    }

    private func checkSession() async {
        defer { isLoading = false }
        user = try? await authService.getCurrentUser()
    }
}

// Usage in SwiftUI
@main
struct AWAVEApp: App {
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
        }
    }
}

struct ContentView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        if auth.isLoading {
            LoadingView()
        } else if let user = auth.user {
            MainTabView(user: user)
        } else {
            AuthView()
        }
    }
}
```

### React Query → Custom Cache

```typescript
// Current: Uses @tanstack/react-query
const { data: sounds, isLoading } = useQuery({
  queryKey: ['sounds', categoryId],
  queryFn: () => fetchSounds(categoryId),
  staleTime: 5 * 60 * 1000,
});
```

```swift
// Swift: Actor-based cache
actor DataCache {
    private var cache: [String: CacheEntry] = [:]
    private let staleTime: TimeInterval = 5 * 60

    struct CacheEntry {
        let data: Any
        let timestamp: Date
    }

    func get<T>(_ key: String) -> T? {
        guard let entry = cache[key],
              Date().timeIntervalSince(entry.timestamp) < staleTime,
              let data = entry.data as? T else {
            return nil
        }
        return data
    }

    func set<T>(_ key: String, data: T) {
        cache[key] = CacheEntry(data: data, timestamp: Date())
    }
}

// ViewModel with caching
@MainActor
@Observable
final class SoundsViewModel {
    private(set) var sounds: [SoundMetadata] = []
    private(set) var isLoading = false

    private let soundService: SoundServiceProtocol
    private let cache = DataCache()

    func fetchSounds(categoryId: String) async {
        let cacheKey = "sounds-\(categoryId)"

        if let cached: [SoundMetadata] = await cache.get(cacheKey) {
            sounds = cached
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            sounds = try await soundService.getSounds(categoryId: categoryId)
            await cache.set(cacheKey, data: sounds)
        } catch {
            // Handle error
        }
    }
}
```

### Custom Hooks → Swift Extensions & Property Wrappers

```typescript
// Current: src/hooks/useTrialStatus.ts
export function useTrialStatus() {
  const [trialDaysRemaining, setTrialDaysRemaining] = useState(0);
  const [isTrialActive, setIsTrialActive] = useState(false);

  useEffect(() => {
    // Calculate trial status
  }, [subscription]);

  return { trialDaysRemaining, isTrialActive };
}
```

```swift
// Swift: Computed on the model
extension Subscription {
    var isTrialActive: Bool {
        status == .trialing && trialDaysRemaining > 0
    }
}

// Or as a property wrapper for complex logic
@propertyWrapper
struct TrialStatus: DynamicProperty {
    @Environment(SubscriptionManager.self) private var subscriptionManager

    var wrappedValue: (daysRemaining: Int, isActive: Bool) {
        let sub = subscriptionManager.subscription
        return (sub?.trialDaysRemaining ?? 0, sub?.isTrialActive ?? false)
    }
}

// Usage
struct TrialBanner: View {
    @TrialStatus var trial

    var body: some View {
        if trial.isActive {
            Text("\(trial.daysRemaining) days left in trial")
        }
    }
}
```

---

## Risk Analysis & Mitigation

### High-Risk Areas

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Audio Engine Complexity** | High | Wrap existing Obj-C first, rewrite later |
| **Subscription Migration** | High | Run parallel systems during transition |
| **User Data Migration** | High | Export/import with validation scripts |
| **Real-time Sync** | Medium | Start with polling, add WebSocket later |
| **OAuth Token Migration** | Medium | Force re-auth for migrated users |

### Technical Debt to Address

```
Current Issues (from codebase analysis):
├── Tests disabled (need XCTest suite)
├── Some audio features mocked
├── Performance monitoring limited
├── TurboModule experimental

Migration Opportunities:
├── Fix test coverage from start
├── Implement proper observability
├── Add Instruments profiling
├── Use Swift Concurrency properly
```

---

## Migration Phases

### Phase 0: Foundation (Week 0)

```
□ Set up Xcode project
□ Configure Swift Package Manager
□ Set up CI/CD (Xcode Cloud or Fastlane)
□ Create project structure (feature-based)
□ Add SwiftLint + SwiftFormat
□ Configure signing & provisioning
```

### Phase 1: Core Infrastructure (Week 1-2)

```
□ Implement networking layer (URLSession + async/await)
□ Create Codable models from TypeScript interfaces
□ Build authentication service
□ Wrap AWAVEAudioModule in Swift
□ Set up UserDefaults + Keychain storage
```

### Phase 2: Authentication (Week 2-3)

```
□ Email/password auth screen
□ OAuth (Google + Apple)
□ Session persistence
□ Onboarding slides
□ Email verification
```

### Phase 3: Main Navigation (Week 3-4)

```
□ Tab bar with 4 categories
□ Category screens (Schlafen, Ruhe, ImFluss)
□ Profile screen (basic)
□ Navigation structure
```

### Phase 4: Audio Player (Week 4-6)

```
□ Basic playback UI
□ Full audio player screen
□ Effects controls
□ Multi-track mixing
□ Background playback
□ Lock screen controls
```

### Phase 5: Content & Discovery (Week 6-8)

```
□ Library screen
□ Search functionality
□ Category detail (Klangwelten)
□ Favorites system
□ Session tracking
```

### Phase 6: Monetization (Week 8-10)

```
□ StoreKit 2 integration
□ Subscription screen
□ Premium content gating
□ Trial management
□ Downsell flows
□ Receipt validation
```

### Phase 7: Polish (Week 10-12)

```
□ Stats dashboard
□ Settings screens
□ Notifications
□ Offline support
□ SOS feature
□ Legal screens
```

### Phase 8: Backend Migration (Parallel)

```
□ Set up Google Cloud infrastructure
□ Migrate database (Cloud SQL)
□ Migrate storage (Cloud Storage)
□ Implement Cloud Functions API
□ Switch iOS app to new backend
□ Deprecate Supabase
```

---

## Next Steps

1. **Set up Xcode project** with proper structure
2. **Create Swift models** from TypeScript interfaces
3. **Build networking layer** to talk to Supabase (temporary)
4. **Wrap AWAVEAudioModule** in Swift observable
5. **Start with AuthScreen** → MainTabs → ProfileScreen

Ready to begin Phase 0?
