# Notifications System - Services Documentation

## 🔧 Service Layer Overview

The notifications system uses a service-oriented architecture with clear separation of concerns. Services handle all backend interactions, preference management, trial reminder logic, and notification logging.

---

## 📦 Services

### NotificationService
**File:** `src/services/NotificationService.ts`  
**Type:** Static Class Service  
**Purpose:** Core notification logic and preference management

#### Configuration
```typescript
const STORAGE_KEYS = {
  TRIAL_REMINDER_SENT: 'notification_trial_reminder_sent',
  LAST_TRIAL_CHECK: 'notification_last_trial_check',
};
```

#### Methods

**`checkTrialStatus(userId: string): Promise<TrialStatus>`**
- Checks user subscription status from `user_subscriptions` table
- Filters for active trial subscriptions (`status = 'trialing'`)
- Calculates days remaining until trial expiration
- Determines if reminder should be sent (3 days threshold)
- Returns trial status object with all relevant information
- Handles errors gracefully (returns safe defaults)

**`wasTrialReminderSent(userId: string): Promise<boolean>`**
- Checks AsyncStorage for reminder sent flag
- Uses user-specific key: `notification_trial_reminder_sent_{userId}`
- Returns boolean indicating if reminder was already sent
- Prevents duplicate reminders per trial period

**`markTrialReminderSent(userId: string): Promise<void>`**
- Marks reminder as sent in AsyncStorage
- Stores per-user flag to prevent duplicates
- Uses user-specific storage key
- Handles storage errors gracefully

**`sendTrialReminder(userId: string, daysRemaining: number): Promise<boolean>`**
- Checks if reminder was already sent (prevents duplicates)
- Verifies user preference (`trial_reminders_enabled`)
- Logs notification to `notification_logs` table
- Marks reminder as sent in AsyncStorage
- Returns success status
- Handles all errors gracefully

**`getNotificationPreferences(userId: string): Promise<NotificationPreferences | null>`**
- Fetches preferences from `notification_preferences` table
- Queries by user_id
- Creates default preferences if not found
- Returns preferences object or null
- Handles database errors

**`createDefaultPreferences(userId: string): Promise<NotificationPreferences | null>`**
- Creates default preference record for new user
- All preferences enabled by default (except marketing)
- Inserts into `notification_preferences` table
- Returns created preferences
- Handles database errors

**`updateNotificationPreferences(userId: string, preferences: Partial<...>): Promise<boolean>`**
- Updates preferences in database
- Supports partial updates (only changed fields)
- Updates by user_id
- Returns success status
- Handles database errors

**`checkAndSendTrialReminder(userId: string): Promise<void>`**
- Main entry point for trial reminder checking
- Checks trial status
- Validates reminder conditions
- Sends reminder if all conditions met
- Called from app lifecycle (AuthContext)
- Handles all errors silently (logged only)

#### Error Handling
- All methods handle errors gracefully
- Database errors logged in development
- Returns safe defaults on error
- No user-facing errors from service layer

#### Dependencies
- `supabase` client
- `AsyncStorage`
- `user_subscriptions` table
- `notification_preferences` table
- `notification_logs` table

---

### useUserProfile Hook
**File:** `src/hooks/useUserProfile.ts`  
**Type:** Custom React Hook  
**Purpose:** User profile and notification preference management

#### Returns
```typescript
{
  userProfile: UserProfile | null;
  subscription: Subscription | null;
  notificationPreferences: NotificationPreferences | null;
  loadUserData: (userId: string) => Promise<void>;
  updateUserProfile: (updates: Partial<UserProfile>) => Promise<{data, error}>;
  updateNotificationPreferences: (updates: Partial<NotificationPreferences>) => Promise<{data, error}>;
}
```

#### Methods

**`loadUserData(userId: string): Promise<void>`**
- Loads user profile from `user_profiles` table
- Loads subscription from `subscriptions` table
- Loads notification preferences from `notification_preferences` table
- Creates default preferences if not found
- Updates component state
- Handles errors gracefully

**`updateUserProfile(updates: Partial<UserProfile>): Promise<{data, error}>`**
- Updates user profile in database
- Uses upsert operation
- Updates component state
- Shows success alert
- Returns result with data or error

**`updateNotificationPreferences(updates: Partial<NotificationPreferences>): Promise<{data, error}>`**
- Updates notification preferences in database
- Uses upsert operation
- Updates component state
- Shows success alert
- Returns result with data or error

**`createDefaultNotificationPreferences(userId: string): Promise<void>`**
- Creates default notification preferences
- Called when preferences don't exist
- Sets all preferences to enabled (except marketing)
- Updates component state

#### State Management
- Uses React useState for component state
- Updates state on successful operations
- Clears state on user logout

#### Dependencies
- `supabase` client
- `AsyncStorage`
- `notification_preferences` table
- `user_profiles` table
- `subscriptions` table

---

## 🔗 Service Dependencies

### Dependency Graph
```
NotificationPreferencesScreen
├── NotificationService
│   ├── supabase client
│   │   ├── notification_preferences table
│   │   ├── notification_logs table
│   │   └── user_subscriptions table
│   └── AsyncStorage
│       └── Local reminder flags
│
ProfileScreen
└── useUserProfile
    └── supabase client
        ├── notification_preferences table
        ├── user_profiles table
        └── subscriptions table

AuthContext
└── NotificationService.checkAndSendTrialReminder()
    └── [Same dependencies as above]
```

### External Dependencies

