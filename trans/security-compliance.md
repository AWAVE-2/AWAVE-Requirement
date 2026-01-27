# Security & Compliance

## Overview

This document outlines the security architecture, data privacy compliance, and App Store requirements for the AWAVE iOS application.

---

## Security Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Security Layers                                      │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Application Layer                             │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │   │
│  │  │  Input       │  │  Output      │  │  Session Management      │  │   │
│  │  │  Validation  │  │  Encoding    │  │  - Token rotation        │  │   │
│  │  │  - Sanitize  │  │  - Escape    │  │  - Secure storage        │  │   │
│  │  │  - Validate  │  │  - Redact    │  │  - Timeout handling      │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Data Layer                                    │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │   │
│  │  │  Keychain    │  │  SwiftData   │  │  File Protection         │  │   │
│  │  │  - Tokens    │  │  - Encrypted │  │  - Complete protection   │  │   │
│  │  │  - API keys  │  │  - SQLCipher │  │  - Audio files           │  │   │
│  │  │  - Secrets   │  │              │  │                          │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Network Layer                                 │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │   │
│  │  │  TLS 1.3     │  │  Certificate │  │  Request Signing         │  │   │
│  │  │  - HTTPS     │  │  Pinning     │  │  - JWT tokens            │  │   │
│  │  │  - ATS       │  │  - Firebase  │  │  - HMAC verification     │  │   │
│  │  │              │  │  - GCP APIs  │  │                          │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Infrastructure Layer                          │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │   │
│  │  │  Cloud Armor │  │  IAM         │  │  Audit Logging           │  │   │
│  │  │  - WAF       │  │  - RBAC      │  │  - Cloud Logging         │  │   │
│  │  │  - DDoS      │  │  - Service   │  │  - Access logs           │  │   │
│  │  │  - Rate limit│  │    accounts  │  │  - Change tracking       │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Authentication Security

### Firebase Authentication Implementation

```swift
// Services/AuthService.swift

import FirebaseAuth
import AuthenticationServices
import CryptoKit

public actor AuthService {
    public static let shared = AuthService()

    private var currentNonce: String?

    // MARK: - Sign in with Apple

    public func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws -> User {
        // Verify nonce
        guard let nonce = currentNonce,
              let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }

        // Create Firebase credential
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: credential.fullName
        )

        // Sign in
        let result = try await Auth.auth().signIn(with: firebaseCredential)

        // Store tokens securely
        try await storeTokens(for: result.user)

        return User(from: result.user)
    }

    // MARK: - Secure Nonce Generation

    public func generateNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Token Management

    private func storeTokens(for user: FirebaseAuth.User) async throws {
        let idToken = try await user.getIDToken()

        try KeychainService.shared.saveToken(idToken, for: "firebase_id_token")
        try KeychainService.shared.saveToken(user.refreshToken ?? "", for: "firebase_refresh_token")
    }

    public func refreshTokenIfNeeded() async throws {
        guard let currentUser = Auth.auth().currentUser else { return }

        // Force refresh if token is about to expire
        let token = try await currentUser.getIDTokenResult(forcingRefresh: false)

        if let expirationDate = token.expirationDate,
           expirationDate.timeIntervalSinceNow < 300 { // 5 minutes
            let newToken = try await currentUser.getIDToken(forcingRefresh: true)
            try KeychainService.shared.saveToken(newToken, for: "firebase_id_token")
        }
    }

    // MARK: - Sign Out

    public func signOut() async throws {
        try Auth.auth().signOut()
        try KeychainService.shared.deleteAll()
    }
}
```

### Keychain Security

```swift
// Services/KeychainService.swift

import Security
import Foundation

public struct KeychainService {
    public static let shared = KeychainService()

    private let accessGroup: String? = nil // Use app's default keychain
    private let service = "com.awave.app"

    public func saveToken(_ token: String, for key: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
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

        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let token = String(data: data, encoding: .utf8) else {
                return nil
            }
            return token

        case errSecItemNotFound:
            return nil

        default:
            throw KeychainError.retrieveFailed(status)
        }
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
    case encodingFailed
    case saveFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)
}
```

---

## Data Protection

### File Protection Classes

```swift
// Data/FileProtection.swift

import Foundation

struct FileProtection {
    /// Apply complete protection to sensitive files
    static func protectFile(at url: URL) throws {
        try FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: url.path
        )
    }

    /// Apply protection until first unlock for audio cache
    static func protectAudioCache(at url: URL) throws {
        try FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
            ofItemAtPath: url.path
        )
    }
}

// Apply during file creation
extension AudioFileManager {
    func saveDownloadedFile(data: Data, for soundId: String) throws -> URL {
        let cacheURL = cacheDirectory.appendingPathComponent("\(soundId).mp3")

        try data.write(to: cacheURL)
        try FileProtection.protectAudioCache(at: cacheURL)

        return cacheURL
    }
}
```

### SwiftData Encryption

