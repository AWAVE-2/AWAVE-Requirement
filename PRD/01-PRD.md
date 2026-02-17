# AWAVE - Product Requirements Document
## Native iOS App (Swift / SwiftUI)

**App ID:** `de.awave.app`
**Current Version:** 1.3
**Platform:** Native iOS (Swift 6.2, SwiftUI, **iOS 26.2+**). Backend: Firebase (Auth, Firestore, Storage). No Supabase.
**Android baseline:** The current iOS app is the **North Star for the Android app**. See [docs/ANDROID-NORDSTERN.md](../../ANDROID-NORDSTERN.md) for implemented features and tech mapping.
**Legacy reference:** Original product concept from Capacitor 6 (Web Audio API); content/tiers described there inform this PRD.

---

## 1. Product Overview

AWAVE is a German-language wellness and meditation app that combines guided meditation sessions, customizable multi-phase audio sessions, real-time binaural beat / frequency synthesis, colored noise generation, and a content-rich library of 100+ pre-built sessions. The app serves three user tiers (Demo, User/Subscriber, Pro) with in-app subscription monetization.

### 1.1 Core Value Proposition

- Customizable multi-phase meditation sessions with layered audio (voice, music, nature, sound effects, synthesized frequencies, colored noise)
- AI-driven symptom-to-session matching via keyword analysis (German language)
- Real-time brainwave entrainment through binaural beats, isochronic tones, and proprietary "NeuroFlow" noise processing
- 4 voice actors (Franca, Flo, Marion, Corinna) for guided content
- Professional session editor for Pro users

### 1.2 Target Audience

- German-speaking users seeking meditation, relaxation, sleep support, stress management, and brainwave entrainment
- Users range from casual (Demo/Subscriber) to advanced (Pro) session creators

---

## 2. User Tiers & Monetization

### 2.1 Demo Mode
- **Access:** Free, no account required
- **Limitation:** 10-minute session timer per app launch
- **Timer behavior:** Counts down globally, pauses during store view, resets on app restart (`location.reload()`)
- **UI indicator:** Demo header with visible countdown timer
- **Upsell:** Prompted at timer expiration and via info menu

### 2.2 User Mode (Subscriber)
- **Access:** Via in-app subscription (StoreKit 2 for native iOS)
- **Subscription plans:**
  - Yearly: `awave_premium_sparpaket` (Apple) - 7.50 EUR/month
  - Monthly: `awave_premium_flexibel` (Apple) - 12.99 EUR/month
- **Features:** Full session playback without time limit, all meditation topics, all soundscapes, favorites
- **Restrictions:** No session editor access, no export

### 2.3 Pro Mode
- **Access:** Unlocked via SHA256 password system (entered through symptom finder input field)
- **Features:** Full session editor, multi-phase creation, session import/export/share, all User features
- **Note for iOS rewrite:** Consider whether to keep password-based Pro unlock or migrate to a separate IAP tier

### 2.4 Subscription Management
- **Verification:** Receipt verification via `cordova-plugin-purchase` (replace with StoreKit 2 native)
- **Restore purchases:** Available on iOS via dedicated button
- **Offline handling:** Network check before restore; subscription state cached in localStorage (UserDefaults equivalent)
- **State persistence keys:**
  - `user`: "demo" | "user" | "pro"
  - `currentSubscription`: null | "monthly" | "yearly"
  - `purchaseDate`: ISO date string

---

## 3. Navigation Architecture

### 3.1 Screen Map

```
Splash Screen
    |
    v
Content Loader (asset check)
    |
    v
Main Menu ─────────────────────────────────────┐
    |                                           |
    ├── Meditation Topics                       ├── Soundscapes
    |       |                                   |       |
    |       ├── Topic Selection (10 topics)     |       ├── Music (8 genres)
    |       ├── Symptom Finder (text input)     |       ├── Nature (18+ sounds)
    |       |       └── SOS Screen              |       ├── Frequency (brainwave)
    |       └── User Session Config             |       └── Noise (6 colors)
    |               └── Live Player             |               └── Live Player
    |                       └── After Session   |
    |                                           |
    ├── Favorites                               |
    |       └── Load/Delete sessions            |
    |                                           |
    ├── Info Menu                               |
    |       ├── Preparation Guide               |
    |       ├── Brainwave Info                  |
    |       ├── Terms / Privacy / Imprint       |
    |       ├── Disclaimer                      |
    |       ├── Support                         |
    |       └── Version / Upgrade               |
    |                                           |
    └── [Pro Only] Session Editor ──────────────┘
            ├── New Session
            ├── Session Overview (phase list)
            └── Phase Editor
                    ├── Text Editor
                    ├── Music Editor
                    ├── Nature Editor
                    ├── Frequency Editor
                    ├── Noise Editor
                    └── Sound Editor
```

