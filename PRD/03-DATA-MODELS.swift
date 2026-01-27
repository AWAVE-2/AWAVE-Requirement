// AWAVE - Swift Data Models
// Extracted from: session-object.js, content-database.js, upgrade-demo.js
// Target: Swift 5.9+ / SwiftUI / iOS 17+

import Foundation

// MARK: - Session Configuration

/// Root session container. Index 0 is always the config, indices 1..N are phases.
struct AWAVESession: Codable, Identifiable {
    let id: String // "AWAVE-Session"
    var name: String // User-defined or auto-generated
    var infoText: String
    var duration: Int // Total seconds (computed from all phases)
    var timer: Int // Countdown during playback
    var voice: Voice
    var version: Double // 1.3
    var livePhase: Int // Current playing phase index (0 = not playing)
    var topic: String // Theme identifier for background
    var type: SessionType
    var enableFreq: Bool

    var phases: [SessionPhase]

    /// Recomputes total duration from all phases
    mutating func refreshDuration() {
        duration = phases.reduce(0) { $0 + $1.duration }
    }
}

enum SessionType: String, Codable {
    case guided
    case soundscape
}

enum Voice: String, Codable, CaseIterable {
    case Franca
    case Flo
    case Marion
    case Corinna
}

// MARK: - Session Phase

struct SessionPhase: Codable, Identifiable {
    let id: UUID
    var name: String
    var h1: String // Category heading
    var h2: String // Content heading
    var duration: Int // Seconds (minimum 60)
    var sleepCheck: Bool

    var text: TextLayer
    var music: MusicLayer
    var nature: NatureLayer
    var sound: SoundLayer
    var noise: NoiseLayer
    var frequency: FrequencyLayer

    init(
        name: String = "Stille",
        h1: String = "Stille",
        h2: String = " ",
        duration: Int = 60,
        sleepCheck: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.h1 = h1
        self.h2 = h2
        self.duration = duration
        self.sleepCheck = sleepCheck
        self.text = TextLayer()
        self.music = MusicLayer()
        self.nature = NatureLayer()
        self.sound = SoundLayer()
        self.noise = NoiseLayer()
        self.frequency = FrequencyLayer()
    }
}

// MARK: - Audio Layers

/// Guided voice text layer
struct TextLayer: Codable {
    var content: String // Content DB identifier or "noText"
    var volume: Int // 0-100
    var fadeIn: Int // Seconds
    var fadeOut: Int // Seconds
    var delayInc: Double // Delay increment factor
    var delayMin: Int // Minimum delay between loops (seconds)
    var delayMax: Int // Maximum delay between loops (seconds)
    var interval: Int // Not used for text (legacy)
    var mix: MixMode

    init(
        content: String = "noText",
        volume: Int = 50,
        fadeIn: Int = 0,
        fadeOut: Int = 0,
        delayInc: Double = 0,
        delayMin: Int = 0,
        delayMax: Int = 0,
        interval: Int = 0,
        mix: MixMode = .mute
    ) {
        self.content = content
        self.volume = volume
        self.fadeIn = fadeIn
        self.fadeOut = fadeOut
        self.delayInc = delayInc
        self.delayMin = delayMin
        self.delayMax = delayMax
        self.interval = interval
        self.mix = mix
    }
}

/// Background music layer
struct MusicLayer: Codable {
    var content: String // Content DB identifier or "noMusic"
    var volume: Int // 0-100
    var fadeIn: Int // Seconds
    var fadeOut: Int // Seconds
    var mix: MixMode

    init(
        content: String = "noMusic",
        volume: Int = 50,
        fadeIn: Int = 0,
        fadeOut: Int = 0,
        mix: MixMode = .mute
    ) {
        self.content = content
        self.volume = volume
        self.fadeIn = fadeIn
        self.fadeOut = fadeOut
        self.mix = mix
    }
}

/// Nature sounds layer
struct NatureLayer: Codable {
    var content: String // Content DB identifier or "noNature"
    var volume: Int // 0-100
    var fadeIn: Int // Seconds
    var fadeOut: Int // Seconds
    var mix: MixMode

    init(
        content: String = "noNature",
        volume: Int = 50,
        fadeIn: Int = 0,
        fadeOut: Int = 0,
        mix: MixMode = .mute
    ) {
        self.content = content
        self.volume = volume
        self.fadeIn = fadeIn
        self.fadeOut = fadeOut
        self.mix = mix
    }
}

