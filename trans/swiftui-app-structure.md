# SwiftUI App Structure

## Project Organization

```
AWAVE/
├── AWAVE.xcodeproj
├── Package.swift                    # SPM dependencies
├── Packages/                        # Local Swift packages
│   ├── AWAVECore/                  # Shared utilities
│   ├── AWAVEDomain/                # Business logic
│   ├── AWAVEData/                  # Data layer
│   └── AWAVEAudio/                 # Audio engine
├── AWAVE/                          # Main app target
│   ├── App/
│   │   ├── AWAVEApp.swift
│   │   ├── AppDelegate.swift       # UIKit lifecycle hooks
│   │   ├── SceneDelegate.swift
│   │   └── DependencyContainer.swift
│   ├── Features/
│   │   ├── Onboarding/
│   │   ├── Home/
│   │   ├── Player/
│   │   ├── Library/
│   │   ├── Search/
│   │   ├── Profile/
│   │   ├── Subscription/
│   │   ├── Settings/
│   │   └── SOS/
│   ├── Navigation/
│   │   ├── AppCoordinator.swift
│   │   ├── TabCoordinator.swift
│   │   └── Routes.swift
│   ├── Shared/
│   │   ├── Components/
│   │   ├── Modifiers/
│   │   ├── Styles/
│   │   └── Extensions/
│   └── Resources/
│       ├── Assets.xcassets
│       ├── Localizable.xcstrings
│       ├── GoogleService-Info.plist
│       └── Info.plist
├── AWAVETests/
├── AWAVEUITests/
└── AWAVEWidgets/                   # Widget extension
```

---

## App Entry Point

```swift
// AWAVE/App/AWAVEApp.swift
import SwiftUI
import FirebaseCore

@main
struct AWAVEApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var appState = AppState()
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(coordinator)
                .environment(\.dependencies, DependencyContainer.live)
                .task {
                    await appState.initialize()
                }
        }
    }
}

// AppDelegate for Firebase and background audio
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        configureAudioSession()
        return true
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }
}
```

---

## Global State Management

```swift
// AWAVE/App/AppState.swift
import SwiftUI
import Observation

@Observable
final class AppState {
    // Authentication
    var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }

    // Subscription
    var subscription: Subscription?
    var isPremium: Bool { subscription?.isActive ?? false }

    // App State
    var isInitialized = false
    var networkStatus: NetworkStatus = .unknown

    // Active Player
    var activeSession: PlaybackSession?
    var isPlaying: Bool { activeSession?.isPlaying ?? false }

    // Dependencies
    private let authService: AuthService
    private let subscriptionService: SubscriptionService

    init(
        authService: AuthService = .live,
        subscriptionService: SubscriptionService = .live
    ) {
        self.authService = authService
        self.subscriptionService = subscriptionService
    }

    func initialize() async {
        // Restore auth state
        currentUser = await authService.getCurrentUser()

        // Load subscription
        if let user = currentUser {
            subscription = await subscriptionService.getSubscription(for: user.id)
        }

        isInitialized = true
    }

    func signOut() async {
        await authService.signOut()
        currentUser = nil
        subscription = nil
        activeSession = nil
    }
}
```

---

## Navigation System

