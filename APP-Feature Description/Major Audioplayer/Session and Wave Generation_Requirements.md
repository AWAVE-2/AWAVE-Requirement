# AWAVE SwiftUI App - Technical Requirements & Architecture

**Version:** 1.0
**Date:** January 2026
**Audience:** Internal Development Team

---

## 1. Executive Summary

AWAVE is a meditation and soundscape application that algorithmically generates unique audio sessions by combining multiple audio layers: voice narration (text), music, nature sounds, frequency generators (oscillators), colored noise, and sound effects. The core innovation lies in the **Session Generator** which creates near-infinite session variations through randomized content selection and real-time audio synthesis.

### Key Technical Challenges
- Real-time multi-layer audio mixing with independent volume/fade controls
- Web Audio API-style oscillator synthesis for binaural/isochronic frequencies
- Phase-based session architecture with dynamic duration adjustment
- Algorithmic session generation with content database integration
- Future: Biofeedback sensor integration for adaptive sessions

---

## 2. System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWAVE iOS App                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   SwiftUI    │  │   Session    │  │    Audio     │  │   Content    │     │
│  │    Views     │◄─┤  Generator   │◄─┤    Engine    │◄─┤   Database   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                 │                 │                 │             │
│         ▼                 ▼                 ▼                 ▼             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Navigation  │  │    Phase     │  │  AVAudio +   │  │    Remote    │     │
│  │  Controller  │  │   Manager    │  │  Core Audio  │  │     CDN      │     │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘     │
├─────────────────────────────────────────────────────────────────────────────┤
│                         Future: Sensor Integration                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │     EEG      │  │     PPG      │  │    Gyros     │  │     REM      │     │
│  │  (Brainwave) │  │ (Heart Rate) │  │  (Movement)  │  │  (Eye Track) │     │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Audio Module Architecture

### 3.1 Audio Layer Stack

The system uses **6 independent audio channels** that mix together:

| Layer | ID | Source Type | Behavior | SwiftUI Equivalent |
|-------|-----|-------------|----------|-------------------|
| **Text** | `textAudio` | MP3 files | Single/Loop playback | `AVAudioPlayerNode` |
| **Music** | `musicAudio` | MP3 files | Continuous, crossfade between phases | `AVAudioPlayerNode` |
| **Nature** | `natureAudio` | MP3 files | Looping with self-crossfade | `AVAudioPlayerNode` |
| **Sound** | `soundAudio` | MP3 files | Interval-based triggers (bells, etc.) | `AVAudioPlayerNode` |
| **Frequency** | Oscillator | Generated | Web Audio API oscillators | `AVAudioSourceNode` (custom) |
| **Noise** | WAV + Filter | Hybrid | Sample + filter modulation | `AVAudioSourceNode` + `AVAudioUnitEQ` |

### 3.2 Audio Signal Flow (Per Channel)

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Source │───►│  Gain   │───►│  Fade   │───►│ Channel │───►│ Master  │───► Output
│  (File/ │    │ Control │    │ In/Out  │    │ Merger  │    │ Volume  │
│  Osc)   │    │         │    │         │    │  (L/R)  │    │         │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
```

### 3.3 Frequency Generator Types

The frequency system supports **12 distinct generation modes**:

#### Basic Types
| Type | Description | Oscillator Config |
|------|-------------|-------------------|
| **Root** | Single carrier frequency | `Osc[1] = RootFreq` |
| **Isochronic** | Pulsing on/off stereo | `Osc[1] = RootFreq` + Pulse Gain |
| **Bilateral** | Alternating L/R channels | `Osc[1] = RootFreq` + L/R Pulse |
| **Binaural** | Different freq per ear | `Osc[1] = Root - (Pulse/2)`, `Osc[2] = Root + (Pulse/2)` |
| **Monaural** | Two freqs same channel | Same as Binaural, merged |
| **Molateral** | Monaural + Bilateral | Combined routing |

#### Shepard Tone Variants (Frequency Sweep)
| Type | Description |
|------|-------------|
| **Shepard** | Continuous ascending/descending illusion |
| **Isoflow** | Shepard + Isochronic pulsing |
| **Bilawave** | Shepard + Bilateral alternation |
| **Binawave** | Shepard + Binaural beats |
| **Monawave** | Shepard + Monaural beats |
| **Flowlateral** | Shepard + Molateral |

#### Oscillator Math
```swift
// Binaural example
let rootFreq: Float = 200.0  // Hz (carrier)
let pulseFreq: Float = 10.0  // Hz (beat frequency)

