# Audio Engine

## AVFoundation Multi-Track System

The AWAVE audio engine is built on Apple's AVFoundation framework, providing professional-grade audio mixing with up to 7 simultaneous tracks.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AWAVEAudioEngine                                   │
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        AVAudioEngine                                   │  │
│  │                                                                        │  │
│  │  ┌─────────────┐  ┌─────────────┐       ┌─────────────┐              │  │
│  │  │ AVAudioNode │  │ AVAudioNode │  ...  │ AVAudioNode │              │  │
│  │  │  (Track 1)  │  │  (Track 2)  │       │  (Track 7)  │              │  │
│  │  └──────┬──────┘  └──────┬──────┘       └──────┬──────┘              │  │
│  │         │                │                     │                      │  │
│  │         └────────────────┼─────────────────────┘                      │  │
│  │                          ▼                                            │  │
│  │                  ┌───────────────┐                                    │  │
│  │                  │ AVAudioMixerNode │                                 │  │
│  │                  │   (Master)     │                                   │  │
│  │                  └───────┬───────┘                                    │  │
│  │                          │                                            │  │
│  │                  ┌───────▼───────┐                                    │  │
│  │                  │ AVAudioOutput │                                    │  │
│  │                  │     Node      │                                    │  │
│  │                  └───────────────┘                                    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────────┐  │
│  │   TrackManager   │  │  SessionTracker  │  │  ProceduralGenerator    │  │
│  │                  │  │                  │  │                          │  │
│  │  - Add/remove    │  │  - Start/end     │  │  - Waves                 │  │
│  │  - Volume        │  │  - Duration      │  │  - Rain                  │  │
│  │  - Mute/solo     │  │  - Analytics     │  │  - White/Pink/Brown noise│  │
│  │  - Loop          │  │                  │  │  - Binaural beats        │  │
│  └──────────────────┘  └──────────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Core Implementation

### AudioEngine Protocol

```swift
// Packages/AWAVEAudio/Sources/AWAVEAudio/AudioEngine.swift

import AVFoundation
import Combine

public protocol AudioEngineProtocol: Actor {
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }

    func prepareMix(_ mix: SoundMix) async throws -> [MixerTrack]
    func play()
    func pause()
    func stop()
    func seek(to time: TimeInterval)

    func addTrack(_ sound: Sound) async throws -> MixerTrack
    func removeTrack(_ trackId: String)
    func setVolume(_ volume: Float, for trackId: String)
    func setMuted(_ muted: Bool, for trackId: String)
}

// MixerTrack model
public struct MixerTrack: Identifiable, Sendable {
    public let id: String
    public let soundId: String
    public let name: String
    public var volume: Float
    public var isMuted: Bool
    public let duration: TimeInterval
    public let color: Color
    public let waveformData: [Float]
}

// SoundMix model
public struct SoundMix: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let sounds: [SoundMixItem]
    public let category: String
    public let thumbnailURL: URL?
}

public struct SoundMixItem: Sendable {
    public let soundId: String
    public let volume: Float
}
```

### AudioEngine Actor

