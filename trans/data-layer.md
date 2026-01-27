# Data Layer

## Overview

The AWAVE iOS app uses a hybrid data persistence strategy:

```
┌─────────────────────────────────────────────────────────────────┐
│                       Data Layer                                 │
│                                                                  │
│  ┌──────────────────────┐    ┌──────────────────────┐          │
│  │     Local Storage    │    │    Remote Storage    │          │
│  │                      │    │                      │          │
│  │  ┌────────────────┐  │    │  ┌────────────────┐  │          │
│  │  │   SwiftData    │  │◄──►│  │   Firestore    │  │          │
│  │  │   (SQLite)     │  │    │  │                │  │          │
│  │  └────────────────┘  │    │  └────────────────┘  │          │
│  │                      │    │                      │          │
│  │  ┌────────────────┐  │    │  ┌────────────────┐  │          │
│  │  │  FileManager   │  │◄──►│  │ Cloud Storage  │  │          │
│  │  │  (Audio Cache) │  │    │  │    (Audio)     │  │          │
│  │  └────────────────┘  │    │  └────────────────┘  │          │
│  │                      │    │                      │          │
│  │  ┌────────────────┐  │    │                      │          │
│  │  │   Keychain     │  │    │                      │          │
│  │  │   (Secrets)    │  │    │                      │          │
│  │  └────────────────┘  │    │                      │          │
│  │                      │    │                      │          │
│  │  ┌────────────────┐  │    │                      │          │
│  │  │  UserDefaults  │  │    │                      │          │
│  │  │  (Settings)    │  │    │                      │          │
│  │  └────────────────┘  │    │                      │          │
│  └──────────────────────┘    └──────────────────────┘          │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Sync Engine                            │  │
│  │  - Offline queue management                               │  │
│  │  - Conflict resolution                                    │  │
│  │  - Background sync                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## SwiftData Models

### User Model

```swift
// Packages/AWAVEData/Sources/AWAVEData/Models/UserModel.swift

import SwiftData
import Foundation

@Model
final class UserModel {
    @Attribute(.unique) var id: String
    var email: String
    var displayName: String
    var avatarURL: URL?
    var createdAt: Date
    var updatedAt: Date

    // Preferences (embedded)
    var defaultCategory: String
    var notificationsEnabled: Bool
    var downloadOverWifiOnly: Bool
    var defaultVolume: Double

    // Stats (embedded)
    var totalListeningMinutes: Int
    var sessionsCompleted: Int
    var streakDays: Int
    var lastActiveAt: Date

    var onboardingCompleted: Bool

    // Relationships
    @Relationship(deleteRule: .cascade) var sessions: [SessionModel]
    @Relationship(deleteRule: .cascade) var favorites: [FavoriteModel]

    init(
        id: String,
        email: String,
        displayName: String,
        avatarURL: URL? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.defaultCategory = "sleep"
        self.notificationsEnabled = true
        self.downloadOverWifiOnly = true
        self.defaultVolume = 0.8
        self.totalListeningMinutes = 0
        self.sessionsCompleted = 0
        self.streakDays = 0
        self.lastActiveAt = Date()
        self.onboardingCompleted = false
        self.sessions = []
        self.favorites = []
    }
}
```

### Sound Model

```swift
// Packages/AWAVEData/Sources/AWAVEData/Models/SoundModel.swift

import SwiftData
import Foundation

@Model
final class SoundModel {
    @Attribute(.unique) var id: String
    var name: String
    var soundDescription: String
    var category: String
    var subcategory: String
    var duration: TimeInterval
    var fileURL: String
    var thumbnailURL: String
    var waveformData: [Float]
    var tags: [String]
    var isPremium: Bool
    var playCount: Int
    var createdAt: Date
    var updatedAt: Date

    // Metadata
    var bpm: Int?
    var key: String?
    var mood: String?
    var isProcedural: Bool
    var proceduralType: String?

    // Local state
    var isDownloaded: Bool
    var localFilePath: String?

    init(
        id: String,
        name: String,
        description: String,
        category: String,
        subcategory: String = "",
        duration: TimeInterval,
        fileURL: String,
        thumbnailURL: String = "",
        waveformData: [Float] = [],
        tags: [String] = [],
        isPremium: Bool = false
    ) {
        self.id = id
        self.name = name
        self.soundDescription = description
        self.category = category
        self.subcategory = subcategory
        self.duration = duration
        self.fileURL = fileURL
        self.thumbnailURL = thumbnailURL
        self.waveformData = waveformData
        self.tags = tags
        self.isPremium = isPremium
        self.playCount = 0
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isProcedural = false
        self.isDownloaded = false
    }
}
```

### Session Model

```swift
// Packages/AWAVEData/Sources/AWAVEData/Models/SessionModel.swift

