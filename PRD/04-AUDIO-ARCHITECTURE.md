# AWAVE - Audio Architecture Assessment
## AVAudioEngine Migration from Web Audio API

**Context (Feb 2026):** Current app is **native iOS (Swift 6.2, SwiftUI, iOS 26.2)**; playback uses PhasePlayer, SessionContentMapping, pre-resolve, and Firebase/Storage. This behaviour is the **baseline for the Android app**. See [docs/ANDROID-NORDSTERN.md](../../ANDROID-NORDSTERN.md).

---

## 1. Current Architecture (Web Audio API)

The existing app uses the Web Audio API with 4 HTML `<audio>` elements and 2 `AudioContext`-based synthesizers per phase:

```
┌─────────────────────────────────────────────────────────┐
│  HTML Audio Elements (file playback)                    │
│                                                         │
│  textAudio ──── GainNode ──── destination                │
│  musicAudio ─── GainNode ──── destination                │
│  natureAudio ── GainNode ──── destination                │
│  soundAudio ─── GainNode ──── destination                │
│  audioDemo ──── (direct) ──── destination                │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  AudioContext #1: Frequency Synthesis                    │
│                                                         │
│  OscillatorNode(s) ─── GainCH(s) ─── [PulsGain(s)]     │
│       └── [ChannelMerger] ─── MasterGain ─── dest       │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  AudioContext #2: Noise Processing                      │
│                                                         │
│  Audio(noise.mp3) ─── MediaElementSource                │
│       └── Splitter ─── FilterL(3x) ─── PanL ───┐       │
│       └── Splitter ─── FilterR(3x) ─── PanR ───┤       │
│                        ChannelMerger ───────────┘       │
│                             └── MasterGain ─── dest     │
└─────────────────────────────────────────────────────────┘
```

### Key Observations
- Each phase creates its own `AudioContext` for frequency and noise (wasteful but isolated)
- Volume control uses JavaScript `setInterval` loops (every 95-100ms) for fading
- Fading is implemented manually with linear interpolation in JS timers
- Cross-phase continuity checks if adjacent phases share content to avoid restarts
- Oscillator parameters are swept using a custom `linearSweep()` function
- The Shepard tone implementation creates N oscillators spanning octaves with gain crossfading

---

## 2. Proposed Native Architecture (AVAudioEngine)

### 2.1 High-Level Architecture

