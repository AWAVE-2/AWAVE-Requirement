# Deep Dive: Core Data & SwiftData Persistence

> **Level**: Understanding iOS persistence from SQLite to SwiftData
> **Goal**: Choose the right persistence strategy, understand the stack
> **Context**: AWAVE needs offline support—understand your options

---

## Table of Contents

1. [iOS Persistence Landscape](#ios-persistence-landscape)
2. [Core Data Architecture](#core-data-architecture)
3. [The Core Data Stack](#the-core-data-stack)
4. [Managed Object Context Deep Dive](#managed-object-context-deep-dive)
5. [Concurrency & Threading](#concurrency--threading)
6. [Fetching & Performance](#fetching--performance)
7. [SwiftData: The Modern Alternative](#swiftdata-the-modern-alternative)
8. [Migration Strategies](#migration-strategies)
9. [Sync Patterns](#sync-patterns)
10. [When to Use What](#when-to-use-what)

---

## iOS Persistence Landscape

### Options Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    iOS Persistence Options                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  UserDefaults                                                    │
│  ├── Key-value store                                            │
│  ├── Property list types only                                   │
│  ├── Synchronous                                                │
│  └── Best for: Settings, small data (<1MB)                      │
│                                                                  │
│  Keychain                                                        │
│  ├── Secure storage                                             │
│  ├── Encrypted at rest                                          │
│  ├── Survives app reinstall (optional)                          │
│  └── Best for: Credentials, tokens, sensitive data              │
│                                                                  │
│  File System                                                     │
│  ├── FileManager API                                            │
│  ├── Documents, Library, Caches directories                     │
│  ├── Codable serialization                                      │
│  └── Best for: Large files, media, documents                    │
│                                                                  │
│  SQLite (direct)                                                 │
│  ├── Relational database                                        │
│  ├── Full SQL control                                           │
│  ├── No ORM overhead                                            │
│  └── Best for: Complex queries, existing SQL expertise          │
│                                                                  │
│  Core Data                                                       │
│  ├── Object graph persistence                                   │
│  ├── Built on SQLite (usually)                                  │
│  ├── Faulting, caching, undo                                    │
│  └── Best for: Complex object graphs, relationships             │
│                                                                  │
│  SwiftData (iOS 17+)                                            │
│  ├── Modern Swift-native                                        │
│  ├── Built on Core Data                                         │
│  ├── @Model macro                                               │
│  └── Best for: New projects, SwiftUI integration                │
│                                                                  │
│  CloudKit                                                        │
│  ├── Apple's cloud sync                                         │
│  ├── Integrates with Core Data                                  │
│  └── Best for: Apple ecosystem sync                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Decision Matrix

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Use Case                        │ Recommendation                        │
├─────────────────────────────────────────────────────────────────────────┤
│ App settings                    │ UserDefaults                          │
│ Auth tokens, passwords          │ Keychain                              │
│ Cached API responses            │ URLCache or custom file cache         │
│ Downloaded media files          │ File system (Caches or Documents)     │
│ Structured app data             │ Core Data / SwiftData                 │
│ Cross-device sync (Apple)       │ Core Data + CloudKit                  │
│ Complex SQL needs               │ SQLite directly (GRDB, SQLite.swift) │
│ Simple key-value (large)        │ File system + Codable                 │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Core Data Architecture

### Conceptual Model

```
Core Data is NOT a database.
Core Data is an OBJECT GRAPH MANAGER that can persist to a database.

┌─────────────────────────────────────────────────────────────────┐
│                     Your Application                             │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Object Graph (in memory)                    │   │
│  │                                                          │   │
│  │     ┌──────┐       ┌──────┐       ┌──────┐             │   │
│  │     │Person│◄─────►│Address│      │ Order│             │   │
│  │     └──┬───┘       └──────┘       └──┬───┘             │   │
│  │        │                             │                  │   │
│  │        │ orders                      │ items            │   │
│  │        ▼                             ▼                  │   │
│  │     ┌──────┐                      ┌──────┐             │   │
│  │     │Order │                      │ Item │             │   │
│  │     └──────┘                      └──────┘             │   │
│  │                                                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              │ persist/load                      │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Persistent Store (SQLite)                   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Concepts

```
ENTITY
├── Like a class definition / table schema
├── Has attributes (properties) and relationships
└── Defined in .xcdatamodeld file

ATTRIBUTE
├── Property of an entity
├── Types: String, Integer, Double, Boolean, Date, Data, UUID, URI, Transformable
└── Can be optional, indexed, transient

RELATIONSHIP
├── Connection between entities
├── To-one or to-many
├── Inverse relationships (bidirectional)
└── Delete rules: Nullify, Cascade, Deny, No Action

MANAGED OBJECT
├── Instance of an entity (like a row)
├── Subclass of NSManagedObject
└── Lives in a managed object context

MANAGED OBJECT CONTEXT
├── Scratchpad for managed objects
├── Tracks changes
├── Saves to persistent store
└── Thread-confined

PERSISTENT STORE COORDINATOR
├── Mediates between context and store
├── Manages multiple stores
└── Handles migrations

PERSISTENT CONTAINER
├── Modern convenience wrapper
├── Sets up entire stack
└── NSPersistentContainer or NSPersistentCloudKitContainer
```

---

## The Core Data Stack

### Traditional Setup

```swift
// Manual stack setup (understanding the pieces)

// 1. Managed Object Model (schema)
let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
let model = NSManagedObjectModel(contentsOf: modelURL)!

// 2. Persistent Store Coordinator (middleware)
let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

// 3. Add persistent store (database file)
let storeURL = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("Model.sqlite")

try coordinator.addPersistentStore(
    ofType: NSSQLiteStoreType,
    configurationName: nil,
    at: storeURL,
    options: [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
)

// 4. Managed Object Context (working area)
let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
context.persistentStoreCoordinator = coordinator
```

### Modern Setup (NSPersistentContainer)

```swift
// Recommended approach
class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")

        // Configure for performance
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }

        // Automatically merge changes from background contexts
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }

    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
}
```

### Stack Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    NSPersistentContainer                         │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    viewContext                           │   │
│  │               (Main Queue Context)                       │   │
│  │                                                          │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                 │   │
│  │  │ Object  │  │ Object  │  │ Object  │  (Managed       │   │
│  │  │   A     │  │   B     │  │   C     │   Objects)      │   │
│  │  └─────────┘  └─────────┘  └─────────┘                 │   │
│  │                                                          │   │
│  └───────────────────────┬─────────────────────────────────┘   │
│                          │                                      │
│  ┌───────────────────────┼─────────────────────────────────┐   │
│  │ Background Context 1  │  Background Context 2           │   │
│  │ (Private Queue)       │  (Private Queue)                │   │
│  └───────────────────────┴─────────────────────────────────┘   │
│                          │                                      │
│  ┌───────────────────────┴─────────────────────────────────┐   │
│  │            NSPersistentStoreCoordinator                  │   │
│  └───────────────────────┬─────────────────────────────────┘   │
│                          │                                      │
│  ┌───────────────────────┴─────────────────────────────────┐   │
│  │              NSPersistentStore (SQLite)                  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Managed Object Context Deep Dive

### Context is a Scratchpad

```
Think of NSManagedObjectContext as a "scratchpad" or "transaction"

┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│  1. Fetch objects → loaded into context                         │
│                                                                  │
│  2. Make changes → tracked in context (not saved yet!)          │
│                                                                  │
│  3. save() → writes to persistent store                         │
│                                                                  │
│  4. rollback() → discards all unsaved changes                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Change Tracking

```swift
// Context tracks:
// - Inserted objects (new)
// - Updated objects (modified)
// - Deleted objects (removed)

context.insertedObjects   // Set<NSManagedObject>
context.updatedObjects    // Set<NSManagedObject>
context.deletedObjects    // Set<NSManagedObject>

context.hasChanges        // Bool

// Individual object state
object.isInserted
object.isUpdated
object.isDeleted
object.changedValues()    // [String: Any] - what changed
```

### Faulting

```
FAULTING = Lazy loading of object data

┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│  Unfired Fault (not loaded):                                    │
│  ┌─────────────────────────────────────────┐                   │
│  │ Person (fault)                          │                   │
│  │ objectID: <x-coredata://...>            │ ← Only ID known   │
│  │ name: ???                               │                   │
│  │ orders: ???                             │                   │
│  └─────────────────────────────────────────┘                   │
│                                                                  │
│  Access property → fault fires → data loaded:                   │
│  ┌─────────────────────────────────────────┐                   │
│  │ Person                                  │                   │
│  │ objectID: <x-coredata://...>            │                   │
│  │ name: "John"                            │ ← Now loaded      │
│  │ orders: [Order1, Order2] (faults)       │                   │
│  └─────────────────────────────────────────┘                   │
│                                                                  │
│  Benefits:                                                       │
│  - Memory efficient (only load what's needed)                   │
│  - Fast fetches (don't load all data upfront)                   │
│                                                                  │
│  Gotcha:                                                         │
│  - Accessing fault on wrong thread = crash                      │
│  - N+1 query problem (batch fetch to avoid)                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

```swift
// Check if object is a fault
if person.isFault {
    // Data not loaded yet
}

// Prefetch to avoid N+1
let request = Person.fetchRequest()
request.relationshipKeyPathsForPrefetching = ["orders", "address"]
// Now orders and address loaded with person
```

---

## Concurrency & Threading

### The Golden Rule

```
MANAGED OBJECTS ARE NOT THREAD-SAFE

Every managed object belongs to ONE context.
Every context belongs to ONE queue (thread).
NEVER pass managed objects between threads.

// WRONG
let person = context1.object(with: objectID) // On main thread
DispatchQueue.global().async {
    person.name = "New Name"  // CRASH or corruption
}

// RIGHT
let objectID = person.objectID  // Thread-safe
DispatchQueue.global().async {
    let backgroundContext = container.newBackgroundContext()
    let person = backgroundContext.object(with: objectID)
    person.name = "New Name"
    try backgroundContext.save()
}
```

### Context Types

```swift
// Main Queue Context (for UI)
let mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
// ALL access must be on main thread
// OR wrapped in mainContext.perform { }

// Private Queue Context (for background work)
let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
// ALL access must be wrapped in backgroundContext.perform { }
// Or use backgroundContext.performAndWait { } (blocking)
```

### Safe Background Operations

```swift
// Pattern 1: performBackgroundTask
container.performBackgroundTask { context in
    // This closure runs on a background queue
    // Context is created for you

    let request = Person.fetchRequest()
    let people = try? context.fetch(request)

    for person in people ?? [] {
        person.processedAt = Date()
    }

    try? context.save()
}

// Pattern 2: Dedicated background context
let backgroundContext = container.newBackgroundContext()
backgroundContext.perform {
    // Work here
    try? backgroundContext.save()
}

// Pattern 3: Modern async/await (iOS 15+)
func updatePerson(id: NSManagedObjectID) async throws {
    try await container.performBackgroundTask { context in
        let person = context.object(with: id) as! Person
        person.updatedAt = Date()
        try context.save()
    }
}
```

### Merge Policies

```swift
// When same object changed in multiple contexts
context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

// Options:
// NSErrorMergePolicy - Fail on conflict (default)
// NSMergeByPropertyStoreTrumpMergePolicy - Store wins
// NSMergeByPropertyObjectTrumpMergePolicy - In-memory wins
// NSOverwriteMergePolicy - In-memory completely overwrites
// NSRollbackMergePolicy - Store completely overwrites
```

---

## Fetching & Performance

### Fetch Request Anatomy

```swift
let request = NSFetchRequest<Person>(entityName: "Person")

// Or type-safe
let request = Person.fetchRequest()

// Predicate (WHERE clause)
request.predicate = NSPredicate(format: "age > %d AND name CONTAINS %@", 18, "John")

// Sort (ORDER BY)
request.sortDescriptors = [
    NSSortDescriptor(keyPath: \Person.lastName, ascending: true),
    NSSortDescriptor(keyPath: \Person.firstName, ascending: true)
]

// Limit (LIMIT)
request.fetchLimit = 100

// Offset (OFFSET)
request.fetchOffset = 0

// Batch size (for memory)
request.fetchBatchSize = 20

// Prefetch relationships (avoid N+1)
request.relationshipKeyPathsForPrefetching = ["orders", "address"]

// Return faults or full objects
request.returnsObjectsAsFaults = true  // Default, memory efficient

// Fetch specific properties only
request.propertiesToFetch = ["name", "email"]
request.resultType = .dictionaryResultType
```

### Predicate Deep Dive

```swift
// Comparison
NSPredicate(format: "age == %d", 25)
NSPredicate(format: "age > %d", 25)
NSPredicate(format: "age BETWEEN {18, 65}")

// String matching
NSPredicate(format: "name == %@", "John")
NSPredicate(format: "name CONTAINS %@", "oh")  // Case-sensitive
NSPredicate(format: "name CONTAINS[cd] %@", "oh")  // Case/diacritic insensitive
NSPredicate(format: "name BEGINSWITH %@", "J")
NSPredicate(format: "name LIKE %@", "*ohn")  // Wildcard

// Compound
NSPredicate(format: "age > 18 AND name BEGINSWITH 'J'")
NSPredicate(format: "age > 18 OR isVIP == YES")
NSPredicate(format: "NOT (age < 18)")

// Collections
NSPredicate(format: "ANY orders.total > 100")
NSPredicate(format: "ALL orders.status == 'completed'")
NSPredicate(format: "orders.@count > 5")

// Relationships
NSPredicate(format: "department.name == %@", "Engineering")
NSPredicate(format: "orders.@sum.total > 1000")

// Type-safe with KeyPath (recommended)
NSPredicate(format: "%K > %d", #keyPath(Person.age), 25)
```

### Performance Patterns

```swift
// 1. COUNT WITHOUT FETCHING
let request = Person.fetchRequest()
request.predicate = NSPredicate(format: "isActive == YES")
let count = try context.count(for: request)  // No objects loaded

// 2. FETCH ONLY IDs
request.resultType = .managedObjectIDResultType
let ids = try context.fetch(request) as! [NSManagedObjectID]

// 3. BATCH UPDATES (iOS 8+)
let batchUpdate = NSBatchUpdateRequest(entityName: "Person")
batchUpdate.predicate = NSPredicate(format: "lastLogin < %@", oneMonthAgo)
batchUpdate.propertiesToUpdate = ["isActive": false]
batchUpdate.resultType = .updatedObjectIDsResultType

let result = try context.execute(batchUpdate) as! NSBatchUpdateResult
let objectIDs = result.result as! [NSManagedObjectID]

// Merge changes into context (batch updates bypass context!)
NSManagedObjectContext.mergeChanges(
    fromRemoteContextSave: [NSUpdatedObjectsKey: objectIDs],
    into: [context]
)

// 4. BATCH DELETE (iOS 9+)
let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
batchDelete.resultType = .resultTypeObjectIDs

let result = try context.execute(batchDelete) as! NSBatchDeleteResult
let deletedIDs = result.result as! [NSManagedObjectID]

NSManagedObjectContext.mergeChanges(
    fromRemoteContextSave: [NSDeletedObjectsKey: deletedIDs],
    into: [context]
)
```

### NSFetchedResultsController (UIKit)

```swift
// Efficient table view data source
class PeopleViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    lazy var fetchedResultsController: NSFetchedResultsController<Person> = {
        let request = Person.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Person.name, ascending: true)]
        request.fetchBatchSize = 20

        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: CoreDataStack.shared.viewContext,
            sectionNameKeyPath: nil,  // Or "department.name" for sections
            cacheName: "PeopleCache"  // Disk cache for faster launches
        )
        frc.delegate = self
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        try? fetchedResultsController.performFetch()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = fetchedResultsController.object(at: indexPath)
        // Configure cell
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()  // Or use begin/endUpdates for animations
    }
}
```

---

## SwiftData: The Modern Alternative

### Why SwiftData?

```
Core Data:                          SwiftData:
- Obj-C heritage                    - Swift-native
- NSManagedObject subclass         - @Model macro
- .xcdatamodeld file               - Plain Swift classes
- NSManagedObjectContext           - ModelContext
- NSFetchRequest                   - #Predicate macro
- Verbose setup                    - Minimal boilerplate
```

### Basic Usage

```swift
import SwiftData

// 1. Define model with @Model macro
@Model
class Person {
    var name: String
    var email: String
    var birthDate: Date?

    @Relationship(deleteRule: .cascade, inverse: \Order.customer)
    var orders: [Order] = []

    init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}

@Model
class Order {
    var total: Decimal
    var createdAt: Date

    var customer: Person?

    init(total: Decimal, customer: Person) {
        self.total = total
        self.createdAt = Date()
        self.customer = customer
    }
}

// 2. Configure in App
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Person.self, Order.self])
    }
}

// 3. Use in views
struct PeopleListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Person.name) private var people: [Person]

    var body: some View {
        List(people) { person in
            Text(person.name)
        }
    }

    func addPerson() {
        let person = Person(name: "New Person", email: "new@example.com")
        context.insert(person)
        // Auto-saves!
    }

    func deletePerson(_ person: Person) {
        context.delete(person)
    }
}
```

### Querying with #Predicate

```swift
// Type-safe predicates
@Query(filter: #Predicate<Person> { person in
    person.name.contains("John") && person.orders.count > 5
})
private var vipCustomers: [Person]