import SwiftData
import Foundation

@Model
final class SessionModel {
    @Attribute(.unique) var id: String
    var userId: String
    var startedAt: Date
    var endedAt: Date?
    var durationSeconds: Int
    var category: String
    var completed: Bool
    var rating: Int?

    // Mix configuration (stored as JSON)
    var mixSoundsJSON: String // [{soundId: String, volume: Float}]
    var mixName: String?

    // Sync state
    var syncStatus: SyncStatus
    var lastSyncedAt: Date?

    @Relationship var user: UserModel?

    init(
        id: String = UUID().uuidString,
        userId: String,
        mixSounds: [(soundId: String, volume: Float)],
        mixName: String? = nil,
        category: String
    ) {
        self.id = id
        self.userId = userId
        self.startedAt = Date()
        self.durationSeconds = 0
        self.category = category
        self.completed = false
        self.syncStatus = .pending

        // Encode mix sounds
        let sounds = mixSounds.map { ["soundId": $0.soundId, "volume": $0.volume] }
        self.mixSoundsJSON = (try? JSONSerialization.data(withJSONObject: sounds).base64EncodedString()) ?? "[]"
        self.mixName = mixName
    }

    var mixSounds: [(soundId: String, volume: Float)] {
        guard let data = Data(base64Encoded: mixSoundsJSON),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return array.compactMap { dict in
            guard let soundId = dict["soundId"] as? String,
                  let volume = dict["volume"] as? Float else { return nil }
            return (soundId, volume)
        }
    }
}

enum SyncStatus: String, Codable {
    case pending
    case syncing
    case synced
    case failed
}
```

### Favorite Model

```swift
// Packages/AWAVEData/Sources/AWAVEData/Models/FavoriteModel.swift

import SwiftData
import Foundation

@Model
final class FavoriteModel {
    @Attribute(.unique) var id: String
    var userId: String
    var soundId: String?
    var mixId: String?
    var type: FavoriteType
    var createdAt: Date

    var syncStatus: SyncStatus

    @Relationship var user: UserModel?

    init(
        id: String = UUID().uuidString,
        userId: String,
        soundId: String? = nil,
        mixId: String? = nil,
        type: FavoriteType
    ) {
        self.id = id
        self.userId = userId
        self.soundId = soundId
        self.mixId = mixId
        self.type = type
        self.createdAt = Date()
        self.syncStatus = .pending
    }
}

enum FavoriteType: String, Codable {
    case sound
    case mix
}
```

### Subscription Model

```swift
// Packages/AWAVEData/Sources/AWAVEData/Models/SubscriptionModel.swift

import SwiftData
import Foundation

@Model
final class SubscriptionModel {
    @Attribute(.unique) var id: String
    var userId: String
    var productId: String?
    var status: SubscriptionStatus
    var platform: String
    var originalTransactionId: String?
    var expiresAt: Date?
    var trialEndsAt: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        userId: String,
        status: SubscriptionStatus = .trial,
        platform: String = "ios"
    ) {
        self.id = id
        self.userId = userId
        self.status = status
        self.platform = platform
        self.createdAt = Date()
        self.updatedAt = Date()
        self.trialEndsAt = Date().addingTimeInterval(7 * 24 * 60 * 60) // 7 days
    }

    var isActive: Bool {
        switch status {
        case .active:
            return expiresAt.map { $0 > Date() } ?? false
        case .trial:
            return trialEndsAt.map { $0 > Date() } ?? false
        default:
            return false
        }
    }
}

enum SubscriptionStatus: String, Codable {
    case active
    case expired
    case cancelled
    case trial
}
```

---

## SwiftData Configuration

```swift
// Packages/AWAVEData/Sources/AWAVEData/DataContainer.swift

import SwiftData
import Foundation

public struct DataContainer {
    public static let shared = DataContainer()

    public let container: ModelContainer