```
┌──────────────────────────────────────────────────────────────┐
│  AWAVEAudioEngine (singleton)                                 │
│                                                               │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  AVAudioEngine                                           │ │
│  │                                                          │ │
│  │  File Players:                                           │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │ │
│  │  │ TextPlayer   │  │ MusicPlayer │  │NaturePlayer │      │ │
│  │  │AVAudioPlayer │  │AVAudioPlayer│  │AVAudioPlayer│      │ │
│  │  │  Node        │  │  Node       │  │  Node       │      │ │
│  │  └──────┬───────┘  └──────┬──────┘  └──────┬──────┘      │ │
│  │         │                 │                │              │ │
│  │         ▼                 ▼                ▼              │ │
│  │  ┌──────────┐     ┌──────────┐     ┌──────────┐          │ │
│  │  │GainNode  │     │GainNode  │     │GainNode  │          │ │
│  │  │(volume+  │     │(volume+  │     │(volume+  │          │ │
│  │  │ fading)  │     │ fading)  │     │ fading)  │          │ │
│  │  └──────┬───┘     └──────┬───┘     └──────┬───┘          │ │
│  │         │                │                │              │ │
│  │         └───────────┬────┴────────────────┘              │ │
│  │                     ▼                                    │ │
│  │              ┌──────────┐                                │ │
│  │              │MainMixer │                                │ │
│  │              │  Node    │                                │ │
│  │              └──────┬───┘                                │ │
│  │                     ▼                                    │ │
│  │              ┌──────────┐                                │ │
│  │              │ Output   │                                │ │
│  │              │  Node    │                                │ │
│  │              └──────────┘                                │ │
│  │                                                          │ │
│  │  Sound Player (discrete, not in engine graph):           │ │
│  │  ┌─────────────┐                                         │ │
│  │  │ SoundPlayer  │  (AVAudioPlayer, separate)             │ │
│  │  └──────────────┘                                        │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  FrequencySynthesizer (AVAudioEngine-based)              │ │
│  │                                                          │ │
│  │  AVAudioSourceNode(s) ─── Gain ─── [Merger] ─── Output  │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  NoiseProcessor (AVAudioEngine-based)                    │ │
│  │                                                          │ │
│  │  AVAudioPlayerNode(noise) ─── Splitter ─── Filters       │ │
│  │       ─── Pan ─── Merger ─── Gain ─── Output             │ │
│  └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

### 2.2 Component Breakdown

#### A. File Playback (Text, Music, Nature, Sound)

**Recommended approach:** `AVAudioPlayerNode` attached to `AVAudioEngine`

```swift
class TrackPlayer {
    let playerNode: AVAudioPlayerNode
    let gainNode: AVAudioMixerNode // or AVAudioUnitEQ for gain
    var currentFile: AVAudioFile?
    var volume: Float // 0.0-1.0
    var fadeTimer: DisplayLink? // CADisplayLink for smooth fading
}
```

**Why AVAudioPlayerNode over AVAudioPlayer:**
- Can be attached to AVAudioEngine graph for real-time gain control
- Supports scheduling multiple buffers for gapless looping
- Can be routed through effects nodes
- Required for nature sounds 2-second overlap crossfade

**Alternative for simpler tracks:** `AVAudioPlayer` can work for text and sound tracks where mixing is not needed, but unifies poorly with the engine graph. Prefer all-engine approach.

#### B. Frequency Synthesis

**Critical requirement.** This is the most complex audio component.

```swift
class FrequencySynthesizer {
    let engine: AVAudioEngine
    var sourceNodes: [AVAudioSourceNode] // One per oscillator
    var gainNodes: [AVAudioMixerNode] // Per-oscillator gain
    var pulsGainNode: AVAudioMixerNode? // For isochronic/bilateral
    var masterGain: AVAudioMixerNode
    var channelMerger: AVAudioMixerNode? // For stereo types

    // Oscillator state
    var phases: [Double] // Phase accumulators per oscillator
    var frequencies: [Double] // Current frequency per oscillator
    var targetFrequencies: [Double] // Sweep targets
}
```

**Implementation via `AVAudioSourceNode`:**

```swift
let sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
    let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
    let sampleRate = 44100.0

    for frame in 0..<Int(frameCount) {
        let sample = Float(sin(self.phase * 2.0 * .pi))
        self.phase += self.currentFrequency / sampleRate
        if self.phase >= 1.0 { self.phase -= 1.0 }

        for buffer in ablPointer {
            let buf = buffer.mData!.assumingMemoryBound(to: Float.self)
            buf[frame] = sample * self.gainValue
        }
    }
    return noErr
}
```

**Why AVAudioSourceNode:**
- Direct sample-level control needed for real-time frequency sweeping
- Can dynamically change frequency every sample
- Efficient for multiple simultaneous oscillators
- Required for Shepard tone cross-fading between octaves

**Alternative: AudioKit.** The AudioKit framework provides higher-level oscillator and filter abstractions. Consider if development speed is prioritized over binary size.

#### C. Noise Processing

```swift
class NoiseProcessor {
    let engine: AVAudioEngine
    let playerNode: AVAudioPlayerNode // Plays noise MP3
    let splitter: AVAudioMixerNode // Channel split
    var filtersL: [AVAudioUnitEQ] // Notch filters for left
    var filtersR: [AVAudioUnitEQ] // Notch filters for right
    let panL: AVAudioMixerNode // Left channel gain
    let panR: AVAudioMixerNode // Right channel gain
    let merger: AVAudioMixerNode // Channel merge
    let masterGain: AVAudioMixerNode
}
```

**NeuroFlow filter implementation:**
- 3 biquad notch filters per channel (6 total)
- `AVAudioUnitEQ` with `.parametric` band type set to notch behavior
- Frequency sweep via `CADisplayLink` or `Timer` updating filter parameters
- Sweep range: [1, 250, 1000] Hz to [2000, 7000, 20000] Hz over 6-second half-cycle

---

## 3. Critical Implementation Challenges

### 3.1 Binaural Beat Precision
**Challenge:** Binaural beats require precise frequency differences between L/R channels. Web Audio API's `OscillatorNode` handles this natively. In AVAudioEngine, we need manual sample-level control.

**Solution:** Use `AVAudioSourceNode` with per-sample frequency tracking. The render callback runs at audio thread priority, ensuring sample-accurate timing.

**Risk level:** Medium. The math is straightforward, but debugging audio thread issues requires experience.

### 3.2 Shepard Tone Multi-Oscillator Management
**Challenge:** Shepard tones require dynamic oscillator counts (based on octave range), per-oscillator gain fading, and synchronized frequency sweeping over a 20-second cycle that repeats indefinitely.

**Current JS implementation:** Creates N oscillators spanning the frequency range, fades the highest in and lowest out, sweeps all simultaneously using `linearSweep()`.

**Solution:**
```swift
class ShepardToneGenerator {
    var oscillatorCount: Int // Dynamic, based on octave span
    var sourceNodes: [AVAudioSourceNode]
    var shepardWidth: TimeInterval = 20 // seconds per cycle

