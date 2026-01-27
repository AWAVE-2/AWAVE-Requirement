# AWAVE - Requirements Summary & Implementation Roadmap
## Complete Requirements Package Overview

---

## Document Index

| # | Document | Purpose |
|---|----------|---------|
| 01 | `01-PRD.md` | Full product requirements (what to build) |
| 02 | `02-FEATURE-SPECS.md` | Screen-by-screen specifications (how it behaves) |
| 03 | `03-DATA-MODELS.swift` | Swift data models (how data is structured) |
| 04 | `04-AUDIO-ARCHITECTURE.md` | Audio engine design (how sound works) |
| 05 | `05-REQUIREMENTS-SUMMARY.md` | This document (overview + roadmap) |

---

## 1. Quantified Scope

### Codebase Metrics (Current JS App)
| Metric | Value |
|--------|-------|
| Total JavaScript | ~14,750 lines |
| Source files | 21 JS files |
| Content database entries | 100+ items |
| Navigation screens | 25+ unique displays |
| Audio synthesis modes | 12 frequency types + 12 noise types |
| Keyword database | 2,655 lines (German) |
| Voices | 4 (Franca, Flo, Marion, Corinna) |

### Estimated iOS Scope
| Component | Estimated Swift Files | Complexity |
|-----------|----------------------|------------|
| Data models | 3-5 files | Low |
| Navigation / Views | 15-20 files | Medium |
| Audio engine | 5-8 files | High |
| Session generator | 3-4 files | Medium |
| Keyword matcher | 2-3 files | Low |
| Content database | 2-3 files (or JSON) | Low |
| Subscription/IAP | 2-3 files | Medium |
| Persistence | 2-3 files | Low |
| Utilities | 3-5 files | Low |
| **Total** | **~35-55 files** | |

---

## 2. Risk Assessment

### High Risk
| Risk | Impact | Mitigation |
|------|--------|------------|
| Frequency synthesis accuracy | Core feature broken | Build POC first, validate with headphones |
| Shepard tone complexity | Audible artifacts | Dedicate focused sprint, consider AudioKit fallback |
| iOS audio session management | Crashes/interruptions | Test exhaustively across iOS versions |
| NeuroFlow filter precision | Wrong spatial effect | A/B test against web version |

### Medium Risk
| Risk | Impact | Mitigation |
|------|--------|------------|
| Cross-phase audio continuity | Audible gaps/pops | Pre-load next phase, use crossfade buffers |
| Timer precision drift | Session timing off | Use `CADisplayLink` or `DispatchSourceTimer` |
| Content database migration | Missing/broken sessions | Automated validation against JS database |
| StoreKit 2 migration | Purchase flow breaks | Test with sandbox accounts early |

### Low Risk
| Risk | Impact | Mitigation |
|------|--------|------------|
| UI/navigation rewrite | Visual differences | SwiftUI previews for rapid iteration |
| Favorites persistence | Data loss | Simple Codable + UserDefaults/SwiftData |
| File import/export | Format incompatibility | Maintain Base64 JSON format for compatibility |

---

## 3. Architecture Decisions to Make

### ADR-01: State Management
**Options:**
- A) `@Observable` + `@Environment` (iOS 17+)
- B) `ObservableObject` + `@StateObject` (iOS 14+)
- C) TCA (The Composable Architecture)

**Recommendation:** Option A if targeting iOS 17+. The session model is complex with nested mutable state, and `@Observable` handles this cleanly.

### ADR-02: Persistence Layer
**Options:**
- A) `UserDefaults` + `Codable` (simple, matches current localStorage approach)
- B) SwiftData (modern, queryable)
- C) Core Data (mature, overkill for this use case)

**Recommendation:** Option A for initial version. Favorites are stored as a single JSON blob currently; UserDefaults handles this directly. Migrate to SwiftData later if query needs arise.

### ADR-03: Audio Framework
**Options:**
- A) Pure `AVAudioEngine` + `AVAudioSourceNode`
- B) AudioKit (wraps AVAudioEngine with higher-level APIs)
- C) Hybrid (AVAudioEngine for file playback, AudioKit for synthesis)

**Recommendation:** Option A. See `04-AUDIO-ARCHITECTURE.md` for detailed rationale.

### ADR-04: Content Database Format
**Options:**
- A) Swift source code (static arrays, like current JS `const` definitions)
- B) JSON bundle (loaded at runtime)
- C) SQLite / SwiftData

**Recommendation:** Option B. JSON is portable, testable, and separates content from code. Load into Swift structs via `Codable` at launch.

### ADR-05: Minimum iOS Version
**Options:**
- A) iOS 17+ (latest SwiftUI, `@Observable`, StoreKit 2 views)
- B) iOS 16+ (broader reach, slightly more boilerplate)

**Recommendation:** Option A. The app is a ground-up rewrite. iOS 17 covers 80%+ of active devices and provides the best developer experience.

