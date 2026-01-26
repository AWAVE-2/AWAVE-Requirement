# Error Handling System - User Flows

## 🔄 Primary Error Flows

### 1. API Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Triggers API Call
   └─> Component Calls Service Method
       └─> ProductionBackendService.method()
           └─> safeApiCall()
               └─> Try: Execute Supabase API Call
                   ├─> Success → Return Data
                   │   └─> Component Updates UI
                   │
                   └─> Error → Catch
                       └─> handleSupabaseError()
                           └─> Check Error Code
                               ├─> PGRST116 → "No data found"
                               ├─> 42501 → "Access denied..."
                               ├─> invalid_grant → "Please sign in again"
                               ├─> 23505 → "This data already exists"
                               ├─> NETWORK_ERROR → "Network connection failed"
                               └─> Unknown → error.message || "Something went wrong"
                                   └─> Throw Transformed Error
                                       └─> Component Catches
                                           └─> Display Error
                                               ├─> Critical → Alert.alert()
                                               ├─> Non-critical → Toast
                                               └─> UI Component → ErrorState
```

**Success Path:**
- API call succeeds
- Data returned to component
- UI updates with data

**Error Paths:**
- **Not Found (PGRST116)**: Gracefully handled, returns null or empty array
- **Permission Denied**: Shows subscription error message
- **Auth Error**: Prompts re-authentication
- **Duplicate Key**: Shows data exists message
- **Network Error**: Shows network error message
- **Unknown Error**: Shows generic error message

---

### 2. Network Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Triggers Network Operation
   └─> Component Calls Network-Dependent Service
       └─> executeWithConnectivity()
           └─> checkConnectivity()
               ├─> Offline → Throw "No network connection"
               │   └─> Component Catches
               │       └─> Display Offline Message
               │           ├─> Alert: "Keine Internetverbindung"
               │           └─> Optionally: Queue Operation
               │               └─> OfflineQueueService.addToQueue()
               │                   └─> Store in AsyncStorage
               │
               └─> Online → Continue
                   └─> retryWithBackoff()
                       └─> Attempt 1: Execute Function
                           ├─> Success → Return Result
                           │   └─> Component Updates UI
                           │
                           └─> Error → Wait 1s
                               └─> Attempt 2: Execute Function
                                   ├─> Success → Return Result
                                   │   └─> Component Updates UI
                                   │
                                   └─> Error → Wait 2s
                                       └─> Attempt 3: Execute Function
                                           ├─> Success → Return Result
                                           │   └─> Component Updates UI
                                           │
                                           └─> Error → Throw Last Error
                                               └─> Component Catches
                                                   └─> Display Error
                                                       └─> Show Retry Option
```

**Success Path:**
- Network available
- API call succeeds (possibly after retry)
- Data returned to component

**Error Paths:**
- **Offline**: Queue operation or show offline message
- **Network Timeout**: Retry with backoff, then show error
- **Persistent Failure**: Show error after max retries

---

### 3. Retry with Backoff Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. API Call Fails
   └─> retryWithBackoff() Triggered
       └─> Attempt 1: Execute Function
           ├─> Success → Return Result Immediately
           │   └─> No Delay, No Further Retries
           │
           └─> Error → Continue to Attempt 2
               └─> Wait 1 Second (initialDelay)
                   └─> Attempt 2: Execute Function
                       ├─> Success → Return Result
                       │   └─> Stop Retrying
                       │
                       └─> Error → Continue to Attempt 3
                           └─> Wait 2 Seconds (delay * 2)
                               └─> Attempt 3: Execute Function
                                   ├─> Success → Return Result
                                   │   └─> Stop Retrying
                                   │
                                   └─> Error → Max Retries Reached
                                       └─> Throw Last Error
                                           └─> Component Handles Error
```

**Retry Timing:**
- Attempt 1: Immediate (0ms delay)
- Attempt 2: After 1s delay
- Attempt 3: After 2s delay (total: 3s from start)
- Attempt 4: After 4s delay (if maxRetries > 3)

**Success Scenarios:**
- Success on any attempt stops retrying immediately
- Result returned as soon as successful

**Failure Scenarios:**
- All retries exhausted
- Last error thrown to component
- User sees error message with retry option

---

### 4. Offline Queue Flow

```
User Action (Offline)          System Response
─────────────────────────────────────────────────────────
1. User Triggers Operation
   └─> executeWithConnectivity()
       └─> checkConnectivity() → false
           └─> Throw "No network connection"
               └─> Component Catches
                   └─> OfflineQueueService.addToQueue()
                       └─> Generate Action ID
                           └─> Store in AsyncStorage
                               └─> Action Queued
                                   └─> Show Offline Message

