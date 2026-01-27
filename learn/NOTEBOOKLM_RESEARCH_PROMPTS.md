# NotebookLM Deep Research Prompts

> **Purpose**: Tailored research prompts for experienced developers learning iOS
> **Context**: 10 years system design + fullstack → iOS native migration
> **Mode**: Use "Deep Research" toggle for 2026 web-sourced documentation

---

## How to Use These Prompts

1. Open NotebookLM
2. Enable **Deep Research** toggle (browses live web)
3. Copy a prompt into "What would you like to research?"
4. Review synthesized findings
5. Cross-reference with Apple official docs when needed

Each prompt is designed to:
- Skip beginner concepts you already know
- Draw parallels to web/backend patterns
- Focus on iOS-specific paradigms
- Address migration concerns directly

---

## Category 1: Architecture & System Design

*Focus: Mapping high-level design skills to Apple ecosystem*

### Prompt 1: TCA vs Redux Deep Dive

```
Compare The Composable Architecture (TCA) to Redux/Toolkit for a React veteran.
Specifically explain:

1. How state side effects in TCA map to Redux thunks/sagas
2. How testing patterns differ (TCA's TestStore vs Jest mocking)
3. iOS-specific pitfalls like thread safety on @MainActor
4. When to use TCA vs simple @Observable pattern
5. Performance implications for audio apps with frequent state updates

Focus on practical migration: I'm moving a meditation app from React Native + Redux to native Swift.
```

### Prompt 2: Navigation Architecture

```
Analyze the 'Coordinator Pattern' in UIKit versus the new 'NavigationStack' in SwiftUI (iOS 16+).

Compare to:
- React Router v6 nested routes
- Next.js App Router
- Vue Router navigation guards

Address:
1. Deep linking implementation (universal links)
2. Complex user flows (auth → onboarding → main app)
3. Modal presentations and dismissal
4. State preservation during navigation
5. Testing navigation flows

I need to replicate a React Native navigation structure with bottom tabs + stack navigation + modal overlays.
```

### Prompt 3: Dependency Injection in Swift

```
Research dependency injection patterns in Swift for a developer familiar with InversifyJS and NestJS DI.

Compare:
1. Protocol-based DI (manual)
2. Factory library (https://github.com/hmlongco/Factory)
3. Swinject container
4. SwiftUI Environment
5. TCA's @Dependency

Address:
- Testing with mock dependencies
- Scoping (singleton, per-request, per-view)
- Async initialization
- How iOS differs from server-side DI (no request scope)
```

---

## Category 2: The "Mental Model" Shift

*Focus: Deepening understanding of iOS-specific paradigms*

### Prompt 4: Memory Management (ARC vs GC)

```
Create a technical deep dive into Memory Management comparing Swift's Automatic Reference Counting (ARC) to JavaScript's Garbage Collection.

Explain:
1. Why retain cycles happen in iOS but never in JavaScript
2. Concrete examples of retain cycles in closures, delegates, and Combine subscriptions
3. How [weak self] and [unowned self] work at the memory level
4. System-level performance implications (deterministic vs GC pauses)
5. Tools to detect memory issues (Memory Graph Debugger, Instruments Leaks)

I'm coming from 10 years of JavaScript where memory management is automatic. I need to develop the instinct for when to use weak references.
```

### Prompt 5: App Sandbox & Data Persistence

```
Research the iOS 'App Sandbox' security model for a web developer familiar with browser storage.

Compare:
- UserDefaults vs localStorage
- SwiftData/Core Data vs IndexedDB
- Keychain vs sessionStorage (but secure)
- File system access vs browser File API

Address:
1. Background execution limits (OS can kill app anytime)
2. Data eviction policies (when iOS purges caches)
3. App Groups for sharing data between app + extensions
4. iCloud sync capabilities
5. GDPR/privacy implications

I need to port a React Native app that uses AsyncStorage extensively.
```

### Prompt 6: Swift Concurrency Model

```
Explain Swift Concurrency (async/await, actors, structured concurrency) to someone who knows JavaScript Promises and Node.js event loop deeply.

Cover:
1. How Swift Tasks differ from JavaScript Promises
2. Actors vs JavaScript SharedArrayBuffer/Atomics
3. @MainActor vs "main thread" in Node/browser
4. Structured concurrency (TaskGroup) vs Promise.all
5. Cancellation (not built into JS Promises)
6. Sendable protocol (no equivalent in JS)

Address pitfalls:
- Reentrancy in actors
- Priority inversion
- Task leaks (forgetting to await)

I'm building an audio app where concurrency correctness is critical.
```

---

## Category 3: Implementation & Migration

*Focus: Practical migration strategies*

### Prompt 7: Network Layer Migration