    private init() {
        let schema = Schema([
            UserModel.self,
            SoundModel.self,
            SessionModel.self,
            FavoriteModel.self,
            SubscriptionModel.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    @MainActor
    public var context: ModelContext {
        container.mainContext
    }
}
```

---

## Repository Pattern

### Sound Repository

```swift
// Packages/AWAVEData/Sources/AWAVEData/Repositories/SoundRepository.swift

import SwiftData
import Foundation

public protocol SoundRepositoryProtocol {
    func getAllSounds() async throws -> [Sound]
    func getSound(id: String) async throws -> Sound?
    func getSounds(category: String) async throws -> [Sound]
    func searchSounds(query: String) async throws -> [Sound]
    func syncSounds() async throws
}

public struct SoundRepository: SoundRepositoryProtocol {
    private let context: ModelContext
    private let firestoreService: FirestoreService
    private let syncEngine: SyncEngine

    public init(
        context: ModelContext = DataContainer.shared.context,
        firestoreService: FirestoreService = .shared,
        syncEngine: SyncEngine = .shared
    ) {
        self.context = context
        self.firestoreService = firestoreService
        self.syncEngine = syncEngine
    }

    public func getAllSounds() async throws -> [Sound] {
        let descriptor = FetchDescriptor<SoundModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        let models = try context.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    public func getSound(id: String) async throws -> Sound? {
        let descriptor = FetchDescriptor<SoundModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first?.toDomain()
    }

    public func getSounds(category: String) async throws -> [Sound] {
        let descriptor = FetchDescriptor<SoundModel>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\.playCount, order: .reverse)]
        )
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    public func searchSounds(query: String) async throws -> [Sound] {
        let lowercased = query.lowercased()
        let descriptor = FetchDescriptor<SoundModel>(
            predicate: #Predicate { sound in
                sound.name.localizedStandardContains(lowercased) ||
                sound.soundDescription.localizedStandardContains(lowercased) ||
                sound.tags.contains { $0.localizedStandardContains(lowercased) }
            },
            sortBy: [SortDescriptor(\.playCount, order: .reverse)]
        )
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    public func syncSounds() async throws {
        // Fetch all sounds from Firestore
        let remoteSounds = try await firestoreService.getAllSounds()

        // Update local database
        for remoteSound in remoteSounds {
            let descriptor = FetchDescriptor<SoundModel>(
                predicate: #Predicate { $0.id == remoteSound.id }
            )

            if let existing = try context.fetch(descriptor).first {
                // Update existing
                existing.name = remoteSound.name
                existing.soundDescription = remoteSound.description
                existing.category = remoteSound.category
                existing.duration = remoteSound.duration
                existing.isPremium = remoteSound.isPremium
                existing.updatedAt = Date()
            } else {
                // Insert new
                let model = SoundModel(from: remoteSound)
                context.insert(model)
            }
        }

        try context.save()
    }
}

// Domain model conversion
extension SoundModel {
    func toDomain() -> Sound {
        Sound(
            id: id,
            name: name,
            description: soundDescription,
            category: category,
            subcategory: subcategory,
            duration: duration,
            fileURL: URL(string: fileURL)!,
            thumbnailURL: URL(string: thumbnailURL),
            waveformData: waveformData,
            tags: tags,
            isPremium: isPremium,
            isDownloaded: isDownloaded
        )
    }

    convenience init(from remote: FirestoreSound) {
        self.init(
            id: remote.id,
            name: remote.name,
            description: remote.description,
            category: remote.category,
            subcategory: remote.subcategory ?? "",
            duration: remote.duration,
            fileURL: remote.fileUrl,
            thumbnailURL: remote.thumbnailUrl ?? "",
            waveformData: remote.waveformData ?? [],
            tags: remote.tags ?? [],
            isPremium: remote.isPremium
        )
    }
}
```

### Session Repository

```swift
// Packages/AWAVEData/Sources/AWAVEData/Repositories/SessionRepository.swift

import SwiftData
import Foundation

public protocol SessionRepositoryProtocol {
    func startSession(mix: SoundMix) async throws -> Session
    func endSession(_ session: Session) async throws
    func getRecentSessions(limit: Int) async throws -> [Session]
    func getSessionStats() async throws -> SessionStats
}

public struct SessionRepository: SessionRepositoryProtocol {
    private let context: ModelContext
    private let syncEngine: SyncEngine

    public init(
        context: ModelContext = DataContainer.shared.context,
        syncEngine: SyncEngine = .shared
    ) {
        self.context = context
        self.syncEngine = syncEngine
    }

    public func startSession(mix: SoundMix) async throws -> Session {
        guard let userId = AuthService.shared.currentUserId else {
            throw RepositoryError.notAuthenticated
        }

        let model = SessionModel(
            userId: userId,
            mixSounds: mix.sounds.map { ($0.soundId, $0.volume) },
            mixName: mix.name,
            category: mix.category
        )

        context.insert(model)
        try context.save()

        // Queue for sync
        syncEngine.queueOperation(.createSession(model.id))

        return model.toDomain()
    }

    public func endSession(_ session: Session) async throws {
        let descriptor = FetchDescriptor<SessionModel>(
            predicate: #Predicate { $0.id == session.id }
        )

        guard let model = try context.fetch(descriptor).first else {
            throw RepositoryError.notFound
        }

        model.endedAt = Date()
        model.durationSeconds = Int(Date().timeIntervalSince(model.startedAt))
        model.completed = model.durationSeconds > 60 // At least 1 minute
        model.syncStatus = .pending

        try context.save()

        // Update user stats
        try await updateUserStats(duration: model.durationSeconds)

        // Queue for sync
        syncEngine.queueOperation(.updateSession(model.id))
    }

    public func getRecentSessions(limit: Int = 10) async throws -> [Session] {
        guard let userId = AuthService.shared.currentUserId else {
            throw RepositoryError.notAuthenticated
        }

        var descriptor = FetchDescriptor<SessionModel>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit

        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    public func getSessionStats() async throws -> SessionStats {
        guard let userId = AuthService.shared.currentUserId else {
            throw RepositoryError.notAuthenticated
        }

        let descriptor = FetchDescriptor<SessionModel>(
            predicate: #Predicate { $0.userId == userId && $0.completed == true }
        )

        let sessions = try context.fetch(descriptor)

        let totalMinutes = sessions.reduce(0) { $0 + $1.durationSeconds } / 60
        let totalSessions = sessions.count

        // Calculate streak
        let streak = calculateStreak(sessions: sessions)

        // Category breakdown
        let categoryStats = Dictionary(grouping: sessions, by: { $0.category })
            .mapValues { $0.count }

        return SessionStats(
            totalListeningMinutes: totalMinutes,
            totalSessions: totalSessions,
            currentStreak: streak,
            categoryBreakdown: categoryStats
        )
    }

    private func updateUserStats(duration: Int) async throws {
        guard let userId = AuthService.shared.currentUserId else { return }

        let descriptor = FetchDescriptor<UserModel>(
            predicate: #Predicate { $0.id == userId }
        )

        guard let user = try context.fetch(descriptor).first else { return }

        user.totalListeningMinutes += duration / 60
        user.sessionsCompleted += 1
        user.lastActiveAt = Date()

        // Update streak
        let calendar = Calendar.current
        if calendar.isDateInYesterday(user.lastActiveAt) || calendar.isDateInToday(user.lastActiveAt) {
            user.streakDays += 1
        } else {
            user.streakDays = 1
        }

        try context.save()
    }

    private func calculateStreak(sessions: [SessionModel]) -> Int {
        guard !sessions.isEmpty else { return 0 }

        let calendar = Calendar.current
        let sortedDates = sessions
            .map { calendar.startOfDay(for: $0.startedAt) }
            .sorted(by: >)

        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        for date in sortedDates {
            if date == currentDate {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else if date < currentDate {
                break
            }
        }

        return streak
    }
}

public enum RepositoryError: Error {
    case notAuthenticated
    case notFound
    case syncFailed
}
```

---

## Firestore Service

```swift
// Packages/AWAVEData/Sources/AWAVEData/Remote/FirestoreService.swift

import FirebaseFirestore
import Foundation

public actor FirestoreService {
    public static let shared = FirestoreService()

    private let db = Firestore.firestore()

    // MARK: - Sounds

    public func getAllSounds() async throws -> [FirestoreSound] {
        let snapshot = try await db.collection("sounds").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: FirestoreSound.self) }
    }

    public func getSound(id: String) async throws -> FirestoreSound? {
        let document = try await db.collection("sounds").document(id).getDocument()
        return try? document.data(as: FirestoreSound.self)
    }

    public func listenToSounds(onChange: @escaping ([FirestoreSound]) -> Void) -> ListenerRegistration {
        return db.collection("sounds")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let sounds = documents.compactMap { try? $0.data(as: FirestoreSound.self) }
                onChange(sounds)
            }
    }

    // MARK: - Sessions

    public func createSession(_ session: FirestoreSession) async throws {
        try db.collection("sessions").document(session.id).setData(from: session)
    }

    public func updateSession(_ session: FirestoreSession) async throws {
        try db.collection("sessions").document(session.id).setData(from: session, merge: true)
    }

    public func getSessions(userId: String, limit: Int = 50) async throws -> [FirestoreSession] {
        let snapshot = try await db.collection("sessions")
            .whereField("userId", isEqualTo: userId)
            .order(by: "startedAt", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: FirestoreSession.self) }
    }

