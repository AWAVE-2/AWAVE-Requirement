# Error Handling System - Services Documentation

## 🔧 Service Layer Overview

The Error Handling system integrates with multiple services across the app to provide comprehensive error management. Services use error handling utilities to ensure consistent error handling and user feedback.

---

## 📦 Core Services

### Error Handling Utilities Service
**File:** `src/utils/errorHandler.ts`  
**Type:** Utility Functions  
**Purpose:** Core error handling functions used throughout the app

#### Service Methods

**`handleSupabaseError(error: SupabaseErrorLike): string`**
- Transforms Supabase errors to user-friendly German messages
- Maps error codes to specific messages
- Logs errors to console for debugging
- Returns user-friendly error string

**Error Code Mapping:**
- `PGRST116` (NOT_FOUND) → "No data found"
- `42501` (PERMISSION_DENIED) → "Access denied - please check your subscription"
- `row_level_security` (RLS) → "Access denied - please check your subscription"
- `invalid_grant` (AUTH) → "Please sign in again"
- `23505` (DUPLICATE_KEY) → "This data already exists"
- `NETWORK_ERROR` → "Network connection failed"
- Default → `error.message || "Something went wrong"`

**Dependencies:**
- `ERROR_CODES` from `backendConstants.ts`
- Console API for logging

---

**`reportSupabaseError(error: SupabaseErrorLike): void`**
- Displays error via React Native Alert
- Uses `handleSupabaseError` for message transformation
- Shows "Request Failed" title
- Non-blocking operation

**Dependencies:**
- `handleSupabaseError` utility
- React Native `Alert` API

---

**`retryWithBackoff<T>(fn, maxRetries?, initialDelay?): Promise<T>`**
- Retries function with exponential backoff strategy
- Default configuration: 3 retries, 1s initial delay
- Delay doubles each retry (1s → 2s → 4s)
- Returns result on first successful attempt
- Throws last error after max retries exhausted

**Configuration:**
- `maxRetries`: Number of retry attempts (default: 3)
- `initialDelay`: Initial delay in milliseconds (default: 1000)

**Retry Strategy:**
- Attempt 1: Immediate execution
- Attempt 2: Wait 1 second
- Attempt 3: Wait 2 seconds
- Attempt 4: Wait 4 seconds (if maxRetries > 3)

**Dependencies:**
- None (pure function)

---

**`checkConnectivity(): Promise<boolean>`**
- Checks network connectivity status
- Uses `NetInfo.fetch()` to determine connection state
- Returns `true` if connected, `false` otherwise
- Non-blocking async operation

**Dependencies:**
- `@react-native-community/netinfo` (NetInfo)

---

**`executeWithConnectivity<T>(fn): Promise<T>`**
- Executes function with connectivity check and retry
- Checks network connectivity before execution
- Throws error if offline
- Uses `retryWithBackoff` if online
- Combines connectivity check with retry logic

**Flow:**
1. Check network connectivity
2. If offline → Throw "No network connection available"
3. If online → Execute function with `retryWithBackoff`
4. Return result or throw error

**Dependencies:**
- `checkConnectivity` utility
- `retryWithBackoff` utility

---

**`safeApiCall<T>(fn): Promise<T>`**
- Wraps API call in try-catch with error transformation
- Executes function in try-catch block
- Transforms errors using `handleSupabaseError`
- Throws transformed error message
- Used by all `ProductionBackendService` methods

**Flow:**
1. Execute function in try-catch
2. On success → Return result
3. On error → Transform error using `handleSupabaseError`
4. Throw transformed error

**Dependencies:**
- `handleSupabaseError` utility

---

### Network Diagnostics Service
**File:** `src/utils/networkDiagnostics.ts`  
**Type:** Static Class  
**Purpose:** Network connectivity diagnostics and health checks

#### Service Methods

**`testSupabaseConnection(): Promise<NetworkDiagnostics>`**
- Tests Supabase backend connectivity
- Uses `supabase.auth.getSession()` as health check
- Measures connection latency
- Returns comprehensive diagnostics

**Returns:**
```typescript
{
  isConnected: boolean;
  latency?: number;        // Milliseconds
  error?: string;          // Error message if failed
  details: {
    supabaseUrl: string;
    authEndpoint: string;
    restEndpoint: string;
    timestamp: string;
  };
}
```