```swift
// Packages/AWAVEAudio/Sources/AWAVEAudio/AWAVEAudioEngine.swift

import AVFoundation
import Combine

public actor AWAVEAudioEngine: AudioEngineProtocol {
    // MARK: - Properties

    private let engine = AVAudioEngine()
    private let mainMixer: AVAudioMixerNode
    private var playerNodes: [String: AVAudioPlayerNode] = [:]
    private var audioFiles: [String: AVAudioFile] = [:]
    private var tracks: [String: MixerTrack] = [:]

    private var displayLink: CADisplayLink?
    private var timeUpdateHandler: ((TimeInterval) -> Void)?

    public private(set) var isPlaying = false
    public private(set) var currentTime: TimeInterval = 0
    public var duration: TimeInterval {
        tracks.values.map(\.duration).max() ?? 0
    }

    // MARK: - Constants

    private let maxTracks = 7
    private let defaultFormat = AVAudioFormat(
        standardFormatWithSampleRate: 44100,
        channels: 2
    )!

    // MARK: - Initialization

    public init() {
        self.mainMixer = engine.mainMixerNode

        // Configure audio session
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowBluetooth, .allowAirPlay]
            )
            try session.setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    // MARK: - Mix Preparation

    public func prepareMix(_ mix: SoundMix) async throws -> [MixerTrack] {
        // Stop any existing playback
        stop()

        // Clear existing nodes
        await clearAllTracks()

        // Load each sound
        var loadedTracks: [MixerTrack] = []

        for item in mix.sounds {
            guard loadedTracks.count < maxTracks else { break }

            do {
                let track = try await loadSound(
                    id: item.soundId,
                    initialVolume: item.volume
                )
                loadedTracks.append(track)
            } catch {
                print("Failed to load sound \(item.soundId): \(error)")
                // Continue loading other sounds
            }
        }

        // Prepare engine
        engine.prepare()

        return loadedTracks
    }

    private func loadSound(id: String, initialVolume: Float) async throws -> MixerTrack {
        // Get local file URL (from cache or download)
        let fileURL = try await AudioFileManager.shared.getLocalURL(for: id)

        // Load audio file
        let audioFile = try AVAudioFile(forReading: fileURL)
        audioFiles[id] = audioFile

        // Create player node
        let playerNode = AVAudioPlayerNode()
        playerNodes[id] = playerNode

        // Attach and connect
        engine.attach(playerNode)
        engine.connect(playerNode, to: mainMixer, format: audioFile.processingFormat)

        // Set initial volume
        playerNode.volume = initialVolume

        // Schedule file for looping playback
        scheduleLoop(for: id)

        // Create track model
        let track = MixerTrack(
            id: id,
            soundId: id,
            name: try await getSoundName(id),
            volume: initialVolume,
            isMuted: false,
            duration: Double(audioFile.length) / audioFile.processingFormat.sampleRate,
            color: generateTrackColor(index: tracks.count),
            waveformData: try await loadWaveformData(for: id)
        )

        tracks[id] = track
        return track
    }

    private func scheduleLoop(for trackId: String) {
        guard let playerNode = playerNodes[trackId],
              let audioFile = audioFiles[trackId] else { return }

        // Reset file position
        audioFile.framePosition = 0

        // Schedule with loop
        playerNode.scheduleFile(audioFile, at: nil) { [weak self] in
            Task { @MainActor in
                await self?.scheduleLoop(for: trackId)
            }
        }
    }

    // MARK: - Playback Control

    public func play() {
        guard !isPlaying else { return }

        do {
            try engine.start()

            // Play all nodes
            for playerNode in playerNodes.values {
                playerNode.play()
            }

            isPlaying = true
            startTimeUpdates()
        } catch {
            print("Failed to start engine: \(error)")
        }
    }

    public func pause() {
        guard isPlaying else { return }

        for playerNode in playerNodes.values {
            playerNode.pause()
        }

        engine.pause()
        isPlaying = false
        stopTimeUpdates()
    }

    public func stop() {
        for playerNode in playerNodes.values {
            playerNode.stop()
        }

        engine.stop()
        isPlaying = false
        currentTime = 0
        stopTimeUpdates()
    }

    public func seek(to time: TimeInterval) {
        let wasPlaying = isPlaying

        // Stop all nodes
        for playerNode in playerNodes.values {
            playerNode.stop()
        }

        // Reschedule from new position
        for (trackId, audioFile) in audioFiles {
            let sampleRate = audioFile.processingFormat.sampleRate
            let framePosition = AVAudioFramePosition(time * sampleRate)

            audioFile.framePosition = min(framePosition, audioFile.length)
            scheduleLoop(for: trackId)
        }

        currentTime = time

        // Resume if was playing
        if wasPlaying {
            for playerNode in playerNodes.values {
                playerNode.play()
            }
        }
    }

    // MARK: - Track Management

    public func addTrack(_ sound: Sound) async throws -> MixerTrack {
        guard tracks.count < maxTracks else {
            throw AudioEngineError.maxTracksReached
        }

        let track = try await loadSound(id: sound.id, initialVolume: 0.8)

        // Start playing if engine is running
        if isPlaying, let playerNode = playerNodes[sound.id] {
            playerNode.play()
        }

        return track
    }

    public func removeTrack(_ trackId: String) {
        guard let playerNode = playerNodes[trackId] else { return }

        // Stop and remove
        playerNode.stop()
        engine.detach(playerNode)

        playerNodes.removeValue(forKey: trackId)
        audioFiles.removeValue(forKey: trackId)
        tracks.removeValue(forKey: trackId)
    }

    public func setVolume(_ volume: Float, for trackId: String) {
        playerNodes[trackId]?.volume = volume
        tracks[trackId]?.volume = volume
    }

    public func setMuted(_ muted: Bool, for trackId: String) {
        if muted {
            playerNodes[trackId]?.volume = 0
        } else {
            playerNodes[trackId]?.volume = tracks[trackId]?.volume ?? 0.8
        }
        tracks[trackId]?.isMuted = muted
    }

    // MARK: - Time Updates

    private func startTimeUpdates() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task {
                await self?.updateCurrentTime()
            }
        }
        RunLoop.current.add(timer, forMode: .common)
    }

    private func stopTimeUpdates() {
        // Timer cleanup handled by invalidation
    }

    private func updateCurrentTime() {
        guard isPlaying,
              let firstPlayer = playerNodes.values.first,
              let nodeTime = firstPlayer.lastRenderTime,
              let playerTime = firstPlayer.playerTime(forNodeTime: nodeTime) else { return }

        let sampleRate = playerTime.sampleRate
        currentTime = Double(playerTime.sampleTime) / sampleRate
    }

    // MARK: - Cleanup

    private func clearAllTracks() async {
        for trackId in playerNodes.keys {
            removeTrack(trackId)
        }
    }

    // MARK: - Helpers

    private func generateTrackColor(index: Int) -> Color {
        let colors: [Color] = [
            .blue, .purple, .pink, .orange, .green, .cyan, .yellow
        ]
        return colors[index % colors.count]
    }
}

// MARK: - Errors

public enum AudioEngineError: Error, LocalizedError {
    case maxTracksReached
    case fileNotFound(String)
    case playbackFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .maxTracksReached:
            return "Maximum number of tracks (7) reached"
        case .fileNotFound(let id):
            return "Audio file not found: \(id)"
        case .playbackFailed(let error):
            return "Playback failed: \(error.localizedDescription)"
        }
    }
}
```