### 3.2 Navigation Behavior
- **History:** Simple prev/curr page tracking (2-level back navigation)
- **Background theme:** Dynamic body background based on selected topic (CSS class)
- **Header modes:** Demo (with timer), User/Pro (standard), Live (minimal)
- **Menu bar:** Context-sensitive with 7 states (Menu, Session, Editor, Favorites, Meditation, Soundscapes, Info)
- **Footer:** 3 modes (Live, Session Editor, Phase Editor)
- **Transitions:** jQuery fadeIn/fadeOut (use SwiftUI transitions)

---

## 4. Meditation Topics

### 4.1 Topic Categories
Each topic triggers an auto-generated multi-phase session:

| Topic ID     | Display Name (DE)  | Background Theme |
|--------------|--------------------|--------------------|
| `sleep`      | Schlafen           | sleep              |
| `stress`     | Stress             | stress             |
| `depression` | Depression         | depression         |
| `healing`    | Heilung            | healing            |
| `dream`      | Traum              | dream              |
| `obe`        | Astralreise        | obe                |
| `trauma`     | Trauma             | trauma             |
| `meditation` | Meditation         | meditation         |
| `belief`     | Glaube             | belief             |
| `angry`      | Wut                | angry              |
| `fantasy`    | Fantasiereise      | (varies)           |

### 4.2 Session Generation
- Sessions are generated algorithmically based on topic
- Generator in `generator-session-content.js` selects appropriate content from the database
- Each generated session consists of multiple phases with text, music, nature, frequency, and noise layers
- "Fantasy" topic generates with a "Neue Fantasiereise generieren" button label

### 4.3 Symptom Finder
- Text input field accepting free-form German text
- Default placeholder: "Ich kann nicht Einschlafen"
- Keyword matching engine (`generator-keywords.js`, 2,655 lines)
- Keyword categories: sleep, stress, depression, healing, dream, OBE, trauma, meditation, belief, anger, problem, SOS
- **SOS Detection:** Matches self-harm/crisis keywords and displays emergency resources screen
- **Pro unlock:** SHA256 password check integrated into symptom input field

---

## 5. Content Library

### 5.1 Text Content (Guided Audio)
62+ guided audio items across 10 categories:

| Category           | Count | Mix Type | Description |
|--------------------|-------|----------|-------------|
| Einleitung         | 8     | one      | Session introductions |
| Atemtechnik        | 8     | one      | Breathing techniques |
| Korperentspannung  | 6     | one      | Body relaxation (PMR, bodyscan, autosuggestion) |
| Gedankenstille     | 3     | one      | Thought silence / mindfulness |
| Traumreise         | 10    | one      | Fantasy journeys, lucid dreaming, astral |
| Hypnose            | 7     | one      | Hypnosis inductions |
| Affirmation        | 11    | loop     | Looping affirmations (40-100 repetitions) |
| Affektregulation   | 7     | one      | Emotional regulation techniques |
| Ende               | 2     | one      | Session closures |
| Stille             | 1     | mute     | Silence placeholder |

**Voice variants:** Each text item has pre-recorded audio in 4 voices with different durations:
- Flo, Franca, Marion, Corinna
- Duration ranges: 40s to 1,145s per item per voice

### 5.2 Music Content
8 genres: Ambient, Chillout, Choir, Deep, Guitar, LoFi, Piano, Zen

### 5.3 Nature Sounds
18+ categories: Beach, Bolt, Cave, Fire, Forest, Jungle, Lake, Night, Ocean, Rain, Storm, Thunder, Waterfall, etc.

### 5.4 Frequency Content (Synthesized)
Brainwave bands: Alpha (8-13Hz), Beta (13-38Hz), Delta (1-4Hz), Gamma (38+Hz), Theta (4-8Hz)

### 5.5 Colored Noise
6 standard colors + 6 "NeuroFlow" sync variants:
- Standard: White, Pink, Brown, Grey, Blue, Violet
- NeuroFlow: WhiteSync, PinkSync, BrownSync, GreySync, BlueSync, VioletSync

### 5.6 Sound Effects
Discrete sounds with interval playback: alarm/bell sounds ("Wecker"), ambient effects

