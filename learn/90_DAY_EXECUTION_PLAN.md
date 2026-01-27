# 90-Day iOS Mastery Execution Plan

> **Goal**: From React Native veteran → Production iOS native app
> **Context**: Migrating AWAVE Advanced (meditation app) to native Swift/SwiftUI
> **Tailored For**: 10 years system design + fullstack experience

---

## Strategic Improvements Applied

### Reordered Phases (SwiftUI First)

```
Original:  UIKit → SwiftUI
Optimized: SwiftUI → UIKit

Why:
- SwiftUI is first-class in 2024+
- Your React mental model maps directly to SwiftUI
- UIKit becomes "systems layer" not primary skill
- You touch UIKit only when SwiftUI hits walls
```

### Added Critical Phases

```
NEW: Phase 2.5 → Advanced Swift Type System
NEW: Phase X   → Swift Concurrency Deep Dive
NEW: Phase Y   → Performance & Diagnostics
NEW: Sections  → App Extensions, Background Execution, Accessibility, Localization
```

---

## Month 1: Language + UI Fluency

### Week 1: Swift Fundamentals (Not Syntax—Paradigms)

**Daily Focus (2-3 hours/day)**

| Day | Topic | Exercise | Output |
|-----|-------|----------|--------|
| 1 | Optionals Deep Dive | 20 unwrapping patterns | Playground |
| 2 | Value vs Reference Types | Struct/Class comparison | Playground |
| 3 | Protocols + Extensions | Build protocol hierarchy | Playground |
| 4 | Enums with Associated Values | Result type, error states | Playground |
| 5 | Closures & Capture Lists | Memory capture patterns | Playground |
| 6 | Generics & Constraints | Generic data structures | Playground |
| 7 | Review + Mini Project | CLI tool in Swift | `awave-cli` |

**Week 1 Exercises**

```swift
// Exercise 1: Optional Gymnastics
// Convert this JS error handling to Swift optionals
// JS: const user = response?.data?.user ?? defaultUser
// Swift: ???

// Exercise 2: Protocol Power
// Create a protocol that both UIKit and SwiftUI views can conform to
protocol Themeable {
    var primaryColor: Color { get }
    func applyTheme()
}

// Exercise 3: Enum State Machine
// Model the AWAVE player states as an enum
enum PlayerState {
    case idle
    case loading(trackId: String)
    case playing(track: Track, progress: Double)
    case paused(track: Track, position: Double)
    case error(Error)
}
```

**Output**: Swift playground with 20+ experiments demonstrating each concept

---

### Week 1.5: Advanced Swift Type System (NEW PHASE)

**The Type System Is Swift's Superpower**

| Day | Topic | Key Insight |
|-----|-------|-------------|
| 1 | `any` vs `some` | Existentials vs opaque types |
| 2 | Associated Types | Protocol with placeholder types |
| 3 | Generic Constraints | `where` clauses, `Self` requirements |
| 4 | Value Semantics | Copy-on-write, `Equatable`, `Hashable` |
| 5 | Type Erasure | `AnyPublisher`, `AnyView` patterns |

```swift
// Exercise: Type System Mastery

// 1. Understand the difference
func returnsSome() -> some View { Text("Hello") }  // Compiler knows exact type
func returnsAny() -> any View { Text("Hello") }    // Type-erased, boxed

// 2. Associated Types
protocol Repository {
    associatedtype Entity: Identifiable
    func fetch(id: Entity.ID) async throws -> Entity
    func save(_ entity: Entity) async throws
}

class UserRepository: Repository {
    typealias Entity = User
    func fetch(id: String) async throws -> User { ... }
    func save(_ entity: User) async throws { ... }
}

// 3. Generic Constraints
func sync<R: Repository>(_ repo: R) async throws
    where R.Entity: Codable, R.Entity: Sendable {
    // Entity must be both Codable AND Sendable
}

// 4. Protocol with Self requirement
protocol Copyable {
    func copy() -> Self
}
```