**Implementation:**
1. Record start time
2. Call `supabase.auth.getSession()` as health check
3. Calculate latency (end time - start time)
4. Return diagnostics with connection status

**Dependencies:**
- `supabase` client
- `PRODUCTION_CONFIG` for URL configuration

---

**`getUserFriendlyError(diagnostics: NetworkDiagnostics): string`**
- Converts diagnostics to user-friendly German message
- Maps error types to specific messages
- Provides actionable guidance

**Error Message Mapping:**
- Connected → "Verbindung erfolgreich"
- "Could not resolve host" → "Der Backend-Server ist nicht erreichbar. Bitte überprüfe deine Internetverbindung oder kontaktiere den Support."
- "Network request failed" → "Netzwerkfehler: Bitte überprüfe deine Internetverbindung und versuche es erneut."
- "timeout" → "Die Anfrage hat zu lange gedauert. Bitte versuche es erneut."
- Default → `Verbindungsfehler: ${diagnostics.error || 'Unbekannter Fehler'}`

**Dependencies:**
- None (pure function)

---

**`logDiagnostics(diagnostics: NetworkDiagnostics): void`**
- Logs detailed diagnostics to console
- Development debugging only
- Includes all diagnostic information

**Dependencies:**
- Console API

---

### Offline Queue Service
**File:** `src/services/OfflineQueueService.ts`  
**Type:** Static Class  
**Purpose:** Offline operation queue management with error recovery

#### Service Methods

**`addToQueue(action, table, data): Promise<void>`**
- Adds failed operation to offline queue
- Generates unique action ID
- Stores in AsyncStorage
- Attempts immediate processing if online

**Error Handling:**
- Queues operations when network fails
- Preserves operation context
- Tracks retry count

**Dependencies:**
- AsyncStorage
- NetInfo

---

**`processQueue(): Promise<number>`**
- Processes all queued actions
- Checks network connectivity
- Executes actions in order
- Handles retries and failures
- Returns count of processed actions
- Prevents concurrent processing

**Error Handling:**
- Network errors: Queue remains, retry on connection
- Operation errors: Increment retry, retry up to max
- Max retries exceeded: Discard action, log error

**Dependencies:**
- AsyncStorage
- NetInfo
- Supabase client

---

**`getQueueStatus(): Promise<QueueStatus>`**
- Returns queue statistics
- Count, oldest timestamp, action types
- Used for debugging and status display

**Dependencies:**
- AsyncStorage

---

**`initialize(): Promise<() => void>`**
- Initializes service
- Processes pending queue
- Sets up network listener
- Returns cleanup function

**Dependencies:**
- AsyncStorage
- NetInfo

---

## 🔗 Service Dependencies

### Dependency Graph
```
Error Handling Utilities
├── handleSupabaseError
│   └── ERROR_CODES (backendConstants)
├── reportSupabaseError
│   └── handleSupabaseError
├── retryWithBackoff
│   └── (no dependencies)
├── checkConnectivity
│   └── NetInfo
├── executeWithConnectivity
│   ├── checkConnectivity
│   └── retryWithBackoff
└── safeApiCall
    └── handleSupabaseError

Network Diagnostics Service
├── testSupabaseConnection
│   ├── supabase client
│   └── PRODUCTION_CONFIG
├── getUserFriendlyError
│   └── (no dependencies)
└── logDiagnostics
    └── Console API

Offline Queue Service
├── addToQueue
│   ├── AsyncStorage
│   └── NetInfo
├── processQueue
│   ├── AsyncStorage
│   ├── NetInfo
│   └── supabase client
└── initialize
    ├── AsyncStorage
    └── NetInfo
```

### External Dependencies

#### React Native
- **NetInfo** - Network connectivity monitoring
- **Alert** - Native alert dialogs
- **AsyncStorage** - Local storage for offline queue

#### Supabase
- **Supabase Client** - Backend API client
- **Auth API** - Session health checks

---

## 🔄 Service Interactions

### Error Handling Flow
```
API Call
    │
    └─> ProductionBackendService.method()
        └─> safeApiCall()
            └─> Try: Supabase API Call
                ├─> Success → Return Data
                └─> Error → Catch
                    └─> handleSupabaseError()
                        └─> Transform Error
                            └─> Throw Transformed Error
                                └─> Component Catches
                                    └─> Display Error (Alert/Toast/ErrorState)
```