---

## 6. Session Structure

### 6.1 Session Config (Index 0)
```
id: "AWAVE-Session"
name: String (user-defined or auto-generated)
infoText: String
duration: Int (total seconds, computed from phases)
timer: Int (countdown during playback)
voice: "Franca" | "Flo" | "Marion" | "Corinna"
version: 1.3
livePhase: Int (current playing phase index)
topic: String (theme identifier)
type: "guided" | "soundscape"
enableFreq: Bool
```

### 6.2 Phase Structure
Each phase (index 1..N) contains:
```
name: String
h1: String (category heading)
h2: String (content heading)
duration: Int (seconds, min 60s)
sleepCheck: Bool

text:      { content, volume, fadeIn, fadeOut, delayInc, delayMin, delayMax, interval, mix }
music:     { content, volume, fadeIn, fadeOut, mix }
nature:    { content, volume, fadeIn, fadeOut, mix }
sound:     { content, volume, interval }
noise:     { content, volume, fadeIn, fadeOut, startBalance, targetBalance, [ctx devices] }
frequency: { content, volume, fadeIn, fadeOut, direction, startPulsFreq, targetPulsFreq, startRootFreq, targetRootFreq, [ctx devices] }
```

### 6.3 Content Mix Types
- `"one"`: Play once, duration locked to audio length
- `"loop"`: Repeat with configurable delay intervals
- `"mute"`: No audio (silence placeholder)

---

## 7. Audio Engine Requirements

### 7.1 Multi-Track Playback
5 simultaneous audio tracks:
1. **Text** - Guided voice audio (AVAudioPlayer)
2. **Music** - Background music (AVAudioPlayer, looping with crossfade)
3. **Nature** - Nature sounds (AVAudioPlayer, seamless loop with 2s overlap)
4. **Sound** - Discrete sound effects with interval timing
5. **Demo** - Preview audio for voice selection

### 7.2 Volume & Fading
- Per-track volume control (0-100 scale, mapped to 0.0-1.0)
- Per-track fade-in and fade-out with configurable duration
- Fading uses interval-based linear ramping (100ms intervals)
- Cross-phase continuity: if adjacent phases share the same content, audio continues without restart
- Volume adjustment during fading skips remaining fade-in

### 7.3 Frequency Synthesis (AVAudioEngine)
12 frequency generation modes:

| Mode | Channels | Description |
|------|----------|-------------|
| root | 1 mono | Pure root frequency tone |
| binaural | 2 stereo | L/R frequency difference creates beat |
| monaural | 2 merged mono | Two tones merged to mono |
| isochronic | 1 pulsed | Root frequency with on/off pulsing |
| bilateral | 1 stereo pulsed | Isochronic alternating L/R |
| molateral | 4 merged stereo | Monaural alternating L/R |
| shepard | N mono | Multi-octave Shepard tone (infinite sweep) |
| isoflow | N pulsed | Shepard + isochronic pulsing |
| bilawave | N stereo pulsed | Shepard + bilateral pulsing |
| binawave | 2N stereo | Shepard + binaural (2 Shepard generators) |
| monawave | 2N mono | Shepard + monaural |
| flowlateral | 4N stereo | Shepard + molateral (4 Shepard generators) |

**Parameters:**
- Pulse frequency: 1-40 Hz (start and target, swept linearly)
- Root frequency: Selectable from predefined array (33Hz to 1111Hz)
- Shepard width: 20 seconds per cycle
- Sweep direction: up / down / consistent
- All oscillators: sine wave type
- Per-oscillator gain with type-specific volume levels (0.025 to 0.125)
- >8Hz pulse auto-downgrades: isochronic->monaural, bilateral->molateral, isoflow->monawave, bilawave->flowlateral

### 7.4 Colored Noise Generation
- 6 noise colors loaded from pre-recorded MP3 files (white, pink, brown, grey, blue, violet)
- Seamless looping via `audio.loop = true`
- **NeuroFlow (Sync) variants:** Add biquad notch filter chain per channel
  - 3 filter channels per ear (L/R)
  - Filter Q: 2
  - Frequency sweep ranges: [1, 250, 1000] to [2000, 7000, 20000] Hz
  - Sync interval: 12 seconds
  - L/R balance sweep: -1.0 (100% Left) to 1.0 (100% Right) with 0.2 step increments
- Splitter -> Filter chain -> Pan gain -> Merger -> Master gain -> Output

