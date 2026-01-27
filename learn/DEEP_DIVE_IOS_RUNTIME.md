# Deep Dive: iOS Runtime & System Architecture

> **Level**: Systems-level understanding
> **Goal**: Know how iOS actually works, not just how to use it
> **Approach**: Darwin kernel to UIKit, with the "why" explained

---

## Table of Contents

1. [The iOS Stack: From Silicon to Swipe](#the-ios-stack-from-silicon-to-swipe)
2. [Darwin: The Unix Beneath](#darwin-the-unix-beneath)
3. [Process & Memory Architecture](#process--memory-architecture)
4. [App Lifecycle: What Actually Happens](#app-lifecycle-what-actually-happens)
5. [The Main Thread & Run Loop](#the-main-thread--run-loop)
6. [Rendering Pipeline: From View to Pixel](#rendering-pipeline-from-view-to-pixel)
7. [Touch Event Handling: The Responder Chain](#touch-event-handling-the-responder-chain)
8. [Inter-Process Communication](#inter-process-communication)
9. [Security Architecture](#security-architecture)
10. [Power Management & Background Execution](#power-management--background-execution)

---

## The iOS Stack: From Silicon to Swipe

```
┌─────────────────────────────────────────────────────────────┐
│                    Your App (Swift/ObjC)                    │
├─────────────────────────────────────────────────────────────┤
│   Cocoa Touch (UIKit, SwiftUI, Foundation, etc.)           │
├─────────────────────────────────────────────────────────────┤
│   Core Services (Core Foundation, Core Data, etc.)          │
├─────────────────────────────────────────────────────────────┤
│   Core OS (Mach, BSD, IOKit, Security)                      │
├─────────────────────────────────────────────────────────────┤
│   Darwin Kernel (XNU = Mach + BSD + IOKit)                  │
├─────────────────────────────────────────────────────────────┤
│   Hardware Abstraction Layer                                 │
├─────────────────────────────────────────────────────────────┤
│   Apple Silicon (A-series / M-series chips)                  │
└─────────────────────────────────────────────────────────────┘
```

### Why This Architecture?

Apple needed:
- **Unix foundation** (stability, POSIX compatibility, developer familiarity)
- **Real-time capabilities** (audio, touch responsiveness)
- **Extreme security** (sandboxing, code signing)
- **Power efficiency** (mobile-first)

They built Darwin by combining:
- **Mach** (from Carnegie Mellon) - microkernel, message passing, memory management
- **BSD** (from FreeBSD) - networking, file system, POSIX APIs
- **IOKit** (Apple) - device drivers

---

## Darwin: The Unix Beneath

### XNU Kernel Architecture

```
                    XNU Kernel
┌──────────────────────────────────────────────────┐
│                                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
│  │    Mach     │  │     BSD     │  │  IOKit   │ │
│  │             │  │             │  │          │ │
│  │ - Tasks     │  │ - Processes │  │ - Drivers│ │
│  │ - Threads   │  │ - Files     │  │ - USB    │ │
│  │ - IPC       │  │ - Sockets   │  │ - GPU    │ │
│  │ - VM        │  │ - Signals   │  │ - Audio  │ │
│  └─────────────┘  └─────────────┘  └──────────┘ │
│                                                   │
└──────────────────────────────────────────────────┘
```

### Mach Concepts You Should Know

**Tasks & Threads**:
```
Mach Task ≈ BSD Process
├── Virtual Address Space
├── Port namespace (IPC)
└── Threads (1 to many)

Mach Thread ≈ BSD Thread
├── Execution context
├── CPU state
└── Stack
```

**Mach Ports** (the IPC primitive):
```
Port = Message queue with access control

┌──────────┐    message    ┌──────────┐
│ Process A│──────────────►│ Process B│
│          │               │          │
│  Port X ─┼───────────────┼─► Port Y │
└──────────┘               └──────────┘

Used for:
- App ↔ SpringBoard communication
- App ↔ System services (locationd, mediaserverd)
- Notification delivery
```

### Why Mach Matters for iOS Developers

1. **Crash reports** show Mach exception types:
   - `EXC_BAD_ACCESS` - Invalid memory access
   - `EXC_BAD_INSTRUCTION` - Illegal instruction (e.g., force unwrap nil)
   - `EXC_CRASH` - Unhandled signal (SIGABRT, etc.)

2. **GCD (Grand Central Dispatch)** is built on Mach:
   ```swift
   DispatchQueue.main     // Uses Mach port for wake-up
   DispatchQueue.global() // Mach thread pool
   ```

3. **XPC Services** use Mach ports for IPC

---

## Process & Memory Architecture

### Virtual Memory Layout

Every iOS app sees this virtual address space:

```
0xFFFFFFFFFFFFFFFF ┌────────────────────────────┐
                   │      Kernel Space          │  ← Inaccessible to your app
                   │      (reserved)            │
0x0000000180000000 ├────────────────────────────┤
                   │                            │
                   │      Shared Libraries      │  ← dyld shared cache
                   │      (dyld cache)          │     UIKit, Foundation, etc.
                   │                            │
                   ├────────────────────────────┤
                   │                            │
                   │      Stack                 │  ← Grows downward
                   │      (per thread)          │     ~1MB default main thread
                   │                            │
                   ├────────────────────────────┤
                   │                            │
                   │      Heap                  │  ← malloc, new, alloc
                   │      (dynamic allocation) │     Grows upward
                   │                            │
                   ├────────────────────────────┤
                   │      __DATA segment        │  ← Globals, static variables
                   ├────────────────────────────┤
                   │      __TEXT segment        │  ← Your code (read-only)
                   ├────────────────────────────┤
0x0000000000000000 │      NULL page            │  ← Catches null pointer derefs
                   └────────────────────────────┘
```

### iOS Memory: No Swap File

**Critical difference from macOS/Linux**: iOS has no swap.

```
Desktop OS:                         iOS:
┌─────────────┐                    ┌─────────────┐
│ RAM (full)  │                    │ RAM (full)  │
│             │                    │             │
│    page     │───► Swap to disk   │    page     │───► KILL APP
│             │                    │             │
└─────────────┘                    └─────────────┘
```

**Implications**:
- Apps MUST respond to memory warnings
- Jetsam kills apps that use too much memory
- No warning - just termination

### Jetsam: The Memory Killer

```
Jetsam priority bands (low to high):

JETSAM_PRIORITY_IDLE           (0)   ← Background apps
JETSAM_PRIORITY_BACKGROUND     (10)
JETSAM_PRIORITY_FOREGROUND     (100) ← Active app
JETSAM_PRIORITY_CRITICAL       (200) ← System daemons

When memory pressure:
1. Compress inactive pages
2. Kill lowest priority apps
3. If still pressure, kill higher priority
4. Kernel panic if critical services threatened
```

**Memory limits** (approximate, varies by device):
- Foreground app: ~1-2GB on modern iPhones
- Background app: ~50-100MB before jetsam
- Extensions: ~50MB hard limit

---

## App Lifecycle: What Actually Happens

### Launch Sequence (Deep)

```
1. User taps icon
      │
      ▼
2. SpringBoard sends launch request to launchd
      │
      ▼
3. launchd forks new process
      │
      ▼
4. Kernel loads Mach-O executable
      │
      ├─► Parse Mach-O headers
      ├─► Map __TEXT (code) as read-only
      ├─► Map __DATA as copy-on-write
      └─► Set up initial stack
      │
      ▼
5. dyld (dynamic linker) takes over
      │
      ├─► Load dependent dylibs (from shared cache)
      ├─► Perform binding (resolve symbols)
      ├─► Run initializers (+load, __attribute__((constructor)))
      └─► Call main()
      │
      ▼
6. UIApplicationMain() called
      │
      ├─► Creates UIApplication singleton
      ├─► Creates AppDelegate
      ├─► Loads main storyboard (if any)
      ├─► Creates UIWindow
      └─► Starts run loop
      │
      ▼
7. First frame rendered
      │
      ▼
8. SpringBoard animates your app in
```

### Launch Time Optimization Points

```
Pre-main (dyld):
├── Reduce dylib count (merge into frameworks)
├── Avoid +load methods (use +initialize)
├── Reduce __DATA size (fewer globals)
└── Use dyld3 closures (automatic on iOS 13+)

Post-main:
├── Defer non-essential work
├── Don't block main thread
├── Use lazy initialization
└── Measure with Instruments (App Launch template)
```

### State Transitions

```
┌─────────────┐
│ Not Running │
└──────┬──────┘
       │ Launch
       ▼
┌─────────────┐        ┌─────────────┐
│   Inactive  │◄──────►│   Active    │
└──────┬──────┘        └──────┬──────┘
       │                      │
       │ Background           │ Home button / switch
       ▼                      ▼
┌─────────────┐        ┌─────────────┐
│  Background │───────►│  Suspended  │
└─────────────┘        └──────┬──────┘
       │                      │
       │                      │ Memory pressure
       ▼                      ▼
┌─────────────────────────────────────┐
│            Terminated               │
└─────────────────────────────────────┘
```

**Key insight**: Suspended ≠ Terminated. Suspended apps:
- Remain in memory (but can be jetsam'd)
- No CPU time
- Wake instantly when foregrounded

---

## The Main Thread & Run Loop

### The Run Loop Model

```swift
// Simplified run loop (what UIApplicationMain creates):
while (appIsRunning) {
    // 1. Process input sources (touch, timers, ports)
    let sources = waitForSources(timeout: .infinity)

    // 2. Execute handlers
    for source in sources {
        source.handler()
    }

    // 3. Check observers (CADisplayLink, etc.)
    notifyObservers(.beforeWaiting)

    // 4. Sleep until next event
}
```

### Run Loop Modes

```
Common Modes:
├── NSDefaultRunLoopMode    - Normal operation
├── UITrackingRunLoopMode   - Scrolling (higher priority)
└── NSRunLoopCommonModes    - Combination of above

Why modes matter:
┌─────────────────────────────────────────────────────────┐
│ Timer scheduled in NSDefaultRunLoopMode                │
│                                                         │
│ User starts scrolling                                   │
│    │                                                    │
│    ▼                                                    │
│ Run loop switches to UITrackingRunLoopMode             │
│    │                                                    │
│    ▼                                                    │
│ Timer STOPS firing (wrong mode)                        │
│                                                         │
│ Solution: Schedule in NSRunLoopCommonModes             │
└─────────────────────────────────────────────────────────┘
```

```swift
// Timer that fires even during scrolling:
let timer = Timer(timeInterval: 1.0, repeats: true) { _ in
    updateUI()
}
RunLoop.main.add(timer, forMode: .common)  // Not .default
```

### Why Main Thread Matters

UIKit is **not thread-safe**. Period.

```
Main Thread                    Background Thread
     │                              │
     │  ┌─────────────────────┐    │
     │  │ UIView.frame = x    │    │
     │  └──────────┬──────────┘    │
     │             │               │
     │             │  RACE         │  ┌─────────────────────┐
     │             │◄──────────────┼──│ UIView.frame = y    │
     │             │  CONDITION    │  └─────────────────────┘
     │             │               │
     │  Undefined behavior         │
     │  Crash / Corruption         │
     ▼                             ▼
```

**Xcode's Main Thread Checker**: Enable in scheme diagnostics to catch violations.

---

## Rendering Pipeline: From View to Pixel

### The Three-Phase Model

```
┌─────────────────────────────────────────────────────────────┐
│                     YOUR APP PROCESS                         │
│                                                              │
│   1. UPDATE PHASE (Main Thread)                              │
│   ┌────────────────────────────────────────────────────────┐│
│   │ - Constraint solving (Auto Layout)                     ││
│   │ - layoutSubviews()                                     ││
│   │ - View hierarchy changes                               ││
│   │ - Layer property changes                               ││
│   └────────────────────────────────────────────────────────┘│
│                           │                                  │
│                           │ Commit Transaction               │
│                           ▼                                  │
│   2. COMMIT (to Render Server)                              │
│   ┌────────────────────────────────────────────────────────┐│
│   │ - Serialize layer tree                                 ││
│   │ - Send via Mach IPC to backboardd                      ││
│   └────────────────────────────────────────────────────────┘│
│                                                              │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               │ Mach message
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                  RENDER SERVER (backboardd)                  │
│                                                              │
│   3. RENDER PHASE (Separate Process)                        │
│   ┌────────────────────────────────────────────────────────┐│
│   │ - Decode layer tree                                    ││
│   │ - Rasterize (Core Animation)                           ││
│   │ - Composite layers (GPU)                               ││
│   │ - Display on screen                                    ││
│   └────────────────────────────────────────────────────────┘│
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Why Separate Render Server?

1. **Your app crash doesn't crash the UI** - SpringBoard keeps rendering
2. **60/120 FPS guarantee** - Render server has higher priority
3. **Power efficiency** - GPU compositing is more efficient
4. **Security** - Screen content isolated from app process

### Core Animation Layers

Every UIView has a backing CALayer:

```
UIView (interface)
    │
    │ .layer
    ▼
CALayer (rendering)
    │
    ├── contents (backing store - bitmap or nil)
    ├── frame, bounds, position
    ├── transform (3D)
    ├── opacity, hidden
    ├── cornerRadius, borderWidth
    ├── shadowPath, shadowOpacity
    └── sublayers (children)
```

**Offscreen rendering triggers** (expensive):
- `cornerRadius` + `masksToBounds` together
- `shadowPath` not set (must compute from contents)
- `shouldRasterize = true`
- Custom `drawRect:`

```swift
// SLOW: Forces offscreen render
view.layer.cornerRadius = 10
view.layer.masksToBounds = true
view.layer.shadowOpacity = 0.5

// FAST: Pre-computed shadow path
view.layer.shadowPath = UIBezierPath(
    roundedRect: view.bounds,
    cornerRadius: 10
).cgPath
```

### CADisplayLink: Sync with Display

```swift
// Fire callback every frame (60/120 Hz)
let displayLink = CADisplayLink(target: self, selector: #selector(step))
displayLink.add(to: .main, forMode: .common)

@objc func step(link: CADisplayLink) {
    let elapsed = link.targetTimestamp - link.timestamp
    // Update animation based on actual frame time
}
```

---

## Touch Event Handling: The Responder Chain

### From Hardware to Code

```
1. Finger touches screen
      │
      ▼
2. Digitizer samples touch (up to 240Hz on ProMotion)
      │
      ▼
3. IOKit driver creates touch event
      │
      ▼
4. backboardd receives event
      │
      ▼
5. backboardd sends to foreground app via Mach port
      │
      ▼
6. UIApplication receives UIEvent
      │
      ▼
7. Hit testing: which view was touched?
      │
      ├─► hitTest(_:with:) called recursively
      ├─► Deepest view that returns true is "first responder"
      │
      ▼
8. Event delivered to hit view
      │
      ▼
9. Responder chain for unhandled events
```

### Hit Testing Algorithm

```swift
// Simplified hitTest implementation:
func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    // 1. Check if we should receive touches
    guard isUserInteractionEnabled,
          !isHidden,
          alpha > 0.01 else {
        return nil
    }

    // 2. Check if point is in our bounds
    guard self.point(inside: point, with: event) else {
        return nil
    }

    // 3. Check subviews in reverse order (front to back)
    for subview in subviews.reversed() {
        let convertedPoint = subview.convert(point, from: self)
        if let hitView = subview.hitTest(convertedPoint, with: event) {
            return hitView  // Subview handles it
        }
    }

    // 4. We handle it ourselves
    return self
}
```

### The Responder Chain

```
UIButton (tapped)
    │
    │ touchesBegan(_:with:) not overridden
    ▼
UIView (superview)
    │
    │ touchesBegan(_:with:) not overridden
    ▼
UIViewController.view
    │
    │ touchesBegan(_:with:) not overridden
    ▼
UIViewController
    │
    │ touchesBegan(_:with:) not overridden
    ▼
UIWindow
    │
    │ touchesBegan(_:with:) not overridden
    ▼
UIApplication
    │
    │ touchesBegan(_:with:) not overridden
    ▼
AppDelegate (if UIResponder)
    │
    ▼
Event discarded
```

**Gesture recognizers** intercept before this chain:

```
Touch event
    │
    ▼
┌─────────────────────────────┐
│ UIGestureRecognizers on     │
│ hit-tested view + ancestors │
│                             │
│ If recognizer claims event: │
│   - Other recognizers fail  │
│   - Responder chain skipped │
└─────────────────────────────┘
    │
    ▼
Responder chain (if no gesture claimed)
```

---

## Inter-Process Communication

### XPC: Modern IPC

```swift
// Define protocol
@objc protocol MyServiceProtocol {
    func processData(_ data: Data, reply: @escaping (Data) -> Void)
}

// Client side
let connection = NSXPCConnection(serviceName: "com.app.service")
connection.remoteObjectInterface = NSXPCInterface(with: MyServiceProtocol.self)
connection.resume()

let service = connection.remoteObjectProxy as! MyServiceProtocol
service.processData(data) { result in
    // Handle result
}
```

### URL Schemes & Universal Links

```
URL Schemes (legacy):                Universal Links (modern):
myapp://path/to/content              https://myapp.com/content

- Any app can claim scheme           - Only verified owner can claim
- No validation                       - apple-app-site-association file
- Opens directly                      - Falls back to web if app not installed
- Security concerns                   - More secure
```

### App Groups (Shared Container)

```swift
// Enable in Capabilities: App Groups

// Write from main app:
let shared = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: "group.com.myapp"
)!
let data = "shared".data(using: .utf8)!
try data.write(to: shared.appendingPathComponent("shared.txt"))

// Read from widget:
let shared = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: "group.com.myapp"
)!
let data = try Data(contentsOf: shared.appendingPathComponent("shared.txt"))
```

---

## Security Architecture

### The Sandbox

```
┌─────────────────────────────────────────────────────────────┐
│                       iOS Sandbox                            │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Your App                           │   │
│  │                                                      │   │
│  │  ┌──────────────┐    ┌──────────────┐              │   │
│  │  │ App Bundle   │    │ Data Container│              │   │
│  │  │ (read-only)  │    │ (read-write)  │              │   │
│  │  │              │    │               │              │   │
│  │  │ - Executable │    │ - Documents/  │              │   │
│  │  │ - Resources  │    │ - Library/    │              │   │
│  │  │ - Frameworks │    │ - tmp/        │              │   │
│  │  └──────────────┘    └──────────────┘              │   │
│  │                                                      │   │
│  │  CANNOT ACCESS:                                      │   │
│  │  ✗ Other apps' data                                 │   │
│  │  ✗ System files                                     │   │
│  │  ✗ Hardware directly                                │   │
│  │  ✗ Network without entitlement                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Code Signing Chain of Trust

```
Apple Root CA
     │
     │ Signs
     ▼
Apple WWDR CA (Worldwide Developer Relations)
     │
     │ Signs
     ▼
Your Developer Certificate
     │
     │ Signs
     ▼
Your App Binary

At runtime:
1. Kernel verifies signature chain
2. Checks entitlements match provisioning profile
3. Validates provisioning profile signed by Apple
4. Only then allows execution
```

### Entitlements

```xml
<!-- Entitlements.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
    <key>com.apple.developer.healthkit</key>
    <true/>
    <key>aps-environment</key>
    <string>production</string>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.myapp.shared</string>
    </array>
</dict>
</plist>
```

Entitlements = capability tokens. No entitlement = no access.

### Data Protection Classes

```swift
// When writing files:
try data.write(to: url, options: .completeFileProtection)

Protection Classes:
┌────────────────────────────────────────────────────────────┐
│ Class                        │ Available When              │
├────────────────────────────────────────────────────────────┤
│ completeFileProtection       │ Device unlocked only        │
│ completeUnlessOpen           │ Unlocked OR file open       │
│ completeUntilFirstUserAuth   │ After first unlock          │
│ none                         │ Always (not recommended)    │
└────────────────────────────────────────────────────────────┘

Under the hood:
- Each file encrypted with unique key
- Key wrapped with class key
- Class key derived from device key + passcode
```

---

## Power Management & Background Execution

### Why Background Is So Restricted

```
Battery capacity: ~3000 mAh
Screen-on drain: ~500 mA
CPU active: ~200 mA
Idle (suspended): ~5 mA

Math:
- 100 apps running in background = 20W
- Battery dead in 30 minutes

Apple's solution: Strict background limits
```

### Background Modes

```
Info.plist UIBackgroundModes:

audio           → Keep playing when backgrounded
location        → Continue receiving location updates
voip            → Maintain VoIP call connection
fetch           → Periodic background fetch (system-scheduled)
remote-notification → Wake on silent push
processing      → Long-running tasks (with user consent)
```

### Background Task API

```swift
// Request time to complete work when backgrounding
func applicationDidEnterBackground(_ application: UIApplication) {
    var taskID: UIBackgroundTaskIdentifier = .invalid

    taskID = application.beginBackgroundTask(withName: "Sync") {
        // Expiration handler - you're about to be killed
        application.endBackgroundTask(taskID)
    }

    Task {
        await syncData()
        application.endBackgroundTask(taskID)
    }
}

// You get ~30 seconds, then terminated
```

### BGTaskScheduler (iOS 13+)

```swift
// Register in AppDelegate
BGTaskScheduler.shared.register(
    forTaskWithIdentifier: "com.app.refresh",
    using: nil
) { task in
    self.handleRefresh(task: task as! BGAppRefreshTask)
}

// Schedule
let request = BGAppRefreshTaskRequest(identifier: "com.app.refresh")
request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
try BGTaskScheduler.shared.submit(request)

// System decides WHEN to actually run based on:
// - Battery level
// - Network conditions
// - User's app usage patterns
// - Device charging state
```

---

## Key Takeaways

### What Makes iOS Different From Web

| Aspect | Web | iOS |
|--------|-----|-----|
| Process lifetime | Tab controls | OS controls |
| Background | Unlimited | Heavily restricted |
| Memory | Swap available | Jetsam kills you |
| Threads | Web Workers | Direct thread access |
| Storage | Quota, evictable | Sandbox, persistent |
| IPC | postMessage | Mach ports, XPC |

### Mental Models to Internalize

1. **You are a guest** - iOS controls your lifecycle
2. **Memory is finite** - No swap, handle warnings
3. **Main thread is sacred** - UI work only
4. **Security by default** - Sandbox, sign, entitle
5. **Power is precious** - Background = privilege

---

## Further Reading

- **Apple's "About the iOS Technologies"** - High-level overview
- **"Mac OS X Internals" by Amit Singh** - Darwin deep dive (macOS, but foundational)
- **WWDC sessions on App Lifecycle, Performance, Security** - Direct from Apple engineers
- **XNU source code** - opensource.apple.com

Next deep dive: **Xcode & Build System Internals**?
