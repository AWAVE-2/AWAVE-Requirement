# Migration Strategy

## Overview

This document outlines the phased migration from React Native to native iOS with Swift/SwiftUI and Google Cloud infrastructure.

---

## Migration Phases

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Migration Timeline                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Phase 1          Phase 2          Phase 3          Phase 4          Phase 5│
│  Foundation       Core Features    Premium          Polish           Launch │
│                                                                              │
│  ▓▓▓▓▓▓▓▓▓▓▓     ▓▓▓▓▓▓▓▓▓▓▓     ▓▓▓▓▓▓▓▓▓▓▓     ▓▓▓▓▓▓▓▓▓▓▓     ▓▓▓▓▓▓│
│                                                                              │
│  - GCP Setup      - Audio Engine   - Subscription   - Performance   - Beta  │
│  - SwiftUI Base   - Player UI      - StoreKit 2     - Animations    - Store │
│  - Auth           - Library        - Paywall        - Accessibility - Market│
│  - Data Layer     - Search         - Analytics      - Localization         │
│                   - Categories     - Push Notifs    - Widget               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Foundation

### Goals
- Set up Google Cloud infrastructure
- Establish SwiftUI app architecture
- Implement authentication flow
- Create data layer with SwiftData + Firestore

### Tasks

#### 1.1 GCP Infrastructure Setup
```bash
# Create GCP project
gcloud projects create awave-ios-prod --name="AWAVE iOS Production"
gcloud config set project awave-ios-prod

# Enable required APIs
gcloud services enable \
  firestore.googleapis.com \
  storage.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudcdn.googleapis.com \
  bigquery.googleapis.com \
  aiplatform.googleapis.com

# Initialize Firebase
firebase init --project awave-ios-prod
```

#### 1.2 Data Migration
```sql
-- Export from Supabase PostgreSQL
COPY (
  SELECT id, name, description, category, subcategory,
         duration, file_url, thumbnail_url, tags, is_premium,
         play_count, created_at
  FROM sound_metadata
) TO '/tmp/sounds.csv' CSV HEADER;

-- Import to Firestore via Cloud Function
// See functions/admin/importSounds.ts
```

#### 1.3 Xcode Project Setup
```
AWAVE/
├── AWAVE.xcodeproj
├── Packages/
│   ├── AWAVECore/
│   ├── AWAVEDomain/
│   ├── AWAVEData/
│   └── AWAVEAudio/
├── AWAVE/
│   ├── App/
│   ├── Features/
│   └── Shared/
└── AWAVETests/
```

#### 1.4 Authentication Implementation
| React Native | Swift/SwiftUI |
|--------------|---------------|
| Supabase Auth | Firebase Auth |
| AsyncStorage tokens | Keychain |
| useAuth hook | AuthService actor |

```swift
// AuthService.swift
public actor AuthService {
    public static let shared = AuthService()

    @Published public private(set) var currentUser: User?

    public func signInWithApple() async throws -> User
    public func signInWithGoogle() async throws -> User
    public func signInWithEmail(email: String, password: String) async throws -> User
    public func signOut() async throws
}
```

### Deliverables
- [ ] GCP project with Firestore, Storage, Functions
- [ ] Xcode project with modular architecture
- [ ] Firebase Auth integration (Apple, Google, Email)
- [ ] SwiftData models + Firestore sync
- [ ] Basic navigation structure

### Success Metrics
- Auth flow working end-to-end
- Data syncing between local and cloud
- App launching without crashes

---

## Phase 2: Core Features

### Goals
- Build the multi-track audio engine
- Implement player UI with waveform visualization
- Create library and search functionality
- Add category navigation

### Tasks

#### 2.1 Audio Engine
| React Native | Swift |
|--------------|-------|
| react-native-track-player | AVFoundation |
| expo-audio | AVAudioEngine |
| JavaScript audio mixing | Native multi-track mixer |

Key improvements:
- Native multi-track playback (7 simultaneous tracks)
- Procedural sound generation (waves, rain, noise)
- Real-time waveform visualization with Metal
- Background audio with Now Playing integration

#### 2.2 Player UI Migration

```
React Native Components          SwiftUI Views
─────────────────────────────────────────────────
<MajorAudioPlayer />       →    PlayerView
├── <MixerTrackList />     →    ├── TrackListView
├── <WaveformDisplay />    →    ├── WaveformView (Canvas)
├── <PlaybackControls />   →    ├── PlaybackControls
└── <VolumeSliders />      →    └── VolumeSliderView
```

