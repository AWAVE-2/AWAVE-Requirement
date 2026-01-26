# Settings System - Services Documentation

## 🔧 Service Layer Overview

The Settings system uses a service-oriented architecture with clear separation of concerns. Services handle backend interactions, preference management, notification handling, and developer settings persistence.

---

## 📦 Services

### NotificationService
**File:** `src/services/NotificationService.ts`  
**Type:** Static Class  
**Purpose:** Notification preference management and trial reminder notifications

#### Configuration
```typescript
const STORAGE_KEYS = {
  TRIAL_REMINDER_SENT: 'notification_trial_reminder_sent',
  LAST_TRIAL_CHECK: 'notification_last_trial_check',
};
```

#### Interface
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

interface TrialStatus {
  isTrialing: boolean;
  trialEndsAt: string | null;
  daysRemaining: number;
  shouldSendReminder: boolean;
}
```

#### Methods

**`getNotificationPreferences(userId: string): Promise<NotificationPreferences | null>`**
- Fetches user notification preferences from Supabase
- Creates default preferences if missing
- Returns preferences or null on error
- Handles PGRST116 (no rows) error gracefully

**`createDefaultPreferences(userId: string): Promise<NotificationPreferences | null>`**
- Creates default notification preferences for new user
- All preferences default to `true`
- Inserts into `notification_preferences` table
- Returns created preferences or null on error

**`updateNotificationPreferences(userId: string, preferences: Partial<NotificationPreferences>): Promise<boolean>`**
- Updates notification preferences in Supabase
- Supports partial updates
- Updates `notification_preferences` table
- Returns success boolean

**`checkTrialStatus(userId: string): Promise<TrialStatus>`**
- Checks if user is in trial period
- Queries `user_subscriptions` table
- Calculates days remaining
- Determines if reminder should be sent (3 days before expiration)
- Returns trial status object

**`wasTrialReminderSent(userId: string): Promise<boolean>`**
- Checks if trial reminder was already sent
- Uses AsyncStorage with user-specific key
- Returns boolean status

**`markTrialReminderSent(userId: string): Promise<void>`**
- Marks trial reminder as sent
- Stores flag in AsyncStorage
- Prevents duplicate reminders

**`sendTrialReminder(userId: string, daysRemaining: number): Promise<boolean>`**
- Sends trial reminder notification
- Checks if reminder already sent
- Respects user preferences (trial_reminders_enabled)
- Logs notification to `notification_log` table
- Marks reminder as sent
- Returns success boolean

**`checkAndSendTrialReminder(userId: string): Promise<void>`**
- Main method to check and send trial reminder
- Checks trial status
- Sends reminder if conditions met
- Handles errors gracefully

#### Storage Keys
- `notification_trial_reminder_sent_{userId}` - Reminder sent flag
- `notification_last_trial_check` - Last check timestamp

#### Error Handling
- Network errors: Returns null/false, logs error
- Database errors: Handles PGRST116 (no rows) gracefully
- Validation errors: Checks user preferences before sending
- Duplicate prevention: Checks if reminder already sent

#### Dependencies
- Supabase client (`supabase`)
- AsyncStorage
- `notification_preferences` table
- `user_subscriptions` table
- `notification_log` table

---

### DevSettingsStorage
**File:** `src/utils/devSettingsStorage.ts`  
**Type:** Static Service Class  
**Purpose:** Developer settings persistence

#### Storage Keys
```typescript
const DEV_KEYS = {
  BYPASS_PAYWALL: 'dev_bypass_paywall',
};
```

#### Methods

**`isPaywallBypassEnabled(): Promise<boolean>`**
- Checks if paywall bypass is enabled
- Returns false in production (forced)
- Returns stored value in DEV mode
- Handles storage errors gracefully

**`setPaywallBypass(enabled: boolean): Promise<void>`**
- Sets paywall bypass flag
- Only works in DEV mode
- Stores in AsyncStorage
- Handles storage errors

#### Security
- Only available in `__DEV__` mode
- Production builds always return false
- No backend synchronization
- Local storage only

#### Dependencies
- AsyncStorage
- `__DEV__` flag check

---

### ProductionBackendService
**File:** `src/services/ProductionBackendService.ts`  
**Type:** Service Class  
**Purpose:** Supabase integration for user profile and settings

#### Settings-Related Methods

**`updateUserProfile(userId: string, updates: Partial<Profile>): Promise<Profile>`**
- Updates user profile metadata
- Used for HealthKit settings
- Merges updates with existing data
- Returns updated profile

**`updateEmail(email: string): Promise<void>`**
- Updates user email address
- Requires re-authentication
- Updates Supabase auth user
- Handles errors

**`updatePassword(password: string): Promise<void>`**
- Updates user password
- Requires current password (handled by Supabase)
- Updates Supabase auth user
- Handles errors

#### Dependencies
- Supabase client
- Supabase Auth API
- Supabase Database API

---

## 🔗 Service Dependencies

### Dependency Graph
```
AccountSettingsScreen
├── useAuth
│   └── AuthContext
│       └── ProductionBackendService
│           └── supabase client
└── useDevSettings
    └── DevSettingsStorage
        └── AsyncStorage