---

### Week 2: SwiftUI Basics (Your React Skills Apply)

**Mental Model Mapping**

| React | SwiftUI | Notes |
|-------|---------|-------|
| `useState` | `@State` | Local view state |
| `useContext` | `@Environment` | Dependency injection |
| `useMemo` | Computed properties | Automatic in Swift |
| `useEffect` | `.onAppear`, `.task` | Lifecycle |
| `props` | Init parameters | Passed down |
| `children` | `@ViewBuilder` | Slot pattern |

**Daily Focus**

| Day | Topic | Build |
|-----|-------|-------|
| 1 | Basic Views + Modifiers | Counter app |
| 2 | Layout (VStack, HStack, Grid) | Grid layout |
| 3 | State + Binding | Form with validation |
| 4 | NavigationStack | Multi-screen flow |
| 5 | Lists + ForEach | Scrollable list |
| 6 | Sheets + Alerts | Modal presentations |
| 7 | Combine Week 2 | Notes app |

**Project: Notes App**

```swift
// Spec: Build a simple notes app
// - List of notes
// - Add/Edit/Delete
// - Persist to UserDefaults
// - Search/filter

@main
struct NotesApp: App {
    var body: some Scene {
        WindowGroup {
            NotesListView()
        }
    }
}

struct NotesListView: View {
    @State private var notes: [Note] = []
    @State private var searchText = ""

    var filteredNotes: [Note] {
        searchText.isEmpty ? notes :
        notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredNotes) { note in
                NavigationLink(value: note) {
                    NoteRow(note: note)
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Notes")
            .navigationDestination(for: Note.self) { note in
                NoteDetailView(note: note)
            }
        }
    }
}
```

---

### Week 3: MVVM + Networking (Async/Await)

**Architecture Pattern**

```
View (SwiftUI)
    │
    │ @StateObject / @Observable
    ▼
ViewModel (Business Logic)
    │
    │ async/await
    ▼
Service (Network / Storage)
    │
    │ URLSession
    ▼
API (REST / GraphQL)
```

**Build: GitHub Client Clone**

```swift
// Models
struct Repository: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let stargazersCount: Int
    let language: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, language
        case stargazersCount = "stargazers_count"
    }
}

// Service
actor GitHubService {
    func searchRepositories(query: String) async throws -> [Repository] {
        var components = URLComponents(string: "https://api.github.com/search/repositories")!
        components.queryItems = [URLQueryItem(name: "q", value: query)]

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
        return response.items
    }
}

// ViewModel
@MainActor
@Observable
final class RepositorySearchViewModel {
    var repositories: [Repository] = []
    var isLoading = false
    var errorMessage: String?

    private let service = GitHubService()

    func search(query: String) async {
        guard !query.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            repositories = try await service.searchRepositories(query: query)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// View
struct RepositorySearchView: View {
    @State private var viewModel = RepositorySearchViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    List(viewModel.repositories) { repo in
                        RepositoryRow(repository: repo)
                    }
                }
            }
            .searchable(text: $searchText)
            .onSubmit(of: .search) {
                Task { await viewModel.search(query: searchText) }
            }
            .navigationTitle("GitHub")
        }
    }
}
```

---

### Week 4: Persistence + Error Handling

**SwiftData (iOS 17+)**

```swift
import SwiftData

@Model
class Note {
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool

    init(title: String, content: String = "") {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isFavorite = false
    }
}

// In your App
@main
struct NotesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Note.self)
    }
}

// In your View
struct NotesListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Note.updatedAt, order: .reverse) private var notes: [Note]

    func addNote() {
        let note = Note(title: "New Note")
        context.insert(note)
    }

    func deleteNote(_ note: Note) {
        context.delete(note)
    }
}
```

**Error Handling Patterns**