```swift
// Data/EncryptedDataContainer.swift

import SwiftData
import Foundation

struct EncryptedDataContainer {
    static func create() throws -> ModelContainer {
        let schema = Schema([
            UserModel.self,
            SoundModel.self,
            SessionModel.self,
            FavoriteModel.self,
            SubscriptionModel.self
        ])

        // Store in protected location
        let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AWAVE")
            .appendingPathComponent("encrypted.store")

        // Create directory with protection
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
        )

        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            allowsSave: true
        )

        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
```

---

## Network Security

### App Transport Security

```xml
<!-- Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <!-- ATS is enabled by default - we only need to configure exceptions if any -->
    <key>NSAllowsArbitraryLoads</key>
    <false/>

    <!-- If needed for specific domains -->
    <key>NSExceptionDomains</key>
    <dict>
        <!-- All our domains use HTTPS, no exceptions needed -->
    </dict>
</dict>
```

### Certificate Pinning

```swift
// Networking/CertificatePinning.swift

import Foundation
import CryptoKit

class PinnedURLSessionDelegate: NSObject, URLSessionDelegate {
    // SHA256 hashes of our certificates
    private let pinnedHashes: Set<String> = [
        // Firebase certificates
        "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
        // GCP certificates
        "sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=",
    ]

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Verify certificate chain
        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Check certificate pinning
        guard let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        for certificate in certificates {
            let data = SecCertificateCopyData(certificate) as Data
            let hash = SHA256.hash(data: data)
            let hashString = "sha256/" + Data(hash).base64EncodedString()

            if pinnedHashes.contains(hashString) {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }

        // No matching pin found
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
```

### Request Signing

```swift
// Networking/RequestSigning.swift

import Foundation
import CryptoKit

struct RequestSigner {
    static func sign(request: inout URLRequest) async throws {
        // Get current ID token
        guard let token = try? KeychainService.shared.getToken(for: "firebase_id_token") else {
            throw NetworkError.notAuthenticated
        }

        // Add authorization header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Add request timestamp
        let timestamp = ISO8601DateFormatter().string(from: Date())
        request.setValue(timestamp, forHTTPHeaderField: "X-Request-Timestamp")

        // Add request ID for tracing
        let requestId = UUID().uuidString
        request.setValue(requestId, forHTTPHeaderField: "X-Request-ID")
    }
}
```

---

## Privacy Compliance

### GDPR Compliance

```swift
// Privacy/GDPRManager.swift

import Foundation

public actor GDPRManager {
    public static let shared = GDPRManager()

    // MARK: - Consent Management

    public func hasConsent(for purpose: ConsentPurpose) -> Bool {
        UserDefaults.standard.bool(forKey: "consent_\(purpose.rawValue)")
    }

    public func setConsent(_ granted: Bool, for purpose: ConsentPurpose) {
        UserDefaults.standard.set(granted, forKey: "consent_\(purpose.rawValue)")

        // Update analytics consent
        if purpose == .analytics {
            Analytics.setAnalyticsCollectionEnabled(granted)
        }
    }

    // MARK: - Data Export

    public func exportUserData() async throws -> URL {
        guard let userId = AuthService.shared.currentUserId else {
            throw PrivacyError.notAuthenticated
        }

        var exportData: [String: Any] = [:]

        // User profile
        let user = try await FirestoreService.shared.getUser(id: userId)
        exportData["profile"] = user?.toDictionary()

        // Sessions
        let sessions = try await FirestoreService.shared.getSessions(userId: userId, limit: 1000)
        exportData["sessions"] = sessions.map { $0.toDictionary() }

        // Favorites
        let favorites = try await FirestoreService.shared.getFavorites(userId: userId)
        exportData["favorites"] = favorites.map { $0.toDictionary() }

        // Write to file
        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        let exportURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("awave_data_export_\(Date().timeIntervalSince1970).json")

        try jsonData.write(to: exportURL)

        return exportURL
    }

    // MARK: - Data Deletion

    public func requestDataDeletion() async throws {
        guard let userId = AuthService.shared.currentUserId else {
            throw PrivacyError.notAuthenticated
        }

        // Queue deletion request
        try await FirestoreService.shared.createDeletionRequest(userId: userId)

        // Sign out locally
        try await AuthService.shared.signOut()

        // Clear local data
        try await clearLocalData()
    }

    private func clearLocalData() async throws {
        // Clear SwiftData
        let context = DataContainer.shared.context
        try context.delete(model: UserModel.self)
        try context.delete(model: SessionModel.self)
        try context.delete(model: FavoriteModel.self)
        try context.save()

        // Clear audio cache
        try await AudioFileManager.shared.clearCache()

        // Clear Keychain
        try KeychainService.shared.deleteAll()

        // Clear UserDefaults
        if let bundleId = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleId)
        }
    }
}

public enum ConsentPurpose: String, CaseIterable {
    case analytics = "analytics"
    case personalization = "personalization"
    case marketing = "marketing"
}

public enum PrivacyError: Error {
    case notAuthenticated
    case exportFailed
    case deletionFailed
}
```

### Privacy Policy Integration