    // MARK: - Favorites

    public func addFavorite(_ favorite: FirestoreFavorite) async throws {
        try db.collection("favorites").document(favorite.id).setData(from: favorite)
    }

    public func removeFavorite(id: String) async throws {
        try await db.collection("favorites").document(id).delete()
    }

    public func getFavorites(userId: String) async throws -> [FirestoreFavorite] {
        let snapshot = try await db.collection("favorites")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: FirestoreFavorite.self) }
    }

    // MARK: - User

    public func getUser(id: String) async throws -> FirestoreUser? {
        let document = try await db.collection("users").document(id).getDocument()
        return try? document.data(as: FirestoreUser.self)
    }

    public func updateUser(_ user: FirestoreUser) async throws {
        try db.collection("users").document(user.id).setData(from: user, merge: true)
    }

    // MARK: - Subscription

    public func getSubscription(userId: String) async throws -> FirestoreSubscription? {
        let document = try await db.collection("subscriptions").document(userId).getDocument()
        return try? document.data(as: FirestoreSubscription.self)
    }
}

// MARK: - Firestore Models

public struct FirestoreSound: Codable, Identifiable {
    @DocumentID public var id: String?
    public var name: String
    public var description: String
    public var category: String
    public var subcategory: String?
    public var duration: TimeInterval
    public var fileUrl: String
    public var thumbnailUrl: String?
    public var waveformData: [Float]?
    public var tags: [String]?
    public var isPremium: Bool
    public var playCount: Int
    @ServerTimestamp public var createdAt: Date?
    @ServerTimestamp public var updatedAt: Date?
}

