# Error Handling System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Error Handling Utilities
- **Custom Error Handler** - `src/utils/errorHandler.ts`
  - Supabase error transformation
  - Retry logic with exponential backoff
  - Network connectivity checking
  - Safe API call wrappers

#### Network Diagnostics
- **Network Diagnostics Service** - `src/utils/networkDiagnostics.ts`
  - Supabase connection health checks
  - Latency measurement
  - User-friendly error messages
  - Connection status monitoring

#### Error Constants
- **Backend Constants** - `src/services/backendConstants.ts`
  - Error code definitions
  - Table names
  - RPC function names

#### Error Display
- **React Native Alert** - Native alert dialogs
- **Toast Component** - `src/components/ui/Toast.tsx`
- **Error State Components** - `src/components/ui/ComponentStates.tsx`

#### Network Monitoring
- **NetInfo** - `@react-native-community/netinfo`
  - Network connectivity detection
  - Network state changes
  - Connection type detection

---

## 📁 File Structure

```
src/
├── utils/
│   ├── errorHandler.ts              # Core error handling utilities
│   └── networkDiagnostics.ts         # Network diagnostics service
├── services/
│   └── backendConstants.ts           # Error code definitions
├── components/
│   └── ui/
│       ├── ComponentStates.tsx       # Error state components
│       └── Toast.tsx                 # Toast notification component
└── services/
    └── OfflineQueueService.ts        # Offline error queue management
```

---

## 🔧 Core Utilities

### errorHandler.ts

#### SupabaseErrorLike Interface
```typescript
export interface SupabaseErrorLike {
  code?: string;
  message?: string;
}
```

#### handleSupabaseError
**Location:** `src/utils/errorHandler.ts`

**Purpose:** Transform Supabase errors to user-friendly messages

**Signature:**
```typescript
handleSupabaseError(error: SupabaseErrorLike): string
```

**Error Code Mapping:**
- `PGRST116` → "No data found"
- `42501` → "Access denied - please check your subscription"
- `row_level_security` → "Access denied - please check your subscription"
- `invalid_grant` → "Please sign in again"
- `23505` → "This data already exists"
- `NETWORK_ERROR` → "Network connection failed"
- Default → `error.message || "Something went wrong"`

**Features:**
- Console error logging
- Error code-based message selection
- Fallback to error message or generic message

---

#### reportSupabaseError
**Location:** `src/utils/errorHandler.ts`

**Purpose:** Display error via Alert dialog

**Signature:**
```typescript
reportSupabaseError(error: SupabaseErrorLike): void
```

**Features:**
- Transforms error using `handleSupabaseError`
- Displays Alert with title "Request Failed"
- Shows user-friendly error message

---

#### retryWithBackoff
**Location:** `src/utils/errorHandler.ts`

**Purpose:** Retry function with exponential backoff

**Signature:**
```typescript
retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries?: number,
  initialDelay?: number
): Promise<T>
```

**Configuration:**
- Default `maxRetries`: 3
- Default `initialDelay`: 1000ms (1 second)
- Delay multiplier: 2x per retry

**Retry Strategy:**
- Attempt 1: Immediate
- Attempt 2: Wait 1s
- Attempt 3: Wait 2s
- Attempt 4: Wait 4s (if maxRetries > 3)

**Behavior:**
- Returns result on first successful attempt
- Throws last error after max retries
- Preserves error context

---

#### checkConnectivity
**Location:** `src/utils/errorHandler.ts`

**Purpose:** Check network connectivity status

**Signature:**
```typescript
checkConnectivity(): Promise<boolean>
```

**Implementation:**
- Uses `NetInfo.fetch()` to check connection
- Returns `true` if connected, `false` otherwise
- Non-blocking async operation

---

#### executeWithConnectivity
**Location:** `src/utils/errorHandler.ts`

**Purpose:** Execute function with connectivity check and retry

**Signature:**
```typescript
executeWithConnectivity<T>(fn: () => Promise<T>): Promise<T>
```

**Flow:**
1. Check network connectivity
2. If offline, throw "No network connection available"
3. If online, execute function with `retryWithBackoff`
4. Return result or throw error

**Usage:**
- Network-dependent API calls
- Operations requiring internet connection
- Prevents unnecessary retry attempts when offline

---

#### safeApiCall
**Location:** `src/utils/errorHandler.ts`

**Purpose:** Safe API call wrapper with error transformation