// Sort descriptors
@Query(sort: [
    SortDescriptor(\Person.lastName),
    SortDescriptor(\Person.firstName)
])
private var sortedPeople: [Person]

// Dynamic queries
struct PeopleView: View {
    @State private var searchText = ""

    var body: some View {
        PeopleList(searchText: searchText)
    }
}

struct PeopleList: View {
    @Query private var people: [Person]

    init(searchText: String) {
        let predicate = #Predicate<Person> { person in
            searchText.isEmpty || person.name.localizedStandardContains(searchText)
        }
        _people = Query(filter: predicate, sort: \Person.name)
    }

    var body: some View {
        List(people) { person in
            Text(person.name)
        }
    }
}
```

### Background Operations

```swift
// SwiftData with async/await
actor DataManager {
    private let modelContainer: ModelContainer

    init() throws {
        modelContainer = try ModelContainer(for: Person.self, Order.self)
    }

    func importPeople(_ data: [PersonDTO]) async throws {
        let context = ModelContext(modelContainer)

        for dto in data {
            let person = Person(name: dto.name, email: dto.email)
            context.insert(person)
        }

        try context.save()
    }
}
```

### SwiftData vs Core Data Feature Comparison

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Feature                      │ Core Data      │ SwiftData              │
├─────────────────────────────────────────────────────────────────────────┤
│ Minimum iOS                  │ iOS 3          │ iOS 17                 │
│ Language                     │ Obj-C / Swift  │ Swift only             │
│ Model definition             │ .xcdatamodeld  │ @Model macro           │
│ SwiftUI integration          │ Manual         │ Native (@Query)        │
│ Undo/Redo                    │ Built-in       │ Built-in               │
│ CloudKit sync                │ Yes            │ Yes                    │
│ Fetch batching               │ Yes            │ Yes                    │
│ Background contexts          │ Manual         │ Automatic              │
│ Migrations                   │ Complex        │ Automatic (simple)     │
│ Learning curve               │ Steep          │ Gentle                 │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Migration Strategies

### Core Data Migrations

```
Lightweight Migration (automatic):
- Add/remove attributes
- Add/remove entities
- Rename with renaming ID
- Add/remove relationships
- Make optional/non-optional