```swift
// AWAVE/Navigation/Routes.swift
import SwiftUI

enum Route: Hashable {
    // Tab routes
    case home
    case library
    case profile

    // Detail routes
    case category(Category)
    case sound(Sound)
    case player(SoundMix)
    case session(Session)

    // Modal routes
    case search
    case subscription
    case settings
    case sos
}

// AWAVE/Navigation/AppCoordinator.swift
@Observable
final class AppCoordinator {
    var selectedTab: Tab = .home
    var homePath = NavigationPath()
    var libraryPath = NavigationPath()
    var profilePath = NavigationPath()

    var presentedSheet: Route?
    var presentedFullScreen: Route?

    enum Tab: String, CaseIterable {
        case home = "Entdecken"
        case library = "Bibliothek"
        case profile = "Profil"

        var icon: String {
            switch self {
            case .home: return "waveform"
            case .library: return "square.stack"
            case .profile: return "person"
            }
        }
    }

    func navigate(to route: Route) {
        switch route {
        case .home, .library, .profile:
            selectedTab = Tab(rawValue: route.description) ?? .home

        case .category, .sound, .session:
            currentPath.append(route)

        case .search, .subscription, .settings:
            presentedSheet = route

        case .sos:
            presentedFullScreen = route

        case .player:
            presentedFullScreen = route
        }
    }

    func dismiss() {
        if presentedFullScreen != nil {
            presentedFullScreen = nil
        } else if presentedSheet != nil {
            presentedSheet = nil
        } else if !currentPath.isEmpty {
            currentPath.removeLast()
        }
    }

    private var currentPath: NavigationPath {
        get {
            switch selectedTab {
            case .home: return homePath
            case .library: return libraryPath
            case .profile: return profilePath
            }
        }
        set {
            switch selectedTab {
            case .home: homePath = newValue
            case .library: libraryPath = newValue
            case .profile: profilePath = newValue
            }
        }
    }
}
```

---

## Root View Structure

```swift
// AWAVE/App/RootView.swift
import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        Group {
            if !appState.isInitialized {
                SplashView()
            } else if !appState.isAuthenticated {
                OnboardingFlow()
            } else {
                MainTabView()
            }
        }
        .overlay(alignment: .bottom) {
            if appState.isPlaying {
                MiniPlayerStrip()
                    .transition(.move(edge: .bottom))
            }
        }
        .sheet(item: $coordinator.presentedSheet) { route in
            sheetContent(for: route)
        }
        .fullScreenCover(item: $coordinator.presentedFullScreen) { route in
            fullScreenContent(for: route)
        }
    }

    @ViewBuilder
    private func sheetContent(for route: Route) -> some View {
        switch route {
        case .search:
            SearchView()
        case .subscription:
            SubscriptionView()
        case .settings:
            SettingsView()
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func fullScreenContent(for route: Route) -> some View {
        switch route {
        case .player(let mix):
            PlayerView(mix: mix)
        case .sos:
            SOSView()
        default:
            EmptyView()
        }
    }
}

// AWAVE/App/MainTabView.swift
struct MainTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

        TabView(selection: $coordinator.selectedTab) {
            HomeTab()
                .tabItem {
                    Label(
                        AppCoordinator.Tab.home.rawValue,
                        systemImage: AppCoordinator.Tab.home.icon
                    )
                }
                .tag(AppCoordinator.Tab.home)

            LibraryTab()
                .tabItem {
                    Label(
                        AppCoordinator.Tab.library.rawValue,
                        systemImage: AppCoordinator.Tab.library.icon
                    )
                }
                .tag(AppCoordinator.Tab.library)

            ProfileTab()
                .tabItem {
                    Label(
                        AppCoordinator.Tab.profile.rawValue,
                        systemImage: AppCoordinator.Tab.profile.icon
                    )
                }
                .tag(AppCoordinator.Tab.profile)
        }
        .tint(.accent)
    }
}
```

---

## Feature Module Structure

Each feature follows a consistent structure:

```
Features/Player/
├── PlayerView.swift           # Main view
├── PlayerViewModel.swift      # @Observable view model
├── Components/
│   ├── MixerTrackView.swift
│   ├── WaveformView.swift
│   ├── PlaybackControls.swift
│   └── TrackVolumeSlider.swift
├── Models/
│   └── PlayerState.swift      # Feature-specific state
└── Services/
    └── PlayerService.swift    # Feature-specific logic
```

### Example: Player Feature

