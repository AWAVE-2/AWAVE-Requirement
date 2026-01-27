# Deep Dive: AVAudioEngine & iOS Audio Architecture

> **Level**: Systems-level understanding for audio app development
> **Goal**: Understand the iOS audio stack from hardware to API
> **Context**: Your AWAVE app already has a native audio module - understand why it works

---

## Table of Contents

1. [iOS Audio Stack Overview](#ios-audio-stack-overview)
2. [Core Audio Fundamentals](#core-audio-fundamentals)
3. [AVAudioEngine Architecture](#avaudioengine-architecture)
4. [Audio Units Deep Dive](#audio-units-deep-dive)
5. [The Audio Render Thread](#the-audio-render-thread)
6. [Audio Session Management](#audio-session-management)
7. [Real-Time Audio Constraints](#real-time-audio-constraints)
8. [Effects Processing](#effects-processing)
9. [Performance Optimization](#performance-optimization)
10. [Common Pitfalls](#common-pitfalls)

---

## iOS Audio Stack Overview

### The Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                     Your App                                     │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              AVAudioEngine (High-level)                    │ │
│  │  - Node-based audio graph                                  │ │
│  │  - Swift/Obj-C friendly                                    │ │
│  │  - Automatic format conversion                             │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Audio Units (Mid-level)                       │ │
│  │  - C API, component-based                                  │ │
│  │  - More control, more complexity                           │ │
│  │  - Custom DSP possible                                     │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Core Audio (Low-level)                        │ │
│  │  - Audio Queue Services                                    │ │
│  │  - Audio File Services                                     │ │
│  │  - Hardware abstraction                                    │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Audio HAL (Hardware Abstraction Layer)        │
│  - IOKit drivers                                                 │
│  - Hardware communication                                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Audio Hardware                                │
│  - DAC (Digital-to-Analog Converter)                            │
│  - ADC (Analog-to-Digital Converter)                            │
│  - Speakers, headphones, microphones                            │
└─────────────────────────────────────────────────────────────────┘
```

### API Choice Matrix

| API | Use Case | Complexity | Performance |
|-----|----------|------------|-------------|
| **AVAudioPlayer** | Simple playback | Very Low | Good |
| **AVPlayer** | Streaming, video | Low | Good |
| **AVAudioEngine** | Real-time processing | Medium | Excellent |
| **Audio Units** | Custom DSP | High | Excellent |
| **Core Audio** | Maximum control | Very High | Maximum |

For AWAVE (multi-track with effects): **AVAudioEngine** is the right choice.

---

## Core Audio Fundamentals

### Digital Audio Basics

```
Analog Sound Wave → ADC → Digital Samples → DAC → Analog Sound Wave

Sample: A single amplitude measurement
Sample Rate: Measurements per second (44100 Hz, 48000 Hz)
Bit Depth: Precision of each sample (16-bit, 24-bit, 32-bit float)
Channel: Independent audio stream (mono=1, stereo=2)
Frame: One sample from each channel
Packet: One or more frames (compressed audio may have multiple frames)
```

### Audio Format Representation

```swift
// AVAudioFormat wraps AudioStreamBasicDescription (ASBD)
let format = AVAudioFormat(
    commonFormat: .pcmFormatFloat32,  // 32-bit floating point
    sampleRate: 44100,                // CD quality
    channels: 2,                      // Stereo
    interleaved: false                // Planar (separate L/R buffers)
)

// Under the hood (C struct):
struct AudioStreamBasicDescription {
    var mSampleRate: Float64        // 44100.0
    var mFormatID: UInt32           // kAudioFormatLinearPCM
    var mFormatFlags: UInt32        // Float, packed, non-interleaved
    var mBytesPerPacket: UInt32     // 4 (one Float32)
    var mFramesPerPacket: UInt32    // 1 (uncompressed)
    var mBytesPerFrame: UInt32      // 4
    var mChannelsPerFrame: UInt32   // 2
    var mBitsPerChannel: UInt32     // 32
}
```

### Interleaved vs Non-Interleaved (Planar)

```
INTERLEAVED (common in file formats):
┌───┬───┬───┬───┬───┬───┬───┬───┐
│ L │ R │ L │ R │ L │ R │ L │ R │  One buffer, alternating
└───┴───┴───┴───┴───┴───┴───┴───┘

NON-INTERLEAVED / PLANAR (better for DSP):
┌───┬───┬───┬───┐
│ L │ L │ L │ L │  Left channel buffer
└───┴───┴───┴───┘
┌───┬───┬───┬───┐
│ R │ R │ R │ R │  Right channel buffer
└───┴───┴───┴───┘

AVAudioEngine uses non-interleaved internally for SIMD efficiency
```

### Buffer Sizes and Latency

```
Buffer Size = Samples per callback

┌────────────────────────────────────────────────────────────────┐
│ Buffer Size │ Latency (@44.1kHz) │ CPU Load │ Use Case         │
├────────────────────────────────────────────────────────────────┤
│ 64 samples  │ 1.5 ms             │ Very High│ Pro audio        │
│ 128 samples │ 2.9 ms             │ High     │ Music apps       │
│ 256 samples │ 5.8 ms             │ Medium   │ General audio    │
│ 512 samples │ 11.6 ms            │ Low      │ Playback only    │
│ 1024 samples│ 23.2 ms            │ Very Low │ Background audio │
└────────────────────────────────────────────────────────────────┘

Latency = Buffer Size / Sample Rate

For meditation app: 256-512 samples is fine (no real-time input)
```

---

## AVAudioEngine Architecture

### The Node Graph Model

```
AVAudioEngine manages a graph of audio nodes:

┌─────────────────────────────────────────────────────────────────┐
│                        AVAudioEngine                             │
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │ AVAudioPlayer│    │ AVAudioPlayer│    │ AVAudioPlayer│      │
│  │    Node 1    │    │    Node 2    │    │    Node 3    │      │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘      │
│         │                   │                   │               │
│         │ connect           │ connect           │ connect       │
│         ▼                   ▼                   ▼               │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │AVAudioUnitEQ │    │AVAudioUnit   │    │              │      │
│  │  (effect)    │    │  Reverb      │    │   (direct)   │      │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘      │
│         │                   │                   │               │
│         └───────────────────┼───────────────────┘               │
│                             │                                    │
│                             ▼                                    │
│                    ┌──────────────┐                             │
│                    │ Main Mixer   │  ← engine.mainMixerNode     │
│                    │    Node      │                             │
│                    └──────┬───────┘                             │
│                           │                                      │
│                           ▼                                      │
│                    ┌──────────────┐                             │
│                    │   Output     │  ← engine.outputNode        │
│                    │    Node      │                             │
│                    └──────────────┘                             │
│                           │                                      │
└───────────────────────────┼──────────────────────────────────────┘
                            │
                            ▼
                      Audio Hardware
```

### Node Types

```swift
// SOURCE NODES (generate audio)
AVAudioPlayerNode       // File/buffer playback
AVAudioInputNode       // Microphone input (engine.inputNode)
AVAudioSourceNode      // Custom generation (iOS 13+)

// EFFECT NODES (process audio)
AVAudioUnitEQ          // Parametric equalizer
AVAudioUnitReverb      // Reverb
AVAudioUnitDelay       // Delay
AVAudioUnitDistortion  // Distortion
AVAudioUnitTimePitch   // Time stretch, pitch shift
AVAudioUnitVarispeed   // Playback speed

// MIXING NODES
AVAudioMixerNode       // Mix multiple inputs
AVAudioEnvironmentNode // 3D spatial audio

// OUTPUT NODES
AVAudioOutputNode      // Hardware output (engine.outputNode)
```

### Building an Audio Graph

```swift
class AudioEngineManager {
    let engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    let eq = AVAudioUnitEQ(numberOfBands: 3)
    let reverb = AVAudioUnitReverb()

    func setupGraph() throws {
        // 1. Attach nodes to engine
        engine.attach(player)
        engine.attach(eq)
        engine.attach(reverb)

        // 2. Get format from a reference point
        let format = engine.mainMixerNode.outputFormat(forBus: 0)

        // 3. Connect nodes in order
        // player → eq → reverb → mainMixer
        engine.connect(player, to: eq, format: format)
        engine.connect(eq, to: reverb, format: format)
        engine.connect(reverb, to: engine.mainMixerNode, format: format)
        // mainMixer → output is automatic

        // 4. Prepare and start
        engine.prepare()
        try engine.start()
    }
}
```

### Multi-Track Setup (Like AWAVE)

```swift
class MultiTrackMixer {
    let engine = AVAudioEngine()
    var players: [String: AVAudioPlayerNode] = [:]
    var effects: [String: [AVAudioNode]] = [:]

    func addTrack(id: String, file: AVAudioFile) throws {
        let player = AVAudioPlayerNode()
        engine.attach(player)

        // Each track gets its own effect chain
        let eq = AVAudioUnitEQ(numberOfBands: 3)
        let reverb = AVAudioUnitReverb()

        engine.attach(eq)
        engine.attach(reverb)

        let format = file.processingFormat

        // player → eq → reverb → mainMixer
        engine.connect(player, to: eq, format: format)
        engine.connect(eq, to: reverb, format: format)
        engine.connect(reverb, to: engine.mainMixerNode, format: format)

        players[id] = player
        effects[id] = [eq, reverb]

        // Schedule file for playback
        player.scheduleFile(file, at: nil)
    }

    func setVolume(trackId: String, volume: Float) {
        players[trackId]?.volume = volume  // 0.0 to 1.0
    }

    func setPan(trackId: String, pan: Float) {
        players[trackId]?.pan = pan  // -1.0 (left) to 1.0 (right)
    }

    func playAll() {
        players.values.forEach { $0.play() }
    }
}
```

---

## Audio Units Deep Dive

### What Are Audio Units?

```
Audio Units are Apple's plugin format for audio processing.
AVAudioEngine nodes wrap Audio Units internally.

┌─────────────────────────────────────────────────────────────┐
│                      Audio Unit                              │
│                                                              │
│  Input Bus(es)  ────►  Processing  ────►  Output Bus(es)   │
│                                                              │
│  Parameters:                                                 │
│  - Volume, pan, etc.                                        │
│  - Effect-specific (reverb size, delay time)                │
│                                                              │
│  Properties:                                                 │
│  - Sample rate                                              │
│  - Channel count                                            │
│  - Bypass state                                             │
└─────────────────────────────────────────────────────────────┘
```

### Audio Unit Categories

```
kAudioUnitType_Output          // Hardware I/O
kAudioUnitType_MusicDevice     // Software instruments
kAudioUnitType_MusicEffect     // MIDI-controlled effects
kAudioUnitType_FormatConverter // Sample rate, format conversion
kAudioUnitType_Effect          // Audio effects
kAudioUnitType_Mixer           // Mixing
kAudioUnitType_Panner          // Spatial positioning
kAudioUnitType_Generator       // Tone generators
```

### Accessing the Underlying Audio Unit

```swift
// AVAudioUnit exposes the underlying AudioUnit
let reverb = AVAudioUnitReverb()

// Access the C Audio Unit for advanced control
let audioUnit = reverb.audioUnit

// Set parameters via Audio Unit API
AudioUnitSetParameter(
    audioUnit,
    kReverb2Param_DryWetMix,  // Parameter ID
    kAudioUnitScope_Global,    // Scope
    0,                         // Element (bus)
    0.5,                       // Value (50% wet)
    0                          // Buffer offset
)
```

### Custom Audio Unit (v3)

```swift
// Modern Audio Unit extension (v3) - runs in your app or as plugin
import AudioToolbox
import AVFoundation

class MyEffectAudioUnit: AUAudioUnit {
    private var inputBus: AUAudioUnitBus!
    private var outputBus: AUAudioUnitBus!

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        inputBus = try AUAudioUnitBus(format: format)
        outputBus = try AUAudioUnitBus(format: format)
    }

    override var internalRenderBlock: AUInternalRenderBlock {
        return { [weak self] actionFlags, timestamp, frameCount, outputBusNumber,
                  outputData, realtimeEventListHead, pullInputBlock in

            // Pull input audio
            guard let pullInputBlock = pullInputBlock else {
                return kAudioUnitErr_NoConnection
            }

            var inputFlags = AudioUnitRenderActionFlags()
            let status = pullInputBlock(&inputFlags, timestamp, frameCount, 0, outputData)

            if status != noErr { return status }

            // Process audio (this is where your DSP goes)
            // outputData already contains input, modify in place
            let buffer = UnsafeMutableAudioBufferListPointer(outputData)
            for channel in 0..<buffer.count {
                let samples = buffer[channel].mData!.assumingMemoryBound(to: Float.self)
                for frame in 0..<Int(frameCount) {
                    // Example: simple gain
                    samples[frame] *= 0.5
                }
            }

            return noErr
        }
    }
}
```

---

## The Audio Render Thread

### Real-Time Thread Characteristics

```
┌─────────────────────────────────────────────────────────────────┐
│                    Audio Render Thread                           │
│                                                                  │
│  Priority: HIGHEST (real-time scheduling)                       │
│  Deadline: Buffer duration (e.g., 5.8ms for 256 samples)        │
│  Consequence of miss: Audible glitch (pop, click, dropout)      │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    FORBIDDEN                             │   │
│  │                                                          │   │
│  │  ✗ Memory allocation (malloc, new, alloc)               │   │
│  │  ✗ Objective-C messaging (autorelease pools)            │   │
│  │  ✗ File I/O                                             │   │
│  │  ✗ Network I/O                                          │   │
│  │  ✗ Locks that might block (mutexes with contention)     │   │
│  │  ✗ Swift Array/Dictionary operations                     │   │
│  │  ✗ String operations                                     │   │
│  │  ✗ Logging/printing                                      │   │
│  │  ✗ Calling into unknown code                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    ALLOWED                               │   │
│  │                                                          │   │
│  │  ✓ Arithmetic operations                                │   │
│  │  ✓ Pre-allocated buffer access                          │   │
│  │  ✓ Atomic operations                                    │   │
│  │  ✓ Lock-free data structures                            │   │
│  │  ✓ SIMD operations                                      │   │
│  │  ✓ Accelerate framework (vDSP)                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### The Render Callback

```swift
// AVAudioSourceNode gives you a render callback
let sourceNode = AVAudioSourceNode { isSilence, timestamp, frameCount, audioBufferList in
    // THIS RUNS ON THE AUDIO THREAD
    // You have ~5ms to fill the buffer

    let bufferList = UnsafeMutableAudioBufferListPointer(audioBufferList)

    for frame in 0..<Int(frameCount) {
        // Generate or process samples
        let sample = sin(phase) * amplitude
        phase += phaseIncrement

        for buffer in bufferList {
            let samples = buffer.mData!.assumingMemoryBound(to: Float.self)
            samples[frame] = sample
        }
    }

    return noErr
}
```

### Thread Communication Pattern

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│   Main Thread                        Audio Thread                │
│   (UI, control)                      (real-time render)         │
│                                                                  │
│   ┌─────────────┐                   ┌─────────────┐            │
│   │  User taps  │                   │  Render     │            │
│   │  volume     │                   │  callback   │            │
│   │  slider     │                   │             │            │
│   └──────┬──────┘                   └──────┬──────┘            │
│          │                                 │                    │
│          │                                 │                    │
│          ▼                                 ▼                    │
│   ┌──────────────────────────────────────────────┐            │
│   │         Atomic / Lock-Free State             │            │
│   │                                              │            │
│   │   @Atomic var volume: Float                  │            │
│   │                                              │            │
│   │   Main writes ──────► Audio reads            │            │
│   │   (no locks!)                                │            │
│   └──────────────────────────────────────────────┘            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

```swift
import Atomics

class AudioState {
    // Use atomic for lock-free thread-safe access
    private let _volume = ManagedAtomic<Float>(1.0)

    var volume: Float {
        get { _volume.load(ordering: .relaxed) }
        set { _volume.store(newValue, ordering: .relaxed) }
    }
}

// Or use OSAtomicFloat (C API) for simpler cases
```

---

## Audio Session Management

### What is AVAudioSession?

```
AVAudioSession negotiates your app's audio behavior with the system.

┌─────────────────────────────────────────────────────────────────┐
│                         iOS System                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  Phone App  │  │  Music App  │  │  Your App   │             │
│  │  (call)     │  │  (music)    │  │  (meditate) │             │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
│         │                │                │                     │
│         └────────────────┼────────────────┘                     │
│                          ▼                                       │
│              ┌─────────────────────┐                            │
│              │   AVAudioSession    │  ← Arbitrates conflicts    │
│              │     (singleton)     │                            │
│              └──────────┬──────────┘                            │
│                         │                                        │
│                         ▼                                        │
│              ┌─────────────────────┐                            │
│              │   Audio Hardware    │                            │
│              └─────────────────────┘                            │
└─────────────────────────────────────────────────────────────────┘
```

### Audio Session Categories

```swift
// Category determines behavior
let session = AVAudioSession.sharedInstance()

// For AWAVE (meditation playback):
try session.setCategory(
    .playback,                    // Audio is primary, mixes with nothing
    mode: .default,
    options: [.mixWithOthers]     // Optional: allow background music
)

// Categories:
// .ambient      - Mixes with others, silenced by lock
// .soloAmbient  - Doesn't mix, silenced by lock (default)
// .playback     - Doesn't mix, plays in background
// .record       - Recording
// .playAndRecord - Both
// .multiRoute   - Multiple outputs simultaneously
```

### Session Lifecycle

```swift
class AudioSessionManager {
    func configure() throws {
        let session = AVAudioSession.sharedInstance()

        // 1. Configure category
        try session.setCategory(.playback, mode: .default)

        // 2. Set preferred settings
        try session.setPreferredSampleRate(44100)
        try session.setPreferredIOBufferDuration(0.005)  // 5ms

        // 3. Activate
        try session.setActive(true)

        // 4. Observe interruptions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )

        // 5. Observe route changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    @objc func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // Phone call, Siri, etc. started
            // Audio automatically paused by system
            pausePlayback()

        case .ended:
            // Interruption ended
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)

            if options.contains(.shouldResume) {
                resumePlayback()
            }

        @unknown default:
            break
        }
    }

    @objc func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        switch reason {
        case .oldDeviceUnavailable:
            // Headphones unplugged - pause playback (Apple guideline)
            pausePlayback()

        case .newDeviceAvailable:
            // Headphones plugged in
            break

        default:
            break
        }
    }
}
```

### Background Audio

```swift
// 1. Enable in Info.plist
// UIBackgroundModes: audio

// 2. Set correct category
try session.setCategory(.playback)

// 3. Activate session
try session.setActive(true)

// 4. Handle interruptions properly (above)

// 5. Set Now Playing info
import MediaPlayer

func updateNowPlaying(title: String, artist: String, duration: TimeInterval) {
    var info = [String: Any]()
    info[MPMediaItemPropertyTitle] = title
    info[MPMediaItemPropertyArtist] = artist
    info[MPMediaItemPropertyPlaybackDuration] = duration
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
    info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0

    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
}

// 6. Handle remote commands (lock screen, Control Center)
func setupRemoteCommands() {
    let commandCenter = MPRemoteCommandCenter.shared()

    commandCenter.playCommand.addTarget { _ in
        self.play()
        return .success
    }

    commandCenter.pauseCommand.addTarget { _ in
        self.pause()
        return .success
    }
}
```

---

## Real-Time Audio Constraints

### The Deadline Problem

```
Audio hardware needs continuous samples at fixed rate.
Miss a deadline = audible glitch.

Sample Rate: 44100 Hz
Buffer Size: 256 samples
Deadline: 256 / 44100 = 5.8 ms

Every 5.8 ms, you MUST deliver 256 samples.
No exceptions. No "try again later."

┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│  Time: 0ms    5.8ms   11.6ms  17.4ms  23.2ms  29.0ms           │
│        │       │       │       │       │       │                │
│        ▼       ▼       ▼       ▼       ▼       ▼                │
│       ┌─┐     ┌─┐     ┌─┐     ┌─┐     ┌─┐     ┌─┐              │
│       │ │     │ │     │ │     │ │     │ │     │ │              │
│       │ │     │ │     │ │     │ │     │ │     │ │              │
│       └─┘     └─┘     └─┘     └─┘     └─┘     └─┘              │
│      Buffer  Buffer  Buffer  Buffer  Buffer  Buffer            │
│        1       2       3       4       5       6                │
│                                                                  │
│  If buffer 4 isn't ready in time:                               │
│  - Hardware plays silence or repeats buffer 3                   │
│  - User hears click/pop/dropout                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Memory Allocation Is Forbidden

```swift
// WHY malloc is forbidden:

malloc() implementation (simplified):
1. Check free list for suitable block
2. If none, request memory from kernel (mmap/sbrk)
3. Kernel call = context switch = unbounded time
4. Free list lock = possible contention = blocking

// BAD: Allocates on audio thread
func renderCallback() {
    let buffer = [Float](repeating: 0, count: 256)  // ALLOCATES!
    // ...
}

// GOOD: Pre-allocate
class AudioProcessor {
    private var buffer: [Float]  // Pre-allocated

    init() {
        buffer = [Float](repeating: 0, count: 256)
    }

    func process(into outputBuffer: UnsafeMutablePointer<Float>) {
        // Use pre-allocated buffer
        // No allocation on audio thread
    }
}
```

### Lock-Free Programming

```swift
// Use single-producer single-consumer (SPSC) ring buffer
// for passing data between threads

class RingBuffer<T> {
    private var buffer: [T?]
    private var readIndex = 0
    private var writeIndex = 0
    private let capacity: Int

    init(capacity: Int) {
        self.capacity = capacity
        self.buffer = [T?](repeating: nil, count: capacity)
    }

    // Main thread writes
    func write(_ value: T) -> Bool {
        let nextWrite = (writeIndex + 1) % capacity
        if nextWrite == readIndex { return false }  // Full

        buffer[writeIndex] = value
        writeIndex = nextWrite  // Atomic on modern CPUs
        return true
    }

    // Audio thread reads
    func read() -> T? {
        if readIndex == writeIndex { return nil }  // Empty

        let value = buffer[readIndex]
        buffer[readIndex] = nil
        readIndex = (readIndex + 1) % capacity  // Atomic
        return value
    }
}
```

---

## Effects Processing

### Built-in Effect Units

```swift
// Reverb
let reverb = AVAudioUnitReverb()
reverb.loadFactoryPreset(.largeHall)
reverb.wetDryMix = 50  // 0-100

// Delay
let delay = AVAudioUnitDelay()
delay.delayTime = 0.5  // seconds
delay.feedback = 50    // percentage
delay.wetDryMix = 30

// EQ
let eq = AVAudioUnitEQ(numberOfBands: 3)
eq.bands[0].filterType = .lowShelf
eq.bands[0].frequency = 100
eq.bands[0].gain = 3  // dB

eq.bands[1].filterType = .parametric
eq.bands[1].frequency = 1000
eq.bands[1].bandwidth = 1  // octaves
eq.bands[1].gain = -2

eq.bands[2].filterType = .highShelf
eq.bands[2].frequency = 8000
eq.bands[2].gain = 2

// Distortion
let distortion = AVAudioUnitDistortion()
distortion.loadFactoryPreset(.drumsBitBrush)
distortion.wetDryMix = 20

// Time/Pitch
let timePitch = AVAudioUnitTimePitch()
timePitch.rate = 1.0    // 0.25 to 4.0
timePitch.pitch = 0     // cents (-2400 to 2400)
```

### Custom DSP with Accelerate

```swift
import Accelerate

class CustomEffect {
    // Low-pass filter using vDSP
    private var filterState = [Float](repeating: 0, count: 2)

    func lowPassFilter(input: UnsafePointer<Float>,
                       output: UnsafeMutablePointer<Float>,
                       frameCount: Int,
                       cutoff: Float) {
        // Biquad filter coefficients
        var coefficients = [Float](repeating: 0, count: 5)
        // ... calculate coefficients from cutoff ...

        // Process using vDSP (SIMD optimized)
        vDSP_deq22(
            input, 1,
            &coefficients,
            output, 1,
            vDSP_Length(frameCount)
        )
    }

    // Mix two buffers
    func mix(a: UnsafePointer<Float>,
             b: UnsafePointer<Float>,
             output: UnsafeMutablePointer<Float>,
             aGain: Float,
             bGain: Float,
             frameCount: Int) {
        // output = a * aGain + b * bGain
        var aGainVar = aGain
        var bGainVar = bGain

        vDSP_vsma(a, 1, &aGainVar, b, 1, output, 1, vDSP_Length(frameCount))
        vDSP_vsma(b, 1, &bGainVar, output, 1, output, 1, vDSP_Length(frameCount))
    }

    // RMS level metering
    func rmsLevel(buffer: UnsafePointer<Float>, frameCount: Int) -> Float {
        var rms: Float = 0
        vDSP_rmsqv(buffer, 1, &rms, vDSP_Length(frameCount))
        return rms
    }
}
```

---

## Performance Optimization

### Profiling Audio

```swift
// Use Instruments: Audio System Trace template

// Manual timing (don't use in production)
#if DEBUG
func measureRenderTime(_ block: () -> Void) {
    let start = mach_absolute_time()
    block()
    let end = mach_absolute_time()

    var timebase = mach_timebase_info_data_t()
    mach_timebase_info(&timebase)

    let nanoseconds = (end - start) * UInt64(timebase.numer) / UInt64(timebase.denom)
    let milliseconds = Double(nanoseconds) / 1_000_000

    if milliseconds > 5.0 {  // > 5ms is dangerous
        print("⚠️ Render took \(milliseconds)ms")
    }
}
#endif
```

### Optimization Techniques

```swift
// 1. Pre-allocate everything
class OptimizedProcessor {
    private let scratchBuffer: UnsafeMutablePointer<Float>
    private let scratchBufferSize: Int

    init(maxFrameCount: Int) {
        scratchBufferSize = maxFrameCount
        scratchBuffer = UnsafeMutablePointer<Float>.allocate(capacity: maxFrameCount)
    }

    deinit {
        scratchBuffer.deallocate()
    }
}

// 2. Use SIMD / Accelerate
import Accelerate

func applyGain(buffer: UnsafeMutablePointer<Float>, count: Int, gain: Float) {
    // Bad: Loop
    // for i in 0..<count { buffer[i] *= gain }

    // Good: vDSP (SIMD)
    var gainVar = gain
    vDSP_vsmul(buffer, 1, &gainVar, buffer, 1, vDSP_Length(count))
}

// 3. Avoid conditionals in hot path
// Bad:
func process(sample: Float, effectEnabled: Bool) -> Float {
    if effectEnabled {  // Branch prediction miss = ~10-20 cycles
        return applyEffect(sample)
    }
    return sample
}

// Good: Separate paths
func processWithEffect(buffer: UnsafeMutablePointer<Float>, count: Int) { ... }
func processNoEffect(buffer: UnsafeMutablePointer<Float>, count: Int) { ... }

// 4. Batch process, don't sample-by-sample
// Bad:
for i in 0..<frameCount {
    output[i] = process(input[i])
}

// Good:
processBlock(input: input, output: output, frameCount: frameCount)
```

---

## Common Pitfalls

### Pitfall 1: Format Mismatches

```swift
// CRASH or silence if formats don't match
let player = AVAudioPlayerNode()
let file = try AVAudioFile(forReading: url)

// File format might be different from engine format
let fileFormat = file.processingFormat      // e.g., 48kHz stereo
let engineFormat = engine.mainMixerNode.outputFormat(forBus: 0)  // e.g., 44.1kHz stereo

// AVAudioEngine handles conversion automatically IF you specify formats correctly
engine.connect(player, to: engine.mainMixerNode, format: fileFormat)
// Engine inserts format converter if needed
```

### Pitfall 2: Forgetting to Start Engine

```swift
// Graph setup is not enough
engine.attach(player)
engine.connect(player, to: engine.mainMixerNode, format: format)

player.scheduleFile(file, at: nil)
player.play()  // Nothing happens!

// Must prepare and start engine
engine.prepare()
try engine.start()  // NOW player.play() works
```

### Pitfall 3: Not Handling Interruptions

```swift
// Phone call comes in
// System stops your audio session
// Engine stops

// When interruption ends:
// - Engine is stopped
// - Player nodes are paused
// - You must restart manually

func handleInterruptionEnded() {
    do {
        try engine.start()  // Restart engine
        player.play()       // Resume playback
    } catch {
        // Handle failure
    }
}
```

### Pitfall 4: Blocking the Audio Thread

```swift
// DISASTER: This will cause glitches
let renderBlock: AVAudioSourceNodeRenderBlock = { ... in
    // This lock might block!
    self.lock.lock()
    defer { self.lock.unlock() }
    // ...
}

// Solution: Use lock-free structures or atomic operations
```

### Pitfall 5: Memory Pressure

```swift
// Loading too many audio files at once
for file in hundredsOfFiles {
    let audioFile = try AVAudioFile(forReading: file)
    // Each file loads into memory
    // Memory warning → jetsam → app killed
}

// Solution: Stream large files, cache intelligently
class AudioCache {
    private var cache = LRUCache<URL, AVAudioFile>(maxCount: 10)

    func getFile(_ url: URL) throws -> AVAudioFile {
        if let cached = cache[url] {
            return cached
        }
        let file = try AVAudioFile(forReading: url)
        cache[url] = file
        return file
    }
}
```

---

## Key Takeaways

### For AWAVE

```
Your existing AWAVEAudioModule uses AVAudioEngine correctly.
Key architecture decisions:

1. One AVAudioEngine instance
2. Multiple AVAudioPlayerNodes (one per track)
3. Per-track effect chains (EQ, reverb, etc.)
4. All connected to mainMixerNode
5. Session category: .playback for background
6. Handle interruptions (phone calls)
7. Handle route changes (headphones)
```

### Mental Model

```
Audio is a REAL-TIME CONTRACT with hardware.
You promise to deliver samples on time.
If you break that promise, the user hears it.

Everything about audio programming optimizes for:
→ Predictable execution time
→ No blocking
→ No allocation in hot path
```

---

## Further Learning

- **Apple's Audio Unit Hosting Guide** - Deep dive into Audio Units
- **WWDC "What's New in AVAudioEngine"** - Yearly updates
- **The Audio Programmer YouTube** - DSP fundamentals
- **Designing Sound by Andy Farnell** - Sound design theory