```
Provide a step-by-step strategy for migrating a REST-heavy web application to native iOS networking.

Current stack:
- Axios with interceptors
- JWT authentication with refresh tokens
- Request retry logic
- TypeScript interfaces for API responses

Target stack:
- URLSession with async/await
- Swift Codable for JSON
- Same backend API

Address:
1. Creating a type-safe API client in Swift
2. Authentication interceptor pattern
3. Retry logic with exponential backoff
4. Error mapping (HTTP status → Swift errors)
5. Request/response logging
6. Offline queue (like Axios offline mode)
7. File upload/download progress

I'm keeping the same Supabase/PostgreSQL backend, just replacing the client.
```

### Prompt 8: SwiftUI vs UIKit Decision Matrix

```
Evaluate the trade-offs of using SwiftUI versus UIKit for an enterprise-level audio/meditation app in 2026.

Consider:
1. Which UIKit components still lack 1:1 SwiftUI equivalents?
2. Best practices for 'hosting' UIKit views inside SwiftUI hierarchy
3. Performance differences for:
   - Large scrolling lists (1000+ items)
   - Complex animations
   - Audio visualization (waveforms)
   - Custom drawing

Provide decision criteria:
- When to start in SwiftUI and drop to UIKit
- When to start in UIKit and embed SwiftUI
- Hybrid approaches

My app has: bottom tab navigation, complex audio player UI, real-time waveform visualization, and animated meditation timers.
```

### Prompt 9: Supabase to Google Cloud Migration

```
Research migrating a Supabase backend to Google Cloud Platform for an iOS app.

Current Supabase services:
- PostgreSQL database (12 tables)
- GoTrue authentication (email + OAuth)
- Storage (audio files, ~50GB)
- Edge Functions (Deno)
- Real-time subscriptions

Target GCP services:
- Cloud SQL (PostgreSQL)
- Firebase Auth OR Identity Platform
- Cloud Storage
- Cloud Functions
- ???real-time equivalent

Address:
1. Database migration strategy (schema + data)
2. Auth migration (preserving user sessions/tokens)
3. Storage migration (CDN configuration)
4. Edge Functions → Cloud Functions (Deno → Node.js)
5. Real-time alternatives (Firestore, Pub/Sub, custom WebSocket)
6. Cost comparison

I want to self-host for more control while keeping similar developer experience.
```

---

## Category 4: AI-Assisted Development

*Focus: Leveraging AI tools for iOS development*

### Prompt 10: Claude Code for Swift Development

```
Research how to effectively use Claude Code or Cursor specifically for Swift/iOS development.

Focus on:
1. Prompting strategies for:
   - Converting React components to SwiftUI
   - Identifying memory leaks (weak/unowned)
   - Migrating imperative UIKit to declarative SwiftUI
   - Generating Codable models from JSON

2. Limitations:
   - What Swift patterns confuse AI models?
   - When to trust vs verify AI-generated code?
   - Xcode-specific tasks AI can't do

3. Workflow integration:
   - Using AI with Xcode (no native Copilot)
   - Cursor as Xcode alternative (trade-offs)
   - Terminal-based development with Claude Code

I want to accelerate my migration without introducing subtle bugs.
```

### Prompt 11: Core ML Integration

```
Research integrating on-device machine learning (Core ML) for a meditation app.

Use cases:
1. Audio classification (detect ambient noise)
2. Heart rate estimation from camera (stress level)
3. Speech detection (guided meditation cues)
4. Personalized recommendation (user listening patterns)

Address:
1. Pre-trained models vs custom training
2. Model optimization (size, latency)
3. Create ML vs TensorFlow → Core ML conversion
4. Privacy implications (on-device vs cloud)
5. Battery/performance impact

I'm used to TensorFlow.js in the browser—how does Core ML compare?
```

---

## Category 5: Production Readiness

*Focus: Shipping and maintaining iOS apps*

### Prompt 12: Code Signing & Provisioning

```
Demystify iOS code signing and provisioning profiles for a developer who's only dealt with web deployment.

Explain like I understand:
- SSL certificates for HTTPS
- Docker image signing
- npm publish authentication

Cover:
1. Development vs Distribution certificates
2. Provisioning profiles (what they contain, why they expire)
3. App IDs and bundle identifiers
4. Entitlements (capabilities)
5. Automatic vs manual signing
6. Common errors and how to fix them
7. CI/CD signing (Fastlane match, Xcode Cloud)

This is my biggest "black box"—I need to understand it, not just follow tutorials blindly.
```

### Prompt 13: App Store Optimization