```swift
// Features/Player/PlayerViewModel.swift
import SwiftUI
import Observation
import AVFoundation

@Observable
final class PlayerViewModel {
    // State
    var state: PlayerState = .idle
    var tracks: [MixerTrack] = []
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var isPlaying = false

    // Dependencies
    private let audioEngine: AudioEngine
    private let sessionRepository: SessionRepository
    private let analyticsService: AnalyticsService

    init(
        audioEngine: AudioEngine,
        sessionRepository: SessionRepository,
        analyticsService: AnalyticsService
    ) {
        self.audioEngine = audioEngine
        self.sessionRepository = sessionRepository
        self.analyticsService = analyticsService
    }

    // MARK: - Actions

    func loadMix(_ mix: SoundMix) async {
        state = .loading

        do {
            // Load tracks
            tracks = try await audioEngine.prepareMix(mix)
            duration = tracks.map(\.duration).max() ?? 0

            // Start session tracking
            try await sessionRepository.startSession(mix: mix)

            state = .ready
        } catch {
            state = .error(error)
        }
    }

    func play() {
        guard state == .ready || state == .paused else { return }

        audioEngine.play()
        isPlaying = true
        state = .playing

        analyticsService.track(.playbackStarted)
    }

    func pause() {
        audioEngine.pause()
        isPlaying = false
        state = .paused

        analyticsService.track(.playbackPaused)
    }

    func seek(to time: TimeInterval) {
        audioEngine.seek(to: time)
        currentTime = time
    }

    func setVolume(_ volume: Float, for track: MixerTrack) {
        audioEngine.setVolume(volume, for: track.id)

        if let index = tracks.firstIndex(where: { $0.id == track.id }) {
            tracks[index].volume = volume
        }
    }

    func addTrack(_ sound: Sound) async {
        guard tracks.count < 7 else { return }

        do {
            let track = try await audioEngine.addTrack(sound)
            tracks.append(track)
        } catch {
            // Handle error
        }
    }

    func removeTrack(_ track: MixerTrack) {
        audioEngine.removeTrack(track.id)
        tracks.removeAll { $0.id == track.id }
    }
}

// Features/Player/PlayerState.swift
enum PlayerState: Equatable {
    case idle
    case loading
    case ready
    case playing
    case paused
    case error(Error)

    static func == (lhs: PlayerState, rhs: PlayerState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.ready, .ready),
             (.playing, .playing),
             (.paused, .paused):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}

// Features/Player/PlayerView.swift
struct PlayerView: View {
    let mix: SoundMix
    @State private var viewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss

    init(mix: SoundMix) {
        self.mix = mix
        _viewModel = State(initialValue: PlayerViewModel(
            audioEngine: .live,
            sessionRepository: .live,
            analyticsService: .live
        ))
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.indigo, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                header

                // Waveform visualization
                WaveformView(tracks: viewModel.tracks)
                    .frame(height: 200)

                // Track mixers
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.tracks) { track in
                            MixerTrackView(
                                track: track,
                                onVolumeChange: { volume in
                                    viewModel.setVolume(volume, for: track)
                                },
                                onRemove: {
                                    viewModel.removeTrack(track)
                                }
                            )
                        }
                    }
                }

                // Progress bar
                ProgressSlider(
                    value: viewModel.currentTime,
                    total: viewModel.duration,
                    onSeek: viewModel.seek
                )

                // Playback controls
                PlaybackControls(
                    isPlaying: viewModel.isPlaying,
                    onPlay: viewModel.play,
                    onPause: viewModel.pause
                )
            }
            .padding()
        }
        .task {
            await viewModel.loadMix(mix)
        }
        .overlay {
            if viewModel.state == .loading {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }

    private var header: some View {
        HStack {
            Button("Schliessen") {
                dismiss()
            }
            .foregroundStyle(.white)

            Spacer()

            Text(mix.name)
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Button {
                // Add track
            } label: {
                Image(systemName: "plus.circle")
            }
            .foregroundStyle(.white)
        }
    }
}
```

---

## Shared Components