/// Discrete sound effects layer
struct SoundLayer: Codable {
    var content: String // Content DB identifier or "noSound"
    var volume: Int // 0-100
    var interval: SoundInterval

    init(
        content: String = "noSound",
        volume: Int = 50,
        interval: SoundInterval = .off
    ) {
        self.content = content
        self.volume = volume
        self.interval = interval
    }
}

/// Sound interval can be a string keyword or numeric minutes
enum SoundInterval: Codable, Equatable {
    case start // Play at phase start
    case end // Play at phase end
    case off // No playback
    case minutes(Int) // Repeat every N minutes

    // Custom Codable for backwards compatibility with JS format
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            switch str {
            case "start": self = .start
            case "end": self = .end
            case "off": self = .off
            default: self = .off
            }
        } else if let num = try? container.decode(Int.self) {
            self = num == 0 ? .off : .minutes(num)
        } else {
            self = .off
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .start: try container.encode("start")
        case .end: try container.encode("end")
        case .off: try container.encode("off")
        case .minutes(let n): try container.encode(n)
        }
    }
}

/// Colored noise generation layer
struct NoiseLayer: Codable {
    var content: String // "noNoise" | "white" | "pink" | "brown" | "grey" | "blue" | "violet" | "*Sync" variants
    var volume: Int // 0-100
    var fadeIn: Int // Seconds
    var fadeOut: Int // Seconds
    var startBalance: Double // -1.0 (left) to 1.0 (right), 0.0 = center
    var targetBalance: Double // Target balance for sweep

    // Runtime audio context properties (NOT persisted)
    // These live in the audio engine, not in the model

    init(
        content: String = "noNoise",
        volume: Int = 50,
        fadeIn: Int = 0,
        fadeOut: Int = 0,
        startBalance: Double = 0,
        targetBalance: Double = 0
    ) {
        self.content = content
        self.volume = volume
        self.fadeIn = fadeIn
        self.fadeOut = fadeOut
        self.startBalance = startBalance
        self.targetBalance = targetBalance
    }

    var isNeuroFlow: Bool {
        content.hasSuffix("Sync")
    }

    var baseNoiseType: String {
        content.replacingOccurrences(of: "Sync", with: "")
    }
}

/// Frequency synthesis layer (binaural beats, isochronic tones, Shepard tones, etc.)
struct FrequencyLayer: Codable {
    var content: String // Frequency type or "noFreq"
    var volume: Int // 0-100
    var fadeIn: Int // Seconds
    var fadeOut: Int // Seconds
    var direction: SweepDirection
    var startPulsFreq: Double // 1-40 Hz
    var targetPulsFreq: Double // 1-40 Hz
    var startRootFreq: Double // From predefined array
    var targetRootFreq: Double // From predefined array
    var enabled: Bool // "on" / "off" in JS, mapped to Bool

    // Runtime audio context properties (NOT persisted)
    // These live in the audio engine, not in the model

    init(
        content: String = "noFreq",
        volume: Int = 50,
        fadeIn: Int = 0,
        fadeOut: Int = 0,
        direction: SweepDirection = .down,
        startPulsFreq: Double = 12,
        targetPulsFreq: Double = 12,
        startRootFreq: Double = 216,
        targetRootFreq: Double = 216,
        enabled: Bool = true
    ) {
        self.content = content
        self.volume = volume
        self.fadeIn = fadeIn
        self.fadeOut = fadeOut
        self.direction = direction
        self.startPulsFreq = startPulsFreq
        self.targetPulsFreq = targetPulsFreq
        self.startRootFreq = startRootFreq
        self.targetRootFreq = targetRootFreq
        self.enabled = enabled
    }

    /// Brainwave band for a given frequency
    static func brainwaveBand(for freq: Double) -> String {
        switch freq {
        case 38...: return "Gamma"
        case 13..<38: return "Beta"
        case 8..<13: return "Alpha"
        case 4..<8: return "Theta"
        case 1..<4: return "Delta"
        default: return "Sub-Delta"
        }
    }
}

enum SweepDirection: String, Codable {
    case up
    case down
    case consistent
}

enum MixMode: String, Codable {
    case one // Play once, duration locked to audio length
    case loop // Repeat with delay
    case mute // No audio (silence)
}

// MARK: - Frequency Types