let leftChannelFreq = rootFreq - (pulseFreq / 2)   // 195 Hz
let rightChannelFreq = rootFreq + (pulseFreq / 2)  // 205 Hz
// Brain perceives 10 Hz "beat" difference
```

### 3.4 Noise Generator Types

| Type | Source | Processing |
|------|--------|------------|
| **White** | `white.mp3` | Direct playback |
| **WhiteSync** | `white.mp3` | + Notch filter sweep (L/R offset) |
| **Pink** | `pink.mp3` | Direct playback |
| **PinkSync** | `pink.mp3` | + Notch filter sweep |
| **Brown** | `brown.mp3` | Direct playback |
| **BrownSync** | `brown.mp3` | + Notch filter sweep |
| **Grey** | `grey.mp3` | Direct playback |
| **Blue** | `blue.mp3` | Direct playback |
| **Violet** | `violet.mp3` | Direct playback |

#### Sync Noise Processing
```
WAV Sample → Channel Splitter → Notch Filter[L] → Channel Merger → Output
                              → Notch Filter[R] →

Filter Loop: 6s sweep Start→Target, 6s sweep Target→Start (offset L/R)
```

---

## 4. Session Structure

### 4.1 Session Types

| Type | Text Layer | Use Case |
|------|------------|----------|
| **Guided Meditation** | Voice narration present | Meditation, Hypnosis, Sleep guidance |
| **Klangwelt (Soundscape)** | No text | Ambient soundscapes for focus/relaxation |

### 4.2 Phase Architecture

Sessions consist of multiple **phases**, each with independent audio configurations:

```
SESSION
├── Phase 0 (Intro)
│   ├── text: "Einleitung.mp3"
│   ├── music: "Piano_10.mp3"
│   ├── nature: "Wald.mp3"
│   ├── frequency: Oscillator (Alpha 10Hz)
│   ├── noise: "white.mp3"
│   └── sound: "Glocke.mp3" (at start)
│
├── Phase 1 (Body)
│   ├── text: [Random Affirmations A8, A2, A7...]
│   ├── music: "Piano_4.mp3"
│   ├── nature: "Wald.mp3" (continues)
│   ├── frequency: Oscillator (Theta sweep)
│   ├── noise: "white.mp3"
│   └── sound: "Glocke.mp3" (at transition)
│
├── Phase N...
│
└── Phase X (Outro)
    ├── text: "Ende.mp3"
    ├── music: "ZenGarden_99.mp3"
    └── sound: "Glocke.mp3" (at end)
```

### 4.3 Phase Timing Rules

#### Text Player Modes
| Mode | Behavior |
|------|----------|
| `one` | Single audio file, length = phase duration |
| `loop` | Multiple files from pool, with pauses, until phase ends |

#### Pause Calculation (Loop Mode)
```swift
// Affirmation pause = audio length * multiplier
let pauseDuration = currentAudioLength * pauseMultiplier
// Pause increases progressively: delayMin → delayMax with delayInc
```

#### Phase Duration Adjustment Cases (CASE 1)
When user changes session timer, phases adjust proportionally:

| Scenario | Action |
|----------|--------|
| Phase > Audio | Self-crossfade loop |
| Phase < Audio | Fade-out at phase boundary |
| Phase = Audio | Direct playback |

### 4.4 Live Content Modification

During playback, certain changes trigger specific behaviors:

| Change | Effect |
|--------|--------|
| Text change | Restart `startTextPlayer(phase)` |
| Music change | Restart `startMusicPlayer(phase)` |
| Nature change | Restart `startNaturePlayer(phase)` |
| Frequency change | Full session restart |
| Noise change | Full session restart |
| Sound change | Full session restart |
| Timer change | Full session restart |
| Single-phase session | Full session restart |

---

## 5. Session Generator Algorithm

### 5.1 Generation Flow

```
User Input (Topic + Settings)
         │
         ▼