---

## Procedural Sound Generation

```swift
// Packages/AWAVEAudio/Sources/AWAVEAudio/ProceduralGenerator.swift

import AVFoundation
import Accelerate

public actor ProceduralSoundGenerator {
    // MARK: - Types

    public enum SoundType {
        case whiteNoise
        case pinkNoise
        case brownNoise
        case waves
        case rain
        case binauralBeat(baseFrequency: Double, beatFrequency: Double)
    }

    // MARK: - Properties

    private let sampleRate: Double = 44100
    private let bufferSize: AVAudioFrameCount = 4096

    // MARK: - Generation

    public func generateBuffer(type: SoundType) -> AVAudioPCMBuffer? {
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: AVAudioFormat(
                standardFormatWithSampleRate: sampleRate,
                channels: 2
            )!,
            frameCapacity: bufferSize
        ) else { return nil }

        buffer.frameLength = bufferSize

        guard let leftChannel = buffer.floatChannelData?[0],
              let rightChannel = buffer.floatChannelData?[1] else { return nil }

        switch type {
        case .whiteNoise:
            generateWhiteNoise(left: leftChannel, right: rightChannel)

        case .pinkNoise:
            generatePinkNoise(left: leftChannel, right: rightChannel)

        case .brownNoise:
            generateBrownNoise(left: leftChannel, right: rightChannel)

        case .waves:
            generateWaves(left: leftChannel, right: rightChannel)

        case .rain:
            generateRain(left: leftChannel, right: rightChannel)

        case .binauralBeat(let base, let beat):
            generateBinauralBeat(
                left: leftChannel,
                right: rightChannel,
                baseFrequency: base,
                beatFrequency: beat
            )
        }

        return buffer
    }

    // MARK: - White Noise

    private func generateWhiteNoise(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>) {
        for i in 0..<Int(bufferSize) {
            let sample = Float.random(in: -1...1) * 0.3
            left[i] = sample
            right[i] = sample
        }
    }

    // MARK: - Pink Noise (1/f noise)

    private var pinkNoiseState: [Float] = [0, 0, 0, 0, 0, 0, 0]

    private func generatePinkNoise(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>) {
        for i in 0..<Int(bufferSize) {
            let white = Float.random(in: -1...1)

            pinkNoiseState[0] = 0.99886 * pinkNoiseState[0] + white * 0.0555179
            pinkNoiseState[1] = 0.99332 * pinkNoiseState[1] + white * 0.0750759
            pinkNoiseState[2] = 0.96900 * pinkNoiseState[2] + white * 0.1538520
            pinkNoiseState[3] = 0.86650 * pinkNoiseState[3] + white * 0.3104856
            pinkNoiseState[4] = 0.55000 * pinkNoiseState[4] + white * 0.5329522
            pinkNoiseState[5] = -0.7616 * pinkNoiseState[5] - white * 0.0168980

            let pink = (pinkNoiseState.reduce(0, +) + white * 0.5362) * 0.11
            left[i] = pink
            right[i] = pink
        }
    }

    // MARK: - Brown Noise (random walk)

    private var brownNoiseState: Float = 0

    private func generateBrownNoise(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>) {
        for i in 0..<Int(bufferSize) {
            let white = Float.random(in: -1...1)
            brownNoiseState += white * 0.02
            brownNoiseState = max(-1, min(1, brownNoiseState)) // Clamp

            let sample = brownNoiseState * 0.5
            left[i] = sample
            right[i] = sample
        }
    }

    // MARK: - Ocean Waves

    private var wavePhase: Double = 0

    private func generateWaves(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>) {
        let baseFreq = 0.1 // Very low frequency for wave rhythm
        let phaseIncrement = (2.0 * .pi * baseFreq) / sampleRate

        for i in 0..<Int(bufferSize) {
            // Multiple sine waves for organic sound
            let wave1 = sin(wavePhase) * 0.3
            let wave2 = sin(wavePhase * 1.5) * 0.2
            let wave3 = sin(wavePhase * 0.5) * 0.15

            // Add filtered noise for texture
            let noise = Float.random(in: -0.1...0.1)

            // Amplitude modulation for wave crests
            let envelope = Float((1 + sin(wavePhase * 0.1)) * 0.5)

            let sample = Float(wave1 + wave2 + wave3) * envelope + noise * envelope
            left[i] = sample
            right[i] = sample

            wavePhase += phaseIncrement
            if wavePhase > 2.0 * .pi * 1000 {
                wavePhase -= 2.0 * .pi * 1000
            }
        }
    }

    // MARK: - Rain

    private var rainDrops: [(phase: Double, amplitude: Float, decay: Float)] = []

    private func generateRain(left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>) {
        // Randomly add new drops
        if Float.random(in: 0...1) < 0.02 {
            rainDrops.append((
                phase: Double.random(in: 0...2 * .pi),
                amplitude: Float.random(in: 0.1...0.4),
                decay: Float.random(in: 0.995...0.999)
            ))
        }

        for i in 0..<Int(bufferSize) {
            var sample: Float = 0

            // Base rain ambience (filtered noise)
            sample += Float.random(in: -0.05...0.05)

            // Individual drops
            for j in (0..<rainDrops.count).reversed() {
                let freq = 800 + Double.random(in: 0...400)
                let dropSample = sin(rainDrops[j].phase) * rainDrops[j].amplitude
                sample += Float(dropSample)

                rainDrops[j].phase += (2.0 * .pi * freq) / sampleRate
                rainDrops[j].amplitude *= rainDrops[j].decay

                // Remove faded drops
                if rainDrops[j].amplitude < 0.001 {
                    rainDrops.remove(at: j)
                }
            }

            left[i] = sample
            right[i] = sample
        }
    }

    // MARK: - Binaural Beats

    private var binauralPhaseLeft: Double = 0
    private var binauralPhaseRight: Double = 0

    private func generateBinauralBeat(
        left: UnsafeMutablePointer<Float>,
        right: UnsafeMutablePointer<Float>,
        baseFrequency: Double,
        beatFrequency: Double
    ) {
        let leftFreq = baseFrequency
        let rightFreq = baseFrequency + beatFrequency

        let leftIncrement = (2.0 * .pi * leftFreq) / sampleRate
        let rightIncrement = (2.0 * .pi * rightFreq) / sampleRate

        for i in 0..<Int(bufferSize) {
            left[i] = Float(sin(binauralPhaseLeft)) * 0.5
            right[i] = Float(sin(binauralPhaseRight)) * 0.5

            binauralPhaseLeft += leftIncrement
            binauralPhaseRight += rightIncrement

            // Wrap phases
            if binauralPhaseLeft > 2.0 * .pi * 1000 { binauralPhaseLeft -= 2.0 * .pi * 1000 }
            if binauralPhaseRight > 2.0 * .pi * 1000 { binauralPhaseRight -= 2.0 * .pi * 1000 }
        }
    }
}
```

