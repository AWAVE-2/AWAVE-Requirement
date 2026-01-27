# APP-Feature Description Summary

## Overview

The `/APP-Feature Description` directory contains comprehensive documentation for all AWAVE features, organized into 24+ feature modules with 203+ markdown files.

---

## Documentation Structure

```
APP-Feature Description/
│
├── Core Documentation
│   ├── FEATURE_MAPPING.md        # Maps code → features
│   ├── MIGRATION_SUMMARY.md      # Legacy app feature status
│   ├── STRUCTURE_SUMMARY.md      # Doc organization guide
│   └── FEATURE_TEMPLATE.md       # Template for new features
│
├── Feature Directories (24+)
│   └── Each contains:
│       ├── README.md             # Feature overview
│       ├── requirements.md       # Functional requirements
│       ├── technical-spec.md     # Technical implementation
│       ├── user-flows.md         # User interaction flows
│       ├── components.md         # UI components
│       └── services.md           # Backend services
│
└── Category Organization
    ├── User & Auth (3 features)
    ├── Content & Nav (4 features)
    ├── Audio & Playback (6 features)
    ├── User Features (3 features)
    ├── Support & Monetization (5 features)
    └── Technical (3 features)
```

---

## Feature Inventory

### 1. Authentication & Account Management

**Purpose**: User identity, authentication, account lifecycle

| Aspect | Details |
|--------|---------|
| Auth Methods | Email/password, Google OAuth, Apple Sign-In |
| Token Storage | AsyncStorage (encrypted), auto-refresh |
| Session | JWT with 1-hour expiry, refresh tokens |
| Account Actions | Register, login, logout, delete, password reset |

**Key Files**: `Auth and Account Managment/`

---

### 2. User Onboarding

**Purpose**: First-time user experience, preference capture

```
Onboarding Flow:
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│ Welcome  │──▶│ Category │──▶│ Notif    │──▶│ Ready    │
│ Screen   │   │ Selection│   │ Permission│   │ to Start │
└──────────┘   └──────────┘   └──────────┘   └──────────┘
```

**Data Captured**: Preferred categories, notification preference, goals

---

### 3. Navigation System

**Purpose**: App navigation structure, routing

| Element | Implementation |
|---------|----------------|
| Tab Bar | Bottom tabs: Home, Library, Profile |
| Stack Nav | Per-tab navigation stacks |
| Modals | Search, Player, Settings |
| Deep Links | `awave://category/sleep`, `awave://sound/{id}` |

---

### 4. Category Screens

**Purpose**: Content discovery by category

| Screen | German | Content Focus |
|--------|--------|---------------|
| Sleep | Schlaf | Bedtime sounds, sleep stories |
| Relax | Ruhe | Calm, peaceful sounds |
| Flow | Im Fluss | Gentle energy, creativity |
| Klangwelten | - | Sound world exploration |

**Components**: Category header, sound grid, featured section, filters

---

### 5. Major Audioplayer (Core Feature)

**Purpose**: Multi-track audio mixing and playback

```
┌─────────────────────────────────────────────────────────────┐
│                    MAJOR AUDIOPLAYER                         │
│                                                              │
│  Architecture:                                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  Multiplayer System (always multi-track)                ││
│  │  ├── TrackMixer 1 ──┐                                   ││
│  │  ├── TrackMixer 2 ──┼──▶ MasterMixer ──▶ Output        ││
│  │  ├── ...            │                                   ││
│  │  └── TrackMixer 7 ──┘                                   ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│  Features:                                                   │
│  • Up to 7 simultaneous tracks                              │
│  • Per-track volume control                                 │
│  • Add/remove tracks during playback                        │
│  • Animated waveform visualization                          │
│  • Session state persistence (freeze/resume)                │
│  • Background playback support                              │
└─────────────────────────────────────────────────────────────┘
```

**Key Insight**: This is AWAVE's core differentiator. The entire playback system is designed around multi-track mixing, not single-file playback.

---

### 6. MiniPlayer Strip

**Purpose**: Persistent playback controls when not in full player

| State | Display |
|-------|---------|
| Playing | Thumbnail, title, pause button, progress |
| Paused | Thumbnail, title, play button |
| Loading | Skeleton with spinner |

**Behavior**: Tap opens full player, swipe up expands, always visible when audio active