    // Each oscillator sweeps one octave, with gain crossfade
    // Top oscillator: gain 0 -> max
    // Bottom oscillator: gain max -> 0
    // Others: constant gain
    // At cycle end: reset frequencies and repeat
}
```

**Risk level:** High. This is the most complex audio synthesis in the app. Recommend building a standalone proof-of-concept first.

### 3.3 Isochronic/Bilateral Pulsing
**Challenge:** On/off gain modulation at the pulse frequency, with exponential ramp to avoid clicks. Web Audio API uses `exponentialRampToValueAtTime()`. AVAudioEngine has no direct equivalent.

**Solution:**
- Use `AVAudioSourceNode` and apply amplitude modulation directly in the render callback
- For smooth transitions: apply short exponential envelope (attack/release) to each pulse
- Track pulse phase accumulator alongside frequency phase

**Risk level:** Medium. Click-free pulsing requires careful envelope shaping.

### 3.4 Cross-Phase Audio Continuity
**Challenge:** When adjacent phases share the same music/nature content, audio must continue playing without interruption, with smooth volume adjustment.

**Solution:**
- Keep `AVAudioPlayerNode` running across phase transitions
- Compare content identifiers between adjacent phases
- If same: adjust gain smoothly (1-second transition)
- If different: fade out current, load and fade in new
- Pre-load next phase's audio files during current phase playback

**Risk level:** Low-Medium. Standard audio engineering pattern.

### 3.5 Background Audio & App Lifecycle
**Challenge:** iOS aggressively manages background audio. The app must pause cleanly when backgrounded and resume without audio artifacts.

**Solution:**
- Configure `AVAudioSession` with `.playback` category
- Handle `AVAudioSession.interruptionNotification`
- Handle `UIApplication.didEnterBackgroundNotification`
- Pause all synthesis (stop render callbacks, save state)
- Resume with 100ms delay for frequency/noise (matches current JS behavior)
- Consider using `beginBackgroundTask` for graceful pause

**Risk level:** Medium. iOS audio session management has many edge cases.

### 3.6 Volume Fading
**Challenge:** Current implementation uses JavaScript `setInterval` at 95-100ms for linear volume ramping. This is imprecise and CPU-wasteful.

**Solution (recommended):** Use `AVAudioMixerNode.volume` with `CADisplayLink` for smooth, display-synced fading:

```swift
class VolumeFader {
    var displayLink: CADisplayLink?
    var startVolume: Float
    var targetVolume: Float
    var fadeDuration: TimeInterval
    var startTime: CFTimeInterval?