---

## Audio File Manager

```swift
// Packages/AWAVEAudio/Sources/AWAVEAudio/AudioFileManager.swift

import Foundation

public actor AudioFileManager {
    public static let shared = AudioFileManager()

    // MARK: - Properties

    private let cacheDirectory: URL
    private let maxCacheSize: UInt64 = 2 * 1024 * 1024 * 1024 // 2GB
    private var cachedFiles: [String: CachedFile] = [:]

    private struct CachedFile {
        let url: URL
        let size: UInt64
        var lastAccessed: Date
    }

    // MARK: - Initialization

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = caches.appendingPathComponent("AudioCache", isDirectory: true)

        // Create cache directory
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        // Load existing cache index
        Task {
            await loadCacheIndex()
        }
    }

    // MARK: - Public API

    public func getLocalURL(for soundId: String) async throws -> URL {
        // Check cache first
        if let cached = cachedFiles[soundId] {
            cachedFiles[soundId]?.lastAccessed = Date()
            return cached.url
        }

        // Download from Cloud Storage
        let remoteURL = try await getRemoteURL(for: soundId)
        let localURL = cacheDirectory.appendingPathComponent("\(soundId).mp3")

        let (tempURL, _) = try await URLSession.shared.download(from: remoteURL)
        try FileManager.default.moveItem(at: tempURL, to: localURL)

        // Add to cache
        let size = try FileManager.default.attributesOfItem(atPath: localURL.path)[.size] as? UInt64 ?? 0
        cachedFiles[soundId] = CachedFile(url: localURL, size: size, lastAccessed: Date())

        // Cleanup if needed
        await cleanupCacheIfNeeded()

        return localURL
    }

    public func isDownloaded(_ soundId: String) -> Bool {
        cachedFiles[soundId] != nil
    }

    public func downloadedSize() -> UInt64 {
        cachedFiles.values.reduce(0) { $0 + $1.size }
    }

    public func clearCache() async {
        for (_, file) in cachedFiles {
            try? FileManager.default.removeItem(at: file.url)
        }
        cachedFiles.removeAll()
    }

    // MARK: - Private Helpers

    private func getRemoteURL(for soundId: String) async throws -> URL {
        // Get signed URL from Firestore or Cloud Function
        let sound = try await FirestoreService.shared.getSound(id: soundId)
        return URL(string: sound.fileUrl)!
    }

    private func loadCacheIndex() {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]
        ) else { return }

        for file in files {
            let soundId = file.deletingPathExtension().lastPathComponent
            let attrs = try? FileManager.default.attributesOfItem(atPath: file.path)
            let size = attrs?[.size] as? UInt64 ?? 0
            let modified = attrs?[.modificationDate] as? Date ?? Date()

            cachedFiles[soundId] = CachedFile(url: file, size: size, lastAccessed: modified)
        }
    }

    private func cleanupCacheIfNeeded() async {
        let currentSize = downloadedSize()
        guard currentSize > maxCacheSize else { return }

        // Sort by last accessed (LRU)
        let sorted = cachedFiles.sorted { $0.value.lastAccessed < $1.value.lastAccessed }

        var freedSize: UInt64 = 0
        let targetFree = currentSize - (maxCacheSize * 80 / 100) // Free to 80%

        for (soundId, file) in sorted {
            guard freedSize < targetFree else { break }

            try? FileManager.default.removeItem(at: file.url)
            cachedFiles.removeValue(forKey: soundId)
            freedSize += file.size
        }
    }
}
```

