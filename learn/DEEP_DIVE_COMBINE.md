# Deep Dive: Combine Framework

> **Level**: Understanding reactive programming on Apple platforms
> **Goal**: Master Combine's mechanics, not just its API
> **Context**: SwiftUI uses Combine internally—understanding it deepens SwiftUI mastery

---

## Table of Contents

1. [Reactive Programming Foundations](#reactive-programming-foundations)
2. [Combine Architecture](#combine-architecture)
3. [Publishers Deep Dive](#publishers-deep-dive)
4. [Subscribers Deep Dive](#subscribers-deep-dive)
5. [Operators: The Power Tools](#operators-the-power-tools)
6. [Subjects: Imperative Bridges](#subjects-imperative-bridges)
7. [Backpressure & Demand](#backpressure--demand)
8. [Error Handling](#error-handling)
9. [Schedulers & Threading](#schedulers--threading)
10. [Combine + SwiftUI Integration](#combine--swiftui-integration)
11. [Combine vs async/await](#combine-vs-asyncawait)
12. [Common Patterns](#common-patterns)

---

## Reactive Programming Foundations

### The Core Idea

```
Traditional (Imperative):
"When X happens, do Y"

var searchText = ""
func textFieldDidChange(_ text: String) {
    searchText = text
    performSearch(text)  // Manually triggered
}

Reactive (Declarative):
"Y is always derived from X"

$searchText
    .debounce(for: 0.3, scheduler: RunLoop.main)
    .removeDuplicates()
    .flatMap { searchService.search($0) }
    .sink { results in /* always up to date */ }
```

### Stream Abstraction

```
A stream is a sequence of values over time:

Traditional Array:     [1, 2, 3, 4, 5]  ← All values exist now
                       └───────────────┘
                           Space

Reactive Stream:       1 ──► 2 ──► 3 ──► 4 ──► 5 ──► |
                       └───────────────────────────────┘
                                    Time

Events:
├── Value emitted (next)
├── Error occurred (failure)
└── Stream completed (finished)

Timeline:
t=0    t=1    t=2    t=3    t=4    t=5
 │      │      │      │      │      │
 1      2      3    error   ✗      ✗   ← Error terminates
                      │
                      └─ No more values after error

 1      2      3      4      5      │   ← Completion terminates
                                    │
                                    └─ Success, stream done
```

### Why Reactive?

```
Problems it solves:

1. ASYNCHRONOUS COMPOSITION
   Chaining async operations without callback hell

2. TIME-BASED OPERATIONS
   Debounce, throttle, delay, timeout

3. DATA FLOW PROPAGATION
   When A changes, B updates, which updates C...

4. CANCELLATION
   Cancel entire chain with one call

5. DECLARATIVE TRANSFORMATIONS
   map, filter, reduce on async streams
```

---

## Combine Architecture

### The Three Pillars

```
┌─────────────────────────────────────────────────────────────────┐
│                         COMBINE                                  │
│                                                                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │  Publisher  │───►│  Operators  │───►│ Subscriber  │         │
│  │             │    │             │    │             │         │
│  │ Emits values│    │ Transform   │    │ Receives    │         │
│  │ over time   │    │ values      │    │ values      │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│                                                                  │
│  Example:                                                        │
│                                                                  │
│  URLSession.dataTaskPublisher(for: url)  ← Publisher            │
│      .map { $0.data }                    ← Operator             │
│      .decode(type: User.self, ...)       ← Operator             │
│      .sink { user in ... }               ← Subscriber           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Protocol Hierarchy

```swift
// Publisher Protocol
protocol Publisher {
    associatedtype Output    // Type of values emitted
    associatedtype Failure: Error  // Error type (Never if can't fail)

    func receive<S: Subscriber>(subscriber: S)
        where S.Input == Output, S.Failure == Failure
}

// Subscriber Protocol
protocol Subscriber {
    associatedtype Input     // Type of values received
    associatedtype Failure: Error  // Error type expected

    func receive(subscription: Subscription)
    func receive(_ input: Input) -> Subscribers.Demand
    func receive(completion: Subscribers.Completion<Failure>)
}

// Subscription Protocol (connection between pub/sub)
protocol Subscription: Cancellable {
    func request(_ demand: Subscribers.Demand)
}
```

### Subscription Lifecycle

```
1. Subscriber subscribes to Publisher
   publisher.subscribe(subscriber)

2. Publisher sends Subscription to Subscriber
   subscriber.receive(subscription: subscription)

3. Subscriber requests values via Subscription
   subscription.request(.max(5))  // Request 5 values

4. Publisher sends values
   subscriber.receive(value)  // Returns Demand for more

5. Publisher completes or fails
   subscriber.receive(completion: .finished)
   subscriber.receive(completion: .failure(error))

6. Subscription cancelled (cleanup)
   subscription.cancel()


Timeline:
┌──────────────┐         ┌──────────────┐
│  Publisher   │         │  Subscriber  │
└──────┬───────┘         └───────┬──────┘
       │                         │
       │  ◄── subscribe ─────────│
       │                         │
       │  ─── subscription ────► │
       │                         │
       │  ◄── request(.max(3)) ──│
       │                         │
       │  ─── value 1 ─────────► │
       │  ◄── .max(1) ───────────│  (request 1 more)
       │                         │
       │  ─── value 2 ─────────► │
       │  ◄── .none ─────────────│  (no more requested)
       │                         │
       │  ─── completion ──────► │
       │                         │
```

---

## Publishers Deep Dive

### Built-in Publishers

```swift
// JUST - Single value, then completes
Just("Hello")
    .sink { print($0) }  // "Hello"

// FUTURE - Async single value
Future<Int, Error> { promise in
    DispatchQueue.global().async {
        promise(.success(42))
    }
}

// EMPTY - Completes immediately with no values
Empty<String, Never>()

// FAIL - Fails immediately
Fail<String, MyError>(error: .somethingWrong)

// DEFERRED - Creates publisher when subscribed
Deferred {
    Just(Date())  // Fresh date on each subscription
}

// SEQUENCE - From array/sequence
[1, 2, 3, 4, 5].publisher
    .sink { print($0) }  // 1, 2, 3, 4, 5

// RECORD - Replay recorded values
let record = Record<Int, Never>(output: [1, 2, 3], completion: .finished)
```

### Property Publishers

```swift
// @Published - SwiftUI/Combine integration
class ViewModel: ObservableObject {
    @Published var count = 0
}

let vm = ViewModel()
vm.$count  // Publisher<Int, Never>
    .sink { print("Count: \($0)") }

vm.count = 5  // "Count: 5"

// CurrentValueSubject alternative
let count = CurrentValueSubject<Int, Never>(0)
count.value  // Current value
count.send(5)  // Emit new value
```

### Foundation Publishers

```swift
// URLSession
URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: Response.self, decoder: JSONDecoder())
    .sink(receiveCompletion: { _ in }, receiveValue: { response in })

// NotificationCenter
NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
    .sink { _ in print("App active") }

// Timer
Timer.publish(every: 1.0, on: .main, in: .common)
    .autoconnect()
    .sink { date in print(date) }

// KVO
object.publisher(for: \.someProperty)
    .sink { newValue in print(newValue) }
```

### Custom Publisher

```swift
// Simple custom publisher
struct CountdownPublisher: Publisher {
    typealias Output = Int
    typealias Failure = Never

    let start: Int

    func receive<S>(subscriber: S) where S: Subscriber,
                                          Failure == S.Failure,
                                          Output == S.Input {
        let subscription = CountdownSubscription(
            subscriber: subscriber,
            start: start
        )
        subscriber.receive(subscription: subscription)
    }
}

class CountdownSubscription<S: Subscriber>: Subscription
    where S.Input == Int, S.Failure == Never {

    private var subscriber: S?
    private var current: Int

    init(subscriber: S, start: Int) {
        self.subscriber = subscriber
        self.current = start
    }

    func request(_ demand: Subscribers.Demand) {
        guard let subscriber = subscriber else { return }

        var demand = demand
        while demand > .none && current >= 0 {
            demand -= 1
            demand += subscriber.receive(current)
            current -= 1
        }

        if current < 0 {
            subscriber.receive(completion: .finished)
        }
    }

    func cancel() {
        subscriber = nil
    }
}

// Usage
CountdownPublisher(start: 5)
    .sink { print($0) }  // 5, 4, 3, 2, 1, 0
```

---

## Subscribers Deep Dive

### Built-in Subscribers

```swift
// SINK - Most common, closure-based
publisher.sink(
    receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("Done")
        case .failure(let error):
            print("Error: \(error)")
        }
    },
    receiveValue: { value in
        print("Value: \(value)")
    }
)

// For Never-failing publishers, simpler overload
publisher.sink { value in
    print(value)
}

// ASSIGN - Assign to property
class Model {
    var name: String = ""
}

let model = Model()
Just("Hello")
    .assign(to: \.name, on: model)  // model.name = "Hello"

// ASSIGN with @Published (avoids retain cycle)
class ViewModel: ObservableObject {
    @Published var data: String = ""
}

publisher
    .assign(to: &viewModel.$data)  // Uses inout, no AnyCancellable needed
```

### AnyCancellable

```swift
// sink() returns AnyCancellable
// Store it or subscription immediately cancels!

class ViewModel {
    private var cancellables = Set<AnyCancellable>()

    func subscribe() {
        publisher
            .sink { value in }
            .store(in: &cancellables)  // Keep alive
    }
}

// Or store individually
var cancellable: AnyCancellable?

cancellable = publisher.sink { }

// Cancel when done
cancellable?.cancel()
cancellable = nil
```

### Custom Subscriber

```swift
class LoggingSubscriber<Input, Failure: Error>: Subscriber {
    let label: String

    init(label: String) {
        self.label = label
    }

    func receive(subscription: Subscription) {
        print("[\(label)] Subscribed")
        subscription.request(.unlimited)  // Request all values
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        print("[\(label)] Received: \(input)")
        return .none  // Don't request more (unlimited already requested)
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case .finished:
            print("[\(label)] Completed")
        case .failure(let error):
            print("[\(label)] Failed: \(error)")
        }
    }
}

// Usage
let subscriber = LoggingSubscriber<Int, Never>(label: "Numbers")
[1, 2, 3].publisher.subscribe(subscriber)
```

---

## Operators: The Power Tools

### Transforming

```swift
// MAP - Transform each value
[1, 2, 3].publisher
    .map { $0 * 2 }  // 2, 4, 6

// TRYMAP - Transform with throwing function
publisher
    .tryMap { try JSONDecoder().decode(User.self, from: $0) }

// FLATMAP - Transform to publisher, flatten results
[1, 2, 3].publisher
    .flatMap { id in
        fetchUser(id: id)  // Returns Publisher<User, Error>
    }
    .sink { user in }  // Flat stream of users

// COMPACTMAP - Transform and filter nil
["1", "two", "3"].publisher
    .compactMap { Int($0) }  // 1, 3

// SCAN - Accumulate values
[1, 2, 3, 4, 5].publisher
    .scan(0, +)  // 1, 3, 6, 10, 15 (running total)
```

### Filtering

```swift
// FILTER
[1, 2, 3, 4, 5].publisher
    .filter { $0 % 2 == 0 }  // 2, 4

// REMOVEDUPLICATES
[1, 1, 2, 2, 3, 3].publisher
    .removeDuplicates()  // 1, 2, 3

// FIRST / LAST
publisher.first()  // Only first value
publisher.first(where: { $0 > 10 })
publisher.last()

// DROP / PREFIX
publisher.dropFirst(3)     // Skip first 3
publisher.drop(while: { $0 < 10 })  // Skip while condition
publisher.prefix(5)        // Take first 5
publisher.prefix(while: { $0 < 10 })
```

### Combining

```swift
// MERGE - Combine same-type publishers
let pub1 = [1, 2, 3].publisher
let pub2 = [4, 5, 6].publisher
pub1.merge(with: pub2)  // Interleaved: depends on timing

// COMBINELATEST - Combine latest values
let name = PassthroughSubject<String, Never>()
let age = PassthroughSubject<Int, Never>()

name.combineLatest(age)
    .sink { name, age in
        print("\(name) is \(age)")
    }

name.send("Alice")  // Nothing yet (age has no value)
age.send(30)        // "Alice is 30"
name.send("Bob")    // "Bob is 30"
age.send(25)        // "Bob is 25"

// ZIP - Pair values in order
let letters = ["a", "b", "c"].publisher
let numbers = [1, 2, 3].publisher
letters.zip(numbers)  // ("a", 1), ("b", 2), ("c", 3)

// SWITCHTOLATEST - Switch to latest inner publisher
let buttonTaps = PassthroughSubject<Void, Never>()
buttonTaps
    .map { fetchLatestData() }  // Each tap creates new publisher
    .switchToLatest()           // Cancel previous, use latest
    .sink { data in }
```

### Timing

```swift
// DEBOUNCE - Wait for pause in events
textField.textPublisher
    .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
    .sink { searchText in
        // Only fires after 300ms of no typing
    }

// THROTTLE - Limit rate
mouseMovePublisher
    .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
    .sink { position in
        // Max 10 updates per second
    }

// DELAY - Delay all values
publisher
    .delay(for: .seconds(2), scheduler: RunLoop.main)
    .sink { }  // Values arrive 2 seconds later

// TIMEOUT - Fail if no value in time
publisher
    .timeout(.seconds(10), scheduler: RunLoop.main)
    .sink(receiveCompletion: { completion in
        // .failure if timeout
    }, receiveValue: { })

// MEASUREINTERVAL - Time between values
publisher
    .measureInterval(using: RunLoop.main)
    .sink { interval in
        print("Time since last: \(interval)")
    }
```

### Sequence Operations

```swift
// COLLECT - Gather all into array
[1, 2, 3].publisher
    .collect()
    .sink { array in
        print(array)  // [1, 2, 3]
    }

// COLLECT by count
[1, 2, 3, 4, 5, 6].publisher
    .collect(2)  // [1, 2], [3, 4], [5, 6]

// REDUCE - Final accumulated value
[1, 2, 3, 4, 5].publisher
    .reduce(0, +)
    .sink { print($0) }  // 15

// ALLSATISFY / CONTAINS
[1, 2, 3].publisher
    .allSatisfy { $0 > 0 }  // true

[1, 2, 3].publisher
    .contains(2)  // true
```

---

## Subjects: Imperative Bridges

### PassthroughSubject

```swift
// PassthroughSubject - No current value, just forwards
let subject = PassthroughSubject<String, Never>()

// Subscribe
subject.sink { print($0) }

// Send values imperatively
subject.send("Hello")  // "Hello"
subject.send("World")  // "World"
subject.send(completion: .finished)

// Use case: Event stream (button taps, notifications)
```

### CurrentValueSubject

```swift
// CurrentValueSubject - Has current value
let subject = CurrentValueSubject<Int, Never>(0)

subject.value  // 0 (access current value)

subject.sink { print($0) }  // Immediately prints 0

subject.send(1)  // prints 1
subject.value    // 1

subject.value = 2  // Also sends, prints 2

// Use case: State that others observe (like @Published)
```

### Subject as Subscriber

```swift
// Subjects conform to both Publisher AND Subscriber
let input = PassthroughSubject<Int, Never>()
let output = PassthroughSubject<Int, Never>()

// Connect them
input.subscribe(output)

// output receives everything input receives
output.sink { print($0) }
input.send(42)  // prints 42
```

---

## Backpressure & Demand

### The Demand System

```swift
// Demand prevents unbounded buffering

enum Demand {
    case none           // No values requested
    case max(Int)       // Request specific count
    case unlimited      // No limit (careful!)
}

// Subscriber controls flow
class SlowSubscriber: Subscriber {
    func receive(subscription: Subscription) {
        subscription.request(.max(1))  // Only want 1 to start
    }

    func receive(_ input: Int) -> Demand {
        // Process slowly...
        sleep(1)
        return .max(1)  // Request 1 more after processing
    }
}

// Publisher must respect demand
// Can't send more than requested
// Prevents memory explosion
```

### Buffer Operator

```swift
// Buffer values when subscriber is slow
fastPublisher
    .buffer(size: 100, prefetch: .keepFull, whenFull: .dropOldest)
    .sink { }

// whenFull options:
// .dropNewest - Drop incoming values
// .dropOldest - Drop oldest buffered
// .customError(Error) - Fail with error
```

---

## Error Handling

### Error Types

```swift
// Publishers have Failure type
Publisher<Output, Failure>

// Never = can't fail
Publisher<Int, Never>

// Specific error
Publisher<User, NetworkError>

// Any error
Publisher<Data, Error>
```

### Error Operators

```swift
// CATCH - Replace error with recovery publisher
publisher
    .catch { error in
        Just(fallbackValue)  // Recover with default
    }

// TRYCATCH - Recovery can also fail
publisher
    .tryCatch { error -> AnyPublisher<Value, Error> in
        if error.isRetryable {
            return retryPublisher
        }
        throw error
    }

// RETRY - Retry on failure
publisher
    .retry(3)  // Try up to 3 times

// MAPERROR - Transform error type
publisher
    .mapError { networkError in
        AppError.network(networkError)
    }

// REPLACEERROR - Replace error with value
publisher
    .replaceError(with: defaultValue)

// ASSERTNOFAILURE - Crash on error (debugging)
publisher
    .assertNoFailure()  // Converts to Never failure type
```

### Error Propagation

```swift
// Errors terminate the stream
[1, 2, 3].publisher
    .tryMap { value -> Int in
        if value == 2 { throw MyError() }
        return value * 2
    }
    .sink(
        receiveCompletion: { completion in
            // .failure(MyError)
        },
        receiveValue: { value in
            // Only receives: 2 (first value * 2)
        }
    )
```

---

## Schedulers & Threading

### What is a Scheduler?

```swift
// Scheduler = Where and when work happens

protocol Scheduler {
    associatedtype SchedulerTimeType: Strideable
    associatedtype SchedulerOptions

    var now: SchedulerTimeType { get }
    var minimumTolerance: SchedulerTimeType.Stride { get }

    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void)
    func schedule(after: SchedulerTimeType, ..., _ action: @escaping () -> Void)
}
```

### Built-in Schedulers

```swift
// RunLoop.main - Main thread (UI)
publisher
    .receive(on: RunLoop.main)
    .sink { /* Safe to update UI */ }

// DispatchQueue - GCD queues
publisher
    .subscribe(on: DispatchQueue.global(qos: .background))  // Start work here
    .receive(on: DispatchQueue.main)  // Receive here
    .sink { }

// OperationQueue
let queue = OperationQueue()
queue.maxConcurrentOperationCount = 1
publisher
    .receive(on: queue)

// ImmediateScheduler - Synchronous, no scheduling
// Used for testing
```

### subscribe(on:) vs receive(on:)

```swift
// subscribe(on:) - Where subscription and upstream work happens
// receive(on:) - Where downstream receives values

URLSession.shared.dataTaskPublisher(for: url)
    // Network request happens on URLSession's queue (automatic)
    .map(\.data)
    // mapping happens on URLSession's queue
    .receive(on: DispatchQueue.main)
    // From here, everything on main queue
    .sink { data in
        // Safe for UI
    }

// More explicit control:
heavyPublisher
    .subscribe(on: DispatchQueue.global())  // Do work in background
    .map { /* Also in background */ }
    .receive(on: RunLoop.main)              // Switch to main
    .sink { /* On main thread */ }
```

---

## Combine + SwiftUI Integration

### @Published

```swift
class ViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [Item] = []
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        // React to searchText changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoading = true
            })
            .flatMap { [weak self] query -> AnyPublisher<[Item], Never> in
                guard let self = self else {
                    return Empty().eraseToAnyPublisher()
                }
                return self.search(query)
                    .catch { _ in Just([]) }
                    .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] results in
                self?.isLoading = false
                self?.results = results
            }
            .store(in: &cancellables)
    }
}

struct SearchView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack {
            TextField("Search", text: $viewModel.searchText)

            if viewModel.isLoading {
                ProgressView()
            }

            List(viewModel.results) { item in
                Text(item.name)
            }
        }
    }
}
```

### onReceive

```swift
struct TimerView: View {
    @State private var currentDate = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(currentDate, style: .time)
            .onReceive(timer) { date in
                currentDate = date
            }
    }
}
```

---

## Combine vs async/await

### When to Use Which

```
async/await (Swift Concurrency):
├── Single value async operations
├── Linear async flows
├── Structured concurrency (task groups)
├── Cleaner syntax for most cases
└── Preferred for new code (iOS 15+)