#### 2.3 Library & Search
- SwiftData queries for local-first search
- Firestore full-text search fallback
- Search suggestions with recent queries
- Filter by category, tags, premium status

#### 2.4 Category Screens
| German | English | SwiftUI Route |
|--------|---------|---------------|
| Schlaf | Sleep | `.category(.sleep)` |
| Ruhe | Relax | `.category(.relax)` |
| Im Fluss | Flow | `.category(.flow)` |
| Fokus | Focus | `.category(.focus)` |

### Deliverables
- [ ] Multi-track audio engine with AVFoundation
- [ ] Player view with waveform visualization
- [ ] Library view with favorites
- [ ] Search with filters
- [ ] Category navigation
- [ ] Mini player strip

### Success Metrics
- Audio playback latency < 50ms
- Smooth 60fps waveform animation
- Search results < 100ms

---

## Phase 3: Premium Features

### Goals
- Implement subscription with StoreKit 2
- Build paywall and sales screens
- Add push notifications
- Integrate analytics

### Tasks

#### 3.1 StoreKit 2 Integration
```swift
// SubscriptionService.swift
public actor SubscriptionService {
    public func getProducts() async throws -> [Product]
    public func purchase(_ product: Product) async throws -> Transaction
    public func restorePurchases() async throws -> [Transaction]
    public func checkEntitlement() async -> Bool
}
```

Products:
- `awave.premium.monthly` - Monthly subscription
- `awave.premium.yearly` - Yearly subscription (with free trial)

#### 3.2 Paywall Design
```
┌─────────────────────────────────────┐
│         Unlock Full Access          │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  🎧 3000+ Premium Sounds    │   │
│  │  🔄 Unlimited Mixing        │   │
│  │  📱 Offline Access          │   │
│  │  🚫 No Ads                  │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌────────────┐ ┌────────────┐     │
│  │  Monthly   │ │  Yearly    │     │
│  │  €9.99/mo  │ │  €59.99/yr │     │
│  │            │ │  SAVE 50%  │     │
│  └────────────┘ └────────────┘     │
│                                     │
│  [    Start 7-Day Free Trial    ]  │
│                                     │
│  Restore Purchases                  │
└─────────────────────────────────────┘
```

#### 3.3 Push Notifications
- Firebase Cloud Messaging
- Local notifications for reminders
- Rich notifications with sound previews

#### 3.4 Analytics
```swift
// AnalyticsService.swift
public struct AnalyticsService {
    func track(_ event: AnalyticsEvent)
    func setUserProperty(_ key: String, value: String)
    func logScreen(_ name: String)
}

enum AnalyticsEvent {
    case appOpen
    case playbackStarted(soundId: String, category: String)
    case playbackCompleted(duration: Int)
    case subscriptionStarted(productId: String)
    case searchPerformed(query: String, resultCount: Int)
    // ...
}
```

### Deliverables
- [ ] StoreKit 2 subscription flow
- [ ] Paywall with A/B testing
- [ ] Receipt validation via Cloud Functions
- [ ] Push notification infrastructure
- [ ] Firebase Analytics + BigQuery export

### Success Metrics
- Trial-to-paid conversion > 40%
- Subscription retention > 70% at 3 months
- Push opt-in rate > 60%

---

## Phase 4: Polish

### Goals
- Performance optimization
- Accessibility compliance
- Localization (German primary)
- iOS exclusive features

### Tasks

#### 4.1 Performance Optimization
| Metric | Target | Approach |
|--------|--------|----------|
| Cold start | < 1.5s | Lazy loading, async init |
| Memory | < 100MB | Image caching, audio cleanup |
| Battery | < 3%/hr | Efficient audio, reduce updates |
| Scroll | 60fps | LazyVStack, prefetching |

#### 4.2 Accessibility
- Full VoiceOver support
- Dynamic Type (all text sizes)
- Reduce Motion alternatives
- High contrast support
- Audio descriptions for sounds

#### 4.3 Localization
Primary: German (de)
Secondary: English (en)

```swift
// Localizable.xcstrings structure
{
  "tab.home": {
    "localizations": {
      "de": { "stringUnit": { "value": "Entdecken" } },
      "en": { "stringUnit": { "value": "Discover" } }
    }
  }
}
```