---

## Background Audio Support

```swift
// Packages/AWAVEAudio/Sources/AWAVEAudio/BackgroundAudioHandler.swift

import AVFoundation
import MediaPlayer

public class BackgroundAudioHandler {
    public static let shared = BackgroundAudioHandler()

    private var nowPlayingInfo: [String: Any] = [:]

    private init() {
        setupRemoteCommands()
        setupInterruptionHandling()
    }

    // MARK: - Remote Commands

    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        // Play
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task {
                await AWAVEAudioEngine.shared.play()
            }
            return .success
        }

        // Pause
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task {
                await AWAVEAudioEngine.shared.pause()
            }
            return .success
        }

        // Skip forward/backward (disabled for ambient audio)
        commandCenter.skipForwardCommand.isEnabled = false
        commandCenter.skipBackwardCommand.isEnabled = false

        // Seeking
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            Task {
                await AWAVEAudioEngine.shared.seek(to: event.positionTime)
            }
            return .success
        }
    }

    // MARK: - Now Playing Info

    public func updateNowPlayingInfo(
        title: String,
        artist: String = "AWAVE",
        artwork: UIImage? = nil,
        duration: TimeInterval,
        currentTime: TimeInterval,
        isPlaying: Bool
    ) {
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        if let artwork = artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                boundsSize: artwork.size
            ) { _ in artwork }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    // MARK: - Interruption Handling

    private func setupInterruptionHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            // Pause playback
            Task {
                await AWAVEAudioEngine.shared.pause()
            }

        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)

            if options.contains(.shouldResume) {
                // Resume playback
                Task {
                    await AWAVEAudioEngine.shared.play()
                }
            }

        @unknown default:
            break
        }
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        switch reason {
        case .oldDeviceUnavailable:
            // Headphones unplugged - pause
            Task {
                await AWAVEAudioEngine.shared.pause()
            }

        default:
            break
        }
    }
}
```