2. Network Reconnects
   └─> Network State Change Detected
       └─> OfflineQueueService.processQueue()
           └─> Check Connectivity → true
               └─> For Each Queued Action
                   └─> Execute Action
                       ├─> Success → Remove from Queue
                       │   └─> Log Success
                       │
                       └─> Error → Increment Retry Count
                           ├─> Retry Count < Max (3)
                           │   └─> Keep in Queue
                           │       └─> Will Retry on Next Process
                           │
                           └─> Retry Count >= Max
                               └─> Discard Action
                                   └─> Log Failure
                                       └─> Return Processed Count
```

**Queue Processing:**
- Automatic on network reconnect
- Manual trigger available
- Processes actions sequentially
- Prevents concurrent processing

**Action Lifecycle:**
- Queued: Stored in AsyncStorage
- Processing: Executing action
- Success: Removed from queue
- Failed: Increment retry count
- Discarded: Max retries exceeded

---

### 5. Network Diagnostics Flow

```
User Action / System Check     System Response
─────────────────────────────────────────────────────────
1. Network Check Triggered
   └─> NetworkDiagnosticsService.testSupabaseConnection()
       └─> Record Start Time
           └─> Call supabase.auth.getSession()
               ├─> Success → Calculate Latency
               │   └─> Return Connected Diagnostics
               │       └─> isConnected: true
               │           └─> latency: <calculated>
               │
               └─> Error → Calculate Latency
                   └─> Return Error Diagnostics
                       └─> isConnected: false
                           └─> error: <error message>
                               └─> getUserFriendlyError()
                                   └─> Transform to German Message
                                       ├─> "Could not resolve host"
                                       │   └─> "Der Backend-Server ist nicht erreichbar..."
                                       ├─> "Network request failed"
                                       │   └─> "Netzwerkfehler: Bitte überprüfe..."
                                       ├─> "timeout"
                                       │   └─> "Die Anfrage hat zu lange gedauert..."
                                       └─> Default
                                           └─> "Verbindungsfehler: {error}"
                                               └─> Display to User
```

**Diagnostic Information:**
- Connection status (connected/disconnected)
- Latency measurement (milliseconds)
- Error details (if failed)
- Endpoint information
- Timestamp

---

## 🔀 Alternative Flows

### Error Recovery Flow

```
Error Occurs
    │
    ├─> Automatic Retry (Transient Failure)
    │   └─> retryWithBackoff()
    │       └─> Success → Continue Normal Flow
    │
    ├─> Queue Operation (Offline)
    │   └─> OfflineQueueService.addToQueue()
    │       └─> Process on Reconnect
    │           └─> Success → Continue Normal Flow
    │
    └─> User Retry (Manual)
        └─> User Clicks Retry Button
            └─> Component Retries Operation
                └─> Success → Continue Normal Flow
```

**Recovery Strategies:**
- **Automatic**: Retry with backoff for transient failures
- **Queue**: Store for later when offline
- **Manual**: User-initiated retry

---

### Error Display Flow

```
Error Transformed
    │
    ├─> Critical Error (Blocks User)
    │   └─> Alert.alert()
    │       └─> Title: "Request Failed"
    │           └─> Message: <transformed error>
    │               └─> Button: "OK"
    │                   └─> User Dismisses
    │
    ├─> Non-Critical Error (Non-blocking)
    │   └─> Toast Component
    │       └─> Type: "error"
    │           └─> Message: <transformed error>
    │               └─> Duration: 3000ms
    │                   └─> Auto-dismiss
    │                       └─> Optional: Action Button
    │                           └─> "Retry" → Retry Operation
    │
    └─> Component Error (Inline)
        └─> ErrorState Component
            └─> Error Icon
                └─> Error Message
                    └─> Retry Button (Optional)
                        └─> User Clicks → Retry Operation
```

**Error Display Types:**
- **Alert**: Critical errors requiring user attention
- **Toast**: Non-critical errors, auto-dismiss
- **ErrorState**: Inline error display in components

---

## 🚨 Error Scenarios

### Scenario 1: Network Timeout

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Loads Data
   └─> API Call Initiated
       └─> executeWithConnectivity()
           └─> checkConnectivity() → true
               └─> retryWithBackoff()
                   └─> Attempt 1: API Call
                       └─> Timeout After 30s
                           └─> Error: "Network request failed"
                               └─> Wait 1s
                                   └─> Attempt 2: API Call
                                       └─> Timeout After 30s
                                           └─> Error: "Network request failed"
                                               └─> Wait 2s
                                                   └─> Attempt 3: API Call
                                                       └─> Timeout After 30s
                                                           └─> Error: "Network request failed"
                                                               └─> Throw Error
                                                                   └─> Component Displays
                                                                       └─> Toast: "Netzwerkfehler: Bitte überprüfe..."
                                                                           └─> Retry Button Available
```

---

### Scenario 2: Offline Operation

