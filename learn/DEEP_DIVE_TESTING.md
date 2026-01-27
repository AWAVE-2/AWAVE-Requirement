# Deep Dive: iOS Testing Architecture

> **Level**: Testing strategies, XCTest internals, and test architecture
> **Goal**: Build comprehensive test suites that catch bugs before users do
> **Context**: Your AWAVE app currently has tests disabled—let's fix that

---

## Table of Contents

1. [Testing Philosophy](#testing-philosophy)
2. [XCTest Framework Architecture](#xctest-framework-architecture)
3. [Unit Testing Deep Dive](#unit-testing-deep-dive)
4. [Testing Async Code](#testing-async-code)
5. [Mocking & Dependency Injection](#mocking--dependency-injection)
6. [UI Testing (XCUITest)](#ui-testing-xcuitest)
7. [Performance Testing](#performance-testing)
8. [Swift Testing (Xcode 16+)](#swift-testing-xcode-16)
9. [Test Architecture Patterns](#test-architecture-patterns)
10. [CI/CD Integration](#cicd-integration)
11. [Code Coverage](#code-coverage)
12. [Testing Best Practices](#testing-best-practices)

---

## Testing Philosophy

### The Testing Pyramid

```
                    ▲
                   /│\
                  / │ \
                 /  │  \          Fewer, slower, expensive
                /   │   \
               / UI Tests\        End-to-end user flows
              /───────────\
             / Integration \      Multiple components together
            /───────────────\
           /   Unit Tests    \    Individual units in isolation
          /───────────────────\

          More, faster, cheaper
```

### What to Test

```
TEST:
├── Business logic (pure functions, calculations)
├── State management (ViewModels, reducers)
├── Data transformations (parsing, mapping)
├── Edge cases (empty, nil, max values)
├── Error handling
└── Critical user paths (UI tests)

DON'T TEST:
├── Apple's code (URLSession, Core Data internals)
├── Third-party library internals
├── Trivial code (getters, setters)
├── Views/UI layout (mostly)
└── Private implementation details
```

### Test Characteristics (F.I.R.S.T.)

```
FAST        - Tests run quickly (milliseconds)
ISOLATED    - No dependencies between tests
REPEATABLE  - Same result every time
SELF-VALIDATING - Pass or fail, no manual inspection
TIMELY      - Written with or before code
```

---

## XCTest Framework Architecture

### Framework Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                        XCTest Framework                          │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    XCTestCase                            │   │
│  │    Base class for test classes                           │   │
│  │    - setUp() / tearDown()                               │   │
│  │    - test methods (func testXxx())                       │   │
│  │    - assertions (XCTAssert...)                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│  ┌───────────────────────────┼───────────────────────────────┐ │
│  │                           │                               │ │
│  │  XCTestExpectation    XCTMetric     XCUIApplication     │ │
│  │  (async testing)      (performance) (UI testing)        │ │
│  │                                                          │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Test Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                     Test Class Lifecycle                         │
│                                                                  │
│  1. class setUp()           ← Once per class (class method)     │
│        │                                                         │
│        ▼                                                         │
│     ┌──────────────────────────────────────────────────────┐   │
│     │  For each test method:                                │   │
│     │                                                       │   │
│     │  2. init()             ← Test case instantiated      │   │
│     │        │                                              │   │
│     │        ▼                                              │   │
│     │  3. setUp()            ← Instance setup              │   │
│     │        │                                              │   │
│     │        ▼                                              │   │
│     │  4. setUpWithError()   ← Setup that can throw        │   │
│     │        │                                              │   │
│     │        ▼                                              │   │
│     │  5. testXxx()          ← The actual test             │   │
│     │        │                                              │   │
│     │        ▼                                              │   │
│     │  6. tearDown()         ← Instance cleanup            │   │
│     │        │                                              │   │
│     │        ▼                                              │   │
│     │  7. tearDownWithError() ← Cleanup that can throw     │   │
│     │                                                       │   │
│     └──────────────────────────────────────────────────────┘   │
│        │                                                         │
│        ▼                                                         │
│  8. class tearDown()        ← Once per class (class method)     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Basic Test Structure

```swift
import XCTest
@testable import MyApp  // Access internal members

class CalculatorTests: XCTestCase {

    var calculator: Calculator!

    // Called before EACH test method
    override func setUp() {
        super.setUp()
        calculator = Calculator()
    }

    // Called after EACH test method
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }

    // Test methods must start with "test"
    func testAddition() {
        let result = calculator.add(2, 3)
        XCTAssertEqual(result, 5, "2 + 3 should equal 5")
    }

    func testDivisionByZero() {
        XCTAssertThrowsError(try calculator.divide(10, by: 0)) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
}
```

---

## Unit Testing Deep Dive

### Assertions

```swift
// EQUALITY
XCTAssertEqual(a, b)              // a == b
XCTAssertNotEqual(a, b)           // a != b
XCTAssertIdentical(a, b)          // a === b (same instance)
XCTAssertNotIdentical(a, b)       // a !== b

// BOOLEAN
XCTAssertTrue(condition)
XCTAssertFalse(condition)

// NIL
XCTAssertNil(optional)
XCTAssertNotNil(optional)

// COMPARISON
XCTAssertGreaterThan(a, b)        // a > b
XCTAssertGreaterThanOrEqual(a, b) // a >= b
XCTAssertLessThan(a, b)           // a < b
XCTAssertLessThanOrEqual(a, b)    // a <= b

// ERRORS
XCTAssertThrowsError(try expression) { error in
    // Validate error
}
XCTAssertNoThrow(try expression)

// FLOATING POINT (with accuracy)
XCTAssertEqual(3.14159, .pi, accuracy: 0.001)

// FAIL
XCTFail("This should not be reached")

// SKIP (conditional test skip)
try XCTSkipIf(condition, "Skipping because...")
try XCTSkipUnless(condition, "Skipping unless...")
```

### Testing Value Types

```swift
struct User: Equatable {
    let id: UUID
    var name: String
    var email: String
}

class UserTests: XCTestCase {

    func testUserCreation() {
        let user = User(id: UUID(), name: "Alice", email: "alice@example.com")

        XCTAssertEqual(user.name, "Alice")
        XCTAssertEqual(user.email, "alice@example.com")
    }

    func testUserEquality() {
        let id = UUID()
        let user1 = User(id: id, name: "Alice", email: "alice@example.com")
        let user2 = User(id: id, name: "Alice", email: "alice@example.com")

        XCTAssertEqual(user1, user2)
    }

    func testUserCopying() {
        var user1 = User(id: UUID(), name: "Alice", email: "alice@example.com")
        var user2 = user1  // Value type = copy

        user2.name = "Bob"

        XCTAssertEqual(user1.name, "Alice")  // Original unchanged
        XCTAssertEqual(user2.name, "Bob")
    }
}
```

### Testing Optionals

```swift
func testOptionalUnwrapping() {
    let json = """
    {"name": "Alice", "age": 30}
    """.data(using: .utf8)!

    let user = try? JSONDecoder().decode(User.self, from: json)

    // Option 1: XCTUnwrap (throws if nil)
    let unwrappedUser = try XCTUnwrap(user, "User should not be nil")
    XCTAssertEqual(unwrappedUser.name, "Alice")

    // Option 2: Guard + fail
    guard let user = user else {
        XCTFail("User should not be nil")
        return
    }
    XCTAssertEqual(user.name, "Alice")
}
```

### Testing Errors

```swift
enum ValidationError: Error, Equatable {
    case emptyName
    case invalidEmail
    case ageTooYoung(minimum: Int)
}

class ValidationTests: XCTestCase {

    func testEmptyNameThrows() {
        XCTAssertThrowsError(try validate(name: "")) { error in
            XCTAssertEqual(error as? ValidationError, .emptyName)
        }
    }

    func testValidInputDoesNotThrow() {
        XCTAssertNoThrow(try validate(name: "Alice", email: "alice@example.com"))
    }

    func testErrorWithAssociatedValue() {
        XCTAssertThrowsError(try validate(age: 10)) { error in
            guard case let ValidationError.ageTooYoung(minimum) = error else {
                XCTFail("Expected ageTooYoung error")
                return
            }
            XCTAssertEqual(minimum, 18)
        }
    }
}
```

---

## Testing Async Code

### XCTestExpectation (Traditional)

```swift
func testAsyncOperation() {
    // Create expectation
    let expectation = expectation(description: "Async operation completes")

    // Start async operation
    service.fetchData { result in
        // Validate in callback
        XCTAssertNotNil(result)
        expectation.fulfill()  // Signal completion
    }

    // Wait for expectation
    wait(for: [expectation], timeout: 5.0)
}

// Multiple expectations
func testMultipleAsyncOperations() {
    let exp1 = expectation(description: "First")
    let exp2 = expectation(description: "Second")

    // ... start operations ...

    wait(for: [exp1, exp2], timeout: 5.0)
    // Or enforce order:
    wait(for: [exp1, exp2], timeout: 5.0, enforceOrder: true)
}

// Inverted expectation (should NOT happen)
func testTimeoutDoesNotTrigger() {
    let notCalled = expectation(description: "Should not be called")
    notCalled.isInverted = true

    // ... operation that should NOT call completion ...

    wait(for: [notCalled], timeout: 1.0)  // Passes if NOT fulfilled
}
```

### async/await Testing (Modern)

```swift
// XCTest supports async test methods directly
func testAsyncFetch() async throws {
    let service = UserService()

    let user = try await service.fetchUser(id: "123")

    XCTAssertEqual(user.name, "Alice")
}

// Testing async sequences
func testAsyncSequence() async throws {
    let stream = Counter(limit: 5)

    var values: [Int] = []
    for await value in stream {
        values.append(value)
    }

    XCTAssertEqual(values, [1, 2, 3, 4, 5])
}

// Testing with timeout
func testWithTimeout() async throws {
    let result = try await withTimeout(seconds: 5) {
        try await slowOperation()
    }
    XCTAssertNotNil(result)
}

// Helper for timeout
func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError()
        }
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
```

### Testing Combine

```swift
import Combine

class CombineTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testPublisher() {
        let expectation = expectation(description: "Publisher emits")
        var receivedValues: [Int] = []

        [1, 2, 3].publisher
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { value in
                    receivedValues.append(value)
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues, [1, 2, 3])
    }

    // Using async/await with Combine
    func testPublisherAsync() async throws {
        let publisher = Just("Hello").delay(for: .milliseconds(100), scheduler: RunLoop.main)

        let value = try await publisher.values.first { _ in true }

        XCTAssertEqual(value, "Hello")
    }
}
```

---

## Mocking & Dependency Injection

### Protocol-Based Mocking

```swift
// 1. Define protocol for dependency
protocol UserServiceProtocol {
    func fetchUser(id: String) async throws -> User
    func saveUser(_ user: User) async throws
}

// 2. Production implementation
class UserService: UserServiceProtocol {
    func fetchUser(id: String) async throws -> User {
        // Real network call
    }

    func saveUser(_ user: User) async throws {
        // Real save
    }
}

// 3. Mock implementation
class MockUserService: UserServiceProtocol {
    var fetchUserResult: Result<User, Error> = .success(User.mock)
    var saveUserCalled = false
    var savedUser: User?

    func fetchUser(id: String) async throws -> User {
        try fetchUserResult.get()
    }

    func saveUser(_ user: User) async throws {
        saveUserCalled = true
        savedUser = user
    }
}

// 4. Class under test uses protocol
class UserViewModel {
    private let service: UserServiceProtocol

    init(service: UserServiceProtocol) {
        self.service = service
    }

    func loadUser(id: String) async {
        // ...
    }
}

// 5. Test with mock
class UserViewModelTests: XCTestCase {
    var mockService: MockUserService!
    var viewModel: UserViewModel!

    override func setUp() {
        mockService = MockUserService()
        viewModel = UserViewModel(service: mockService)
    }

    func testLoadUser() async {
        mockService.fetchUserResult = .success(User(name: "Alice"))

        await viewModel.loadUser(id: "123")

        XCTAssertEqual(viewModel.user?.name, "Alice")
    }

    func testLoadUserError() async {
        mockService.fetchUserResult = .failure(NetworkError.notFound)

        await viewModel.loadUser(id: "123")

        XCTAssertNil(viewModel.user)
        XCTAssertNotNil(viewModel.error)
    }
}
```

### Spy Pattern

```swift
// Spy records calls for verification
class SpyUserService: UserServiceProtocol {
    var fetchUserCallCount = 0
    var fetchUserArguments: [String] = []

    func fetchUser(id: String) async throws -> User {
        fetchUserCallCount += 1
        fetchUserArguments.append(id)
        return User.mock
    }
}

// Test
func testFetchCalledCorrectly() async {
    let spy = SpyUserService()
    let viewModel = UserViewModel(service: spy)

    await viewModel.loadUser(id: "123")
    await viewModel.loadUser(id: "456")

    XCTAssertEqual(spy.fetchUserCallCount, 2)
    XCTAssertEqual(spy.fetchUserArguments, ["123", "456"])
}
```

### Stub Pattern

```swift
// Stub returns canned responses
class StubUserService: UserServiceProtocol {
    var users: [String: User] = [:]

    func fetchUser(id: String) async throws -> User {
        guard let user = users[id] else {
            throw NetworkError.notFound
        }
        return user
    }
}

// Test
func testWithStub() async throws {
    let stub = StubUserService()
    stub.users["123"] = User(name: "Alice")
    stub.users["456"] = User(name: "Bob")

    let viewModel = UserViewModel(service: stub)

    await viewModel.loadUser(id: "123")
    XCTAssertEqual(viewModel.user?.name, "Alice")

    await viewModel.loadUser(id: "456")
    XCTAssertEqual(viewModel.user?.name, "Bob")
}
```

### Fake Pattern

```swift
// Fake has working implementation (in-memory)
class FakeUserRepository: UserRepositoryProtocol {
    private var storage: [String: User] = [:]

    func save(_ user: User) async throws {
        storage[user.id] = user
    }

    func fetch(id: String) async throws -> User {
        guard let user = storage[id] else {
            throw RepositoryError.notFound
        }
        return user
    }

    func delete(id: String) async throws {
        storage.removeValue(forKey: id)
    }
}

// Test real behavior without database
func testUserRepositoryBehavior() async throws {
    let fake = FakeUserRepository()
    let user = User(id: "123", name: "Alice")

    try await fake.save(user)
    let fetched = try await fake.fetch(id: "123")

    XCTAssertEqual(fetched.name, "Alice")
}
```

---

## UI Testing (XCUITest)

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        UI Test Process                           │
│                                                                  │
│  ┌───────────────────────┐       ┌───────────────────────────┐ │
│  │   Test Runner         │       │   App Under Test          │ │
│  │   (XCUITest)          │       │   (Your App)              │ │
│  │                       │       │                           │ │
│  │   XCUIApplication ────┼──────►│   Accessibility           │ │
│  │   XCUIElement         │ IPC   │   Elements                │ │
│  │   XCUIElementQuery    │       │                           │ │
│  │                       │       │                           │ │
│  └───────────────────────┘       └───────────────────────────┘ │
│                                                                  │
│  Tests run in SEPARATE process from app!                        │
│  Communication via accessibility framework.                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Basic UI Test

```swift
import XCTest

class LoginUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]  // App can check this
        app.launch()
    }

    func testLoginSuccess() throws {
        // Find elements
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let loginButton = app.buttons["loginButton"]

        // Interact
        emailField.tap()
        emailField.typeText("alice@example.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Assert
        let welcomeLabel = app.staticTexts["Welcome, Alice!"]
        XCTAssertTrue(welcomeLabel.waitForExistence(timeout: 5))
    }

    func testLoginFailure() throws {
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let loginButton = app.buttons["loginButton"]

        emailField.tap()
        emailField.typeText("wrong@example.com")

        passwordField.tap()
        passwordField.typeText("wrongpassword")

        loginButton.tap()

        // Check error alert
        let alert = app.alerts["Error"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertTrue(alert.staticTexts["Invalid credentials"].exists)
    }
}
```

### Element Queries

```swift
// By accessibility identifier (preferred)
app.buttons["submitButton"]
app.textFields["emailField"]

// By label text
app.buttons["Submit"]
app.staticTexts["Welcome"]

// By type
app.buttons.firstMatch
app.textFields.count
app.cells.element(boundBy: 0)

// Descendant queries
app.tables["userList"].cells.containing(.staticText, identifier: "Alice")

// Predicates
let predicate = NSPredicate(format: "label CONTAINS 'Alice'")
app.staticTexts.matching(predicate)
```

### Waiting

```swift
// Wait for existence
let element = app.buttons["submit"]
XCTAssertTrue(element.waitForExistence(timeout: 10))

// Wait for condition
let expectation = XCTNSPredicateExpectation(
    predicate: NSPredicate(format: "isEnabled == true"),
    object: element
)
wait(for: [expectation], timeout: 10)

// Wait for hittable (visible and interactable)
XCTAssertTrue(element.isHittable)
```

### Accessibility Identifiers

```swift
// In your app code (SwiftUI)
TextField("Email", text: $email)
    .accessibilityIdentifier("emailTextField")

Button("Login") { login() }
    .accessibilityIdentifier("loginButton")

// In your app code (UIKit)
textField.accessibilityIdentifier = "emailTextField"
button.accessibilityIdentifier = "loginButton"
```

---

## Performance Testing

### Measure Block

```swift
func testPerformanceOfSort() throws {
    let largeArray = (0..<10000).shuffled()

    measure {
        _ = largeArray.sorted()
    }
}

// With options
func testPerformanceWithMetrics() throws {
    let metrics: [XCTMetric] = [
        XCTClockMetric(),           // Wall clock time
        XCTCPUMetric(),             // CPU time
        XCTMemoryMetric(),          // Memory usage
        XCTStorageMetric()          // Disk I/O
    ]

    let options = XCTMeasureOptions()
    options.iterationCount = 10

    measure(metrics: metrics, options: options) {
        // Code to measure
    }
}
```

### Baselines

```swift
// Xcode stores performance baselines per device
// Test fails if performance regresses significantly

func testCriticalPathPerformance() throws {
    measure {
        // Critical code path
    }
    // Set baseline in Xcode: Editor → Set Baseline
    // Future runs compare against baseline
}
```

---

## Swift Testing (Xcode 16+)

### New Syntax

```swift
import Testing

// Suite (replaces XCTestCase)
@Suite("User Tests")
struct UserTests {

    // Test function
    @Test("Creating a user sets properties correctly")
    func createUser() {
        let user = User(name: "Alice", email: "alice@example.com")

        #expect(user.name == "Alice")
        #expect(user.email == "alice@example.com")
    }

    // Parameterized tests
    @Test("Validation", arguments: [
        ("", false),           // Empty name invalid
        ("Alice", true),       // Normal name valid
        ("A", true),           // Single char valid
    ])
    func validateName(name: String, shouldBeValid: Bool) {
        #expect(isValidName(name) == shouldBeValid)
    }

    // Async test
    @Test("Fetching user")
    func fetchUser() async throws {
        let user = try await service.fetchUser(id: "123")
        #expect(user.name == "Alice")
    }

    // Test with error
    @Test("Invalid ID throws")
    func invalidId() async {
        await #expect(throws: ValidationError.self) {
            try await service.fetchUser(id: "")
        }
    }
}
```

### Key Differences from XCTest

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Feature              │ XCTest            │ Swift Testing               │
├─────────────────────────────────────────────────────────────────────────┤
│ Test class           │ class: XCTestCase │ @Suite struct               │
│ Test method          │ func testXxx()    │ @Test func xxx()            │
│ Assertion            │ XCTAssertEqual    │ #expect(a == b)             │
│ Async                │ async func test   │ @Test func x() async        │
│ Parameterized        │ Manual            │ @Test(arguments:)           │
│ Tags                 │ N/A               │ @Tag                        │
│ Traits               │ N/A               │ @Test(.bug("123"))          │
│ Parallel             │ Opt-in            │ Default                     │
└─────────────────────────────────────────────────────────────────────────┘
```

### Migration Strategy

```swift
// Can use both in same project
// XCTest for UI tests (XCUITest still required)
// Swift Testing for unit tests

import XCTest
import Testing

// Gradual migration
@Suite struct NewTests {
    @Test func newStyle() { #expect(true) }
}

class LegacyTests: XCTestCase {
    func testOldStyle() { XCTAssertTrue(true) }
}
```

---

## Test Architecture Patterns

### Arrange-Act-Assert (AAA)

```swift
func testUserRegistration() async throws {
    // ARRANGE - Set up preconditions
    let mockService = MockUserService()
    mockService.registrationResult = .success(User(id: "123", name: "Alice"))
    let viewModel = RegistrationViewModel(service: mockService)

    // ACT - Perform the action
    await viewModel.register(name: "Alice", email: "alice@example.com")

    // ASSERT - Verify the outcome
    XCTAssertEqual(viewModel.user?.name, "Alice")
    XCTAssertTrue(viewModel.isRegistered)
    XCTAssertNil(viewModel.error)
}
```

### Given-When-Then (BDD Style)

```swift
func testUserRegistration() async throws {
    // GIVEN a registration form with valid data
    let mockService = MockUserService()
    mockService.registrationResult = .success(User(id: "123", name: "Alice"))
    let viewModel = RegistrationViewModel(service: mockService)

    // WHEN the user submits the registration
    await viewModel.register(name: "Alice", email: "alice@example.com")

    // THEN the user should be registered
    XCTAssertEqual(viewModel.user?.name, "Alice")
    XCTAssertTrue(viewModel.isRegistered)
}
```

### Test Fixtures

```swift
// Shared test data
enum TestFixtures {
    static let validUser = User(
        id: "test-123",
        name: "Test User",
        email: "test@example.com"
    )

    static let validUsers: [User] = [
        User(id: "1", name: "Alice", email: "alice@example.com"),
        User(id: "2", name: "Bob", email: "bob@example.com"),
    ]

    static let invalidJSON = """
    {"invalid": "data"}
    """.data(using: .utf8)!

    static let validJSON = """
    {"id": "123", "name": "Alice", "email": "alice@example.com"}
    """.data(using: .utf8)!
}

// Usage
func testUserParsing() throws {
    let user = try JSONDecoder().decode(User.self, from: TestFixtures.validJSON)
    XCTAssertEqual(user, TestFixtures.validUser)
}
```

### Test Helpers

```swift
// Custom assertions
func assertUserEquals(_ actual: User?, expected: User, file: StaticString = #file, line: UInt = #line) {
    guard let actual = actual else {
        XCTFail("User is nil", file: file, line: line)
        return
    }
    XCTAssertEqual(actual.id, expected.id, file: file, line: line)
    XCTAssertEqual(actual.name, expected.name, file: file, line: line)
    XCTAssertEqual(actual.email, expected.email, file: file, line: line)
}

// Async helpers
extension XCTestCase {
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output where T.Failure == Never {
        var result: T.Output?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher.sink { value in
            result = value
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
        cancellable.cancel()

        return try XCTUnwrap(result, file: file, line: line)
    }
}
```

---

## CI/CD Integration

### Xcode Cloud

```yaml
# ci_scripts/ci_post_clone.sh
#!/bin/sh

# Install dependencies
brew install swiftlint

# ci_scripts/ci_pre_xcodebuild.sh
#!/bin/sh

# Run SwiftLint
swiftlint lint --strict
```

### GitHub Actions

```yaml
name: iOS CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Run tests
        run: |
          xcodebuild test \
            -workspace MyApp.xcworkspace \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -resultBundlePath TestResults.xcresult

      - name: Upload results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: TestResults.xcresult
```

### Fastlane

```ruby
# Fastfile
lane :test do
  run_tests(
    workspace: "MyApp.xcworkspace",
    scheme: "MyApp",
    devices: ["iPhone 15"],
    code_coverage: true,
    output_directory: "./test_output",
    output_types: "html,junit"
  )
end
```

---

## Code Coverage

### Enabling Coverage

```
Xcode:
1. Edit Scheme → Test → Options
2. Check "Gather coverage for..."
3. Select targets

Command line:
xcodebuild test \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults.xcresult
```

### Viewing Coverage

```bash
# Generate report from xcresult
xcrun xccov view --report TestResults.xcresult

# JSON format
xcrun xccov view --report --json TestResults.xcresult > coverage.json

# Per-file
xcrun xccov view --file Sources/MyFile.swift TestResults.xcresult
```

### Coverage Targets

```
Reasonable targets:
├── Overall: 70-80%
├── Business logic: 90%+
├── ViewModels: 85%+
├── Utilities: 80%+
├── Views: 30-50% (mostly UI tests)
└── Generated code: Exclude

Don't chase 100%:
- Diminishing returns
- Test quality > quantity
- Focus on critical paths
```

---

## Testing Best Practices

### Naming

```swift
// Pattern: test_[methodName]_[scenario]_[expectedBehavior]

func test_fetchUser_validId_returnsUser() { }
func test_fetchUser_invalidId_throwsNotFound() { }
func test_fetchUser_networkError_throwsNetworkError() { }

// Or BDD style
func test_givenValidId_whenFetchingUser_thenReturnsUser() { }
```

### Test Independence

```swift
// WRONG: Tests depend on order
class BadTests: XCTestCase {
    static var sharedUser: User?

    func test1_createUser() {
        Self.sharedUser = createUser()  // Other tests depend on this
    }

    func test2_updateUser() {
        Self.sharedUser?.name = "Updated"  // Depends on test1
    }
}

// RIGHT: Each test is independent
class GoodTests: XCTestCase {
    func testCreateUser() {
        let user = createUser()
        XCTAssertNotNil(user)
    }

    func testUpdateUser() {
        let user = createUser()  // Create fresh
        user.name = "Updated"
        XCTAssertEqual(user.name, "Updated")
    }
}
```

### Don't Test Implementation Details

```swift
// WRONG: Testing private implementation
func testInternalCacheUpdated() {
    viewModel.loadUser()
    XCTAssertTrue(viewModel._internalCache.contains("user"))  // Private!
}

// RIGHT: Test public behavior
func testLoadUserSetsUserProperty() async {
    await viewModel.loadUser()
    XCTAssertNotNil(viewModel.user)  // Public property
}
```

### Test One Thing

```swift
// WRONG: Multiple assertions testing different things
func testUserFlow() {
    XCTAssertTrue(viewModel.canRegister)
    viewModel.register()
    XCTAssertTrue(viewModel.isRegistered)
    viewModel.login()
    XCTAssertTrue(viewModel.isLoggedIn)
    viewModel.logout()
    XCTAssertFalse(viewModel.isLoggedIn)
}

// RIGHT: Separate tests
func testCanRegister() {
    XCTAssertTrue(viewModel.canRegister)
}

func testRegister() {
    viewModel.register()
    XCTAssertTrue(viewModel.isRegistered)
}

func testLoginAfterRegistration() {
    viewModel.register()
    viewModel.login()
    XCTAssertTrue(viewModel.isLoggedIn)
}
```

---

## Key Takeaways

### Testing Strategy

```
1. Unit tests for business logic (fast, many)
2. Integration tests for services (medium, some)
3. UI tests for critical flows (slow, few)
4. Performance tests for critical paths
```

### Mock vs Real

```
MOCK:
- External services (network, database)
- Slow operations
- Non-deterministic behavior

USE REAL:
- Value types
- Pure functions
- In-memory implementations (fakes)
```

### What Makes Tests Valuable

```
✓ Tests catch bugs before users
✓ Tests document behavior
✓ Tests enable refactoring
✓ Tests run fast (< 10 min total)
✓ Tests are maintainable
✓ Tests are trustworthy (no flakes)
```

---

## Further Learning

- **Apple's Testing Documentation** - Official guide
- **WWDC "Testing Tips & Tricks"** - Practical patterns
- **WWDC "Meet Swift Testing"** - New framework
- **"Working Effectively with Legacy Code"** - Testing strategies