/// All available frequency generation modes
enum FrequencyType: String, CaseIterable {
    // Standard
    case root // Pure root frequency
    case binaural // L/R frequency difference
    case monaural // Two tones merged to mono
    case isochronic // Pulsed on/off
    case bilateral // Alternating L/R pulsing
    case molateral // Monaural alternating L/R

    // AWAVE proprietary (Shepard-based)
    case shepard // Multi-octave infinite sweep
    case isoflow // Shepard + isochronic
    case bilawave // Shepard + bilateral
    case binawave // Shepard + binaural
    case monawave // Shepard + monaural
    case flowlateral // Shepard + molateral

    /// Number of base oscillators needed
    var oscillatorCount: Int {
        switch self {
        case .root, .isochronic, .bilateral: return 1
        case .binaural, .monaural: return 2
        case .molateral: return 4
        case .shepard, .isoflow, .bilawave: return -1 // Dynamic (octave-based)
        case .binawave, .monawave: return -1 // Dynamic * 2
        case .flowlateral: return -1 // Dynamic * 4
        }
    }

    /// Whether this type requires stereo channel merger
    var requiresMerger: Bool {
        switch self {
        case .bilateral, .binaural, .molateral,
             .bilawave, .binawave, .flowlateral:
            return true
        default:
            return false
        }
    }

    /// Auto-downgrade for >8Hz pulse frequency
    var highFrequencyFallback: FrequencyType? {
        switch self {
        case .isochronic: return .monaural
        case .bilateral: return .molateral
        case .isoflow: return .monawave
        case .bilawave: return .flowlateral
        default: return nil
        }
    }
}

// MARK: - Content Database

/// Represents a content item in the database
struct ContentItem: Codable, Identifiable {
    let id: String // Unique identifier (also used as const name in JS)
    let displayName: String // dbList
    let h1: String // Category heading
    let h2: String // Content heading
    let type: ContentType
    let category: String
    let mix: MixMode
    let counter: Int // Repetition count (for loop content)
    let topic: String // Visual theme
    let files: [AudioFileGroup] // Audio file references
    let playtime: [Voice: Int]? // Duration per voice (text content only)
}

enum ContentType: String, Codable {
    case text
    case music
    case nature
    case frequency
    case noise
    case sound
}

/// Audio file group for content with multiple audio files
/// JS uses a nested array structure: [deliveryIndex, [filePaths]]
struct AudioFileGroup: Codable {
    var deliveryIndex: Int
    var filePaths: [String]
}

// MARK: - Noise Types

enum NoiseColor: String, CaseIterable {
    case white
    case pink
    case brown
    case grey
    case blue
    case violet

    var displayName: String {
        switch self {
        case .white: return "Weisses Rauschen"
        case .pink: return "Pinkes Rauschen"
        case .brown: return "Braunes Rauschen"
        case .grey: return "Graues Rauschen"
        case .blue: return "Blaues Rauschen"
        case .violet: return "Violettes Rauschen"
        }
    }

    var syncVariant: String {
        rawValue + "Sync"
    }

    var neuroFlowDisplayName: String {
        "NeuroFlow: " + rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var audioFileName: String {
        "noise/\(rawValue).mp3"
    }
}

// MARK: - Root Frequency Presets

/// Predefined root frequencies available in the editor
let rootFrequencyPresets: [Double] = [
    33, 44, 54, 55, 60, 66, 77, 88, 99, 100, 108, 111, 174, 200, 216, 222, 285,
    300, 333, 396, 400, 417, 432, 440, 444, 500, 528, 555, 600, 639, 666,
    700, 741, 777, 800, 852, 864, 888, 900, 963, 999, 1000, 1111
]

// MARK: - User State

enum UserTier: String, Codable {
    case demo
    case user // Subscriber
    case pro
}

enum SubscriptionPlan: String, Codable {
    case monthly
    case yearly
}

struct UserState: Codable {
    var tier: UserTier
    var subscription: SubscriptionPlan?
    var purchaseDate: Date?
    var userName: String?
}

// MARK: - Favorites Storage

/// Container for persistent favorites storage
struct FavoritesStore: Codable {
    var sessions: [AWAVESession]

    init() {
        self.sessions = []
    }

    mutating func add(_ session: AWAVESession, name: String) {
        var copy = session
        var saveName = name
        var suffix = 2

        // Handle duplicate names
        while sessions.contains(where: { $0.name == saveName }) {
            saveName = "\(name) (\(suffix))"
            suffix += 1
        }

        copy.name = saveName
        copy.topic = "user"
        sessions.append(copy)
    }