```
User Action (Offline)          System Response
─────────────────────────────────────────────────────────
1. User Adds Favorite (Offline)
   └─> executeWithConnectivity()
       └─> checkConnectivity() → false
           └─> Throw "No network connection"
               └─> Component Catches
                   └─> OfflineQueueService.addToQueue()
                       └─> Action: "add_favorite"
                           └─> Data: { soundId: "123" }
                               └─> Store in AsyncStorage
                                   └─> Show Toast: "Offline - wird gespeichert"
                                       └─> User Continues Using App

2. Network Reconnects
   └─> Network State Change
       └─> OfflineQueueService.processQueue()
           └─> Execute Queued Actions
               └─> addFavorite(soundId: "123")
                   └─> Success → Remove from Queue
                       └─> Show Toast: "Favorit hinzugefügt"
```

---

### Scenario 3: Permission Denied

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Accesses Premium Feature
   └─> API Call: getPremiumContent()
       └─> safeApiCall()
           └─> Supabase Query
               └─> Error: { code: "42501", message: "..." }
                   └─> handleSupabaseError()
                       └─> Code: "42501"
                           └─> Message: "Access denied - please check your subscription"
                               └─> Throw Error
                                   └─> Component Catches
                                       └─> Alert.alert()
                                           └─> Title: "Request Failed"
                                               └─> Message: "Access denied - please check your subscription"
                                                   └─> User Redirected to Subscription Screen
```

---

### Scenario 4: Not Found (Graceful Handling)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Requests Non-Existent Resource
   └─> API Call: getUserProfile(userId: "invalid")
       └─> safeApiCall()
           └─> Supabase Query
               └─> Error: { code: "PGRST116", message: "..." }
                   └─> handleSupabaseError()
                       └─> Code: "PGRST116"
                           └─> Message: "No data found"
                               └─> Service Handles Gracefully
                                   └─> Returns null
                                       └─> Component Displays Empty State
                                           └─> No Error Shown to User
```

---

## 🔄 State Transitions

### Error State Machine

```
No Error
    │
    └─> Error Occurs
        └─> Error Transformed
            └─> Error Displayed
                │
                ├─> User Retries
                │   └─> Loading State
                │       ├─> Success → No Error
                │       └─> Error → Error Displayed (Loop)
                │
                ├─> Auto Retry
                │   └─> Retry Attempt
                │       ├─> Success → No Error
                │       └─> Error → Next Retry or Error Displayed
                │
                └─> User Dismisses
                    └─> No Error (if non-critical)
                        └─> Or Error Persists (if critical)
```

### Network State Machine

```
Online
    │
    └─> Network Disconnects
        └─> Offline
            └─> Operations Queued
                └─> Network Reconnects
                    └─> Online
                        └─> Queue Processed
                            └─> Operations Executed
```

---

## 📊 Flow Diagrams

### Complete Error Handling Flow

```
User Action
    │
    └─> Component Calls Service
        └─> Service Method
            └─> safeApiCall()
                └─> Try: API Call
                    │
                    ├─> Success Path
                    │   └─> Return Data
                    │       └─> Component Updates UI
                    │           └─> User Sees Success
                    │
                    └─> Error Path
                        └─> Catch Error
                            └─> handleSupabaseError()
                                └─> Transform Error
                                    └─> Throw Transformed Error
                                        └─> Component Catches
                                            └─> Determine Error Type
                                                │
                                                ├─> Critical → Alert.alert()
                                                │   └─> User Dismisses
                                                │
                                                ├─> Non-Critical → Toast
                                                │   └─> Auto-dismiss
                                                │       └─> Optional Retry
                                                │
                                                └─> Component Error → ErrorState
                                                    └─> Inline Display
                                                        └─> Retry Button
                                                            └─> User Retries
                                                                └─> [Loop to User Action]
```

---

### Network-Aware Error Flow

```
User Action
    │
    └─> Network-Dependent Operation
        └─> executeWithConnectivity()
            └─> checkConnectivity()
                │
                ├─> Offline
                │   └─> Throw "No network connection"
                │       └─> Component Catches
                │           └─> Option A: Queue Operation
                │               └─> OfflineQueueService.addToQueue()
                │                   └─> Store for Later
                │           └─> Option B: Show Offline Message
                │               └─> Alert: "Keine Internetverbindung"
                │
                └─> Online
                    └─> retryWithBackoff()
                        └─> Execute with Retry
                            ├─> Success → Return Result
                            └─> Failure → Throw Error
                                └─> Component Handles Error
```

---

## 🎯 User Goals

### Goal: Understand Error
- **Path:** Error occurs → Transform → Display clear message
- **Time:** < 1 second
- **Steps:** Error → Message → User understands

### Goal: Recover from Error
- **Path:** Error → Retry (automatic or manual) → Success
- **Time:** < 5 seconds (with retry)
- **Steps:** Error → Retry → Success

### Goal: Continue Offline
- **Path:** Offline → Queue → Reconnect → Process
- **Time:** Automatic on reconnect
- **Steps:** Queue → Reconnect → Process → Success

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