┌─────────────────────────────┐
│  1. Select Session Template │  (based on category: Sleep, Anxiety, etc.)
│     - Define phase sequence │
│     - Set phase purposes    │
└─────────────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│  2. For Each Phase:         │
│     - Random text from pool │
│     - Random music genre    │
│     - Random nature sound   │
│     - Appropriate frequency │
│     - Optional noise        │
│     - Sound triggers        │
└─────────────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│  3. Apply Voice Selection   │
│     - Adjust durations      │
│     - Generate file paths   │
└─────────────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│  4. Calculate Total Time    │
│     - Sum phase durations   │
│     - Allow user adjustment │
└─────────────────────────────┘
```

### 5.2 File Path Generation (`getAudioSrc`)

```swift
func getAudioSrc(dbItem: ContentItem, phase: Int) -> String {
    switch dbItem.type {
    case .nature, .noise, .sound:
        return "../path/\(dbItem.filename).mp3"

    case .text:
        let voiceName = session.voice
        if dbItem.files.count == 1 {
            return "../audio/text/\(dbItem.path)/\(voiceName)_\(dbItem.name).mp3"
        } else {
            // Random selection with 2/3 exclusion rule
            let randomIndex = getWeightedRandom(dbItem.files, excludeRecent: 2/3)
            return "../audio/text/\(dbItem.path)/\(voiceName)_\(dbItem.name)_\(randomIndex).mp3"
        }

    case .music:
        let randomIndex = getWeightedRandom(dbItem.files, excludeRecent: 2/3)
        return "../audio/music/\(dbItem.genre)/\(dbItem.genre)_\(randomIndex).mp3"
    }
}
```

### 5.3 Content Selection Rules (Example: Anxiety)

```
USER SELECTS: "Anxiety" + "Sitting"
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│ MANDATORY: At least 1 of 4 Primary Exercises:               │
│   - Tresorübung (Vault Exercise)                           │
│   - Laptop der Erinnerung (Laptop of Memory)               │
│   - Innerer sicherer Ort (Inner Safe Place)                │
│   - Angstlösung (Anxiety Resolution)                       │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│ COMBINATION PHASES (Different Categories):                  │
│   - Body relaxation (Bodyscan, PMR, Autosugestion)         │
│   - Breathing (Atem-Achtsamkeit, 4-7-8, Bienenatmung)      │
│   - Mindfulness (Gedankenleere, Goldener Faden)            │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│ INTRO/OUTRO based on position:                              │
│   - Sitting → "Mentalübung im Sitzen"                       │
│   - Lying → "Mentalübung im Liegen"                        │
│   - Hypnosis module → "Hypnoseauflösung"                   │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│ FREQUENCY: CONTRAINDICATED FOR ANXIETY                      │
│   - No frequency generation for anxiety sessions           │
│   - Warning required for: Epilepsy, U18, Pregnancy, etc.   │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. Data Models

### 6.1 Session Model

```swift
struct Session: Codable, Identifiable {
    let id: UUID
    var type: SessionType  // .guided, .soundscape
    var category: String   // "sleep", "anxiety", "meditation"
    var voice: String      // Speaker name
    var duration: TimeInterval
    var phases: [Phase]
    var enableFrequency: Bool
    var savedAt: Date?
}

enum SessionType: String, Codable {
    case guided = "guided"
    case soundscape = "soundscape"
}
```