Custom Migration (manual):
- Complex transformations
- Splitting/merging entities
- Data manipulation during migration
```

```swift
// Enable automatic migration
let options = [
    NSMigratePersistentStoresAutomaticallyOption: true,
    NSInferMappingModelAutomaticallyOption: true
]

try coordinator.addPersistentStore(
    ofType: NSSQLiteStoreType,
    at: storeURL,
    options: options
)

// Custom mapping model (for complex migrations)
// Create .xcmappingmodel file in Xcode
// Define entity mappings, attribute mappings
// Optionally add custom NSEntityMigrationPolicy
```

### SwiftData Migrations

```swift
// SwiftData uses schema versioning
enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Person.self]
    }

    @Model
    class Person {
        var name: String
        init(name: String) { self.name = name }
    }
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Person.self]
    }

    @Model
    class Person {
        var name: String
        var email: String  // NEW FIELD

        init(name: String, email: String) {
            self.name = name
            self.email = email
        }
    }
}

// Migration plan
enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            // Set default email for existing people
            let people = try context.fetch(FetchDescriptor<SchemaV2.Person>())
            for person in people {
                if person.email.isEmpty {
                    person.email = "unknown@example.com"
                }
            }
            try context.save()
        }
    )
}

// Use migration plan
let container = try ModelContainer(
    for: Person.self,
    migrationPlan: MigrationPlan.self
)
```

---

## Sync Patterns

### Core Data + CloudKit

```swift
// Automatic sync with iCloud
let container = NSPersistentCloudKitContainer(name: "Model")