---

### 7. Library

**Purpose**: User's personal sound collection

| Section | Content |
|---------|---------|
| Favorites | User-saved sounds and mixes |
| Recent | Recently played items |
| Downloads | Offline-available sounds |
| Custom Mixes | User-created sound combinations |

---

### 8. Search Drawer

**Purpose**: Sound discovery and search

```
Search Features:
├── Text search (name, description, tags)
├── Category filter
├── Premium/Free filter
├── Recent searches
├── Search suggestions
└── SOS keyword detection (crisis support trigger)
```

**Performance**: < 50ms response using cached metadata

---

### 9. Session-Based Async Download

**Purpose**: On-demand audio file downloading

```
Download Strategy:
┌──────────────────────────────────────────────────────────┐
│                                                          │
│   App Start ──▶ Load Metadata (< 30s for 3000+ files)   │
│                        │                                 │
│                        ▼                                 │
│   User Selects ──▶ Check Cache ──▶ Hit? ──▶ Play       │
│                        │                                 │
│                        ▼ Miss                            │
│                   Download ──▶ Cache ──▶ Play           │
│                        │                                 │
│                        ▼ Fail                            │
│                   Stream (fallback)                      │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

**Cache Management**: LRU eviction, 2GB max, WiFi-only option

---

### 10. Favorite Functionality

**Purpose**: Save and organize preferred sounds

| Action | Behavior |
|--------|----------|
| Add | Heart icon tap, instant feedback, sync to cloud |
| Remove | Un-heart, confirmation optional |
| Sync | Offline queue, reconcile on reconnect |
| Organization | By type (sound vs mix), by date added |

---

### 11. Profile View

**Purpose**: User identity and statistics

```
Profile Sections:
├── Avatar & Name
├── Subscription Status
├── Quick Stats (minutes, sessions, streak)
├── Achievements/Badges
└── Settings Link
```

---

### 12. Stats & Analytics

**Purpose**: User engagement tracking and display

| Metric | Description |
|--------|-------------|
| Total Minutes | Cumulative listening time |
| Sessions | Count of completed sessions |
| Streak | Consecutive days active |
| Category Split | Time per category |
| Weekly Trend | 7-day activity graph |

---

### 13. Session Tracking

**Purpose**: Record and analyze playback sessions

```
Session Lifecycle:
Start ──▶ Active ──▶ End
  │         │         │
  ▼         ▼         ▼
Record:   Track:    Calculate:
• Mix     • Duration • Completed?
• Time    • Pauses   • Rating prompt
• User    • Adjusts  • Sync to cloud
```

---

### 14. SOS Screen

**Purpose**: Crisis support resources

| Element | Content |
|---------|---------|
| Hotlines | Country-specific crisis numbers |
| Resources | Mental health websites, apps |
| Quick Actions | Tap-to-call, tap-to-text |
| Trigger | Search keywords, direct navigation |

**Important**: This feature prioritizes user safety over engagement metrics.

---

### 15. Support

**Purpose**: Help and customer service

- FAQ / Help Center
- Contact form
- Bug reporting
- Feature requests

---

### 16. Subscription & Payment

**Purpose**: Monetization and premium access

```
Subscription Tiers:
┌────────────────────┬────────────────────┐
│       FREE         │      PREMIUM       │
├────────────────────┼────────────────────┤
│ 50 basic sounds    │ 3000+ sounds       │
│ Single track       │ 7-track mixing     │
│ 10 min sessions    │ Unlimited          │
│ No offline         │ Full offline       │
│ No custom mixes    │ Save custom mixes  │
│ Ads                │ Ad-free            │
└────────────────────┴────────────────────┘

