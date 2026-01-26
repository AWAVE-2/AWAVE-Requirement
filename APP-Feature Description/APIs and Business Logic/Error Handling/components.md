# Error Handling System - Components Inventory

## 🛠️ Utilities

### errorHandler
**File:** `src/utils/errorHandler.ts`  
**Type:** Error Handling Utilities  
**Purpose:** Core error handling functions

#### Functions

**`handleSupabaseError(error: SupabaseErrorLike): string`**
- Transforms Supabase errors to user-friendly messages
- Maps error codes to German messages
- Logs errors to console
- Returns user-friendly error string

**Error Code Mapping:**
- `PGRST116` → "No data found"
- `42501` → "Access denied - please check your subscription"
- `row_level_security` → "Access denied - please check your subscription"
- `invalid_grant` → "Please sign in again"
- `23505` → "This data already exists"
- `NETWORK_ERROR` → "Network connection failed"
- Default → `error.message || "Something went wrong"`

**Usage:**
```typescript
const errorMessage = handleSupabaseError(error);
```

---

**`reportSupabaseError(error: SupabaseErrorLike): void`**
- Displays error via Alert dialog
- Uses `handleSupabaseError` for message
- Shows "Request Failed" title
- Non-blocking operation

**Usage:**
```typescript
reportSupabaseError(error);
```

---

**`retryWithBackoff<T>(fn, maxRetries?, initialDelay?): Promise<T>`**
- Retries function with exponential backoff
- Default: 3 retries, 1s initial delay
- Delay doubles each retry (1s, 2s, 4s)
- Returns result on success
- Throws last error after max retries

**Configuration:**
- `maxRetries`: Number of retry attempts (default: 3)
- `initialDelay`: Initial delay in ms (default: 1000)

**Usage:**
```typescript
const result = await retryWithBackoff(
  () => apiCall(),
  3,
  1000
);
```

---

**`checkConnectivity(): Promise<boolean>`**
- Checks network connectivity status
- Uses NetInfo.fetch()
- Returns true if connected, false otherwise
- Non-blocking async operation

**Usage:**
```typescript
const isConnected = await checkConnectivity();
```

---

**`executeWithConnectivity<T>(fn): Promise<T>`**
- Executes function with connectivity check
- Throws error if offline
- Uses retryWithBackoff if online
- Combines connectivity check with retry

**Usage:**
```typescript
const result = await executeWithConnectivity(
  () => apiCall()
);
```

---

**`safeApiCall<T>(fn): Promise<T>`**
- Wraps API call in try-catch
- Transforms errors using handleSupabaseError
- Throws transformed error message
- Used by all ProductionBackendService methods

**Usage:**
```typescript
const result = await safeApiCall(
  () => apiCall()
);
```

---

### networkDiagnostics
**File:** `src/utils/networkDiagnostics.ts`  
**Type:** Network Diagnostics Service  
**Purpose:** Network connectivity diagnostics

#### NetworkDiagnosticsService Class

**`testSupabaseConnection(): Promise<NetworkDiagnostics>`**
- Tests Supabase backend connectivity
- Measures connection latency
- Returns diagnostics with connection status
- Includes endpoint information

**Returns:**
```typescript
{
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

**Usage:**
```typescript
const diagnostics = await NetworkDiagnosticsService.testSupabaseConnection();
```

---

**`getUserFriendlyError(diagnostics: NetworkDiagnostics): string`**
- Converts diagnostics to user-friendly German message
- Maps error types to specific messages
- Provides actionable guidance

**Error Messages:**
- Connected → "Verbindung erfolgreich"
- "Could not resolve host" → "Der Backend-Server ist nicht erreichbar..."
- "Network request failed" → "Netzwerkfehler: Bitte überprüfe..."
- "timeout" → "Die Anfrage hat zu lange gedauert..."
- Default → "Verbindungsfehler: {error}"

**Usage:**
```typescript
const message = NetworkDiagnosticsService.getUserFriendlyError(diagnostics);
```

---

**`logDiagnostics(diagnostics: NetworkDiagnostics): void`**
- Logs detailed diagnostics to console
- Development debugging only
- Includes all diagnostic information

**Usage:**
```typescript
NetworkDiagnosticsService.logDiagnostics(diagnostics);
```

---

### backendConstants
**File:** `src/services/backendConstants.ts`  
**Type:** Constants  
**Purpose:** Error code definitions

#### ERROR_CODES
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
```typescript
import { ERROR_CODES } from '../services/backendConstants';

if (error.code === ERROR_CODES.NOT_FOUND) {
  // Handle not found
}
```

---

## 🧩 UI Components

### ErrorState
**File:** `src/components/ui/ComponentStates.tsx`  
**Type:** Error Display Component  
**Purpose:** Display error state in UI

**Props:**
```typescript
interface ErrorStateProps {
  title?: string;                    // Error title (default: "Error")
  message?: string;                  // Error message
  onRetry?: () => void;             // Retry callback
  retryText?: string;               // Retry button text (default: "Retry")
  style?: ViewStyle;                // Custom styles
}
```

**Features:**
- Error icon display
- Error title and message
- Retry button (optional)
- Customizable styling
- Theme integration

**Usage:**
```typescript
<ErrorState
  title="Connection Error"
  message="Unable to connect to server"
  onRetry={handleRetry}
  retryText="Try Again"