```swift
// Views/Settings/PrivacySettingsView.swift

import SwiftUI

struct PrivacySettingsView: View {
    @State private var analyticsConsent = true
    @State private var personalizationConsent = true
    @State private var showExportSheet = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        Form {
            Section("Data Collection") {
                Toggle("Usage Analytics", isOn: $analyticsConsent)
                    .onChange(of: analyticsConsent) { _, newValue in
                        Task {
                            await GDPRManager.shared.setConsent(newValue, for: .analytics)
                        }
                    }

                Toggle("Personalized Recommendations", isOn: $personalizationConsent)
                    .onChange(of: personalizationConsent) { _, newValue in
                        Task {
                            await GDPRManager.shared.setConsent(newValue, for: .personalization)
                        }
                    }
            }

            Section("Your Data") {
                Button("Export My Data") {
                    showExportSheet = true
                }

                Button("Delete My Account", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }

            Section {
                Link("Privacy Policy", destination: URL(string: "https://awave.app/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://awave.app/terms")!)
            }
        }
        .navigationTitle("Privacy")
        .sheet(isPresented: $showExportSheet) {
            DataExportView()
        }
        .confirmationDialog(
            "Delete Account?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Everything", role: .destructive) {
                Task {
                    try? await GDPRManager.shared.requestDataDeletion()
                }
            }
        } message: {
            Text("This will permanently delete all your data including listening history, favorites, and subscription. This cannot be undone.")
        }
    }
}
```

---

## App Store Compliance

### Required Privacy Disclosures

```
App Privacy Details (App Store Connect):

Data Linked to You:
├── Contact Info
│   └── Email Address (Account creation, support)
├── Identifiers
│   └── User ID (App functionality)
└── Usage Data
    └── Product Interaction (Analytics)

Data Not Linked to You:
├── Usage Data
│   └── Crash Data (Diagnostics)
└── Diagnostics
    └── Performance Data (App improvement)

Data Used for Tracking: None
```

### Subscription Compliance

```swift
// Subscription/SubscriptionTerms.swift

struct SubscriptionTerms {
    // Required disclosures for App Store
    static let monthlyPrice = "€9.99/month"
    static let yearlyPrice = "€59.99/year"

    static let termsText = """
    • Payment will be charged to your Apple ID account at confirmation of purchase.
    • Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.
    • Account will be charged for renewal within 24 hours prior to the end of the current period at the rate of the selected plan.
    • Subscriptions may be managed and auto-renewal may be turned off by going to Account Settings after purchase.
    • Any unused portion of a free trial period will be forfeited when purchasing a subscription.
    """

    static let privacyPolicyURL = URL(string: "https://awave.app/privacy")!
    static let termsOfServiceURL = URL(string: "https://awave.app/terms")!
}
```

### Health Data (HealthKit)

```xml
<!-- Info.plist -->
<key>NSHealthShareUsageDescription</key>
<string>AWAVE uses Health data to track your mindfulness minutes and show your wellness progress.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>AWAVE records mindfulness sessions to your Health app to help you track your wellness journey.</string>
```

---

## Security Checklist

### Pre-Launch Security Review

- [ ] **Authentication**
  - [ ] Secure nonce generation for Sign in with Apple
  - [ ] Token stored in Keychain with appropriate protection
  - [ ] Token refresh implemented
  - [ ] Session timeout handling

- [ ] **Data Storage**
  - [ ] Sensitive data in Keychain
  - [ ] SwiftData with file protection
  - [ ] Audio cache with appropriate protection
  - [ ] No sensitive data in UserDefaults

- [ ] **Network Security**
  - [ ] All connections use HTTPS
  - [ ] ATS enabled (no exceptions)
  - [ ] Certificate pinning implemented
  - [ ] Request signing for API calls

- [ ] **Privacy**
  - [ ] GDPR consent management
  - [ ] Data export functionality
  - [ ] Account deletion functionality
  - [ ] Privacy policy accessible

- [ ] **App Store Compliance**
  - [ ] Privacy nutrition labels accurate
  - [ ] Subscription terms displayed
  - [ ] HealthKit permissions justified
  - [ ] No prohibited APIs used

- [ ] **Code Security**
  - [ ] No hardcoded secrets
  - [ ] No debug logging in production
  - [ ] No test accounts in production
  - [ ] Code obfuscation (optional)

### Ongoing Security

- [ ] Dependency vulnerability scanning (weekly)
- [ ] Security patch updates (as released)
- [ ] Penetration testing (quarterly)
- [ ] Access control review (monthly)
- [ ] Incident response plan documented

---

## Incident Response

### Security Incident Procedure

1. **Detection** - Automated monitoring or user report
2. **Containment** - Disable affected features, rotate keys
3. **Investigation** - Determine scope and impact
4. **Notification** - Inform affected users within 72 hours (GDPR)
5. **Remediation** - Fix vulnerability, update affected systems
6. **Post-mortem** - Document lessons learned

### Contact

- Security issues: security@awave.app
- Privacy requests: privacy@awave.app
- Emergency: [On-call PagerDuty]