```swift
// Domain errors
enum AWAVEError: LocalizedError {
    case networkFailure(underlying: Error)
    case authenticationRequired
    case subscriptionExpired
    case audioLoadFailed(trackId: String)

    var errorDescription: String? {
        switch self {
        case .networkFailure: return "Network connection failed"
        case .authenticationRequired: return "Please sign in"
        case .subscriptionExpired: return "Your subscription has expired"
        case .audioLoadFailed(let id): return "Failed to load track: \(id)"
        }
    }
}

// Result type pattern
func fetchUser() async -> Result<User, AWAVEError> {
    do {
        let user = try await api.getCurrentUser()
        return .success(user)
    } catch {
        return .failure(.networkFailure(underlying: error))
    }
}

// View error handling
struct ContentView: View {
    @State private var error: AWAVEError?

    var body: some View {
        MainView()
            .alert(isPresented: Binding(
                get: { error != nil },
                set: { if !$0 { error = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(error?.localizedDescription ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
}
```

**Week 4 Output**: Offline-capable notes app with SwiftData

---

## Month 2: Architecture + Systems

### Week 5: UIKit Fundamentals (Systems Layer)

**Why Learn UIKit Now?**

- AWAVE has a native audio module in Obj-C
- Some complex UIs need UIKit (e.g., waveform visualization)
- Understanding UIKit makes you better at SwiftUI

**Key Concepts**

```swift
// View Controller Lifecycle
class AudioPlayerViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // One-time setup (like componentDidMount)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // About to appear (refresh data)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Fully visible (start animations)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // About to leave (pause audio)
    }
}

// Embedding UIKit in SwiftUI
struct WaveformView: UIViewRepresentable {
    let audioURL: URL

    func makeUIView(context: Context) -> UIWaveformView {
        let view = UIWaveformView()
        view.load(audioURL)
        return view
    }

    func updateUIView(_ uiView: UIWaveformView, context: Context) {
        // Handle updates
    }
}

// Embedding SwiftUI in UIKit
class LegacyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let swiftUIView = ModernPlayerControls()
        let hostingController = UIHostingController(rootView: swiftUIView)

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
```

---

### Week 6: Swift Concurrency Deep Dive (NEW PHASE)

**This Is Critical For Audio Apps**

| Concept | Use Case in AWAVE |
|---------|-------------------|
| `Task` | Loading tracks, API calls |
| `Task.detached` | Audio processing (no main actor) |
| `async let` | Parallel asset loading |
| `TaskGroup` | Batch downloads |
| `Actor` | Audio engine state |
| `@MainActor` | UI updates |
| `AsyncSequence` | Playback progress stream |

**Exercises**

```swift
// 1. Parallel Loading
func loadPlayerAssets(trackIds: [String]) async throws -> [Track] {
    async let tracks = loadTracks(trackIds)
    async let artwork = loadArtwork(trackIds)
    async let waveforms = loadWaveforms(trackIds)

    let (t, a, w) = try await (tracks, artwork, waveforms)
    return zip(t, zip(a, w)).map { Track(data: $0, artwork: $1.0, waveform: $1.1) }
}

// 2. Actor for Thread-Safe Audio State
actor AudioEngineState {
    private var tracks: [String: TrackState] = [:]
    private var isPlaying = false

    func addTrack(_ id: String, state: TrackState) {
        tracks[id] = state
    }

    func setPlaying(_ playing: Bool) {
        isPlaying = playing
    }

    func getTrack(_ id: String) -> TrackState? {
        tracks[id]
    }
}

// 3. AsyncSequence for Progress
struct PlaybackProgressSequence: AsyncSequence {
    typealias Element = Double

    let player: AVAudioPlayer

    struct AsyncIterator: AsyncIteratorProtocol {
        let player: AVAudioPlayer

        mutating func next() async -> Double? {
            try? await Task.sleep(for: .milliseconds(100))
            guard player.isPlaying else { return nil }
            return player.currentTime / player.duration
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(player: player)
    }
}

// Usage
for await progress in PlaybackProgressSequence(player: player) {
    await MainActor.run {
        self.progress = progress
    }
}

// 4. Cancellation
func downloadWithCancellation(url: URL) async throws -> Data {
    try Task.checkCancellation()

    let (data, _) = try await URLSession.shared.data(from: url)

    try Task.checkCancellation()

    return data
}

// 5. TaskGroup for Batch Operations
func downloadAllTracks(_ urls: [URL]) async throws -> [Data] {
    try await withThrowingTaskGroup(of: (Int, Data).self) { group in
        for (index, url) in urls.enumerated() {
            group.addTask {
                let (data, _) = try await URLSession.shared.data(from: url)
                return (index, data)
            }
        }

        var results = [Data?](repeating: nil, count: urls.count)
        for try await (index, data) in group {
            results[index] = data
        }
        return results.compactMap { $0 }
    }
}
```