### 7.5 Playback Controls
- Play / Pause toggle
- Session restart
- Session exit (with confirmation dialog)
- Phase skip (auto-advance at phase end)
- Live content swap (change music/nature/freq/noise during playback via overlay)
- Keep-awake during playback
- Portrait-only orientation lock
- App pause/resume handling (pause on background, show notice on resume)

---

## 8. Session Editor (Pro Only)

### 8.1 Session-Level Controls
- Session name (editable)
- Phase list (add, delete, reorder via up/down)
- Total duration display (computed)
- Import session (Base64 JSON file, `.awave` extension)
- Export/Share session (Base64 JSON via native share sheet)

### 8.2 Phase-Level Controls
Each phase has 6 collapsible editor sections:

**Text Editor:**
- Content picker (category -> item, 62+ items)
- Voice selector (cycle through 4 voices)
- Volume slider
- Delay controls (min/max with increment, for loop content)
- Fade in/out controls
- Sleep check toggle

**Music Editor:**
- Content picker (category -> item)
- Volume slider
- Fade in/out controls

**Nature Editor:**
- Content picker (category -> item)
- Volume slider
- Fade in/out controls

**Frequency Editor:**
- Content picker (12 frequency modes)
- Volume slider
- Shepard direction (up/down)
- Pulse frequency start/target (1-40 Hz, with band label)
- Root frequency start/target (from predefined array)
- Fade in/out controls

**Noise Editor:**
- Content picker (6 standard + 6 NeuroFlow)
- Volume slider
- NeuroFlow balance start/target (-1.0 to 1.0)
- Fade in/out controls

**Sound Editor:**
- Content picker
- Volume slider
- Interval: "start" | "end" | numeric minutes (1-N)

### 8.3 Phase Timer
- Duration in seconds (min 60s)
- Non-linear increment steps: 1min, 5min, 10min, 15min
- Locked when text content mix is "one" (duration = audio length)
- Validation: fadeIn + fadeOut must not exceed duration

### 8.4 Preview
- Per-phase audio preview (all tracks simultaneously)
- Auto-exit preview at phase duration
- Mute/unmute toggle
- Voice preview on user session config screen

---

## 9. Favorites System

### 9.1 Storage
- Sessions stored as JSON array in localStorage (migrate to UserDefaults or SwiftData)
- Key: `favorites`
- Deep copy on save (prevents reference mutation)

### 9.2 Operations
- Save current session with user-defined name (auto-date placeholder)
- Duplicate name handling: appends "(2)", "(3)", etc.
- Load favorite (replaces current session)
- Delete individual favorite (with confirmation)
- Delete all favorites (with confirmation)
- Topic reset to "user" on save

---

## 10. Platform Requirements

### 10.1 Device Capabilities
- Screen orientation: Portrait only (locked)
- Keep-awake: Screen stays on during session playback
- Status bar: Custom styling
- Keyboard: Managed for text input fields

### 10.2 Background/Foreground Handling
- **App goes to background during session:** Pause playback, show "Session Pausiert" dialog on resume
- **Recommendation dialog:** "Keep device plugged in" before long sessions

### 10.3 File Handling
- Import: Read `.awave` files (Base64-encoded JSON)
- Export: Write to cache, share via native share sheet
- Version compatibility check on import

### 10.4 Network
- Required only for subscription restore
- Offline mode: Full functionality except purchase/restore operations

---

## 11. Localization

### 11.1 Current State
- App is **German only** (all UI text, content, keywords)
- All strings are hardcoded in JS/HTML
- Content database contains German meditation scripts

### 11.2 Recommendation for iOS Rewrite
- Extract all UI strings to Localizable.strings
- Keep content database separate from UI localization
- Design data models to support future multi-language content

---

## 12. Non-Functional Requirements

### 12.1 Performance
- Audio synthesis must run in real-time without glitches
- Multi-oscillator Shepard tones can require 10+ simultaneous oscillators
- Timer precision: 50ms polling interval with 1-second tick sync
- Fade intervals: 95-100ms with drift correction

### 12.2 Battery
- Keep-awake during sessions is mandatory
- Recommend charging for long sessions
- Audio synthesis is CPU-intensive; optimize with Accelerate/vDSP where possible

### 12.3 Accessibility
- Current app has no accessibility support
- iOS rewrite should add: VoiceOver labels, Dynamic Type, sufficient contrast ratios

### 12.4 Data Migration
- Consider migration path from web/Capacitor version favorites (localStorage JSON) to native storage
