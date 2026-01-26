# Settings System - Technical Specification

## 🏗️ Architecture Overview

### Technology Stack

#### Backend
- **Supabase** - Notification preferences storage
  - `notification_preferences` table
  - User profile updates
  - Real-time synchronization

#### Storage
- **AsyncStorage** - Local preference persistence
  - Privacy preferences
  - Developer settings
  - Notification toggle states

#### State Management
- **React Context API** - `AuthContext` for user state
- **Custom Hooks** - `useDevSettings`, `useUserProfile`
- **Local State** - Component-level state management

#### Services Layer
- `NotificationService` - Notification preference management
- `ProductionBackendService` - Supabase integration
- `DevSettingsStorage` - Developer settings persistence

---

## 📁 File Structure

```
src/
├── screens/
│   ├── AccountSettingsScreen.tsx        # Account settings screen
│   ├── PrivacySettingsScreen.tsx        # Privacy settings screen
│   └── NotificationPreferencesScreen.tsx # Notification preferences
├── components/
│   └── profile/
│       ├── ProfileSettingsSection.tsx    # Reusable settings section
│       └── ProfileAccountSection.tsx     # Account navigation section
├── services/
│   ├── NotificationService.ts            # Notification preference service
│   └── ProductionBackendService.ts       # Backend integration
├── hooks/
│   ├── useDevSettings.ts                # Developer settings hook
│   └── useUserProfile.ts                # User profile hook
└── utils/
    └── devSettingsStorage.ts             # Dev settings storage
```

---

## 🔧 Components

### AccountSettingsScreen
**Location:** `src/screens/AccountSettingsScreen.tsx`

**Purpose:** Main account settings interface with email, password, and security options

**Props:** None (screen component)

**State:**
- `currentEmail: string` - Current user email
- `newEmail: string` - New email input
- `isEmailValid: boolean` - Email validation state
- `newPassword: string` - New password input
- `showPassword: boolean` - Password visibility
- `isPasswordValid: boolean` - Password validation state
- `biometricEnabled: boolean` - Biometric toggle state
- `pushNotifications: boolean` - Push notification toggle
- `loading: boolean` - Loading state
- `confirmDialog: object` - Confirmation dialog state

**Features:**
- Email update with validation
- Password change with strength validation
- Biometric login toggle
- Push notifications toggle
- Developer settings (DEV mode only)
- Toast notifications for feedback
- Confirmation dialogs for critical actions

**Dependencies:**
- `useAuth` context
- `useDevSettings` hook
- `useToast` hook
- `useTheme` hook
- `UnifiedHeader` component
- `EnhancedCard` component
- `Input` component
- `ConfirmDialog` component

---

### PrivacySettingsScreen
**Location:** `src/screens/PrivacySettingsScreen.tsx`

**Purpose:** Privacy consent management interface

**Props:** None (screen component)

**State:**
- `healthDataConsent: boolean` - Health data consent
- `analyticsConsent: boolean` - Analytics consent
- `marketingConsent: boolean` - Marketing consent
- `isLoading: boolean` - Loading state

**Storage Key:** `awavePrivacyPreferences`

**Features:**
- Health data consent checkbox
- Analytics consent checkbox
- Marketing consent checkbox
- Save preferences button
- Last updated timestamp
- Custom checkbox component
- Gradient card styling

**Dependencies:**
- `AsyncStorage` for persistence
- `useTheme` hook
- `useTranslation` hook
- `EnhancedCard` component
- `UnifiedHeader` component

---

### NotificationPreferencesScreen
**Location:** `src/screens/NotificationPreferencesScreen.tsx`

**Purpose:** Granular notification preference control

**Props:** None (screen component)

**State:**
- `loading: boolean` - Initial load state
- `saving: boolean` - Save operation state
- `preferences: NotificationPreferences | null` - User preferences

**Features:**
- General notification toggles (push, email)
- Content notification toggles (trial, favorites, new content, system)
- Real-time preference updates
- Backend synchronization
- Optimistic UI updates
- Error handling with rollback
- Loading and empty states

**Dependencies:**
- `NotificationService` for backend operations
- `useAuth` context
- `useTheme` hook
- Supabase client

---

### ProfileSettingsSection
**Location:** `src/components/profile/ProfileSettingsSection.tsx`

**Purpose:** Reusable settings section component

**Props:**
```typescript
interface ProfileSettingsSectionProps {
  notificationsEnabled?: boolean;
  biometricEnabled?: boolean;
  onNotificationsToggle?: (enabled: boolean) => void;
  onBiometricToggle?: (enabled: boolean) => void;
}
```