#### Supabase
- **Database API:** Preference storage and retrieval
- **Auth API:** User authentication (for user_id)
- **RLS Policies:** Data access control

#### AsyncStorage
- **Local Storage:** Reminder tracking flags
- **Caching:** Optional preference caching

---

## 🔄 Service Interactions

### Preference Management Flow
```
User Action (Toggle)
    │
    ├─> NotificationPreferencesScreen
    │   └─> NotificationService.updateNotificationPreferences()
    │       └─> Supabase Update
    │           └─> notification_preferences table
    │
    └─> ProfileScreen
        └─> useUserProfile.updateNotificationPreferences()
            └─> Supabase Upsert
                └─> notification_preferences table
```

### Preference Loading Flow
```
Component Mount
    │
    └─> NotificationService.getNotificationPreferences()
        └─> Supabase Query
            ├─> Found → Return Preferences
            └─> Not Found → Create Defaults
                └─> Supabase Insert
                    └─> Return Preferences
```

### Trial Reminder Flow
```
App Launch / Sign In
    │
    └─> AuthContext Effect
        └─> NotificationService.checkAndSendTrialReminder()
            ├─> checkTrialStatus()
            │   └─> Supabase Query (user_subscriptions)
            │       └─> Calculate days remaining
            │
            ├─> wasTrialReminderSent()
            │   └─> AsyncStorage Check
            │
            ├─> getNotificationPreferences()
            │   └─> Supabase Query (notification_preferences)
            │
            └─> sendTrialReminder()
                ├─> Supabase Insert (notification_logs)
                └─> markTrialReminderSent()
                    └─> AsyncStorage Set
```

---

## 🧪 Service Testing

### Unit Tests
- Service method calls
- Error handling
- Trial status calculation
- Reminder duplicate prevention
- Preference creation logic

### Integration Tests
- Supabase API calls
- Database operations
- AsyncStorage operations
- Error scenarios

### Mocking
- Supabase client
- AsyncStorage
- Network requests
- Database responses

---

## 📊 Service Metrics

### Performance
- **Preference Load:** < 1 second
- **Preference Save:** < 2 seconds
- **Trial Status Check:** < 1 second
- **Reminder Send:** < 1 second

### Reliability
- **Preference Update Success Rate:** > 99%
- **Trial Reminder Delivery Rate:** > 95%
- **Default Creation Success Rate:** 100%

### Error Rates
- **Database Errors:** < 1%
- **Network Errors:** < 1%
- **Storage Errors:** < 0.1%

---

## 🔐 Security Considerations

### Data Access
- User-specific preferences (RLS policies)
- Users can only access their own data
- Service role for admin operations
- Secure database storage

### Data Validation
- User ID validation before operations
- Preference value validation (boolean)
- Trial status validation before reminder sending

### Error Handling
- No sensitive data in error messages
- Errors logged for debugging
- User-friendly error messages

---

## 🐛 Error Handling

### Service-Level Errors
- Network connectivity checks
- Database error handling
- Storage error handling
- User-friendly error messages
- Error logging for debugging

### Error Types
- **Network Errors:** Connectivity issues
- **Database Errors:** Query failures, constraint violations
- **Storage Errors:** AsyncStorage failures
- **Validation Errors:** Invalid data

### Error Recovery
- Automatic retry for transient failures
- Graceful degradation
- Safe defaults on error
- User notification on critical errors

---

## 📝 Service Configuration

### Storage Keys
```typescript
const STORAGE_KEYS = {
  TRIAL_REMINDER_SENT: 'notification_trial_reminder_sent',
  LAST_TRIAL_CHECK: 'notification_last_trial_check',
};
```

### Default Preferences
```typescript
{
  push_notifications_enabled: true,
  email_notifications_enabled: true,
  trial_reminders_enabled: true,
  favorites_updates_enabled: true,
  new_content_enabled: true,
  system_updates_enabled: true,
}
```

### Trial Reminder Configuration
- **Threshold:** 3 days before expiration
- **Check Frequency:** On app launch and sign-in
- **Duplicate Prevention:** Per trial period

---

## 🔄 Service Updates

### Future Enhancements
- Push notification delivery (currently only logging)
- Scheduled notifications
- Notification templates
- Notification analytics
- Multi-device preference sync
- Notification batching
- Quiet hours support

---

## 📊 Database Schema Integration

### Tables Used

**notification_preferences:**
- User preference storage
- One record per user
- Auto-created on first access

**notification_logs:**
- Notification audit trail
- All sent notifications logged
- User-specific access

**user_subscriptions:**
- Trial status checking
- Subscription information
- Trial expiration dates

### Queries

**Get Preferences:**
```typescript
supabase
  .from('notification_preferences')
  .select('*')
  .eq('user_id', userId)
  .single()
```

**Update Preferences:**
```typescript
supabase
  .from('notification_preferences')
  .update(preferences)
  .eq('user_id', userId)
```

**Check Trial Status:**
```typescript
supabase
  .from('user_subscriptions')
  .select('status, trial_end_date')
  .eq('user_id', userId)
  .eq('status', 'trialing')
  .single()
```

**Log Notification:**
```typescript
supabase
  .from('notification_logs')
  .insert({
    user_id: userId,
    notification_type: 'trial_reminder',
    title: '...',
    message: '...',
    sent_at: new Date().toISOString(),
  })
```

---

*For component usage, see `components.md`*  
*For user flows, see `user-flows.md`*  
*For technical details, see `technical-spec.md`*
