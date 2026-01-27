# Deep Dive: Networking & URLSession Internals

> **Level**: Understanding iOS networking from sockets to async/await
> **Goal**: Build robust network layers, debug network issues
> **Context**: Your AWAVE app connects to Supabase—understand what happens under the hood

---

## Table of Contents

1. [iOS Networking Stack](#ios-networking-stack)
2. [URLSession Architecture](#urlsession-architecture)
3. [Request Lifecycle Deep Dive](#request-lifecycle-deep-dive)
4. [Configuration & Caching](#configuration--caching)
5. [Authentication & Security](#authentication--security)
6. [Background Transfers](#background-transfers)
7. [Modern Swift Concurrency Integration](#modern-swift-concurrency-integration)
8. [Network Debugging](#network-debugging)
9. [Performance Optimization](#performance-optimization)
10. [Building a Production Network Layer](#building-a-production-network-layer)

---

## iOS Networking Stack

### The Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                       Your App                                   │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                   URLSession                               │ │
│  │    High-level API, Swift-friendly, automatic features     │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                   CFNetwork                                │ │
│  │    Core Foundation networking (C API)                     │ │
│  │    - HTTP protocol implementation                         │ │
│  │    - TLS/SSL                                              │ │
│  │    - Proxy support                                        │ │
│  │    - Authentication                                       │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                 Network.framework                          │ │
│  │    Modern transport layer (iOS 12+)                       │ │
│  │    - TCP/UDP connections                                  │ │
│  │    - QUIC (HTTP/3)                                        │ │
│  │    - Multipath TCP                                        │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              │                                   │
└──────────────────────────────┼───────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                      BSD Sockets                                 │
│    POSIX socket interface (socket, connect, send, recv)         │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Network Stack (Kernel)                        │
│    TCP/IP implementation, routing, interfaces                   │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Hardware (WiFi, Cellular)                     │
└─────────────────────────────────────────────────────────────────┘
```

### Why URLSession?

```
URLSession provides:
✓ HTTP/1.1, HTTP/2, HTTP/3 (automatic negotiation)
✓ TLS 1.2/1.3 (automatic, secure defaults)
✓ Cookie management
✓ Caching (HTTP cache semantics)
✓ Authentication challenges
✓ Background transfers
✓ Multipath TCP (WiFi + Cellular)
✓ Proxy support
✓ Certificate pinning
✓ Progress tracking
✓ Cancellation

You get all this for free. Don't use raw sockets.
```

---

## URLSession Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────────┐
│                        URLSession                                │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              URLSessionConfiguration                     │   │
│  │  - Timeout intervals                                     │   │
│  │  - Cache policy                                          │   │
│  │  - Cookie policy                                         │   │
│  │  - HTTP headers                                          │   │
│  │  - Cellular/WiFi preferences                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              URLSessionTask (s)                          │   │
│  │                                                          │   │
│  │  URLSessionDataTask      - In-memory response            │   │
│  │  URLSessionDownloadTask  - File download                 │   │
│  │  URLSessionUploadTask    - File upload                   │   │
│  │  URLSessionStreamTask    - TCP stream                    │   │
│  │  URLSessionWebSocketTask - WebSocket (iOS 13+)           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              URLSessionDelegate                          │   │
│  │  - Authentication challenges                             │   │
│  │  - Progress updates                                      │   │
│  │  - Redirects                                             │   │
│  │  - Completion                                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Session Types

```swift
// 1. SHARED SESSION (simple cases)
let session = URLSession.shared
// - Singleton
// - No delegate
// - Default configuration
// - Cannot modify

// 2. DEFAULT SESSION (most apps)
let config = URLSessionConfiguration.default
let session = URLSession(configuration: config)
// - Persistent cache
// - Persistent cookies
// - Credential storage

// 3. EPHEMERAL SESSION (private browsing)
let config = URLSessionConfiguration.ephemeral
let session = URLSession(configuration: config)
// - No disk cache
// - No persistent cookies
// - Session-only credentials

// 4. BACKGROUND SESSION (downloads that survive app termination)
let config = URLSessionConfiguration.background(withIdentifier: "com.app.download")
let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
// - Continues when app suspended/terminated
// - Requires delegate
// - System manages transfers
```

### Configuration Options

```swift
let config = URLSessionConfiguration.default

// Timeouts
config.timeoutIntervalForRequest = 30      // Per-request timeout
config.timeoutIntervalForResource = 300    // Total resource timeout

// Caching
config.requestCachePolicy = .returnCacheDataElseLoad
config.urlCache = URLCache(
    memoryCapacity: 50_000_000,    // 50 MB
    diskCapacity: 100_000_000,     // 100 MB
    diskPath: "myCache"
)

// Connections
config.httpMaximumConnectionsPerHost = 6   // Default is 6
config.allowsCellularAccess = true
config.waitsForConnectivity = true         // iOS 11+: Wait instead of fail

// Headers
config.httpAdditionalHeaders = [
    "User-Agent": "MyApp/1.0",
    "Accept-Language": "de-DE"
]

// Cookies
config.httpCookieStorage = HTTPCookieStorage.shared
config.httpCookieAcceptPolicy = .onlyFromMainDocumentDomain

// Protocol support
config.tlsMinimumSupportedProtocolVersion = .TLSv12
config.multipathServiceType = .handover    // Multipath TCP
```

---

## Request Lifecycle Deep Dive

### What Happens When You Make a Request

```
let (data, response) = try await URLSession.shared.data(from: url)

Timeline:

1. REQUEST CREATION
   ├── URLRequest constructed
   ├── Headers set (User-Agent, Accept, etc.)
   └── Body encoded (if POST/PUT)

2. CACHE CHECK
   ├── Check URLCache for cached response
   ├── Validate freshness (Cache-Control, Expires, ETag)
   └── Return cached if valid, or proceed

3. DNS RESOLUTION
   ├── Check DNS cache
   ├── Query DNS server (if not cached)
   └── Get IP address(es)

4. CONNECTION ESTABLISHMENT
   ├── Check connection pool for existing connection
   ├── If none: TCP handshake (SYN, SYN-ACK, ACK)
   ├── If HTTPS: TLS handshake
   │   ├── ClientHello (supported ciphers, TLS version)
   │   ├── ServerHello (chosen cipher, certificate)
   │   ├── Certificate validation
   │   ├── Key exchange
   │   └── Encrypted tunnel established
   └── Connection ready

5. REQUEST SENT
   ├── HTTP request line (GET /path HTTP/2)
   ├── Headers
   └── Body (if any)

6. RESPONSE RECEIVED
   ├── Status line (HTTP/2 200 OK)
   ├── Response headers
   ├── Body data (possibly chunked)
   └── Connection: keep-alive or close

7. RESPONSE PROCESSING
   ├── Decompress (if Content-Encoding: gzip)
   ├── Store in cache (if cacheable)
   ├── Parse cookies (if Set-Cookie)
   └── Deliver to app

8. COMPLETION
   ├── Return (data, response) to async context
   └── Connection returned to pool (or closed)
```

### Connection Reuse (HTTP Keep-Alive)

```
Without Keep-Alive (HTTP/1.0 default):

Request 1:  [TCP][TLS][REQ][RES][CLOSE]
Request 2:        [TCP][TLS][REQ][RES][CLOSE]
Request 3:              [TCP][TLS][REQ][RES][CLOSE]

With Keep-Alive (HTTP/1.1+ default):

Request 1:  [TCP][TLS][REQ][RES]
Request 2:              [REQ][RES]
Request 3:                    [REQ][RES]
                                       [CLOSE after idle timeout]

URLSession maintains a connection pool and reuses connections automatically.
```

### HTTP/2 Multiplexing

```
HTTP/1.1 (one request per connection at a time):

Connection 1: ───[Request A]─────────[Response A]───
Connection 2: ───[Request B]─────────[Response B]───
Connection 3: ───[Request C]─────────[Response C]───

HTTP/2 (multiple requests on single connection):

Connection:   ───[A]─[B]─[C]────[A resp]─[B resp]─[C resp]───

URLSession automatically uses HTTP/2 if server supports it.
No code changes needed.
```

---

## Configuration & Caching

### HTTP Cache Semantics

```
Cache-Control Header (Response):

max-age=3600        → Cache for 1 hour
no-cache            → Always revalidate
no-store            → Never cache
private             → Don't cache in shared caches
public              → OK to cache everywhere
must-revalidate     → Check freshness before using

┌─────────────────────────────────────────────────────────────────┐
│                     Cache Decision Flow                          │
│                                                                  │
│  Request arrives                                                 │
│       │                                                          │
│       ▼                                                          │
│  Is response in cache?                                           │
│       │                                                          │
│   No  │  Yes                                                     │
│   │   └─────────────┐                                           │
│   │                 ▼                                            │
│   │          Is it fresh?                                        │
│   │          (max-age not exceeded)                              │
│   │                 │                                            │
│   │            Yes  │  No                                        │
│   │             │   └───────────────────┐                       │
│   │             │                       ▼                        │
│   │             │              Revalidate with server            │
│   │             │              (If-None-Match: etag)             │
│   │             │                       │                        │
│   │             │              304 Not Modified?                 │
│   │             │                  │         │                   │
│   │             │              Yes │         │ No (200 OK)       │
│   │             │                  │         │                   │
│   │             ▼                  ▼         ▼                   │
│   │         Return cached      Use cached   Store & return new  │
│   │                                                              │
│   ▼                                                              │
│  Fetch from network                                              │
│  Store in cache (if cacheable)                                   │
│  Return response                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Request Cache Policies

```swift
var request = URLRequest(url: url)

// Use cache, then network (default)
request.cachePolicy = .useProtocolCachePolicy

// Prefer cache, fallback to network
request.cachePolicy = .returnCacheDataElseLoad

// Cache only, fail if not cached
request.cachePolicy = .returnCacheDataDontLoad

// Network only, ignore cache
request.cachePolicy = .reloadIgnoringLocalCacheData

// Force revalidation
request.cachePolicy = .reloadRevalidatingCacheData
```

### Custom Caching

```swift
// Implement URLCache subclass for custom behavior
class CustomCache: URLCache {
    override func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        // Custom cache lookup
        // Could use database, files, etc.
    }

    override func storeCachedResponse(_ cachedResponse: CachedURLResponse,
                                       for request: URLRequest) {
        // Custom storage logic
    }
}

// Or use delegate to modify caching
class NetworkDelegate: NSObject, URLSessionDataDelegate {
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    willCacheResponse proposedResponse: CachedURLResponse,
                    completionHandler: @escaping (CachedURLResponse?) -> Void) {

        // Modify cache behavior
        if proposedResponse.response.url?.host == "api.example.com" {
            // Cache API responses for longer
            var headers = (proposedResponse.response as? HTTPURLResponse)?
                .allHeaderFields as? [String: String] ?? [:]
            headers["Cache-Control"] = "max-age=3600"

            let modifiedResponse = HTTPURLResponse(
                url: proposedResponse.response.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: headers
            )!

            completionHandler(CachedURLResponse(
                response: modifiedResponse,
                data: proposedResponse.data
            ))
        } else {
            completionHandler(proposedResponse)
        }
    }
}
```

---

## Authentication & Security

### App Transport Security (ATS)

```
ATS is enabled by default since iOS 9.
Requires HTTPS with modern TLS for all connections.

Requirements:
✓ TLS 1.2 or higher
✓ Forward secrecy cipher suites
✓ SHA-256+ certificate signature
✓ 2048-bit+ RSA key (or 256-bit+ ECC)

// Info.plist exceptions (avoid if possible)
<key>NSAppTransportSecurity</key>
<dict>
    <!-- Allow specific domain to use HTTP -->
    <key>NSExceptionDomains</key>
    <dict>
        <key>legacy-api.example.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### Certificate Pinning

```swift
// Pin to specific certificate or public key
class PinningDelegate: NSObject, URLSessionDelegate {

    // SHA-256 hash of server's public key
    let pinnedKeyHash = "base64EncodedHash=="

    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Evaluate server trust
        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Get server's public key
        guard let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
              let serverPublicKey = SecCertificateCopyKey(serverCertificate),
              let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) as Data? else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Hash and compare
        let serverKeyHash = serverPublicKeyData.sha256().base64EncodedString()

        if serverKeyHash == pinnedKeyHash {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
```

### Authentication Challenges

```swift
// Handle various authentication types
class AuthDelegate: NSObject, URLSessionTaskDelegate {

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        switch challenge.protectionSpace.authenticationMethod {

        case NSURLAuthenticationMethodHTTPBasic,
             NSURLAuthenticationMethodHTTPDigest:
            // Username/password
            let credential = URLCredential(
                user: "username",
                password: "password",
                persistence: .forSession
            )
            completionHandler(.useCredential, credential)

        case NSURLAuthenticationMethodClientCertificate:
            // Client certificate (mTLS)
            let identity = loadClientIdentity()  // SecIdentity
            let credential = URLCredential(
                identity: identity,
                certificates: nil,
                persistence: .forSession
            )
            completionHandler(.useCredential, credential)

        case NSURLAuthenticationMethodServerTrust:
            // Server certificate validation
            // Handle pinning here
            completionHandler(.performDefaultHandling, nil)

        default:
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
```

### Bearer Token Authentication

```swift
// Most common pattern for APIs
class APIClient {
    private var accessToken: String?
    private var refreshToken: String?

    func authenticatedRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        var request = request

        // Add bearer token
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        // Handle 401 Unauthorized
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 401 {
            // Try to refresh token
            try await refreshAccessToken()

            // Retry request with new token
            request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
            return try await URLSession.shared.data(for: request)
        }

        return (data, response)
    }

    private func refreshAccessToken() async throws {
        // Call refresh endpoint
        // Update accessToken and refreshToken
    }
}
```

---

## Background Transfers

### How Background Sessions Work

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│  ┌────────────┐         ┌────────────────────┐                  │
│  │  Your App  │         │  System (nsurlsessiond) │             │
│  └─────┬──────┘         └──────────┬─────────┘                  │
│        │                           │                             │
│        │ 1. Create background task │                             │
│        │──────────────────────────►│                             │
│        │                           │                             │
│        │ 2. App suspended/killed   │                             │
│        │     ┌──┐                  │                             │
│        │     │  │                  │ 3. System continues         │
│        │     └──┘                  │    download                 │
│        │                           │    ────────────►            │
│        │                           │                             │
│        │                           │ 4. Download completes       │
│        │◄──────────────────────────│                             │
│        │ 5. App relaunched         │                             │
│        │    (in background)        │                             │
│        │                           │                             │
│        │ 6. Delegate methods       │                             │
│        │    called                 │                             │
│        │                           │                             │
└─────────────────────────────────────────────────────────────────┘
```

### Implementation

```swift
class BackgroundDownloader: NSObject, URLSessionDownloadDelegate {
    static let shared = BackgroundDownloader()

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(
            withIdentifier: "com.myapp.backgroundDownload"
        )
        config.isDiscretionary = false  // Start immediately
        config.sessionSendsLaunchEvents = true  // Wake app on completion
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    // Store completion handler from AppDelegate
    var backgroundCompletionHandler: (() -> Void)?

    func download(url: URL) -> URLSessionDownloadTask {
        let task = session.downloadTask(with: url)
        task.resume()
        return task
    }

    // MARK: - URLSessionDownloadDelegate

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        // Move file from temp location
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsURL.appendingPathComponent(downloadTask.originalRequest!.url!.lastPathComponent)

        try? FileManager.default.moveItem(at: location, to: destinationURL)
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        // Update UI (dispatch to main thread)
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            // Call the completion handler to tell system we're done
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
}

// In AppDelegate:
func application(_ application: UIApplication,
                 handleEventsForBackgroundURLSession identifier: String,
                 completionHandler: @escaping () -> Void) {
    BackgroundDownloader.shared.backgroundCompletionHandler = completionHandler
}
```

---

## Modern Swift Concurrency Integration

### async/await with URLSession

```swift
// Simple GET
let (data, response) = try await URLSession.shared.data(from: url)

// With URLRequest
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.httpBody = try JSONEncoder().encode(payload)
let (data, response) = try await URLSession.shared.data(for: request)

// Download to file
let (localURL, response) = try await URLSession.shared.download(from: url)

// Upload
let (data, response) = try await URLSession.shared.upload(for: request, from: fileData)
```

### Streaming with AsyncSequence

```swift
// Stream bytes as they arrive (iOS 15+)
let (bytes, response) = try await URLSession.shared.bytes(from: url)

for try await byte in bytes {
    // Process byte by byte
}

// More practical: lines
let (bytes, response) = try await URLSession.shared.bytes(from: url)

for try await line in bytes.lines {
    // Process line by line (great for SSE, NDJSON)
}
```

### Cancellation

```swift
// Tasks automatically support cancellation
let task = Task {
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}

// Later:
task.cancel()

// In your network code, check for cancellation
func fetchData() async throws -> Data {
    try Task.checkCancellation()  // Throws if cancelled

    let (data, _) = try await URLSession.shared.data(from: url)

    try Task.checkCancellation()  // Check again after long operation

    return data
}
```

### Progress Tracking

```swift
// Use delegate for progress
class ProgressTracker: NSObject, URLSessionTaskDelegate {
    var progressHandler: ((Double) -> Void)?

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        progressHandler?(progress)
    }
}

// Or use observation (simpler)
let task = URLSession.shared.dataTask(with: request)
let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
    print("Progress: \(progress.fractionCompleted)")
}
task.resume()
```

---

## Network Debugging

### Using Charles Proxy / Proxyman

```swift
// Trust proxy certificate in simulator
// Configure proxy in System Preferences

// For production apps, you may need to disable ATS for proxy
#if DEBUG
// Allow proxy for debugging
#endif
```

### URLProtocol for Mocking

```swift
// Intercept all network requests
class MockURLProtocol: URLProtocol {
    static var mockResponses: [URL: (Data, HTTPURLResponse)] = [:]

    override class func canInit(with request: URLRequest) -> Bool {
        return true  // Intercept all requests
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url,
              let (data, response) = MockURLProtocol.mockResponses[url] else {
            client?.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable))
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

// Register for testing
let config = URLSessionConfiguration.ephemeral
config.protocolClasses = [MockURLProtocol.self]
let testSession = URLSession(configuration: config)
```

### Network Link Conditioner

```
Xcode → Open Developer Tool → More Developer Tools → Download
Install "Additional Tools for Xcode"
System Preferences → Network Link Conditioner

Presets:
- 3G
- Edge
- DSL
- WiFi (various)
- 100% Loss (test offline)
- High Latency DNS
```

### Logging

```swift
// Enable URLSession debug logging
// Set environment variable: CFNETWORK_DIAGNOSTICS=3

// Or use os_log
import os

let networkLog = OSLog(subsystem: "com.myapp", category: "network")

func logRequest(_ request: URLRequest) {
    os_log("Request: %{public}@ %{public}@",
           log: networkLog,
           type: .debug,
           request.httpMethod ?? "GET",
           request.url?.absoluteString ?? "")
}

func logResponse(_ response: URLResponse, data: Data) {
    guard let http = response as? HTTPURLResponse else { return }
    os_log("Response: %{public}d, %{public}d bytes",
           log: networkLog,
           type: .debug,
           http.statusCode,
           data.count)
}
```

---

## Performance Optimization

### Connection Coalescing

```
HTTP/2 allows multiple domains to share a connection if:
1. Same IP address
2. Same TLS certificate (covers both domains)

Example:
api.example.com and cdn.example.com
Both resolve to same IP, same cert
→ Single connection for both

URLSession handles this automatically.
```

### Request Priorities

```swift
var request = URLRequest(url: url)

// Set priority hint
request.networkServiceType = .responsiveData  // High priority
// .default
// .video
// .voice
// .responsiveData (high priority for UI)
// .background (low priority)

// URLSessionTask priority (0.0 to 1.0)
let task = session.dataTask(with: request)
task.priority = URLSessionTask.highPriority  // 0.75
// URLSessionTask.defaultPriority = 0.5
// URLSessionTask.lowPriority = 0.25
```

### Prefetching

```swift
// Prefetch resources before needed
class Prefetcher {
    private let session = URLSession.shared
    private var prefetchTasks: [URL: URLSessionDataTask] = [:]

    func prefetch(_ urls: [URL]) {
        for url in urls {
            guard prefetchTasks[url] == nil else { continue }

            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad

            let task = session.dataTask(with: request)
            task.priority = URLSessionTask.lowPriority
            task.resume()

            prefetchTasks[url] = task
        }
    }

    func cancelPrefetch(_ url: URL) {
        prefetchTasks[url]?.cancel()
        prefetchTasks[url] = nil
    }
}
```

### Batch Requests with TaskGroup

```swift
func fetchAll(_ urls: [URL]) async throws -> [Data] {
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

## Building a Production Network Layer

### Architecture

```swift
// MARK: - Endpoint Definition

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    var queryItems: [URLQueryItem]? { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Error

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case networkError(Error)
}

// MARK: - API Client

actor APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private var accessToken: String?

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func setAccessToken(_ token: String?) {
        self.accessToken = token
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try buildRequest(endpoint)
        let (data, response) = try await executeRequest(request)
        return try decode(data, as: T.self)
    }

    func request(_ endpoint: Endpoint) async throws {
        let request = try buildRequest(endpoint)
        _ = try await executeRequest(request)
    }

    // MARK: - Private

    private func buildRequest(_ endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(url: endpoint.baseURL.appendingPathComponent(endpoint.path),
                                       resolvingAgainstBaseURL: true)
        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Auth header
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Custom headers
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func executeRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
            }

            return (data, httpResponse)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    private func decode<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// MARK: - Usage

enum UserEndpoint: Endpoint {
    case getUser(id: String)
    case updateUser(id: String, data: UpdateUserRequest)

    var baseURL: URL { URL(string: "https://api.example.com")! }

    var path: String {
        switch self {
        case .getUser(let id): return "/users/\(id)"
        case .updateUser(let id, _): return "/users/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getUser: return .get
        case .updateUser: return .patch
        }
    }

    var headers: [String: String] { [:] }

    var body: Data? {
        switch self {
        case .getUser: return nil
        case .updateUser(_, let data): return try? JSONEncoder().encode(data)
        }
    }

    var queryItems: [URLQueryItem]? { nil }
}

// Usage
let client = APIClient()
let user: User = try await client.request(UserEndpoint.getUser(id: "123"))
```

---

## Key Takeaways

### Mental Model

```
1. URLSession is a CONNECTION MANAGER, not just a request maker
2. HTTP/2 and connection reuse happen automatically
3. Caching follows HTTP semantics (respect Cache-Control)
4. Background sessions survive app termination
5. async/await is the modern way
```

### Best Practices

```
✓ Use URLSessionConfiguration for app-wide settings
✓ Reuse URLSession instances (don't create per-request)
✓ Handle all error cases (network, HTTP, decoding)
✓ Implement retry with exponential backoff
✓ Use certificate pinning for sensitive apps
✓ Support cancellation
✓ Log requests in debug builds
```

---

## Further Learning

- **Apple's "Networking Overview"** - Foundation concepts
- **WWDC "Advances in Networking"** - Yearly updates
- **HTTP/2 and HTTP/3 specs** - Protocol understanding
- **"High Performance Browser Networking"** by Ilya Grigorik