---

### Week 7: Architecture Patterns

**TCA (The Composable Architecture) - Redux for Swift**

```swift
import ComposableArchitecture

// Feature
@Reducer
struct AudioPlayer {
    @ObservableState
    struct State: Equatable {
        var track: Track?
        var isPlaying = false
        var progress: Double = 0
        var volume: Float = 1.0
    }

    enum Action {
        case loadTrack(Track)
        case trackLoaded(Result<AudioFile, Error>)
        case play
        case pause
        case setVolume(Float)
        case progressUpdated(Double)
    }

    @Dependency(\.audioEngine) var audioEngine

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadTrack(let track):
                state.track = track
                return .run { send in
                    let result = await Result { try await audioEngine.load(track) }
                    await send(.trackLoaded(result))
                }

            case .trackLoaded(.success):
                return .none

            case .trackLoaded(.failure):
                return .none

            case .play:
                state.isPlaying = true
                return .run { send in
                    audioEngine.play()
                    for await progress in audioEngine.progressStream() {
                        await send(.progressUpdated(progress))
                    }
                }

            case .pause:
                state.isPlaying = false
                audioEngine.pause()
                return .none

            case .setVolume(let volume):
                state.volume = volume
                audioEngine.setVolume(volume)
                return .none

            case .progressUpdated(let progress):
                state.progress = progress
                return .none
            }
        }
    }
}

// View
struct AudioPlayerView: View {
    @Bindable var store: StoreOf<AudioPlayer>

    var body: some View {
        VStack {
            if let track = store.track {
                Text(track.title)
                    .font(.headline)

                ProgressView(value: store.progress)

                HStack {
                    Button(action: { store.send(.play) }) {
                        Image(systemName: "play.fill")
                    }
                    Button(action: { store.send(.pause) }) {
                        Image(systemName: "pause.fill")
                    }
                }

                Slider(value: $store.volume.sending(\.setVolume))
            }
        }
    }
}
```

**Dependency Injection with Factory**

```swift
import Factory

extension Container {
    var authService: Factory<AuthServiceProtocol> {
        Factory(self) { AuthService() }
    }

    var audioEngine: Factory<AudioEngineProtocol> {
        Factory(self) { AWAVEAudioEngine() }
    }

    var userRepository: Factory<UserRepositoryProtocol> {
        Factory(self) { UserRepository() }
    }
}

// Usage
class ViewModel {
    @Injected(\.authService) private var authService
    @Injected(\.audioEngine) private var audioEngine
}

// Testing
Container.shared.authService.register { MockAuthService() }
```

---

### Week 8: Performance & Diagnostics (NEW PHASE)

**Instruments Mastery**

| Tool | What It Finds | When to Use |
|------|---------------|-------------|
| **Time Profiler** | CPU bottlenecks | App feels slow |
| **Allocations** | Memory usage | Memory warnings |
| **Leaks** | Retain cycles | Memory keeps growing |
| **Network** | Slow/failed requests | API issues |
| **Core Animation** | Frame drops | Janky scrolling |
| **Energy Log** | Battery drain | Background audio |