```
Research App Store submission and optimization for a meditation app targeting the German-speaking (DACH) market.

Cover:
1. App Review guidelines specific to:
   - Subscription apps
   - Health/wellness category
   - Audio background modes

2. ASO (App Store Optimization):
   - Keyword research for German market
   - Screenshot/preview video best practices
   - Localization requirements

3. Common rejection reasons and how to avoid them

4. In-App Purchase configuration:
   - Auto-renewable subscriptions
   - Free trials
   - Family Sharing
   - StoreKit 2 vs original StoreKit

I'm migrating from React Native where we've already been approved—what changes for native?
```

### Prompt 14: Performance Profiling

```
Create a comprehensive guide to iOS performance profiling for a developer experienced with Chrome DevTools and Node.js profiling.

Map these tools:
- Chrome Performance tab → ???
- Chrome Memory tab → ???
- Node.js --inspect → ???
- Lighthouse → ???

Cover Instruments:
1. Time Profiler (CPU)
2. Allocations (memory)
3. Leaks (retain cycles)
4. Network (HTTP traffic)
5. Core Animation (frame rate)
6. Energy Log (battery)
7. Signposts (custom tracing)

Specific scenarios:
- Profiling audio playback performance
- Finding UI jank during animations
- Memory growth during long meditation sessions
- Network request waterfalls

I need to achieve 60fps consistently during audio visualization.
```

---

## Category 6: Advanced Topics

*Focus: Deep expertise areas*

### Prompt 15: Audio Engine Architecture

```
Research building a professional audio engine for iOS using AVAudioEngine.

Requirements:
- Multi-track playback (8+ simultaneous tracks)
- Real-time effects: reverb, delay, EQ, compression
- Per-track volume and pan
- Crossfade between tracks
- Background playback
- AirPlay/Bluetooth audio routing
- Waveform visualization

Compare to:
- Web Audio API (AudioContext, AudioWorklet)
- howler.js patterns

Address:
1. Audio session configuration
2. Interruption handling (phone calls, Siri)
3. Route changes (headphones unplugged)
4. Buffer management for gapless playback
5. Thread safety (audio render thread)
6. Performance optimization (reduce latency)

I have an existing Objective-C audio module (AWAVEAudioModule) using AVAudioEngine—how do I wrap it in modern Swift?
```

### Prompt 16: Offline-First Architecture

```
Research offline-first architecture patterns for iOS apps.

Requirements:
- Downloaded audio content (50GB+ library)
- Sync user data when online
- Conflict resolution for multi-device
- Background sync

Compare to:
- Service Workers + IndexedDB (web)
- Workbox strategies
- Apollo Client offline

Cover:
1. SwiftData/Core Data for structured data
2. File manager for large media
3. URLSession background configuration
4. Sync algorithms (CRDT, last-write-wins)
5. Queue management for pending operations
6. Storage quotas and cleanup

I need to support meditation sessions that work completely offline, then sync stats when back online.
```

### Prompt 17: Accessibility Deep Dive

```
Research iOS accessibility implementation for a meditation app.

Compare to:
- ARIA labels in web
- screen-reader-only classes
- focus management

Cover:
1. VoiceOver integration
   - Labels, hints, traits
   - Custom actions
   - Rotor navigation

2. Dynamic Type
   - Scaling fonts
   - Layout adjustments
   - Minimum touch targets

3. Reduce Motion
   - Respecting user preference
   - Alternative animations

4. Audio-specific accessibility
   - Audio descriptions
   - Haptic feedback alternatives
   - Voice control

5. Testing accessibility
   - Accessibility Inspector
   - VoiceOver testing
   - Automated audits

German-market specific:
- German VoiceOver pronunciation
- Localized accessibility labels

I need to pass App Store accessibility review and serve users with disabilities properly.
```

---

## Quick Reference: When to Use Each Prompt

| Situation | Prompt # |
|-----------|----------|
| "How does X work in iOS vs web?" | 4, 5, 6 |
| "How do I architect this?" | 1, 2, 3 |
| "How do I migrate this specific thing?" | 7, 8, 9 |
| "How do I use AI effectively?" | 10, 11 |
| "How do I ship this?" | 12, 13 |
| "How do I make this fast?" | 14, 15 |
| "How do I make this work offline?" | 16 |
| "How do I make this accessible?" | 17 |

---

## Pro Tips for NotebookLM

1. **Enable Deep Research** for 2026-current documentation
2. **Follow up** with "Give me code examples" after conceptual answers
3. **Ask for comparisons** to technologies you know
4. **Request trade-off analysis** not just "how to"
5. **Save good responses** to your notebook for reference

---

## Your Biggest Black Boxes

Based on your background, these likely feel most unfamiliar:

1. **Code Signing** (Prompt 12) - No web equivalent
2. **Memory Management** (Prompt 4) - JS is GC'd
3. **Audio Engine** (Prompt 15) - Complex native API
4. **Concurrency Model** (Prompt 6) - Different from JS event loop

Start with these if you're feeling uncertain.