**State:**
- `notificationsEnabled: boolean` - Notification toggle state
- `biometricEnabled: boolean` - Biometric toggle state
- `isLoading: boolean` - Loading state

**Storage Keys:**
- `@awave_notifications_enabled`
- `@awave_biometric_enabled`

**Features:**
- Notifications toggle with persistence
- HealthKit toggle with persistence
- Toast notifications for feedback
- External prop synchronization
- Local storage fallback

**Dependencies:**
- `AsyncStorage` for persistence
- `useToast` hook
- `useTheme` hook
- `EnhancedCard` component

---

### ProfileAccountSection
**Location:** `src/components/profile/ProfileAccountSection.tsx`

**Purpose:** Account navigation section with links to settings screens

**Props:** None

**State:**
- `isRestoring: boolean` - Purchase restoration state

**Features:**
- Navigation to Account Settings
- Navigation to Legal screen
- Navigation to Privacy Settings
- Restore purchases functionality
- Reset onboarding (DEV only)
- Gradient card styling
- Icon-based navigation

**Dependencies:**
- `useNavigation` hook
- `useTheme` hook
- `IAPService` for purchase restoration
- `onboardingStorage` for onboarding reset

---

## 🔌 Services

### NotificationService
**Location:** `src/services/NotificationService.ts`

**Class:** Static service class

**Interface:**
```typescript
interface NotificationPreferences {
  user_id: string;
  push_notifications_enabled: boolean;
  email_notifications_enabled: boolean;
  trial_reminders_enabled: boolean;
  favorites_updates_enabled: boolean;
  new_content_enabled: boolean;
  system_updates_enabled: boolean;
}
```

**Methods:**

**`getNotificationPreferences(userId: string): Promise<NotificationPreferences | null>`**
- Fetches user notification preferences from Supabase
- Creates default preferences if missing
- Returns preferences or null on error

**`createDefaultPreferences(userId: string): Promise<NotificationPreferences | null>`**
- Creates default notification preferences for new user
- All preferences default to `true`
- Returns created preferences or null on error

**`updateNotificationPreferences(userId: string, preferences: Partial<NotificationPreferences>): Promise<boolean>`**
- Updates notification preferences in Supabase
- Partial updates supported
- Returns success boolean

**`checkTrialStatus(userId: string): Promise<TrialStatus>`**
- Checks if user is in trial period
- Calculates days remaining
- Determines if reminder should be sent

**`sendTrialReminder(userId: string, daysRemaining: number): Promise<boolean>`**
- Sends trial reminder notification
- Checks if reminder already sent
- Respects user preferences
- Logs notification to database

**Storage Keys:**
- `notification_trial_reminder_sent_{userId}` - Reminder sent flag
- `notification_last_trial_check` - Last check timestamp

**Dependencies:**
- Supabase client
- AsyncStorage

---

### DevSettingsStorage
**Location:** `src/utils/devSettingsStorage.ts`

**Class:** Static service class

**Storage Keys:**
- `dev_bypass_paywall` - Paywall bypass flag

**Methods:**

**`isPaywallBypassEnabled(): Promise<boolean>`**
- Checks if paywall bypass is enabled
- Returns false in production
- Returns stored value in DEV mode

**`setPaywallBypass(enabled: boolean): Promise<void>`**
- Sets paywall bypass flag
- Only works in DEV mode
- Stores in AsyncStorage

**Dependencies:**
- AsyncStorage
- `__DEV__` flag check

---

## 🪝 Hooks

### useDevSettings
**Location:** `src/hooks/useDevSettings.ts`

**Purpose:** Developer settings management hook

**Returns:**
```typescript
{
  isPaywallBypassEnabled: boolean;
  togglePaywallBypass: () => Promise<void>;
}
```

**Features:**
- Paywall bypass state management
- Toggle functionality
- DEV mode only
- AsyncStorage persistence

**Dependencies:**
- `DevSettingsStorage` utility

---

### useUserProfile
**Location:** `src/hooks/useUserProfile.ts` (referenced in ProfileScreen)

**Purpose:** User profile data management

**Returns:**
```typescript
{
  userProfile: Profile | null;
  subscription: Subscription | null;
  notificationPreferences: NotificationPreferences | null;
  updateNotificationPreferences: (prefs: Partial<NotificationPreferences>) => Promise<void>;
}
```