### ADR-06: Pro Mode Unlock Mechanism
**Options:**
- A) Keep SHA256 password system (parity with current app)
- B) Separate IAP tier for Pro
- C) Feature flag / remote config

**Recommendation:** Decision needed from product owner. The current password-based system is non-standard. If Pro is intended for internal/partner use, keep it. If it's a monetization tier, migrate to IAP.

---

## 4. Implementation Phases

### Phase 1: Foundation
- Project setup (Xcode, SwiftUI app lifecycle)
- Data models (Swift structs from `03-DATA-MODELS.swift`)
- Content database (JSON conversion from `content-database.js`)
- Navigation skeleton (all screens with placeholder content)
- User tier management (UserDefaults persistence)
- Basic UI theme system (topic backgrounds)

### Phase 2: Core Audio
- AVAudioEngine setup and audio session configuration
- File playback engine (Text, Music, Nature, Sound players)
- Volume control and fading system
- Phase timer and session lifecycle
- Basic live player UI

### Phase 3: Content & Navigation
- Meditation topic selection and session generation
- Symptom finder with keyword matching
- SOS screen
- Soundscapes browser
- User session config screen
- Favorites (save, load, delete, import, export)

### Phase 4: Frequency Synthesis
- Root frequency oscillator
- Binaural beats (L/R channel separation)
- Monaural beats (merged channels)
- Isochronic tones (gain pulsing)
- Bilateral tones (alternating L/R pulsing)
- Molateral (monaural + bilateral)
- Linear frequency sweep

### Phase 5: Advanced Audio
- Shepard tone multi-oscillator synthesis
- Shepard-based variants (isoflow, bilawave, binawave, monawave, flowlateral)
- Colored noise playback (standard)
- NeuroFlow noise processing (notch filters, balance sweep)
- Cross-phase audio continuity
- Live content swapping during playback

### Phase 6: Session Editor (Pro)
- Phase list management (add, delete, reorder)
- Text editor (content picker, voice, delay, fade)
- Music/Nature editors (content picker, fade)
- Frequency editor (type, pulse, root, direction, fade)
- Noise editor (type, NeuroFlow balance, fade)
- Sound editor (content, interval)
- Phase preview

### Phase 7: Monetization & Polish
- StoreKit 2 subscription integration
- Demo mode timer
- Restore purchases
- Subscription info display
- App lifecycle handling (background/foreground)
- Accessibility (VoiceOver, Dynamic Type)
- Performance optimization
- Testing

---

## 5. Content Migration Checklist

| Content Type | Count | Source File | Migration Format |
|-------------|-------|-------------|------------------|
| Text (guided) | 62+ items | `content-database.js` | JSON |
| Music | 8 genres, N tracks | `content-database.js` + audio/ | JSON + bundled MP3 |
| Nature | 18+ categories | `content-database.js` + audio/ | JSON + bundled MP3 |
| Sound effects | N items | `content-database.js` + audio/ | JSON + bundled MP3 |
| Noise files | 6 colors | audio/noise/ | Bundled MP3 |
| Topic images | 50+ backgrounds | src/img/topics/ | Asset catalog |
| Category images | 30+ icons | src/img/ | Asset catalog |
| Voice audio | 62 items x 4 voices | audio/ | Bundled MP3 |
| Keywords | 2,655 lines | `generator-keywords.js` | JSON or Swift arrays |
| Session templates | per-topic generators | `generator-session-content.js` | Swift logic |

---

## 6. Quality Criteria

### Functional Parity
- [ ] All 25+ screens navigable
- [ ] All 10 meditation topics generate valid sessions
- [ ] Symptom finder matches keywords correctly
- [ ] SOS detection works for all crisis terms
- [ ] All 12 frequency types produce correct output
- [ ] All 12 noise types (6 standard + 6 NeuroFlow) work
- [ ] 4 voices selectable and play correct audio
- [ ] Session editor creates valid multi-phase sessions
- [ ] Favorites save/load/delete/import/export
- [ ] Demo timer limits session to 10 minutes
- [ ] Subscriptions purchasable and verifiable
- [ ] Session file import/export compatible with existing .awave format

### Audio Quality
- [ ] No audible clicks/pops during phase transitions
- [ ] Binaural beats produce perceptible beat frequency
- [ ] Shepard tones sound continuous (no reset artifacts)
- [ ] Fading is smooth (no stepping)
- [ ] Cross-phase continuity works for matching content
- [ ] NeuroFlow produces spatial audio effect with headphones
- [ ] All audio stops cleanly on session exit

### Performance
- [ ] App launches in < 2 seconds
- [ ] Session starts playing in < 1 second
- [ ] No audio glitches during 2+ hour sessions
- [ ] Battery drain acceptable for background playback
- [ ] Memory stable (no growth over session duration)