**Signature:**
```typescript
safeApiCall<T>(fn: () => Promise<T>): Promise<T>
```

**Flow:**
1. Execute function in try-catch
2. Catch any errors
3. Transform error using `handleSupabaseError`
4. Throw transformed error message

**Usage:**
- All `ProductionBackendService` methods
- Consistent error handling across API calls
- Automatic error transformation

---

## 🔌 Network Diagnostics Service

### NetworkDiagnosticsService
**Location:** `src/utils/networkDiagnostics.ts`

**Type:** Static Class

**Purpose:** Network connectivity diagnostics and health checks

---

#### NetworkDiagnostics Interface
```typescript
export interface NetworkDiagnostics {
  isConnected: boolean;
  latency?: number;
  error?: string;
  details: {
    supabaseUrl: string;
    authEndpoint: string;
    restEndpoint: string;
    timestamp: string;
  };
}
```

---

#### testSupabaseConnection
**Purpose:** Test Supabase backend connectivity

**Signature:**
```typescript
static async testSupabaseConnection(): Promise<NetworkDiagnostics>
```

**Implementation:**
1. Record start time
2. Call `supabase.auth.getSession()` as health check
3. Calculate latency
4. Return diagnostics with connection status

**Returns:**
- `isConnected`: boolean
- `latency`: number (milliseconds)
- `error`: string (if connection failed)
- `details`: Connection endpoint information

---

#### getUserFriendlyError
**Purpose:** Get user-friendly error message from diagnostics

**Signature:**
```typescript
static getUserFriendlyError(diagnostics: NetworkDiagnostics): string
```

**Error Message Mapping:**
- Connected → "Verbindung erfolgreich"
- "Could not resolve host" → "Der Backend-Server ist nicht erreichbar..."
- "Network request failed" → "Netzwerkfehler: Bitte überprüfe..."
- "timeout" → "Die Anfrage hat zu lange gedauert..."
- Default → "Verbindungsfehler: {error}"

**Features:**
- German error messages
- Context-specific messages
- Actionable guidance

---

#### logDiagnostics
**Purpose:** Log detailed diagnostics to console

**Signature:**
```typescript
static logDiagnostics(diagnostics: NetworkDiagnostics): void
```

**Usage:**
- Development debugging
- Network troubleshooting
- Performance monitoring

---

## 📦 Error Constants

### ERROR_CODES
**Location:** `src/services/backendConstants.ts`

**Definition:**
```typescript
export const ERROR_CODES = {
  NOT_FOUND: 'PGRST116',
  PERMISSION_DENIED: '42501',
  ROW_LEVEL_SECURITY: 'row_level_security',
  INVALID_GRANT: 'invalid_grant',
  DUPLICATE_KEY: '23505',
  NETWORK_ERROR: 'NETWORK_ERROR',
} as const;
```

**Usage:**
- Error code comparison
- Error type checking
- Error message selection

---

## 🎨 Error Display Components

### ErrorState Component
**Location:** `src/components/ui/ComponentStates.tsx`

**Purpose:** Display error state in UI

**Props:**
```typescript
interface ErrorStateProps {
  title?: string;
  message?: string;
  onRetry?: () => void;
  retryText?: string;
  style?: ViewStyle;
}
```

**Features:**
- Error icon display
- Error title and message
- Retry button (optional)
- Customizable styling

---

### ComponentStateHandler
**Location:** `src/components/ui/ComponentStates.tsx`

**Purpose:** Handle component states (loading, error, empty, success)

**Props:**
```typescript
interface ComponentStateProps {
  state: 'loading' | 'error' | 'empty' | 'success';
  loadingText?: string;
  errorText?: string;
  emptyText?: string;
  successText?: string;
  onRetry?: () => void;
  onRefresh?: () => void;
  style?: ViewStyle;
  showIcon?: boolean;
  children?: React.ReactNode;
}
```

**Features:**
- State-based rendering
- Loading spinner
- Error display with retry
- Empty state display
- Success state display

---

### Toast Component
**Location:** `src/components/ui/Toast.tsx`

**Purpose:** Display toast notifications for errors

**Props:**
```typescript
interface ToastProps {
  message: string;
  type?: 'default' | 'success' | 'error' | 'warning' | 'info';
  position?: 'top' | 'bottom' | 'center';
  duration?: number;
  onClose?: () => void;
  action?: {
    label: string;
    onPress: () => void;
  };
  style?: ViewStyle;
}
```