```swift
// Shared/Components/WaveformView.swift
struct WaveformView: View {
    let tracks: [MixerTrack]
    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for (index, track) in tracks.enumerated() {
                    drawWaveform(
                        context: context,
                        size: size,
                        track: track,
                        offset: CGFloat(index) * 10,
                        time: timeline.date.timeIntervalSinceReferenceDate
                    )
                }
            }
        }
    }

    private func drawWaveform(
        context: GraphicsContext,
        size: CGSize,
        track: MixerTrack,
        offset: CGFloat,
        time: TimeInterval
    ) {
        var path = Path()
        let midY = size.height / 2 + offset
        let amplitude = CGFloat(track.volume) * 30

        for x in stride(from: 0, to: size.width, by: 2) {
            let relativeX = x / size.width
            let sine = sin(relativeX * .pi * 4 + time * 2)
            let y = midY + sine * amplitude

            if x == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        context.stroke(
            path,
            with: .color(track.color.opacity(0.8)),
            lineWidth: 2
        )
    }
}

// Shared/Components/MiniPlayerStrip.swift
struct MiniPlayerStrip: View {
    @Environment(AppState.self) private var appState
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        if let session = appState.activeSession {
            HStack(spacing: 12) {
                // Thumbnail
                AsyncImage(url: session.mix.thumbnailURL) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Title
                VStack(alignment: .leading) {
                    Text(session.mix.name)
                        .font(.subheadline.weight(.medium))
                    Text(session.mix.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Controls
                Button {
                    if appState.isPlaying {
                        session.pause()
                    } else {
                        session.play()
                    }
                } label: {
                    Image(systemName: appState.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            .onTapGesture {
                coordinator.navigate(to: .player(session.mix))
            }
        }
    }
}
```

---

## Design System

```swift
// Shared/Styles/AWAVEColors.swift
extension Color {
    static let awavePrimary = Color("Primary")        // Deep purple
    static let awaveSecondary = Color("Secondary")    // Soft blue
    static let awaveAccent = Color("Accent")          // Vibrant teal
    static let awaveBackground = Color("Background")  // Dark gradient base
    static let awaveSurface = Color("Surface")        // Card backgrounds

    // Semantic colors
    static let awaveSuccess = Color.green
    static let awaveWarning = Color.orange
    static let awaveError = Color.red
}

// Shared/Styles/AWAVEFonts.swift
extension Font {
    static let awaveTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let awaveHeadline = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let awaveBody = Font.system(size: 16, weight: .regular, design: .default)
    static let awaveCaption = Font.system(size: 12, weight: .medium, design: .default)
}

// Shared/Modifiers/CardStyle.swift
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
```

---

## Dependency Injection

```swift
// AWAVE/App/DependencyContainer.swift
struct DependencyContainer {
    let authService: AuthService
    let audioEngine: AudioEngine
    let soundRepository: SoundRepository
    let sessionRepository: SessionRepository
    let downloadManager: DownloadManager
    let analyticsService: AnalyticsService
    let subscriptionService: SubscriptionService

    static let live = DependencyContainer(
        authService: .live,
        audioEngine: .live,
        soundRepository: FirestoreSoundRepository(),
        sessionRepository: FirestoreSessionRepository(),
        downloadManager: .live,
        analyticsService: .live,
        subscriptionService: .live
    )

    static let preview = DependencyContainer(
        authService: .mock,
        audioEngine: .mock,
        soundRepository: MockSoundRepository(),
        sessionRepository: MockSessionRepository(),
        downloadManager: .mock,
        analyticsService: .mock,
        subscriptionService: .mock
    )
}

// Environment key
private struct DependenciesKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.live
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}

// Usage in views
struct SomeView: View {
    @Environment(\.dependencies) private var deps

    var body: some View {
        Button("Play") {
            deps.audioEngine.play()
        }
    }
}
```

---

## Localization

```swift
// Using String Catalogs (Localizable.xcstrings)
// Shared/Extensions/LocalizedStrings.swift
extension String {
    enum Localized {
        // Navigation
        static let home = String(localized: "tab.home")
        static let library = String(localized: "tab.library")
        static let profile = String(localized: "tab.profile")

        // Player
        static let play = String(localized: "player.play")
        static let pause = String(localized: "player.pause")
        static let addTrack = String(localized: "player.addTrack")

        // Categories
        static let sleep = String(localized: "category.sleep")
        static let focus = String(localized: "category.focus")
        static let relax = String(localized: "category.relax")

        // Errors
        static let networkError = String(localized: "error.network")
        static let audioError = String(localized: "error.audio")
    }
}

// Usage
Text(String.Localized.play)
```
