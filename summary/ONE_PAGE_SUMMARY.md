# AWAVE - One Page Summary

## The Product
**AWAVE** is a meditation and sound therapy **native iOS app (Swift/SwiftUI)** that helps users achieve relaxation, focus, and better sleep through multi-track audio, guided sessions, and ambient soundscapes. **The current iOS app is the baseline (North Star) for the Android app.**

## Core Value Proposition
- Multi-track audio mixing with real-time customization (Player, Mixer)
- Category-based sessions (Schlaf, Stress, Im Fluss) with topic-based generation
- Personalized wellness (onboarding, category preference, favorites, session tracking)
- Subscription & 7-day trial with 48h/12h reminders (StoreKit 2, Cloud Functions)
- Offline-capable with session-based content resolution and download cache

## Feature Categories (Implemented in iOS – Feb 2026)

| Domain | Key Features |
|--------|--------------|
| **Audio & Player** | Major Audioplayer, SessionContentMapping, PhasePlayer, Background Audio |
| **Content** | Library, Search Drawer, Klangwelten, Category Screens (Schlaf/Stress/Im Fluss) |
| **User Journey** | Auth (Firebase), Onboarding (Preloader, Consent Toast, Category), Profile, Favorites |
| **Monetization** | StoreKit 2, Trial, Sales Screens, Downsell, 48h/12h reminders |
| **Support** | SOS Drawer, Settings, Legal |

## Documentation
- **Nordstern für Android:** `docs/ANDROID-NORDSTERN.md`
- **Doc index:** `docs/DOCUMENTATION-INDEX.md`
- **Requirements:** `docs/Requirements/` (APP-Feature Description, PRD)
- **Parity backlog (OLD-APP & Web):** `Requirements/APP-Feature Description/Backlog-Parity-OLD-APP-and-Web/README.md`

## Tech Stack (Current)
`Swift 6.2` | `SwiftUI` | `iOS 26.2` | `Firebase (Auth, Firestore, Storage)` | `StoreKit 2`  
No Supabase. No React Native.

## Three Content Pillars (Tabs)
1. **Schlaf (Sleep)** - Sleep-focused soundscapes and guided sessions
2. **Stress (Ruhe)** - Relaxation and stress relief content
3. **Im Fluss (Flow)** - Focus and productivity audio experiences  
Plus **Search** tab (drawer) and **Profile** tab.

---
*Repository: AWAVE2-Swift | Last Updated: February 2026 | iOS = baseline for Android*