    func update() {
        guard let start = startTime else { return }
        let elapsed = CACurrentMediaTime() - start
        let progress = min(Float(elapsed / fadeDuration), 1.0)
        let currentVolume = startVolume + (targetVolume - startVolume) * progress
        mixerNode.volume = currentVolume

        if progress >= 1.0 {
            displayLink?.invalidate()
        }
    }
}
```

**Alternative:** `AVAudioUnitTimePitch` or scheduled parameter changes on the audio engine. However, `CADisplayLink` is simpler and matches the original behavior.

---

## 4. Recommended Framework Decisions

### 4.1 AVAudioEngine vs AudioKit

| Factor | AVAudioEngine | AudioKit |
|--------|--------------|----------|
| Oscillators | Manual via AVAudioSourceNode | Built-in `Oscillator` class |
| Filters | AVAudioUnitEQ | Higher-level `BandPassFilter` etc. |
| Binary size | 0 (system framework) | ~10-20MB |
| Learning curve | Steeper | Gentler |
| Control | Full | Full (wraps AVAudioEngine) |
| Maintenance | Apple-maintained | Community-maintained |

**Recommendation:** Start with pure `AVAudioEngine` + `AVAudioSourceNode`. The oscillator requirements are specific enough that AudioKit's abstractions may not save much effort, while adding a dependency. If the frequency synthesis proof-of-concept proves too complex, pivot to AudioKit.

### 4.2 Accelerate Framework for DSP

For NeuroFlow noise processing, consider using `vDSP` for filter parameter interpolation and `vForce` for sine wave generation in bulk:

```swift
import Accelerate

// Generate sine wave buffer efficiently
var phases = [Double](repeating: 0, count: frameCount)
vDSP.fill(&phases, withRamp: startPhase, increment: phaseIncrement)
var sines = [Float](repeating: 0, count: frameCount)
vForce.sin(phases.map { Float($0) }, result: &sines)
```

This can significantly reduce CPU load for multi-oscillator Shepard tones.

---

## 5. Audio Session Configuration

```swift
func configureAudioSession() throws {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
    try session.setActive(true)
    try session.setPreferredSampleRate(44100)
    try session.setPreferredIOBufferDuration(0.005) // 5ms for low latency
}
```

**Category:** `.playback` - audio continues when screen locks (but app must handle background state)
**Mode:** `.default` - standard audio behavior
**Options:** `.mixWithOthers` can be toggled based on user preference

---

## 6. Implementation Priority Order

1. **File playback engine** (Text, Music, Nature, Sound) - Foundation for all features
2. **Volume fading system** - Required by all playback
3. **Phase timer and session lifecycle** - Controls everything
4. **Binaural beat synthesis** (root, binaural, monaural) - Core frequency feature
5. **Isochronic/bilateral pulsing** - Extends frequency synthesis
6. **Colored noise playback** (standard) - Simple file playback with loop
7. **NeuroFlow noise processing** (sync filters) - Complex filter chain
8. **Shepard tone synthesis** - Most complex frequency feature
9. **Cross-phase continuity** - Polish feature
10. **Live content swapping** - UI-driven audio changes

---

## 7. Testing Strategy

### 7.1 Unit Tests
- Frequency calculation accuracy (binaural difference, Shepard octaves)
- Fade timing precision
- Phase timer accuracy
- Session serialization/deserialization

### 7.2 Integration Tests
- Multi-track simultaneous playback
- Phase transition without audio gaps
- Pause/resume state consistency
- Background/foreground lifecycle

### 7.3 Performance Tests
- CPU usage during max oscillator count (Shepard + noise + 3 file tracks)
- Memory usage during extended sessions
- Battery drain measurement
- Audio glitch detection under load

### 7.4 Manual Testing
- Binaural beat perception with headphones
- Shepard tone continuity (no audible "reset")
- NeuroFlow spatial effect verification
- Cross-phase music continuity smoothness