**Signposts for Custom Tracing**

```swift
import os.signpost

let log = OSLog(subsystem: "com.awave", category: "Audio")

func loadTrack(_ id: String) async throws -> Track {
    let signpostID = OSSignpostID(log: log)

    os_signpost(.begin, log: log, name: "Load Track", signpostID: signpostID, "trackId: %{public}@", id)
    defer { os_signpost(.end, log: log, name: "Load Track", signpostID: signpostID) }

    // ... loading logic
}
```

**Memory Debugging**

```swift
// Finding retain cycles
class AudioPlayerViewModel {
    var onComplete: (() -> Void)?

    func setup() {
        // BAD - creates retain cycle
        onComplete = {
            self.cleanup()  // Strong reference to self
        }

        // GOOD - weak capture
        onComplete = { [weak self] in
            self?.cleanup()
        }
    }
}

// Using Memory Graph Debugger
// 1. Run app
// 2. Debug → View Memory Graph
// 3. Look for cycles (objects with multiple incoming references)
```

---

## Month 3: Production Skills

### Week 9: Authentication & Security

**Keychain for Secure Storage**

```swift
import Security

actor KeychainManager {
    enum Key: String {
        case accessToken
        case refreshToken
        case userId
    }

    func save(_ data: Data, for key: Key) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func read(for key: Key) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound { return nil }
            throw KeychainError.readFailed(status)
        }

        return result as? Data
    }
}
```

**OAuth Flow**

```swift
import AuthenticationServices

class AuthManager: NSObject, ASAuthorizationControllerDelegate {

    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email, .fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController,
                                  didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

        let userId = credential.user
        let email = credential.email
        let identityToken = credential.identityToken

        // Send to your backend
        Task {
            try await api.authenticateWithApple(
                userId: userId,
                email: email,
                identityToken: identityToken
            )
        }
    }
}
```

---

### Week 10: Push Notifications & Deep Linking

**Push Notifications**

```swift
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    func requestPermission() async throws -> Bool {
        try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleReminder(at time: DateComponents, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    // Handle notification when app is open
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }

    // Handle tap on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        // Navigate based on payload
    }
}
```

**Universal Links / Deep Linking**

```swift
// In your App
@main
struct AWAVEApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    func handleDeepLink(_ url: URL) {
        // dripin://track/123
        // dripin://playlist/456

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }

        switch components.host {
        case "track":
            if let trackId = components.path.dropFirst().description.isEmpty ? nil : String(components.path.dropFirst()) {
                // Navigate to track
            }
        case "playlist":
            // Navigate to playlist
        default:
            break
        }
    }
}
```

---

### Week 11: CI/CD & TestFlight

**Fastlane Setup**

```ruby
# Fastfile
default_platform(:ios)

platform :ios do

  desc "Run all tests"
  lane :test do
    run_tests(
      scheme: "AWAVE",
      devices: ["iPhone 15 Pro"],
      code_coverage: true
    )
  end

  desc "Build and upload to TestFlight"
  lane :beta do
    # Increment build number
    increment_build_number(xcodeproj: "AWAVE.xcodeproj")

    # Build
    build_app(
      scheme: "AWAVE",
      export_method: "app-store",
      output_directory: "./build"
    )

    # Upload
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )

    # Notify
    slack(message: "New build uploaded to TestFlight!")
  end

  desc "Deploy to App Store"
  lane :release do
    build_app(scheme: "AWAVE")
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false
    )
  end

end
```

**GitHub Actions**