#### 4.4 iOS Exclusive Features

**Widgets**
```swift
// AWAVEWidget.swift
struct AWAVEWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "QuickPlay") { entry in
            QuickPlayWidgetView(entry: entry)
        }
        .configurationDisplayName("Quick Play")
        .description("Start your favorite mix instantly")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

**Shortcuts**
- "Start Sleep Session"
- "Play My Mix"
- "Track Meditation"

**Focus Filters**
- Sleep Focus: Auto-enable sleep sounds
- Work Focus: Auto-enable focus sounds

### Deliverables
- [ ] Performance benchmarks met
- [ ] Full accessibility audit passed
- [ ] German/English localization complete
- [ ] Widget implementation
- [ ] Siri Shortcuts integration
- [ ] Focus mode integration

### Success Metrics
- Accessibility audit score > 95%
- Performance benchmarks met
- Widget adoption > 20%

---

## Phase 5: Launch

### Goals
- Beta testing with TestFlight
- App Store submission
- Marketing preparation
- Monitoring setup

### Tasks

#### 5.1 TestFlight Beta
- Internal testing (2 weeks)
- External beta (4 weeks, 1000 users)
- Crash monitoring with Crashlytics
- Feedback collection via TestFlight

#### 5.2 App Store Preparation
```
App Store Connect Setup:
├── App Information
│   ├── Name: AWAVE - Meditation & Sleep
│   ├── Subtitle: Personalized Sound Mixing
│   ├── Category: Health & Fitness
│   └── Privacy Policy URL
├── Screenshots (6.7", 6.5", 5.5")
├── App Preview Videos
├── Description (4000 chars)
├── Keywords (100 chars)
├── What's New
└── Review Notes
```

#### 5.3 Monitoring & Alerts
```yaml
# Cloud Monitoring alerts
alerts:
  - name: high_error_rate
    condition: error_rate > 1%
    notification: pagerduty

  - name: api_latency
    condition: p99_latency > 500ms
    notification: slack

  - name: low_conversion
    condition: trial_conversion < 30%
    notification: email
```

#### 5.4 Launch Checklist
- [ ] App Store listing complete
- [ ] Privacy policy updated
- [ ] Terms of service updated
- [ ] Support email configured
- [ ] Social media assets ready
- [ ] Press kit prepared
- [ ] Monitoring dashboards live
- [ ] On-call rotation scheduled
- [ ] Rollback plan documented

### Success Metrics
- Beta crash-free rate > 99.5%
- App Store approval on first submission
- Launch week DAU > 1000

---

## Risk Mitigation

### Technical Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Audio engine complexity | High | Early prototyping, fallback to simpler mixer |
| Data migration errors | High | Dry runs, validation scripts, rollback plan |
| Performance regressions | Medium | Continuous benchmarking, profiling |
| StoreKit edge cases | Medium | Extensive sandbox testing |

### Business Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| User migration friction | High | Feature parity, data migration, incentives |
| Revenue gap during migration | Medium | Parallel operation, gradual rollout |
| Negative reviews | Medium | Beta testing, quick response team |

---

## Resource Requirements

### Team Composition
- 2 iOS Engineers (Swift/SwiftUI)
- 1 Backend Engineer (GCP/Firebase)
- 1 Designer (iOS HIG expertise)
- 0.5 QA Engineer
- 0.5 Product Manager

### Infrastructure Costs (Monthly)
| Service | Estimate |
|---------|----------|
| Firestore | $100-300 |
| Cloud Storage | $50-100 |
| Cloud Functions | $20-50 |
| Cloud CDN | $20-50 |
| BigQuery | $30-100 |
| Firebase Auth | Free tier |
| **Total** | **$220-600** |

---

## Success Criteria

### Phase Completion Gates

| Phase | Gate Criteria |
|-------|---------------|
| Phase 1 | Auth working, data syncing, app stable |
| Phase 2 | Audio playback, core UI complete, < 5 P1 bugs |
| Phase 3 | Subscriptions working, 50% beta retention |
| Phase 4 | Performance targets met, accessibility audit passed |
| Phase 5 | App Store approved, monitoring live |

### Overall Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| App Store rating | 4.8+ | App Store Connect |
| Crash-free rate | > 99.9% | Crashlytics |
| User retention (D7) | > 40% | Firebase Analytics |
| Trial conversion | > 40% | Revenue analytics |
| NPS score | > 50 | In-app survey |