---

## Waveform Generation

```swift
// Packages/AWAVEAudio/Sources/AWAVEAudio/WaveformGenerator.swift

import AVFoundation
import Accelerate

public struct WaveformGenerator {
    public static func generate(from url: URL, samples: Int = 100) async throws -> [Float] {
        let file = try AVAudioFile(forReading: url)
        let format = file.processingFormat
        let frameCount = UInt32(file.length)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw WaveformError.bufferCreationFailed
        }

        try file.read(into: buffer)

        guard let floatData = buffer.floatChannelData?[0] else {
            throw WaveformError.noAudioData
        }

        // Downsample to desired number of samples
        let framesPerSample = Int(frameCount) / samples
        var waveform: [Float] = []

        for i in 0..<samples {
            let startFrame = i * framesPerSample
            let endFrame = min(startFrame + framesPerSample, Int(frameCount))

            // Calculate RMS for this segment
            var sum: Float = 0
            vDSP_svesq(floatData + startFrame, 1, &sum, vDSP_Length(endFrame - startFrame))
            let rms = sqrt(sum / Float(endFrame - startFrame))

            waveform.append(rms)
        }

        // Normalize
        if let maxVal = waveform.max(), maxVal > 0 {
            waveform = waveform.map { $0 / maxVal }
        }

        return waveform
    }
}

public enum WaveformError: Error {
    case bufferCreationFailed
    case noAudioData
}
```

---

## Usage Example

```swift
// In a SwiftUI View
struct PlayerView: View {
    @State private var engine = AWAVEAudioEngine()
    @State private var tracks: [MixerTrack] = []
    @State private var isPlaying = false

    let mix: SoundMix

    var body: some View {
        VStack {
            // Waveform visualization
            WaveformView(tracks: tracks)

            // Track controls
            ForEach(tracks) { track in
                TrackControlView(
                    track: track,
                    onVolumeChange: { volume in
                        Task {
                            await engine.setVolume(volume, for: track.id)
                        }
                    }
                )
            }

            // Play/Pause button
            Button {
                Task {
                    if isPlaying {
                        await engine.pause()
                    } else {
                        await engine.play()
                    }
                    isPlaying.toggle()
                }
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.largeTitle)
            }
        }
        .task {
            do {
                tracks = try await engine.prepareMix(mix)
            } catch {
                print("Failed to prepare mix: \(error)")
            }
        }
    }
}
```