**Features:**
- User profile data fetching
- Subscription status
- Notification preferences
- Preference update functionality

**Dependencies:**
- `ProductionBackendService`
- `NotificationService`

---

## 🔐 Security Implementation

### Password Security
- Minimum length: 10 characters
- Real-time validation feedback
- Secure password storage (via Supabase)
- Password visibility toggle

### Email Security
- Format validation (regex)
- Confirmation dialog before update
- Secure backend update (via Supabase)
- Current email display (read-only)

### Privacy Preferences
- Stored in AsyncStorage (local)
- Last updated timestamp tracking
- Consent tracking for compliance
- Clear descriptions for each consent type

### Developer Settings
- Only available in `__DEV__` mode
- Hidden from production builds
- Stored in AsyncStorage
- No backend synchronization

---

## 🔄 State Management

### AccountSettingsScreen State
```typescript
{
  currentEmail: string;
  newEmail: string;
  isEmailValid: boolean;
  newPassword: string;
  showPassword: boolean;
  isPasswordValid: boolean;
  biometricEnabled: boolean;
  pushNotifications: boolean;
  loading: boolean;
  confirmDialog: {
    visible: boolean;
    title: string;
    message?: string;
    onConfirm: () => void;
    destructive?: boolean;
  };
}
```

### PrivacySettingsScreen State
```typescript
{
  healthDataConsent: boolean;
  analyticsConsent: boolean;
  marketingConsent: boolean;
  isLoading: boolean;
}
```

### NotificationPreferences State
```typescript
{
  loading: boolean;
  saving: boolean;
  preferences: NotificationPreferences | null;
}
```

### Privacy Preferences Storage
```typescript
{
  healthDataConsent: boolean;
  analyticsConsent: boolean;
  marketingConsent: boolean;
  lastUpdated: string; // ISO timestamp
}
```

---

## 🌐 API Integration

### Supabase Endpoints

**Notification Preferences:**
- `supabase.from('notification_preferences').select()` - Get preferences
- `supabase.from('notification_preferences').insert()` - Create defaults
- `supabase.from('notification_preferences').update()` - Update preferences

**User Profile:**
- `supabase.from('user_profiles').update()` - Update profile metadata
- `supabase.auth.updateUser()` - Update email/password

**Notification Log:**
- `supabase.from('notification_log').insert()` - Log notifications

### AsyncStorage Keys

**Privacy Preferences:**
- `awavePrivacyPreferences` - Complete privacy preferences object

**Notification Toggles:**
- `@awave_notifications_enabled` - Notification toggle state
- `@awave_biometric_enabled` - Biometric toggle state

**Developer Settings:**
- `dev_bypass_paywall` - Paywall bypass flag

---

## 📱 Platform-Specific Notes

### iOS
- Biometric authentication (Face ID / Touch ID)
- HealthKit integration support
- Native notification permissions

### Android
- Biometric authentication (Fingerprint / Face)
- Health data integration (future)
- Native notification permissions

### Cross-Platform
- AsyncStorage works on both platforms
- Supabase integration is platform-agnostic
- Theme system supports both platforms

---

## 🧪 Testing Strategy

### Unit Tests
- Email validation logic
- Password validation logic
- Preference storage operations
- Default preference creation
- Dev settings storage

### Integration Tests
- Backend synchronization
- Preference persistence
- Error handling flows
- Network failure scenarios
- Optimistic update rollback

### E2E Tests
- Complete email update flow
- Complete password change flow
- Privacy preference save flow
- Notification preference toggle flow
- Biometric toggle flow
- Developer settings (DEV mode)

---

## 🐛 Error Handling

### Error Types
- Network errors (backend sync failures)
- Validation errors (invalid email/password)
- Storage errors (AsyncStorage failures)
- Authentication errors (session expiry)
- Backend errors (Supabase failures)

### Error Messages
- User-friendly German messages
- Clear action guidance
- Retry options where applicable
- No technical jargon

### Error Recovery
- Optimistic updates with rollback
- Local storage fallback
- Retry mechanisms
- Graceful degradation

---

## 📊 Performance Considerations

### Optimization
- Optimistic UI updates
- Debounced validation
- Lazy loading of preferences
- Efficient storage operations

### Monitoring
- Settings screen load time
- Preference update success rate
- Backend sync success rate
- Error rate tracking

---

*For component details, see `components.md`*  
*For service dependencies, see `services.md`*  
*For user flows, see `user-flows.md`*