public struct FirestoreSession: Codable, Identifiable {
    @DocumentID public var id: String?
    public var userId: String
    @ServerTimestamp public var startedAt: Date?
    public var endedAt: Date?
    public var durationSeconds: Int
    public var mix: FirestoreMix
    public var category: String
    public var completed: Bool
    public var rating: Int?
}

public struct FirestoreMix: Codable {
    public var sounds: [FirestoreMixSound]
    public var name: String?
}

public struct FirestoreMixSound: Codable {
    public var soundId: String
    public var volume: Float
}

public struct FirestoreFavorite: Codable, Identifiable {
    @DocumentID public var id: String?
    public var userId: String
    public var soundId: String?
    public var mixId: String?
    public var type: String
    @ServerTimestamp public var createdAt: Date?
}

public struct FirestoreUser: Codable, Identifiable {
    @DocumentID public var id: String?
    public var email: String
    public var displayName: String
    public var avatarUrl: String?
    public var preferences: FirestorePreferences
    public var stats: FirestoreStats
    public var onboardingCompleted: Bool
    @ServerTimestamp public var createdAt: Date?
    @ServerTimestamp public var updatedAt: Date?
}

public struct FirestorePreferences: Codable {
    public var defaultCategory: String
    public var notificationsEnabled: Bool
    public var downloadOverWifiOnly: Bool
    public var defaultVolume: Double
}

public struct FirestoreStats: Codable {
    public var totalListeningMinutes: Int
    public var sessionsCompleted: Int
    public var streakDays: Int
    @ServerTimestamp public var lastActiveAt: Date?
}

public struct FirestoreSubscription: Codable, Identifiable {
    @DocumentID public var id: String?
    public var userId: String
    public var productId: String?
    public var status: String
    public var platform: String
    public var originalTransactionId: String?
    public var expiresAt: Date?
    public var trialEndsAt: Date?
    @ServerTimestamp public var createdAt: Date?
    @ServerTimestamp public var updatedAt: Date?
}
```

---

## Sync Engine

```swift
// Packages/AWAVEData/Sources/AWAVEData/Sync/SyncEngine.swift

import Foundation
import Network
import SwiftData