**Features:**
- Auto-dismiss after duration
- Multiple toast types
- Position configuration
- Action buttons
- Animation support

---

### useToast Hook
**Location:** `src/components/ui/Toast.tsx`

**Purpose:** Toast management hook

**Returns:**
```typescript
{
  toasts: ToastConfig[];
  showToast: (config: ToastConfig) => void;
  removeToast: (id: string) => void;
  success: (message: string, config?: Partial<ToastConfig>) => void;
  error: (message: string, config?: Partial<ToastConfig>) => void;
  warning: (message: string, config?: Partial<ToastConfig>) => void;
  info: (message: string, config?: Partial<ToastConfig>) => void;
}
```

**Usage:**
- Show error toasts
- Show success messages
- Show warnings
- Show info messages

---

## 🔄 Error Handling Flow

### API Call Error Flow
```
API Call
    │
    └─> safeApiCall()
        └─> Try: Execute Function
            ├─> Success → Return Result
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
            └─> Online → Continue
                └─> retryWithBackoff()
                    └─> Attempt 1
                        ├─> Success → Return
                        └─> Error → Wait 1s
                            └─> Attempt 2
                                ├─> Success → Return
                                └─> Error → Wait 2s
                                    └─> Attempt 3
                                        ├─> Success → Return
                                        └─> Error → Throw Last Error
```

### Offline Error Flow
```
API Call (Offline)
    │
    └─> executeWithConnectivity()
        └─> checkConnectivity() → false
            └─> Throw "No network connection"
                └─> Component Catches
                    └─> OfflineQueueService.addToQueue()
                        └─> Store in AsyncStorage
                            │
                            └─> Network Reconnects
                                └─> OfflineQueueService.processQueue()
                                    └─> Execute Queued Actions
                                        └─> Remove on Success
```

---

## 🔐 Error Code Mapping

### Supabase Error Codes

| Code | Type | User Message |
|------|------|--------------|
| `PGRST116` | Not Found | "No data found" |
| `42501` | Permission Denied | "Access denied - please check your subscription" |
| `row_level_security` | RLS Violation | "Access denied - please check your subscription" |
| `invalid_grant` | Auth Error | "Please sign in again" |
| `23505` | Duplicate Key | "This data already exists" |
| `NETWORK_ERROR` | Network | "Network connection failed" |
| *Unknown* | Generic | `error.message` or "Something went wrong" |

---

## 🌐 API Integration

### Error Handling in ProductionBackendService

All methods follow this pattern:
```typescript
static async methodName(...args): Promise<Result> {
  return safeApiCall(async () => {
    // API call implementation
    const { data, error } = await supabase...
    if (error) throw error;
    return data;
  });
}
```

### Network-Dependent Operations

Operations requiring network use:
```typescript
return executeWithConnectivity(async () => {
  // Network-dependent operation
});
```

---

## 📱 Platform-Specific Notes

### iOS
- NetInfo uses native iOS network monitoring
- Alert uses native iOS alert dialogs
- Toast uses React Native Animated API

### Android
- NetInfo uses native Android network monitoring
- Alert uses native Android alert dialogs
- Toast uses React Native Animated API

---

## 🧪 Testing Strategy

### Unit Tests
- Error transformation logic
- Retry backoff calculation
- Connectivity checking
- Error code mapping

### Integration Tests
- API error handling
- Network error scenarios
- Retry logic execution
- Offline queue processing

### E2E Tests
- Complete error flows
- User error interactions
- Network state changes
- Error recovery scenarios

---

## 🐛 Error Handling Best Practices

### Error Transformation
- Always transform errors before displaying
- Use error codes for error type detection
- Provide fallback messages for unknown errors
- Log full error details for debugging

### Retry Logic
- Use exponential backoff for retries
- Set reasonable max retry limits
- Don't retry on non-retryable errors (e.g., 400, 401)
- Preserve error context across retries

### Network Handling
- Check connectivity before API calls
- Queue operations when offline
- Process queue on reconnect
- Provide clear offline indicators

### User Communication
- Use German for user-facing messages
- Avoid technical jargon
- Provide actionable guidance
- Show retry options when applicable

---

## 📊 Performance Considerations

### Optimization
- Error transformation is synchronous (< 10ms)
- Connectivity checks are async (< 1s)
- Retry delays don't block UI thread
- Error logging is development-only

### Monitoring
- Error frequency tracking
- Retry success rate
- Network error patterns
- Queue processing metrics

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For error flows, see `user-flows.md`*