/>
```

---

### ComponentStateHandler
**File:** `src/components/ui/ComponentStates.tsx`  
**Type:** State Management Component  
**Purpose:** Handle component states (loading, error, empty, success)

**Props:**
```typescript
interface ComponentStateProps {
  state: 'loading' | 'error' | 'empty' | 'success';
  loadingText?: string;              // Loading message
  errorText?: string;                // Error message
  emptyText?: string;                // Empty state message
  successText?: string;              // Success message
  onRetry?: () => void;              // Retry callback
  onRefresh?: () => void;            // Refresh callback
  style?: ViewStyle;                 // Custom styles
  showIcon?: boolean;                // Show state icon (default: true)
  children?: React.ReactNode;        // Content when state is 'success'
}
```

**States:**
- **loading**: Shows loading spinner
- **error**: Shows error icon and message with retry button
- **empty**: Shows empty state message
- **success**: Shows children content

**Usage:**
```typescript
<ComponentStateHandler
  state={dataState}
  loadingText="Loading data..."
  errorText="Failed to load data"
  emptyText="No data available"
  onRetry={handleRetry}
>
  {/* Content when state is 'success' */}
</ComponentStateHandler>
```

---

### Toast
**File:** `src/components/ui/Toast.tsx`  
**Type:** Notification Component  
**Purpose:** Display toast notifications for errors and messages

**Props:**
```typescript
interface ToastProps {
  message: string;                   // Toast message
  type?: 'default' | 'success' | 'error' | 'warning' | 'info';
  position?: 'top' | 'bottom' | 'center';
  duration?: number;                 // Auto-dismiss duration in ms (default: 3000)
  onClose?: () => void;              // Close callback
  action?: {                         // Action button
    label: string;
    onPress: () => void;
  };
  style?: ViewStyle;                 // Custom styles
}
```

**Features:**
- Auto-dismiss after duration
- Multiple toast types with icons
- Position configuration
- Action buttons
- Animation support
- Theme integration

**Toast Types:**
- **success**: ✅ Green background
- **error**: ❌ Red background
- **warning**: ⚠️ Orange background
- **info**: ℹ️ Blue background
- **default**: 💬 Default background

**Usage:**
```typescript
<Toast
  message="Error occurred"
  type="error"
  position="top"
  duration={3000}
  action={{
    label: "Retry",
    onPress: handleRetry
  }}
/>
```

---

### useToast Hook
**File:** `src/components/ui/Toast.tsx`  
**Type:** React Hook  
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

**Methods:**
- `showToast(config)` - Show custom toast
- `removeToast(id)` - Remove toast by ID
- `success(message, config?)` - Show success toast
- `error(message, config?)` - Show error toast
- `warning(message, config?)` - Show warning toast
- `info(message, config?)` - Show info toast

**Usage:**
```typescript
const { error, success } = useToast();

// Show error toast
error("Failed to load data", {
  duration: 5000,
  action: {
    label: "Retry",
    onPress: handleRetry
  }
});

// Show success toast
success("Data loaded successfully");
```

---

## 🔗 Component Relationships

### Error Handling Flow
```
API Call
    │
    └─> safeApiCall()
        └─> Error Occurs
            └─> handleSupabaseError()
                └─> Component Catches Error
                    ├─> Alert.alert() (Critical)
                    ├─> Toast (Non-critical)
                    └─> ErrorState (UI Component)
```

### Error Display Hierarchy
```
Error Occurs
    │
    ├─> Critical Error → Alert.alert()
    │   └─> Blocks user interaction
    │
    ├─> Non-critical Error → Toast
    │   └─> Auto-dismisses
    │
    └─> Component Error → ErrorState
        └─> Inline error display
            └─> Retry button available
```

---

## 🎨 Styling

### Theme Integration
All error components use the theme system:
- Colors: `theme.colors.awave.error`, `theme.colors.awave.text`
- Typography: `theme.typography.fontFamily`
- Spacing: Consistent padding and margins

### Error Colors
- **Error**: Red (`theme.colors.awave.error`)
- **Warning**: Orange
- **Info**: Blue
- **Success**: Green

---

## 🔄 State Management

### Error State Flow
```
No Error → Error Occurs → Error Displayed → User Action
    │           │              │                  │
    │           │              │                  ├─> Retry → Loading → Success/Error
    │           │              │                  │
    │           │              │                  └─> Dismiss → No Error
    │           │              │
    │           │              └─> Auto-dismiss (Toast)
    │           │
    │           └─> Error Transformed
    │
    └─> Normal State
```

---

## 🧪 Testing Considerations

### Component Tests
- Error message display
- Retry button functionality
- Toast auto-dismiss
- Error state transitions
- Theme integration

### Integration Tests
- Error handling flow
- Network error scenarios
- Retry functionality
- Toast management

### E2E Tests
- Complete error flows
- User error interactions
- Error recovery scenarios

---

## 📊 Component Metrics

### Complexity
- **errorHandler**: Low (pure functions)
- **networkDiagnostics**: Medium (async operations)
- **ErrorState**: Low (display component)
- **ComponentStateHandler**: Medium (state management)
- **Toast**: Medium (animation + state)

### Reusability
- **errorHandler utilities**: High (used everywhere)
- **ErrorState**: High (reusable error display)
- **ComponentStateHandler**: High (generic state handler)
- **Toast**: High (reusable notification)

### Dependencies
- All components depend on theme system
- Error utilities depend on NetInfo
- UI components depend on React Native components
- Toast depends on Animated API

---

*For service dependencies, see `services.md`*  
*For error flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