Combine:
├── Multiple values over time (streams)
├── Time-based operations (debounce, throttle)
├── Complex event composition
├── @Published / SwiftUI integration
└── Still relevant for reactive patterns
```

### Bridging

```swift
// Combine to async/await
let value = try await publisher.values.first(where: { _ in true })

// Or more explicitly
extension Publisher {
    func firstValue() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.first()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}

// async/await to Combine
func fetchUser() async throws -> User { ... }

let publisher = Deferred {
    Future { promise in
        Task {
            do {
                let user = try await fetchUser()
                promise(.success(user))
            } catch {
                promise(.failure(error))
            }
        }
    }
}
```

---

## Common Patterns

### Network Request

```swift
func fetchUser(id: Int) -> AnyPublisher<User, Error> {
    let url = URL(string: "https://api.example.com/users/\(id)")!

    return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: User.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```

### Form Validation

```swift
class FormViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isValid = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        Publishers.CombineLatest($email, $password)
            .map { email, password in
                email.contains("@") && password.count >= 8
            }
            .assign(to: &$isValid)
    }
}
```

### Retry with Exponential Backoff

```swift
extension Publisher {
    func retryWithBackoff(
        retries: Int,
        initialDelay: TimeInterval,
        scheduler: some Scheduler
    ) -> AnyPublisher<Output, Failure> {
        self.catch { error -> AnyPublisher<Output, Failure> in
            guard retries > 0 else {
                return Fail(error: error).eraseToAnyPublisher()
            }

            let delay = initialDelay * pow(2, Double(retries - 1))

            return Just(())
                .delay(for: .seconds(delay), scheduler: scheduler)
                .flatMap { _ in self }
                .retryWithBackoff(
                    retries: retries - 1,
                    initialDelay: initialDelay,
                    scheduler: scheduler
                )
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
```

### Cancellation Token Pattern

```swift
class SearchManager {
    private var searchCancellable: AnyCancellable?

    func search(_ query: String) {
        // Cancel previous search
        searchCancellable?.cancel()

        searchCancellable = searchPublisher(query)
            .sink { results in
                // Handle results
            }
    }
}
```

---

## Key Takeaways

### Mental Model

```
1. Publisher = Factory of values over time
2. Subscriber = Consumer that controls demand
3. Operators = Transform streams declaratively
4. Subscription = Connection, cancellation handle
5. Scheduler = Where/when work executes
```

### Best Practices

```
✓ Store cancellables (or subscription dies)
✓ Use [weak self] in closures
✓ receive(on: main) before UI updates
✓ Prefer async/await for simple cases
✓ Use Combine for streams and time-based ops
✓ eraseToAnyPublisher() to hide implementation
✓ Handle errors explicitly
```

---

## Further Learning

- **Apple's Combine Documentation** - API reference
- **WWDC "Introducing Combine"** - Original introduction
- **WWDC "Combine in Practice"** - Real-world patterns
- **"Using Combine" by Joseph Heck** - Comprehensive book