    mutating func remove(named name: String) {
        sessions.removeAll { $0.name == name }
    }

    mutating func removeAll() {
        sessions.removeAll()
    }
}

// MARK: - Import / Export

/// Session file format (.awave)
/// Encoded as: Base64(JSON(AWAVESession))
struct AWAVEFile {
    static let fileExtension = "awave"

    static func encode(_ session: AWAVESession) throws -> Data {
        let jsonData = try JSONEncoder().encode(session)
        let base64String = jsonData.base64EncodedString()
        return Data(base64String.utf8)
    }

    static func decode(_ data: Data) throws -> AWAVESession {
        guard let base64String = String(data: data, encoding: .utf8),
              let jsonData = Data(base64: base64String) else {
            throw AWAVEFileError.invalidFormat
        }

        let session = try JSONDecoder().decode(AWAVESession.self, from: jsonData)

        guard session.id == "AWAVE-Session" else {
            throw AWAVEFileError.invalidSession
        }

        // Version compatibility check
        guard session.version >= 1.3 else {
            throw AWAVEFileError.incompatibleVersion
        }

        return session
    }
}

enum AWAVEFileError: LocalizedError {
    case invalidFormat
    case invalidSession
    case incompatibleVersion

    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Die ausgewaehlte Datei ist keine gueltige AWAVE-Session!"
        case .invalidSession:
            return "Die ausgewaehlte Datei ist keine gueltige AWAVE-Session!"
        case .incompatibleVersion:
            return "Die Session ist veraltet und mit dieser Version der AWAVE-App nicht kompatibel!"
        }
    }
}

// MARK: - Timer

/// Phase timer step increments (non-linear, matching JS behavior)
struct PhaseTimerSteps {
    /// Steps for decreasing duration
    static func decrementStep(from current: Int) -> Int {
        switch current {
        case (45 * 60)...: return 15 * 60
        case (30 * 60): return 10 * 60
        case (10 * 60)...: return 5 * 60
        case (2 * 60)...: return 60
        default: return 0 // Cannot go below 60s
        }
    }

    /// Steps for increasing duration
    static func incrementStep(from current: Int) -> Int {
        switch current {
        case ..<(5 * 60): return 60
        case ..<(16 * 60): return 5 * 60
        case (20 * 60): return 10 * 60
        case (30 * 60)...: return 15 * 60
        default: return 5 * 60
        }
    }
}

// MARK: - Fade Step Increments

/// Non-linear fade duration steps (matching JS behavior)
struct FadeSteps {
    static func decrementStep(from current: Int) -> Int {
        switch current {
        case (45 * 60)...: return 15 * 60
        case (30 * 60): return 10 * 60
        case (10 * 60)...: return 5 * 60
        case (61)...: return 60
        case 31...: return 30
        case 30: return 10
        case 6...: return 5
        default: return current // -> 0
        }
    }

    static func incrementStep(from current: Int) -> Int {
        switch current {
        case ..<20: return 5
        case ..<30: return 10
        case ..<60: return 30
        case ..<(5 * 60): return 60
        case ..<(20 * 60): return 5 * 60
        case (20 * 60): return 10 * 60
        case (30 * 60)...: return 15 * 60
        default: return 60
        }
    }
}

// MARK: - NeuroFlow Filter Configuration

/// Configuration for NeuroFlow sync noise processing
struct NeuroFlowConfig {
    static let syncInterval: TimeInterval = 12 // seconds
    static let filterChannels: Int = 3
    static let filterQ: Float = 2.0

    static let startFrequencies: [Float] = [1, 250, 1000]
    static let targetFrequencies: [Float] = [2000, 7000, 20000]

    /// Balance step size for editor controls
    static let balanceStep: Double = 0.2
    static let balanceRange: ClosedRange<Double> = -1.0...1.0
}

// MARK: - Subscription Products

struct SubscriptionProducts {
    static let apple = AppleProducts()
    static let google = GoogleProducts()

    struct AppleProducts {
        let yearly = "awave_premium_sparpaket"
        let monthly = "awave_premium_flexibel"
    }

    struct GoogleProducts {
        let yearly = "awave.jaehrlich"
        let monthly = "awave.monatlich"
    }
}