### 6.2 Phase Model

```swift
struct Phase: Codable, Identifiable {
    let id: UUID
    var duration: TimeInterval
    var timer: TimeInterval  // Remaining time

    var text: TextConfig
    var music: MusicConfig
    var nature: NatureConfig
    var frequency: FrequencyConfig
    var noise: NoiseConfig
    var sound: SoundConfig
}

struct TextConfig: Codable {
    var content: String      // Reference to content-database item
    var mix: TextMix         // .one, .loop
    var delayMin: Double
    var delayMax: Double
    var delayInc: Double
    var volume: Float
    var fadeIn: TimeInterval
    var fadeOut: TimeInterval
}

enum TextMix: String, Codable {
    case one = "one"
    case loop = "loop"
}

struct MusicConfig: Codable {
    var content: String      // "noMusic" or genre reference
    var volume: Float
    var fadeIn: TimeInterval
    var fadeOut: TimeInterval
}

struct NatureConfig: Codable {
    var content: String
    var volume: Float
    var fadeIn: TimeInterval
    var fadeOut: TimeInterval
}

struct FrequencyConfig: Codable {
    var content: String      // "noFrequency" or type
    var type: FrequencyType
    var rootFreq: Float
    var pulseFreq: Float
    var sweepStart: Float?
    var sweepEnd: Float?
    var sweepDuration: TimeInterval?
    var volume: Float
}

enum FrequencyType: String, Codable {
    case root, isochronic, bilateral, binaural, monaural, molateral
    case shepard, isoflow, bilawave, binawave, monawave, flowlateral
}

struct NoiseConfig: Codable {
    var content: String      // "noNoise", "white", "whiteSync", etc.
    var volume: Float
}

struct SoundConfig: Codable {
    var content: String
    var interval: SoundInterval
    var volume: Float
}

enum SoundInterval: String, Codable {
    case start = "start"
    case end = "end"
    case startAndEnd = "startAndEnd"
    case interval = "interval"  // With numeric value
    case off = "off"
}
```

### 6.3 Content Database Item

```swift
struct ContentItem: Codable, Identifiable {
    let id: String
    var type: ContentType
    var category: String
    var name: String
    var path: String
    var files: [[Any]]       // File tracking for random selection
    var duration: [String: TimeInterval]  // Per voice durations
    var tags: [String]
    var contraindications: [String]
}

enum ContentType: String, Codable {
    case text, music, nature, noise, sound
}
```

---

## 7. SwiftUI Implementation Considerations

### 7.1 Audio Engine Architecture

```swift
import AVFoundation
import Accelerate

class AWAVEAudioEngine: ObservableObject {
    private let engine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()

    // Player nodes for file-based audio
    private var textPlayer: AVAudioPlayerNode?
    private var musicPlayer: AVAudioPlayerNode?
    private var naturePlayer: AVAudioPlayerNode?
    private var soundPlayer: AVAudioPlayerNode?

    // Source nodes for generated audio
    private var frequencySource: AVAudioSourceNode?
    private var noiseSource: AVAudioSourceNode?

    // Volume/fade control
    @Published var masterVolume: Float = 1.0
    @Published var channelVolumes: [String: Float] = [:]

    // Phase management
    @Published var currentPhase: Int = 0
    @Published var phaseTimer: TimeInterval = 0

    func startSession(_ session: Session) { ... }
    func startPhase(_ phase: Int) { ... }
    func stopSession() { ... }
}
```

### 7.2 Oscillator Generation (Core Audio)