```yaml
name: iOS CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Install dependencies
        run: |
          brew install swiftlint
          bundle install

      - name: Lint
        run: swiftlint

      - name: Run tests
        run: bundle exec fastlane test

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

---

### Week 12: Migration Sprint

**AWAVE Feature Migration Checklist**

```
□ Project setup complete
□ All Swift models created
□ Network layer working with Supabase
□ Auth flow complete (email + OAuth)
□ Main tabs navigation
□ Audio player basic playback
□ Audio player full features (effects)
□ Library screen
□ Search functionality
□ Favorites system
□ Session tracking
□ Subscription (StoreKit 2)
□ Settings screens
□ Notifications
□ Offline support
□ TestFlight build submitted
```

**TestFlight Submission**

```bash
# 1. Archive
xcodebuild archive \
  -scheme AWAVE \
  -archivePath ./build/AWAVE.xcarchive \
  -destination "generic/platform=iOS"

# 2. Export
xcodebuild -exportArchive \
  -archivePath ./build/AWAVE.xcarchive \
  -exportPath ./build/AWAVE \
  -exportOptionsPlist ExportOptions.plist

# 3. Upload
xcrun altool --upload-app \
  -f ./build/AWAVE/AWAVE.ipa \
  -t ios \
  -u "$APPLE_ID" \
  -p "$APP_SPECIFIC_PASSWORD"
```

---

## Missing-But-Critical Topics (Addendum)

### App Extensions

```swift
// Widget for Lock Screen
struct AWAVEWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AWAVEWidget", provider: Provider()) { entry in
            AWAVEWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Now Playing")
        .description("See your current meditation track")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}
```

### Background Execution

```swift
// Background audio (Info.plist)
// UIBackgroundModes: audio

// Background fetch
func application(_ application: UIApplication,
                 performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    Task {
        do {
            try await syncOfflineQueue()
            completionHandler(.newData)
        } catch {
            completionHandler(.failed)
        }
    }
}

// Background URL session (for downloads)
let config = URLSessionConfiguration.background(withIdentifier: "com.awave.download")
let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
```

### Accessibility

```swift
// SwiftUI accessibility
Text("Play meditation")
    .accessibilityLabel("Play current meditation")
    .accessibilityHint("Double tap to start playback")
    .accessibilityAddTraits(.isButton)

// Dynamic Type
Text("Meditation")
    .font(.title)  // Automatically scales

// Custom accessibility action
Button("Play") { play() }
    .accessibilityAction(named: "Skip 30 seconds") {
        skip(seconds: 30)
    }
```

### Localization

```swift
// String catalog (Xcode 15+)
// Localizable.xcstrings

// Usage
Text("welcome_message")  // Automatically localized

// Plurals
Text("sessions_count \(count)")
// Localizable.xcstrings:
// "sessions_count %lld" = {
//   "one" = "%lld session"
//   "other" = "%lld sessions"
// }

// Date formatting
Text(date, style: .date)  // Respects locale
```

---

## Mastery Indicators

You know you're "there" when:

```
□ You instinctively choose between struct, class, actor
□ You design protocols before implementations
□ You profile before optimizing
□ You can explain retain cycles without thinking
□ You can migrate UIKit → SwiftUI
□ You can ship TestFlight blindfolded
□ You understand why @MainActor matters
□ You can debug memory issues with Memory Graph
□ You handle errors at the right abstraction level
□ You write tests that actually catch bugs
```

---

## Golden Rules (Tattoo These)

```
1. Main thread is sacred
2. Value types first
3. Make illegal states unrepresentable
4. No singleton business logic
5. Views are dumb
6. Test ViewModels, not Views
7. Avoid premature UIKit unless needed
8. Profile before you optimize
9. Concurrency is not optional
10. Accessibility is not optional
```

---

## Next Steps

**Recommended Path**:

1. **Today**: Set up Xcode project for AWAVE iOS
2. **Week 1**: Swift exercises while reading Phase 1 doc
3. **Week 2**: SwiftUI basics with AWAVE UI mockups
4. **Week 3**: Build auth flow connecting to Supabase
5. **Week 4**: Persistence layer
6. **Continue**: Following this 90-day plan

Ready to start with project setup?