container.loadPersistentStores { description, error in
    if let error = error {
        fatalError("CloudKit container failed: \(error)")
    }
}

// Enable history tracking (required for CloudKit)
let description = container.persistentStoreDescriptions.first
description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

// Handle remote changes
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleRemoteChange),
    name: .NSPersistentStoreRemoteChange,
    object: nil
)

@objc func handleRemoteChange(_ notification: Notification) {
    // Refresh UI
}
```

### Custom Backend Sync Pattern

```swift
// For syncing with Supabase/Firebase/custom backend

struct SyncRecord: Codable {
    let id: UUID
    let entityName: String
    let action: SyncAction
    let data: [String: AnyCodable]
    let timestamp: Date
    let synced: Bool
}

enum SyncAction: String, Codable {
    case insert, update, delete
}

class SyncEngine {
    private let context: NSManagedObjectContext

    func trackChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: context
        )
    }

    @objc func contextDidSave(_ notification: Notification) {
        let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []
        let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []
        let deleted = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []

        // Create sync records
        for object in inserted {
            createSyncRecord(object, action: .insert)
        }
        // ... etc
    }

    func sync() async throws {
        let pendingRecords = fetchPendingSyncRecords()

        for record in pendingRecords {
            try await uploadToBackend(record)
            markAsSynced(record)
        }

        let serverChanges = try await fetchServerChanges(since: lastSyncDate)
        applyServerChanges(serverChanges)
    }
}
```

---

## When to Use What

### For AWAVE Specifically

```
User Profiles, Favorites, Session History:
→ Core Data or SwiftData
→ Relationships (user → favorites, user → sessions)
→ Offline support
→ Sync with Supabase via custom sync layer