```swift
// Custom AVAudioSourceNode for frequency generation
func createBinauralOscillator(rootFreq: Float, pulseFreq: Float) -> AVAudioSourceNode {
    let sampleRate = Float(engine.outputNode.outputFormat(forBus: 0).sampleRate)
    var leftPhase: Float = 0
    var rightPhase: Float = 0

    let leftFreq = rootFreq - (pulseFreq / 2)
    let rightFreq = rootFreq + (pulseFreq / 2)

    return AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
        let bufferList = UnsafeMutableAudioBufferListPointer(audioBufferList)

        for frame in 0..<Int(frameCount) {
            let leftSample = sin(leftPhase)
            let rightSample = sin(rightPhase)

            // Stereo output
            bufferList[0].mData?.assumingMemoryBound(to: Float.self)[frame] = leftSample
            bufferList[1].mData?.assumingMemoryBound(to: Float.self)[frame] = rightSample

            leftPhase += 2.0 * .pi * leftFreq / sampleRate
            rightPhase += 2.0 * .pi * rightFreq / sampleRate

            if leftPhase > 2.0 * .pi { leftPhase -= 2.0 * .pi }
            if rightPhase > 2.0 * .pi { rightPhase -= 2.0 * .pi }
        }
        return noErr
    }
}
```

### 7.3 View Hierarchy

```
AWAVEApp
├── ContentView
│   ├── HomeView
│   │   ├── MeditationButton
│   │   ├── KlangweltButton
│   │   └── FavoritesButton
│   │
│   ├── CategorySelectionView
│   │   ├── PresetCategoryGrid (12 categories)
│   │   └── CustomTopicInput
│   │
│   ├── SessionConfigView
│   │   ├── SessionPreview
│   │   ├── VoiceSelector
│   │   ├── DurationSlider
│   │   ├── FrequencyWarning
│   │   └── RegenerateButton
│   │
│   ├── SessionPlayerView
│   │   ├── NowPlayingInfo
│   │   ├── PhaseIndicator
│   │   ├── PlaybackControls
│   │   ├── VolumeSliders (per channel)
│   │   └── TimerDisplay
│   │
│   └── SessionEndView
│       ├── SaveSessionPrompt
│       └── RatingPrompt
│
└── SettingsView
    ├── VoicePreferences
    ├── FrequencyWarningToggle
    └── AccountSettings
```

---

## 8. User Stories

### 8.1 Session Generation

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| US-001 | As a user, I want to select a meditation category so that I receive a relevant session | 12 preset categories displayed; custom input available; session generates within 2 seconds |
| US-002 | As a user, I want to regenerate the proposed session if I don't like it | "Regenerate" button creates new random selection; previous config not repeated |
| US-003 | As a user, I want to select my preferred narrator voice | Voice picker shows all available voices with audio preview |
| US-004 | As a user, I want to adjust the session duration before starting | Timer slider adjusts ±50% of suggested duration; phases scale proportionally |
| US-005 | As a user, I want to see frequency warnings if applicable | Modal displays contraindications; user must acknowledge before continuing |

### 8.2 Session Playback

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| US-010 | As a user, I want to play/pause the session | Single tap toggles state; all audio layers respond simultaneously |
| US-011 | As a user, I want to adjust individual layer volumes during playback | 6 volume sliders (text, music, nature, frequency, noise, sound) |
| US-012 | As a user, I want to change music/nature during the session | Selection triggers only that player restart, not full session |
| US-013 | As a user, I want to see remaining time and current phase | Phase indicator + countdown timer visible |
| US-014 | As a user, I want background audio to continue when app is minimized | AVAudioSession configured for background playback |

### 8.3 Session Persistence

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| US-020 | As a user, I want to save a session I enjoyed | Session saved with all parameters; retrievable from favorites |
| US-021 | As a user, I want to replay a saved session exactly | Identical audio sequence reproduced |
| US-022 | As a user, I want to be warned that unsaved sessions cannot be recreated | End-of-session modal explains uniqueness |

---

## 9. API / Backend Requirements

### 9.1 Content Hosting

