# Deep Dive: Xcode & Build System Internals

> **Level**: Understanding the machinery, not just button clicks
> **Goal**: Debug build issues, optimize build times, understand the pipeline
> **Approach**: From source file to signed .ipa

---

## Table of Contents

1. [Xcode Architecture Overview](#xcode-architecture-overview)
2. [The Build Pipeline](#the-build-pipeline)
3. [Project Structure Deep Dive](#project-structure-deep-dive)
4. [Dependency Management](#dependency-management)
5. [Compilation Process](#compilation-process)
6. [Linking & Frameworks](#linking--frameworks)
7. [Code Signing Demystified](#code-signing-demystified)
8. [Build Settings Hierarchy](#build-settings-hierarchy)
9. [Build Performance](#build-performance)
10. [Debugging the Build](#debugging-the-build)

---

## Xcode Architecture Overview

### What Xcode Actually Is

```
Xcode.app
    │
    ├── IDE (User Interface)
    │   └── Source editor, UI designers, debugger UI
    │
    ├── Build System (xcodebuild)
    │   └── llbuild (Low-Level Build System)
    │
    ├── Compilers
    │   ├── swiftc (Swift compiler)
    │   ├── clang (C/C++/Obj-C compiler)
    │   └── actool, ibtool, etc. (Asset compilers)
    │
    ├── Linker (ld64)
    │   └── Creates final executable
    │
    ├── Debugger (LLDB)
    │   └── Runtime debugging
    │
    ├── Simulator
    │   └── x86_64/arm64 simulation environment
    │
    └── Instruments
        └── Performance profiling
```

### Key Directories

```
~/Library/Developer/
├── Xcode/
│   ├── DerivedData/           ← Build products, indices
│   │   └── YourProject-hash/
│   │       ├── Build/
│   │       │   ├── Intermediates.noindex/
│   │       │   └── Products/
│   │       └── Index/         ← Code completion index
│   ├── Archives/              ← .xcarchive files
│   └── UserData/
│       ├── KeyBindings/
│       └── FontAndColorThemes/
│
├── CoreSimulator/
│   └── Devices/               ← Simulator runtimes
│
└── Toolchains/
    └── Custom Swift toolchains
```

---

## The Build Pipeline

### End-to-End Flow

```
Source Files (.swift, .m, .c, resources)
            │
            ▼
┌─────────────────────────────────────────┐
│        DEPENDENCY ANALYSIS              │
│  - Parse build graph                    │
│  - Determine what needs rebuilding      │
│  - Check timestamps & content hashes    │
└─────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────┐
│        COMPILATION                       │
│  - Swift files → .o (object files)      │
│  - Obj-C files → .o                     │
│  - Assets → compiled assets             │
│  - Storyboards → .nib                   │
└─────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────┐
│        LINKING                          │
│  - Combine .o files                     │
│  - Link frameworks                      │
│  - Resolve symbols                      │
│  - Generate executable                  │
└─────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────┐
│        POST-PROCESSING                  │
│  - Copy resources to bundle             │
│  - Code sign                            │
│  - Embed provisioning profile           │
└─────────────────────────────────────────┘
            │
            ▼
        .app Bundle
```

### Build Phases (What You Configure)

```
Target Build Phases (Xcode UI):

1. Dependencies
   └── Other targets that must build first

2. Compile Sources
   └── .swift, .m, .c files to compile

3. Link Binary With Libraries
   └── Frameworks and libraries to link

4. Copy Bundle Resources
   └── Assets, storyboards, data files

5. Embed Frameworks (if any)
   └── Copy frameworks into app bundle

6. Run Script (optional)
   └── Custom build scripts (SwiftLint, etc.)
```

### Build Rules (How Files Are Processed)

```
File Extension → Build Rule → Output

.swift        → Swift Compiler    → .o
.m            → Clang            → .o
.c            → Clang            → .o
.storyboard   → ibtool           → .storyboardc
.xib          → ibtool           → .nib
.xcassets     → actool           → Assets.car
.metal        → Metal Compiler   → .metallib
.intentdefinition → intentbuilderc → Generated Swift
```

---

## Project Structure Deep Dive

### .xcodeproj Anatomy

```
MyApp.xcodeproj/
├── project.pbxproj           ← THE file (all project data)
├── project.xcworkspace/
│   └── contents.xcworkspacedata
├── xcshareddata/
│   └── xcschemes/            ← Shared schemes
└── xcuserdata/
    └── username.xcuserdatad/
        └── xcschemes/        ← Personal schemes
```

### project.pbxproj Format

```
// It's a nested plist (NeXTSTEP heritage)
{
    archiveVersion = 1;
    objectVersion = 56;
    objects = {
        // Every item has a 24-character UUID
        29B97316FDCFA39411CA2CEA /* Project object */ = {
            isa = PBXProject;
            buildConfigurationList = ...;
            mainGroup = ...;
            targets = (...);
        };

        // File reference
        ABC123... /* AppDelegate.swift */ = {
            isa = PBXFileReference;
            path = AppDelegate.swift;
            sourceTree = "<group>";
        };

        // Build file (file + settings)
        DEF456... /* AppDelegate.swift in Sources */ = {
            isa = PBXBuildFile;
            fileRef = ABC123...;
        };
    };
    rootObject = 29B97316FDCFA39411CA2CEA;
}
```

### Workspaces vs Projects

```
Project (.xcodeproj)
├── Single project
├── Can have multiple targets
└── Self-contained

Workspace (.xcworkspace)
├── Container for multiple projects
├── Shared build directory
├── Cross-project dependencies
└── Used by CocoaPods, modern apps

┌────────────────────────────────────────────┐
│            MyApp.xcworkspace               │
│  ┌─────────────────┐  ┌─────────────────┐ │
│  │  MyApp.xcodeproj│  │Pods.xcodeproj   │ │
│  │  - MyApp target │  │- Alamofire      │ │
│  │  - Tests target │  │- Kingfisher     │ │
│  └─────────────────┘  └─────────────────┘ │
└────────────────────────────────────────────┘
```

### Schemes

```
Scheme = "How to build and run"

┌────────────────────────────────────────────────────────────┐
│                    Scheme: MyApp                           │
├────────────────────────────────────────────────────────────┤
│ Build      │ Which targets, in what order                  │
│ Run        │ Executable, arguments, environment            │
│ Test       │ Test targets, coverage                       │
│ Profile    │ Instruments template                          │
│ Analyze    │ Static analysis settings                      │
│ Archive    │ Distribution settings                         │
└────────────────────────────────────────────────────────────┘
```

---

## Dependency Management

### Swift Package Manager (SPM)

```
Package.swift Structure:

let package = Package(
    name: "MyLibrary",

    platforms: [
        .iOS(.v15),      // Minimum deployment target
        .macOS(.v12)
    ],

    products: [
        // What this package exports
        .library(
            name: "MyLibrary",
            targets: ["MyLibrary"]
        ),
        .executable(
            name: "mytool",
            targets: ["MyTool"]
        )
    ],

    dependencies: [
        // External packages
        .package(url: "https://github.com/...", from: "1.0.0"),
        .package(url: "https://github.com/...", branch: "main"),
        .package(url: "https://github.com/...", exact: "2.0.0"),
        .package(path: "../LocalPackage")
    ],

    targets: [
        // Actual source modules
        .target(
            name: "MyLibrary",
            dependencies: ["Alamofire"],
            path: "Sources/MyLibrary",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "MyLibraryTests",
            dependencies: ["MyLibrary"]
        )
    ]
)
```

### How SPM Resolution Works

```
1. Read Package.swift
      │
      ▼
2. Fetch all dependencies (recursive)
      │
      ▼
3. Build dependency graph
      │
      ├── Check version constraints
      ├── Resolve conflicts (highest compatible)
      └── Generate Package.resolved (lockfile)
      │
      ▼
4. Clone/checkout exact versions
      │
      ▼
5. Compile packages in dependency order
```

### SPM vs CocoaPods vs Carthage

```
┌─────────────────────────────────────────────────────────────────┐
│ Aspect            │ SPM          │ CocoaPods    │ Carthage      │
├───────────────────┼──────────────┼──────────────┼───────────────┤
│ Apple-supported   │ ✓            │ ✗            │ ✗             │
│ Xcode integration │ Native       │ Workspace    │ Manual        │
│ Binary caching    │ ✓ (Xcode 14+)│ Via plugins  │ Prebuilt      │
│ Configuration     │ Package.swift│ Podfile      │ Cartfile      │
│ Lockfile          │ Package.resolved │ Podfile.lock │ Cartfile.resolved │
│ Resource bundling │ ✓            │ ✓            │ Limited       │
│ Obj-C support     │ ✓            │ ✓            │ ✓             │
└─────────────────────────────────────────────────────────────────┘

Recommendation: Use SPM for new projects. CocoaPods still needed
for some legacy libraries.
```

---

## Compilation Process

### Swift Compilation Stages

```
Source.swift
     │
     ▼
┌────────────────┐
│    Parsing     │  → AST (Abstract Syntax Tree)
└────────────────┘
     │
     ▼
┌────────────────┐
│    Sema        │  → Type-checked AST
│  (Semantic     │    (Types resolved, constraints satisfied)
│   Analysis)    │
└────────────────┘
     │
     ▼
┌────────────────┐
│    SILGen      │  → SIL (Swift Intermediate Language)
│                │    (High-level, Swift-specific IR)
└────────────────┘
     │
     ▼
┌────────────────┐
│  SIL Optimizer │  → Optimized SIL
│                │    (Inlining, ARC optimization, etc.)
└────────────────┘
     │
     ▼
┌────────────────┐
│    IRGen       │  → LLVM IR
│                │    (Low-level, platform-agnostic)
└────────────────┘
     │
     ▼
┌────────────────┐
│     LLVM       │  → Machine Code (.o file)
│   Backend      │    (x86_64, arm64)
└────────────────┘
```

### Whole Module Optimization (WMO)

```
Without WMO:                    With WMO:
┌──────────────┐               ┌──────────────────────────────┐
│ File1.swift  │──► File1.o    │                              │
└──────────────┘               │  All files compiled together │
┌──────────────┐               │                              │
│ File2.swift  │──► File2.o    │  ──► Single optimization     │
└──────────────┘               │      context                 │
┌──────────────┐               │                              │
│ File3.swift  │──► File3.o    │  ──► Better inlining,        │
└──────────────┘               │      dead code elimination   │
                               │                              │
Can't inline across files      │  ──► Module.o                │
                               └──────────────────────────────┘
```

**Trade-off**:
- WMO = Better runtime performance, slower incremental builds
- Incremental = Faster builds, less optimization

**Typical setup**:
- Debug: Incremental (fast builds)
- Release: WMO (optimized binary)

### Compilation Flags You Should Know

```
// Swift Compiler Flags (OTHER_SWIFT_FLAGS)

-Onone              // No optimization (Debug)
-O                  // Optimize for speed (Release)
-Osize              // Optimize for size
-whole-module-optimization  // WMO

-enable-testing     // Enable @testable imports
-suppress-warnings  // Hide warnings

-D DEBUG            // Define compilation condition
                    // Use: #if DEBUG ... #endif

// LLVM Flags (OTHER_LDFLAGS, OTHER_CFLAGS)

-dead_strip         // Remove unused code
-ObjC               // Load all Obj-C symbols
-framework UIKit    // Link framework
```

---

## Linking & Frameworks

### Static vs Dynamic Linking

```
STATIC LIBRARY (.a)
┌─────────────────────────────────────────────────────┐
│                                                      │
│  Your Code.o + Library.a = Single Executable        │
│                                                      │
│  Pros:                                               │
│  - No load-time overhead                            │
│  - Single binary                                    │
│                                                      │
│  Cons:                                               │
│  - Larger binary size                               │
│  - Can't share between apps                         │
│  - Full rebuild on library change                   │
└─────────────────────────────────────────────────────┘

DYNAMIC LIBRARY (.dylib, .framework)
┌─────────────────────────────────────────────────────┐
│                                                      │
│  Your Executable ──links to──► Library.dylib        │
│                                                      │
│  At runtime:                                        │
│  1. dyld loads library                              │
│  2. Resolves symbols                                │
│  3. Patches call sites                              │
│                                                      │
│  Pros:                                               │
│  - Smaller binary                                   │
│  - Shared across apps (system frameworks)           │
│  - Update library without recompiling app           │
│                                                      │
│  Cons:                                               │
│  - Load-time overhead                               │
│  - Library must be present at runtime               │
└─────────────────────────────────────────────────────┘
```

### Framework Types

```
System Framework (e.g., UIKit)
├── Shipped with iOS
├── In dyld shared cache
├── Already loaded when your app runs
└── Link: just reference, no embedding

Embedded Framework
├── Your code or third-party
├── Copied into app bundle
├── Loaded at launch
└── Increases app size

Static Framework
├── Like static library + resources
├── Compiled into your binary
├── No runtime loading
└── Used by some SPM packages
```

### The Mach-O Format

```
Your compiled binary is a Mach-O file:

┌─────────────────────────────────────────┐
│            Mach-O Header               │
│  - Magic number (0xFEEDFACF)           │
│  - CPU type (arm64)                    │
│  - File type (executable, dylib)       │
│  - Number of load commands             │
└─────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│           Load Commands                 │
│  LC_SEGMENT_64 __TEXT                  │
│  LC_SEGMENT_64 __DATA                  │
│  LC_LOAD_DYLIB @rpath/MyFramework      │
│  LC_CODE_SIGNATURE                      │
│  LC_ENCRYPTION_INFO                     │
└─────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│              Segments                   │
│                                         │
│  __TEXT (executable code)              │
│    __text (main code)                  │
│    __stubs (lazy binding stubs)        │
│    __const (constant data)             │
│                                         │
│  __DATA (writable data)                │
│    __data (initialized data)           │
│    __bss (uninitialized data)          │
│    __objc_classlist (Obj-C classes)    │
│                                         │
│  __LINKEDIT (linking info)             │
│    Symbol table                         │
│    String table                         │
│    Code signature                       │
└─────────────────────────────────────────┘
```

### Inspecting Binaries

```bash
# View Mach-O structure
otool -l MyApp

# View linked libraries
otool -L MyApp

# View symbols
nm MyApp | head -50

# View Swift symbols (demangled)
nm MyApp | swift-demangle

# View segments and sizes
size -m MyApp

# Check architectures (universal binary)
lipo -info MyApp
# Output: Architectures in the fat file: arm64 arm64e
```

---

## Code Signing Demystified

### The Chain of Trust

```
Apple Root CA
     │
     │ "I trust Apple"
     ▼
Apple WWDR CA (Worldwide Developer Relations)
     │
     │ "I trust developers Apple verified"
     ▼
Your Developer Certificate
     │
     │ "I am this developer"
     ▼
Code Signature
     │
     │ "I signed this code"
     ▼
Provisioning Profile
     │
     │ "This code can run on these devices with these capabilities"
     ▼
iOS Kernel
     │
     │ Verifies entire chain before execution
     ▼
App Runs (or doesn't)
```

### Certificate Types

```
Development Certificate
├── For: Running on your test devices
├── Tied to: Your Apple ID
├── Creates: Personal signing identity
└── Stored in: Your Mac's Keychain

Distribution Certificate
├── For: App Store / Ad Hoc / Enterprise
├── Tied to: Your team
├── Creates: Team signing identity
└── Stored in: Team member Keychains

Types:
- Apple Development (iOS + macOS development)
- Apple Distribution (App Store)
- Developer ID (macOS outside App Store)
```

### Provisioning Profiles

```
┌───────────────────────────────────────────────────────────────┐
│                  Provisioning Profile                         │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ App ID: TEAMID.com.company.appname                      │ │
│  │                                                          │ │
│  │ Certificates:                                            │ │
│  │   - Developer Certificate ABC123...                      │ │
│  │   - Developer Certificate DEF456...                      │ │
│  │                                                          │ │
│  │ Devices (Development/Ad Hoc only):                      │ │
│  │   - iPhone UDID: 00001234-...                           │ │
│  │   - iPad UDID: 00005678-...                             │ │
│  │                                                          │ │
│  │ Entitlements:                                           │ │
│  │   - aps-environment: development                        │ │
│  │   - com.apple.developer.healthkit: true                 │ │
│  │                                                          │ │
│  │ Expiration: 2025-01-15                                  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  Signed by: Apple WWDR CA                                    │
└───────────────────────────────────────────────────────────────┘

Profile Types:
- Development: For testing, requires device UDIDs
- Ad Hoc: For limited distribution (100 devices)
- App Store: For submission (no device list)
- Enterprise: For company-internal (no device limit)
```

### Automatic Signing (How It Works)

```
When you select "Automatically manage signing":

1. Xcode reads your Bundle Identifier
      │
      ▼
2. Xcode checks Apple Developer Portal
      │
      ├─► App ID exists? If not, create it
      ├─► Certificate valid? If not, create/download
      └─► Profile exists? If not, create it
      │
      ▼
3. Downloads/generates provisioning profile
      │
      ▼
4. Embeds profile in build

Behind the scenes:
- Uses your Apple ID credentials
- Calls Apple's developer services API
- Caches profiles in ~/Library/MobileDevice/Provisioning Profiles/
```

### Manual Signing (When You Need Control)

```swift
// In Build Settings:

CODE_SIGN_STYLE = Manual
CODE_SIGN_IDENTITY = "Apple Distribution: Company Name (TEAMID)"
PROVISIONING_PROFILE_SPECIFIER = "MyApp_AppStore_Profile"

// Or use Fastlane match for team consistency:
// - Stores certs/profiles in Git repo
// - All team members use same identity
// - No "works on my machine" issues
```

---

## Build Settings Hierarchy

### Resolution Order (Lowest to Highest Priority)

```
1. Platform Defaults
   └── Xcode's built-in defaults for iOS/macOS

2. Project-Level Settings
   └── Shared across all targets

3. Target-Level Settings
   └── Specific to this target

4. Build Configuration Settings (.xcconfig)
   └── Can override at project or target level

5. Command-Line Arguments
   └── xcodebuild SETTING=value

Each level OVERRIDES the previous
```

### .xcconfig Files

```
// Development.xcconfig
#include "Base.xcconfig"

SWIFT_OPTIMIZATION_LEVEL = -Onone
DEBUG_INFORMATION_FORMAT = dwarf
ENABLE_TESTABILITY = YES
OTHER_SWIFT_FLAGS = $(inherited) -D DEBUG

// Release.xcconfig
#include "Base.xcconfig"

SWIFT_OPTIMIZATION_LEVEL = -O
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
ENABLE_TESTABILITY = NO

// Base.xcconfig (shared)
IPHONEOS_DEPLOYMENT_TARGET = 15.0
SWIFT_VERSION = 5.0
TARGETED_DEVICE_FAMILY = 1,2  // iPhone, iPad

// Environment-specific
API_BASE_URL = https:$(DOUBLE_SLASH)api.example.com
DOUBLE_SLASH = //  // Workaround for URL in xcconfig
```

### Key Build Settings

```
// Architectures
ARCHS = arm64                    // Build for these CPUs
VALID_ARCHS = arm64              // Allowed architectures
ONLY_ACTIVE_ARCH = YES           // Debug: build only current

// Optimization
SWIFT_OPTIMIZATION_LEVEL = -Onone/-O/-Osize
GCC_OPTIMIZATION_LEVEL = 0/1/2/3/s

// Code Signing
CODE_SIGN_IDENTITY = Apple Development
PROVISIONING_PROFILE_SPECIFIER = ...
DEVELOPMENT_TEAM = TEAMID

// Deployment
IPHONEOS_DEPLOYMENT_TARGET = 15.0

// Search Paths
FRAMEWORK_SEARCH_PATHS = $(inherited) ...
HEADER_SEARCH_PATHS = $(inherited) ...

// Linking
OTHER_LDFLAGS = -ObjC -framework MyFramework
LD_RUNPATH_SEARCH_PATHS = @executable_path/Frameworks
```

---

## Build Performance

### Measuring Build Time

```bash
# Enable build timing in Xcode
defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES

# View detailed build log
# Xcode → Report Navigator → Build

# Command line with timing
xcodebuild build -project MyApp.xcodeproj \
    -scheme MyApp \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    OTHER_SWIFT_FLAGS="-Xfrontend -debug-time-compilation"
```

### Common Build Time Killers

```
1. Type Inference Complexity
   // SLOW - compiler struggles
   let x = [1, 2, 3].map { $0 * 2 }.filter { $0 > 2 }.reduce(0, +)

   // FAST - explicit types
   let x: Int = [1, 2, 3].map { $0 * 2 }.filter { $0 > 2 }.reduce(0, +)

2. Complex Closures
   // SLOW
   let result = items.sorted { a, b in
       a.date < b.date && a.priority > b.priority || a.name < b.name
   }

   // FAST - extract to function
   func compare(_ a: Item, _ b: Item) -> Bool { ... }
   let result = items.sorted(by: compare)

3. Deeply Nested Generics
   // SLOW
   Dictionary<String, Array<Optional<Result<Response, Error>>>>

   // FAST - typealias
   typealias ResponseCache = Dictionary<String, Array<OptionalResult>>

4. Large Files
   // Split 5000+ line files
   // Use extensions in separate files
```

### Build Caching

```
DerivedData Caches:
├── Module cache (compiled Swift modules)
├── Build products (.o files, frameworks)
├── Index (code completion database)
└── Logs

Xcode Cloud / CI caching:
- Cache DerivedData between builds
- Cache SPM checkouts (SourcePackages/)
- Cache CocoaPods (Pods/)

Remote caching (advanced):
- Bazel with remote cache
- Buck with cache
- SPM binary targets
```

### Parallelization

```
Build Settings:
SWIFT_COMPILATION_MODE = incremental  // Parallel file compilation

Project Settings:
- Build Active Architecture Only = YES (Debug)
- Parallelize Build = YES

Hardware:
- More CPU cores = faster parallel builds
- SSD = faster I/O (obviously)
- RAM = larger build cache
```

---

## Debugging the Build

### Reading Build Logs

```
Xcode Build Log Structure:

▼ Build target MyApp
  ▼ Compile Swift source files
    ○ CompileSwift normal arm64 /path/to/File.swift
      cd /path/to/project
      /Applications/Xcode.app/.../swiftc -module-name MyApp ...

  ▼ Link MyApp
    ○ Ld /path/to/MyApp normal
      cd /path/to/project
      /Applications/Xcode.app/.../clang -target arm64-apple-ios15.0 ...

  ▼ Sign MyApp.app
    ○ CodeSign /path/to/MyApp.app
      /usr/bin/codesign --force --sign ABC123... ...
```

### Common Build Errors

```
ERROR: "No such module 'ModuleName'"
CAUSE: SPM package not resolved, framework not linked
FIX:
  - File → Packages → Resolve Package Versions
  - Check Link Binary With Libraries

ERROR: "Undefined symbols for architecture arm64"
CAUSE: Missing library, wrong architecture
FIX:
  - Check Other Linker Flags (-ObjC, -framework X)
  - Verify library is arm64

ERROR: "Code signing failed"
CAUSE: Wrong certificate, expired profile, missing entitlement
FIX:
  - Check Signing & Capabilities tab
  - Verify profile in Developer Portal
  - Check Bundle ID matches

ERROR: "Multiple commands produce..."
CAUSE: Duplicate resources, conflicting outputs
FIX:
  - Remove duplicate files from Copy Bundle Resources
  - Check SPM resource handling
```

### xcodebuild Command Line

```bash
# List available schemes
xcodebuild -list

# Build for simulator
xcodebuild build \
    -workspace MyApp.xcworkspace \
    -scheme MyApp \
    -destination 'platform=iOS Simulator,name=iPhone 15'

# Build for device
xcodebuild build \
    -workspace MyApp.xcworkspace \
    -scheme MyApp \
    -destination 'generic/platform=iOS'

# Archive for distribution
xcodebuild archive \
    -workspace MyApp.xcworkspace \
    -scheme MyApp \
    -archivePath ./build/MyApp.xcarchive

# Export IPA
xcodebuild -exportArchive \
    -archivePath ./build/MyApp.xcarchive \
    -exportPath ./build \
    -exportOptionsPlist ExportOptions.plist

# Clean
xcodebuild clean \
    -workspace MyApp.xcworkspace \
    -scheme MyApp
```

---

## Key Takeaways

### Mental Model

```
Source → Compile → Link → Sign → Bundle

Each step can fail independently.
Understand which step failed to fix it.
```

### Build System Philosophy

1. **Incremental** - Only rebuild what changed
2. **Parallel** - Compile independent files simultaneously
3. **Cached** - Reuse previous build products
4. **Deterministic** - Same input → same output

### When Things Go Wrong

```
1. Clean build folder (Cmd+Shift+K, then Cmd+Shift+Option+K)
2. Delete DerivedData (if desperate)
3. Check build log (Report Navigator)
4. Verify signing (Signing & Capabilities)
5. Resolve packages (File → Packages → Resolve)
```

---

## Next Steps

- **Practice**: Break builds intentionally, fix them
- **Explore**: Read build logs for successful builds
- **Optimize**: Profile your build, find bottlenecks
- **Automate**: Set up xcodebuild scripts, Fastlane

Next deep dive: **SwiftUI Internals & Rendering**?