Pricing: €9.99/month or €59.99/year (7-day trial)
```

---

### 17. Sales Screens

**Purpose**: Conversion optimization

| Screen | Trigger |
|--------|---------|
| Soft Paywall | Access premium sound |
| Hard Paywall | Trial expiration |
| Upgrade Prompt | Feature limitation hit |
| Trial Ending | 1 day before expiry |

---

### 18. Settings & Preferences

**Purpose**: App configuration

| Category | Settings |
|----------|----------|
| Playback | Default volume, auto-stop timer |
| Downloads | WiFi-only, cache limit |
| Notifications | Types, frequency, quiet hours |
| Privacy | Analytics consent, data export |
| Account | Email, password, delete |

---

### 19. APIs and Business Logic

**Purpose**: Backend integration layer

```
API Architecture:
┌─────────────────────────────────────────────────────┐
│                  Supabase Client                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │    Auth     │  │   Database  │  │   Storage   │ │
│  │   Service   │  │   Service   │  │   Service   │ │
│  └─────────────┘  └─────────────┘  └─────────────┘ │
│         │                │                │         │
│         └────────────────┼────────────────┘         │
│                          ▼                          │
│                   React Hooks                       │
│         useAuth, useSounds, useSession, etc.       │
└─────────────────────────────────────────────────────┘
```

---

### 20. Databases

**Purpose**: Data persistence architecture

| Layer | Technology | Purpose |
|-------|------------|---------|
| Cloud | Supabase PostgreSQL | Source of truth |
| Local | AsyncStorage | Preferences, cache |
| Files | React Native FS | Audio file cache |

**Sync Strategy**: Offline queue with automatic reconciliation

---

### 21. Background Audio

**Purpose**: Audio continues when app backgrounded

| Platform | Implementation |
|----------|----------------|
| iOS | Audio background mode, Now Playing info |
| Android | Foreground service, notification controls |

---

### 22. Visual Effects & Notifications

**Purpose**: Animations and user engagement

| Effect | Usage |
|--------|-------|
| Waveform | Player visualization |
| Floating Orbs | Ambient decoration |
| Transitions | Screen changes |
| Haptics | Button feedback |

---

### 23. Offline Support

**Purpose**: Full functionality without network

```
Offline Capabilities:
├── Play downloaded sounds ✓
├── Create/edit mixes ✓
├── Track sessions (queued) ✓
├── Toggle favorites (queued) ✓
├── Download new sounds ✗
├── Sync to cloud ✗ (until online)
└── Stream sounds ✗
```

---

### 24. Styles and UI

**Purpose**: Design system and visual consistency

| Element | Specification |
|---------|---------------|
| Colors | Dark theme, purple/blue accent |
| Typography | SF Pro (iOS), Roboto (Android) |
| Spacing | 8px grid system |
| Corners | 16px radius for cards |
| Shadows | Subtle elevation hierarchy |

---

## Migration Status (from Legacy Apps)

### From OLD-APP (V.1) - 14 Missing Features

| Priority | Feature | Status |
|----------|---------|--------|
| High | Multi-Phase Session System | Partial |
| High | Frequency Generation | Not implemented |
| High | Noise Generation | Not implemented |
| Medium | Symptom Finder | Not implemented |
| Medium | Live Volume Control | Partial |
| Low | Session Import/Export | Not implemented |

### From React APP (Lovable) - 12 Missing Features

| Priority | Feature | Status |
|----------|---------|--------|
| High | Category Tile Selector | Partial |
| High | Custom Sound Library | Partial |
| Medium | Recommendation Section | Not implemented |
| Medium | Trial Management UI | Partial |
| Low | Social Proof Section | Not implemented |

---

## Key Observations

### Documentation Strengths
1. **Consistency** - Every feature follows the same structure
2. **Completeness** - Requirements, tech spec, flows all present
3. **Traceability** - FEATURE_MAPPING links code to docs
4. **Migration tracking** - Clear legacy feature status

### Documentation Gaps
1. **No API contracts** - Endpoints not formally specified
2. **No test specs** - Testing strategy undocumented
3. **No ADRs** - Architecture decisions not recorded
4. **No runbooks** - Operational procedures missing

### Feature Insights
1. **Core differentiator is solid** - Multi-track mixing well-designed
2. **Audio system is mature** - Background, offline, session tracking
3. **Monetization is standard** - Freemium with soft/hard paywalls
4. **Safety considered** - SOS feature shows user care

---

## Implications for Transformation

The feature documentation reveals:

1. **What to preserve**: Core audio mixing, session tracking, favorites
2. **What to enhance**: Performance, platform integration, AI recommendations
3. **What to add**: iOS widgets, Shortcuts, HealthKit, visionOS readiness
4. **What to migrate**: Database schema → Firestore, Auth → Firebase

This analysis directly informed the `/trans` documentation strategy.