| Endpoint | Purpose |
|----------|---------|
| `GET /audio/text/{path}/{voice}_{name}.mp3` | Narration audio files |
| `GET /audio/music/{genre}/{genre}_{index}.mp3` | Music tracks |
| `GET /audio/nature/{name}.mp3` | Nature soundscapes |
| `GET /audio/noise/{type}.mp3` | Colored noise samples |
| `GET /audio/sound/{name}.mp3` | Sound effects (bells, etc.) |
| `GET /content-database.json` | Full content metadata |

### 9.2 Caching Strategy

| Content Type | Cache Duration | Strategy |
|--------------|----------------|----------|
| Narration | Permanent | Download on first use |
| Music | 30 days | LRU eviction |
| Nature | 30 days | LRU eviction |
| Noise | Permanent | Bundle with app |
| Sound | Permanent | Bundle with app |

---

## 10. Future: Biofeedback Integration (CASE 3)

### 10.1 Sensor Inputs

| Sensor | Data | Use |
|--------|------|-----|
| **EEG** | Delta/Theta/Alpha/Beta/Gamma waves | Detect relaxation depth |
| **PPG** | Heart rate, HRV | Stress/relaxation indicator |
| **Gyroscope** | Movement | Detect if user fell asleep or moved |
| **REM** | Eye movement | Dream state detection |

### 10.2 Adaptive Phase Transitions

```
IF voltageALL > 8 (EEG active) THEN
    - Play "wake" sound
    - Wait 30-60 seconds
    - If still active: extend relaxation phase

IF Gyros > 30 (movement detected) THEN
    - Assume user awake
    - Consider phase transition

IF REM > 200 THEN
    - User in dream state
    - Reduce audio intensity
```

### 10.3 Emotional State Mapping

| State | Target Frequency (Hz) | Approach |
|-------|----------------------|----------|
| Panic | ≥100 → ≤10 | Gradual descent |
| Stress | ≥45 → ≤8 | Breathing + relaxation |
| Light Relaxation | ≥15 → ≤6 | Deepening meditation |
| Deep Relaxation | ≥8 → ≤4 | Maintain state |
| Meditation | ≥6 → ≤3 | Theta maintenance |
| Sleep | ≥3 → ≤1 | Delta induction |

---

## 11. Non-Functional Requirements

| Requirement | Specification |
|-------------|---------------|
| **Platform** | iOS 16.0+, iPadOS 16.0+ |
| **Audio Latency** | <20ms for live parameter changes |
| **Memory** | <200MB active session footprint |
| **Battery** | Background playback for 8+ hours |
| **Offline** | Core functionality without network |
| **Accessibility** | VoiceOver support, Dynamic Type |

---

## 12. Glossary

| Term | Definition |
|------|------------|
| **Phase** | A segment of a session with distinct audio configuration |
| **Klangwelt** | Soundscape mode without voice narration |
| **Binaural Beat** | Auditory illusion from slightly different frequencies in each ear |
| **Isochronic Tone** | Evenly spaced tone pulses |
| **Shepard Tone** | Auditory illusion of continuously ascending/descending pitch |
| **BLOXX** | Modular text segments that can be dynamically assembled |
| **Affirmation** | Short positive statement played in loop mode |

---

## Appendix A: Session Category Templates

| Category | Primary Phases | Frequency Allowed |
|----------|---------------|-------------------|
| Sleep | Relaxation → Deepening → Sleep | Yes (Delta target) |
| Anxiety | Safe Place → Breathing → Resolution | **No** |
| Meditation | Arrival → Body → Mind → Return | Yes (Theta/Alpha) |
| Hypnosis | Induction → Trance → Suggestion → Return | Yes |
| AKE (Astral) | Relaxation → Energy → Projection → Return | Yes (Theta) |
| Dream | Relaxation → Sleep → REM awareness | Yes |
| Ruhe (Calm) | Arrival → Relaxation → Mindfulness | Yes |

---

*Document generated from: Audiomodule.pdf, Session Generator Konzept.pdf, Video Transcript*