PrivacySettingsScreen
└── AsyncStorage (direct)

NotificationPreferencesScreen
├── useAuth
│   └── AuthContext
└── NotificationService
    ├── supabase client
    └── AsyncStorage

ProfileSettingsSection
├── AsyncStorage (direct)
└── useToast
```

### External Dependencies

#### Supabase
- **Auth API:** Email/password updates
- **Database API:** Notification preferences, user profiles
- **Tables:**
  - `notification_preferences` - User notification preferences
  - `user_profiles` - User profile metadata
  - `user_subscriptions` - Subscription and trial status
  - `notification_log` - Notification history

#### Storage
- **AsyncStorage:** Local preference persistence
  - Privacy preferences
  - Developer settings
  - Notification toggle states
  - Trial reminder flags

---

## 🔄 Service Interactions

### Notification Preference Update Flow
```
User Toggle Action
    │
    └─> NotificationPreferencesScreen.handleToggle()
        └─> Optimistic UI Update
            └─> NotificationService.updateNotificationPreferences()
                └─> Supabase Update
                    ├─> Success → Keep optimistic update
                    └─> Error → Rollback optimistic update
                        └─> Show error message
```

### Privacy Preference Save Flow
```
User Save Action
    │
    └─> PrivacySettingsScreen.handleSavePreferences()
        └─> Create preferences object
            └─> AsyncStorage.setItem()
                ├─> Success → Show success alert
                └─> Error → Show error alert
```

### Email Update Flow
```
User Update Email Action
    │
    └─> AccountSettingsScreen.handleEmailUpdate()
        └─> Show confirmation dialog
            └─> User confirms
                └─> ProductionBackendService.updateEmail()
                    └─> Supabase Auth Update
                        ├─> Success → Update local state
                        └─> Error → Show error toast
```

### Password Update Flow
```
User Update Password Action
    │
    └─> AccountSettingsScreen.handlePasswordUpdate()
        └─> Validate password strength
            └─> ProductionBackendService.updatePassword()
                └─> Supabase Auth Update
                    ├─> Success → Clear password field
                    └─> Error → Show error toast
```

### Trial Reminder Check Flow
```
App Lifecycle Event
    │
    └─> NotificationService.checkAndSendTrialReminder()
        └─> checkTrialStatus()
            ├─> Not trialing → Return
            └─> Trialing → Continue
                └─> Check if reminder should be sent
                    ├─> Should not send → Return
                    └─> Should send → Continue
                        └─> wasTrialReminderSent()
                            ├─> Already sent → Return
                            └─> Not sent → Continue
                                └─> getNotificationPreferences()
                                    ├─> Disabled → Return
                                    └─> Enabled → Continue
                                        └─> sendTrialReminder()
                                            └─> Log to database
                                                └─> markTrialReminderSent()
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- Storage operations
- Default preference creation
- Trial status calculation
- Reminder duplicate prevention

### Integration Tests
- Supabase API calls
- AsyncStorage operations
- Preference persistence
- Backend synchronization
- Error recovery

### Mocking
- Supabase client
- AsyncStorage
- Network requests
- Auth context

---

## 📊 Service Metrics

### Performance
- **Preference Fetch:** < 500ms
- **Preference Update:** < 1 second
- **Trial Status Check:** < 500ms
- **Storage Operations:** < 100ms

### Reliability
- **Preference Update Success Rate:** > 99%
- **Backend Sync Success Rate:** > 95%
- **Storage Operation Success Rate:** > 99%
- **Trial Reminder Accuracy:** > 98%

### Error Rates
- **Network Errors:** < 1%
- **Storage Errors:** < 0.5%
- **Validation Errors:** < 2%
- **Backend Sync Failures:** < 1%

---

## 🔐 Security Considerations

### Data Storage
- Privacy preferences: AsyncStorage (local only)
- Notification preferences: Supabase (backend sync)
- Developer settings: AsyncStorage (DEV only)
- No sensitive data in logs

### Authentication
- User authentication required for updates
- Session validation before changes
- Secure backend communication (HTTPS)
- Password updates require current password

### Privacy
- Privacy preferences respected
- Consent tracking for compliance
- Data collection opt-out support
- Marketing consent management

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Retry logic for transient failures
- User-friendly error messages
- Error logging for debugging

### Error Types
- **Network Errors:** Connectivity issues
- **Database Errors:** Supabase failures
- **Storage Errors:** AsyncStorage failures
- **Validation Errors:** Invalid input
- **Authentication Errors:** Session expiry

---

## 📝 Service Configuration

### Environment Variables
```typescript
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

### Service Initialization
```typescript
// Services are static/class-based
// No initialization required
// Direct method calls
```

### Storage Keys
```typescript
// Privacy Preferences
awavePrivacyPreferences

// Notification Toggles
@awave_notifications_enabled
@awave_biometric_enabled

// Developer Settings
dev_bypass_paywall

// Trial Reminders
notification_trial_reminder_sent_{userId}
notification_last_trial_check
```

---

## 🔄 Service Updates

### Future Enhancements
- Real-time preference synchronization
- Multi-device preference sync
- Preference change history
- Advanced notification scheduling
- Preference import/export

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