Cached Audio Metadata:
→ SwiftData @Query for UI
→ Background refresh from API

Downloaded Audio Files:
→ File system (Documents or Caches)
→ NOT in database (too large)
→ Store file path/URL in database

App Settings:
→ UserDefaults
→ @AppStorage in SwiftUI

Auth Tokens:
→ Keychain
→ NOT UserDefaults (insecure)
```

### Decision Framework

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│  "I need to store..."                                           │
│                                                                  │
│  Simple key-value (settings)     → UserDefaults                 │
│  Sensitive data                  → Keychain                     │
│  Large files (media)             → File system                  │
│  Structured data + relationships → Core Data / SwiftData        │
│  Complex SQL queries             → SQLite directly              │
│  Cross-device sync (Apple)       → CloudKit + Core Data         │
│  Custom backend sync             → Core Data + custom sync      │
│                                                                  │
│  "My minimum iOS is..."                                         │
│                                                                  │
│  iOS 17+                         → SwiftData (recommended)      │
│  iOS 13-16                       → Core Data                    │
│  Below iOS 13                    → Core Data (older patterns)   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Key Takeaways

### Core Data Mental Model

```
1. It's an OBJECT GRAPH, not a database
2. Contexts are SCRATCHPADS with tracked changes
3. Objects are THREAD-CONFINED
4. Faults are LAZY LOADING (feature, not bug)
5. save() writes changes, rollback() discards them
```

### Performance Rules

```
1. Use fetchBatchSize for large result sets
2. Prefetch relationships to avoid N+1
3. Use batch operations for bulk changes
4. Fetch on background, display on main
5. Use NSFetchedResultsController for table views
```

---

## Further Learning

- **Apple's Core Data Programming Guide** - Comprehensive
- **WWDC "Make Core Data & CloudKit Work for You"**
- **WWDC "Meet SwiftData"** - Modern approach
- **"Core Data" by Florian Kugler & Daniel Eggert** - Deep dive book