public actor SyncEngine {
    public static let shared = SyncEngine()

    private var operationQueue: [SyncOperation] = []
    private var isSyncing = false
    private let firestoreService: FirestoreService

    private let monitor = NWPathMonitor()
    private var isConnected = false

    public init(firestoreService: FirestoreService = .shared) {
        self.firestoreService = firestoreService
        setupNetworkMonitoring()
    }

    // MARK: - Public API

    public func queueOperation(_ operation: SyncOperation) {
        operationQueue.append(operation)
        persistQueue()

        if isConnected && !isSyncing {
            Task {
                await processQueue()
            }
        }
    }

    public func forceSync() async {
        guard isConnected else { return }
        await processQueue()
    }

    // MARK: - Network Monitoring

    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task {
                await self?.handleNetworkChange(isConnected: path.status == .satisfied)
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }

    private func handleNetworkChange(isConnected: Bool) async {
        self.isConnected = isConnected

        if isConnected && !operationQueue.isEmpty && !isSyncing {
            await processQueue()
        }
    }

    // MARK: - Queue Processing

    private func processQueue() async {
        guard !isSyncing else { return }
        isSyncing = true

        defer { isSyncing = false }

        while !operationQueue.isEmpty {
            let operation = operationQueue.removeFirst()

            do {
                try await executeOperation(operation)
                await updateSyncStatus(for: operation, status: .synced)
            } catch {
                // Re-queue with retry count
                var retryOp = operation
                retryOp.retryCount += 1

                if retryOp.retryCount < 3 {
                    operationQueue.append(retryOp)
                } else {
                    await updateSyncStatus(for: operation, status: .failed)
                }
            }

            persistQueue()
        }
    }

    private func executeOperation(_ operation: SyncOperation) async throws {
        switch operation.type {
        case .createSession(let sessionId):
            let session = try await getLocalSession(sessionId)
            try await firestoreService.createSession(session.toFirestore())

        case .updateSession(let sessionId):
            let session = try await getLocalSession(sessionId)
            try await firestoreService.updateSession(session.toFirestore())

        case .addFavorite(let favoriteId):
            let favorite = try await getLocalFavorite(favoriteId)
            try await firestoreService.addFavorite(favorite.toFirestore())

        case .removeFavorite(let favoriteId):
            try await firestoreService.removeFavorite(id: favoriteId)

        case .updateUser:
            let user = try await getLocalUser()
            try await firestoreService.updateUser(user.toFirestore())
        }
    }

    // MARK: - Persistence

    private func persistQueue() {
        let data = try? JSONEncoder().encode(operationQueue)
        UserDefaults.standard.set(data, forKey: "syncQueue")
    }

    private func loadQueue() {
        guard let data = UserDefaults.standard.data(forKey: "syncQueue"),
              let queue = try? JSONDecoder().decode([SyncOperation].self, from: data) else { return }
        operationQueue = queue
    }

    // MARK: - Helpers

    private func updateSyncStatus(for operation: SyncOperation, status: SyncStatus) async {
        // Update local model sync status
        // Implementation depends on operation type
    }

    private func getLocalSession(_ id: String) async throws -> SessionModel {
        // Fetch from SwiftData
        fatalError("Implement with ModelContext")
    }

    private func getLocalFavorite(_ id: String) async throws -> FavoriteModel {
        fatalError("Implement with ModelContext")
    }

    private func getLocalUser() async throws -> UserModel {
        fatalError("Implement with ModelContext")
    }
}

public struct SyncOperation: Codable {
    public var id: String = UUID().uuidString
    public var type: SyncOperationType
    public var createdAt: Date = Date()
    public var retryCount: Int = 0
}

public enum SyncOperationType: Codable {
    case createSession(String)
    case updateSession(String)
    case addFavorite(String)
    case removeFavorite(String)
    case updateUser
}
```

---

## Keychain Storage

```swift
// Packages/AWAVEData/Sources/AWAVEData/Local/KeychainService.swift

import Security
import Foundation

public struct KeychainService {
    public static let shared = KeychainService()

    private let service = "com.awave.app"

    // MARK: - Token Storage

    public func saveToken(_ token: String, for key: String) throws {
        let data = token.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete existing
        SecItemDelete(query as CFDictionary)

        // Add new
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    public func getToken(for key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    public func deleteToken(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    public func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

public enum KeychainError: Error {
    case saveFailed(OSStatus)
    case deleteFailed(OSStatus)
}
```
