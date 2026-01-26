# Account Settings - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Frontend
- **React Native** - Mobile framework
- **TypeScript** - Type safety
- **React Hooks** - State management (useState, useEffect)

#### Backend
- **Supabase Auth** - Email/password updates
- **Supabase Database** - User profile updates

#### State Management
- **React Context API** - AuthContext for user state
- **Local State** - Form inputs and UI state
- **AsyncStorage** - Developer settings persistence

#### UI Components
- `EnhancedCard` - Card containers
- `Input` - Form inputs
- `Switch` - Toggle switches
- `ConfirmDialog` - Confirmation dialogs
- `Toast` - Notification system

---

## 📁 File Structure

```
src/
├── screens/
│   └── AccountSettingsScreen.tsx      # Main account settings screen
├── components/
│   ├── ui/
│   │   ├── Input.tsx                   # Form input component
│   │   ├── EnhancedCard.tsx            # Card container
│   │   ├── ConfirmDialog.tsx          # Confirmation dialog
│   │   └── Toast.tsx                   # Toast notification system
│   └── navigation/
│       └── UnifiedHeader.tsx           # Screen header
├── contexts/
│   └── AuthContext.tsx                 # Authentication context
├── hooks/
│   └── useDevSettings.ts               # Developer settings hook
└── services/
    └── ProductionBackendService.ts     # Backend integration
```

---

## 🔧 Components

### AccountSettingsScreen
**Location:** `src/screens/AccountSettingsScreen.tsx`

**Purpose:** Main account settings screen

**State:**
```typescript
{
  loading: boolean;
  currentEmail: string;
  newEmail: string;
  isEmailValid: boolean;
  newPassword: string;
  showPassword: boolean;
  isPasswordValid: boolean;
  biometricEnabled: boolean;
  pushNotifications: boolean;
  confirmDialog: {
    visible: boolean;
    title: string;
    message?: string;
    onConfirm: () => void;
    destructive?: boolean;
  };
  toasts: Toast[];
}
```

**Methods:**
- `validateEmail(email: string): boolean` - Email format validation
- `validatePassword(password: string): boolean` - Password length validation
- `handleEmailChange(email: string): void` - Email input handler
- `handlePasswordChange(password: string): void` - Password input handler
- `handleEmailUpdate(): void` - Email update handler
- `handlePasswordUpdate(): Promise<void>` - Password update handler
- `handleBiometricToggle(enabled: boolean): void` - Biometric toggle handler

**Validation:**
- Email: `/^[^\s@]+@[^\s@]+\.[^\s@]+$/`
- Password: Minimum 10 characters

---

## 🔌 Services

### AuthContext (useAuth)
**Location:** `src/contexts/AuthContext.tsx`

**Methods:**
```typescript
updateEmail(email: string): Promise<{data, error}>
updatePassword(password: string): Promise<{data, error}>
user: User | null
```

**Implementation:**
- Uses Supabase Auth API
- Handles re-authentication for email updates
- Returns success/error responses

---

### ProductionBackendService
**Location:** `src/services/ProductionBackendService.ts`

**Methods:**
```typescript
updateUserProfile(userId: string, updates: object): Promise<Profile>
```

**Implementation:**
- Updates user profile metadata
- Used for HealthKit preferences
- Merges updates with existing data

---

### useDevSettings Hook
**Location:** `src/hooks/useDevSettings.ts`

**State:**
```typescript
{
  isPaywallBypassEnabled: boolean;
  togglePaywallBypass: () => void;
}
```

**Storage:**
- Key: `dev_paywall_bypass`
- Type: boolean
- Location: AsyncStorage

---

## 🔐 Security Implementation

### Email Validation
- Format: Standard email regex pattern
- Real-time validation
- Confirmation dialog before update
- Secure API communication (HTTPS)

### Password Validation
- Minimum length: 10 characters
- Secure input (secureTextEntry)
- Password never displayed
- Secure API communication (HTTPS)

### Developer Settings
- Only available in __DEV__ mode
- Stored locally (not synced)
- No security implications

---

## 🔄 State Management

### Local State
```typescript
{
  loading: boolean;
  currentEmail: string;
  newEmail: string;
  isEmailValid: boolean;
  newPassword: string;
  showPassword: boolean;
  isPasswordValid: boolean;
  biometricEnabled: boolean;
  pushNotifications: boolean;
  confirmDialog: ConfirmDialogState;
  toasts: Toast[];
}
```

### Context State
```typescript
{
  user: User | null;
  updateEmail: (email: string) => Promise<{data, error}>;
  updatePassword: (password: string) => Promise<{data, error}>;
}
```

### Persistent State
```typescript
{
  dev_paywall_bypass: boolean; // AsyncStorage
}
```

---

## 🌐 API Integration

### Supabase Auth Endpoints
- `supabase.auth.updateUser({ email })` - Email update
- `supabase.auth.updateUser({ password })` - Password update

### Supabase Database Endpoints
- `supabase.from('profiles').update()` - Profile metadata update

---

## 📱 Platform-Specific Notes

### iOS
- Biometric authentication (Face ID/Touch ID)
- Native keyboard types
- Secure text entry

### Android
- Biometric authentication (Fingerprint/Face)
- Native keyboard types
- Secure text entry

---

## 🧪 Testing Strategy

### Unit Tests
- Email validation logic
- Password validation logic
- Form state management
- Toast notification system

### Integration Tests
- Supabase Auth API calls
- Profile update API calls
- Error handling
- Confirmation dialogs

### E2E Tests
- Complete email update flow
- Complete password update flow
- Settings toggle functionality
- Error scenarios

---

## 🐛 Error Handling

### Error Types
- Network errors
- Validation errors
- Authentication errors
- Update failures

### Error Messages
- User-friendly German messages
- Clear action guidance
- Retry options where applicable

---

## 📊 Performance Considerations

### Optimization
- Real-time validation (debounced)
- Efficient state updates
- Lazy loading of components
- Toast auto-dismiss

### Monitoring
- Update success rate
- Average update time
- Error rates
- User satisfaction

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