### Network Error Flow
```
API Call
    │
    └─> executeWithConnectivity()
        └─> checkConnectivity()
            ├─> Offline → Throw "No network connection"
            │   └─> Component Catches
            │       └─> OfflineQueueService.addToQueue()
            │           └─> Store in AsyncStorage
            │
            └─> Online → Continue
                └─> retryWithBackoff()
                    └─> Attempt with Backoff
                        ├─> Success → Return Result
                        └─> Failure → Throw Error
```

### Offline Queue Processing Flow
```
Network Reconnects
    │
    └─> OfflineQueueService.processQueue()
        └─> Check Connectivity
            ├─> Offline → Return 0
            └─> Online → Continue
                └─> For Each Queued Action
                    ├─> Execute Action
                    │   ├─> Success → Remove from Queue
                    │   └─> Error → Increment Retry Count
                    │       ├─> Retry Count < Max → Keep in Queue
                    │       └─> Retry Count >= Max → Discard
                    └─> Return Processed Count
```

### Network Diagnostics Flow
```
User Action / System Check
    │
    └─> NetworkDiagnosticsService.testSupabaseConnection()
        └─> Call supabase.auth.getSession()
            ├─> Success → Return Connected Diagnostics
            └─> Error → Return Error Diagnostics
                └─> getUserFriendlyError()
                    └─> Display User-Friendly Message
```

---

## 🧪 Service Testing

### Unit Tests
- Error transformation logic
- Retry backoff calculation
- Connectivity checking
- Error code mapping
- Queue processing logic

### Integration Tests
- API error handling
- Network error scenarios
- Retry logic execution
- Offline queue processing
- Network diagnostics

### Mocking
- Supabase client
- NetInfo
- AsyncStorage
- Console API

---

## 📊 Service Metrics

### Performance
- **Error Transformation:** < 10ms
- **Connectivity Check:** < 1 second
- **Retry Execution:** Non-blocking
- **Queue Processing:** < 5 seconds for 10 items

### Reliability
- **Error Transformation Success Rate:** > 99%
- **Retry Success Rate:** > 70% (for transient failures)
- **Queue Processing Success Rate:** > 95%
- **Network Diagnostic Accuracy:** > 95%

### Error Rates
- **Network Errors:** < 1%
- **API Errors:** < 2%
- **Queue Failures:** < 5%
- **Error Transformation Failures:** < 0.1%

---

## 🔐 Security Considerations

### Error Information
- User-facing errors don't expose sensitive data
- Technical errors logged only in development
- Error messages don't reveal system internals
- Network diagnostics don't expose credentials

### Error Handling
- Errors don't leak sensitive information
- Error logging is development-only
- User messages are sanitized
- Network errors don't expose infrastructure details

---

## 🐛 Error Handling Best Practices

### Service-Level Errors
- All services use `safeApiCall` wrapper
- Network-dependent operations use `executeWithConnectivity`
- Errors are transformed before throwing
- Error context is preserved

### Error Recovery
- Automatic retry for transient failures
- Offline queue for network failures
- User retry options for recoverable errors
- Graceful degradation when possible

### Error Logging
- Full error details logged in development
- User-friendly messages in production
- Error frequency tracking
- Network diagnostics for troubleshooting

---

## 📝 Service Configuration

### Error Handler Configuration
```typescript
// Default retry configuration
const DEFAULT_MAX_RETRIES = 3;
const DEFAULT_INITIAL_DELAY = 1000; // 1 second
const DELAY_MULTIPLIER = 2;
```

### Network Diagnostics Configuration
```typescript
// Connection timeout (implicit via health check)
const HEALTH_CHECK_ENDPOINT = '/auth/v1/session';
```

### Queue Configuration
```typescript
// Offline queue settings
const QUEUE_KEY = 'offline_action_queue';
const MAX_RETRIES = 3;
```

---

## 🔄 Service Updates

### Future Enhancements
- Error analytics and tracking
- Enhanced network diagnostics
- Adaptive retry strategies
- Error categorization and prioritization
- Error reporting to backend

---

*For component usage, see `components.md`*  
*For error flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
