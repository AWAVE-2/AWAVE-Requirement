# Notifications System - User Flows

## 🔄 Primary User Flows

### 1. View Notification Preferences Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Profile Screen
   └─> Display Profile Screen
       └─> Show notification toggle (if available)

2. Navigate to Notification Preferences
   └─> Navigate to NotificationPreferencesScreen
       └─> Check user authentication
           ├─> Not authenticated → Show empty state
           └─> Authenticated → Continue
               └─> Show loading state
                   └─> Load preferences from database
                       ├─> Error → Show error state
                       └─> Success → Continue
                           ├─> No preferences → Create defaults
                           └─> Preferences found → Display
                               └─> Show all preference categories
                                   ├─> General Settings
                                   │   ├─> Push notifications
                                   │   └─> Email notifications
                                   └─> Content Notifications
                                       ├─> Trial reminders
                                       ├─> Favorites updates
                                       ├─> New content
                                       └─> System updates
```

**Success Path:**
- User views all notification preferences
- Preferences loaded from database
- All categories displayed with current state

**Error Paths:**
- Not authenticated → Empty state message
- Network error → Error message with retry
- Database error → Error message

---

### 2. Update Notification Preference Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. View Notification Preferences
   └─> Preferences displayed

2. Toggle a Preference Switch
   └─> Optimistic UI update
       └─> Switch state changes immediately
           └─> Call updateNotificationPreferences()
               └─> Show saving state (optional)
                   └─> Supabase update request
                       ├─> Error → Revert UI change
                       │   └─> Show error message
                       └─> Success → Confirm change
                           └─> Update local state
                               └─> Show success feedback (optional)
```

**Success Path:**
- Toggle switch
- Immediate UI update (optimistic)
- Save to database
- Change persisted

**Error Paths:**
- Network error → Revert change, show error
- Database error → Revert change, show error
- Invalid data → Revert change, show validation error

---

### 3. Quick Toggle from Profile Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Profile Screen
   └─> Display Profile Screen
       └─> Load user profile data
           └─> Load notification preferences
               └─> Sync notification state
                   └─> Display notification toggle

2. Toggle Notification Switch
   └─> Update local state
       └─> Call updateNotificationPreferences()
           └─> Supabase upsert request
               ├─> Error → Show error alert
               └─> Success → Update state
                   └─> Show success alert
```

**Success Path:**
- Quick toggle from profile
- Immediate save
- Success confirmation

**Error Paths:**
- Save error → Error alert
- Network error → Error alert

---

### 4. Trial Reminder Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. App Launch / User Sign In
   └─> AuthContext initializes
       └─> User authenticated
           └─> Wait 2 seconds (delay)
               └─> Call checkAndSendTrialReminder()
                   └─> Check trial status
                       ├─> No trial → Exit
                       └─> Active trial → Continue
                           └─> Calculate days remaining
                               ├─> > 3 days → Exit
                               └─> ≤ 3 days → Continue
                                   └─> Check if reminder sent
                                       ├─> Already sent → Exit
                                       └─> Not sent → Continue
                                           └─> Get notification preferences
                                               ├─> Trial reminders disabled → Exit
                                               └─> Trial reminders enabled → Continue
                                                   └─> Send trial reminder
                                                       └─> Log to notification_logs
                                                           └─> Mark as sent in AsyncStorage
                                                               └─> Reminder sent successfully
```

**Success Path:**
- Trial expires in 3 days
- Reminder not yet sent
- User has reminders enabled
- Reminder logged and sent

**Skip Conditions:**
- No active trial
- Trial expires in > 3 days
- Reminder already sent
- User disabled trial reminders

---

### 5. Default Preference Creation Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. User Accesses Preferences
   └─> Load preferences from database
       └─> Query notification_preferences table
           ├─> Preferences found → Return preferences
           └─> No preferences found → Continue
               └─> Create default preferences
                   └─> Insert into database
                       ├─> Error → Return null, log error
                       └─> Success → Return preferences
                           └─> Display preferences
```

**Success Path:**
- New user accesses preferences
- Defaults created automatically
- Preferences displayed

**Error Paths:**
- Database error → Error state, log error
- Insert failure → Error state, allow retry

---

## 🔀 Alternative Flows

### Preference Sync Flow

```
App Launch
    │
    └─> User Authenticated
        └─> Load User Profile
            └─> Load Notification Preferences
                ├─> Found → Sync to UI
                └─> Not Found → Create Defaults
                    └─> Sync to UI
```

**Use Cases:**
- App restart
- User sign-in
- Profile screen load

---

### Error Recovery Flow

```
Preference Update Error
    │
    ├─> Network Error
    │   └─> Revert UI Change
    │       └─> Show Error Message
    │           └─> User Can Retry
    │
    ├─> Database Error
    │   └─> Revert UI Change
    │       └─> Show Error Message
    │           └─> Log Error
    │               └─> User Can Retry
    │
    └─> Validation Error
        └─> Revert UI Change
            └─> Show Validation Error
                └─> User Can Correct
```

**Recovery Options:**
- Retry operation
- Check network connection
- Contact support (if persistent)

---

### Trial Reminder Duplicate Prevention Flow

```
Trial Reminder Check
    │
    └─> Check AsyncStorage
        ├─> Reminder Sent Flag Exists
        │   └─> Skip Reminder
        │       └─> Exit
        │
        └─> No Flag
            └─> Check Trial Status
                └─> Send Reminder
                    └─> Mark as Sent
                        └─> Store Flag in AsyncStorage
```

**Prevention Mechanism:**
- Per-user storage key
- Flag persists across app restarts
- Prevents duplicate reminders per trial period

---

## 🚨 Error Flows

### Network Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Preference Update
   └─> Network request fails
       └─> Detect network error
           └─> Revert optimistic update
               └─> Show error message
                   └─> "Einstellung konnte nicht gespeichert werden."
                       └─> User can retry
```

**Error Messages:**
- "Einstellung konnte nicht gespeichert werden."
- "Benachrichtigungseinstellungen konnten nicht geladen werden."
- "Bitte überprüfe deine Internetverbindung."

---

### Database Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Preference Load
   └─> Database query fails
       └─> Detect database error
           └─> Log error (dev mode)
               └─> Show error state
                   └─> User can retry
```

**Error Handling:**
- Errors logged in development
- User-friendly error messages
- Retry capability
- Graceful degradation

---

### Missing Preferences Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Load Preferences
   └─> Query database
       └─> No preferences found
           └─> Create default preferences
               ├─> Success → Display defaults
               └─> Error → Show error state
                   └─> Allow retry
```

**Default Creation:**
- Automatic on first access
- All preferences enabled (except marketing)
- Transparent to user

---

## 🔄 State Transitions

### Preference Loading States

```
Initial → Loading → Loaded
    │        │         │
    │        │         └─> Error → Retry
    │        │
    │        └─> Error → Retry
    │
    └─> Empty (Not Authenticated)
```

### Preference Update States

```
Idle → Toggling → Saving → Saved
  │        │         │        │
  │        │         │        └─> Error → Revert
  │        │         │
  │        │         └─> Error → Revert
  │        │
  │        └─> Optimistic Update
  │
  └─> Error → Retry
```

### Trial Reminder States

```
Not Checked → Checking → Checked
      │          │          │
      │          │          ├─> Reminder Sent
      │          │          │
      │          │          └─> Reminder Skipped
      │          │
      │          └─> Error → Logged
      │
      └─> No Trial → Exit
```

---

## 📊 Flow Diagrams

### Complete Preference Management Journey

```
Profile Screen
    │
    ├─> Quick Toggle
    │   └─> Update Preference
    │       └─> Save to Database
    │           └─> Success
    │
    └─> Navigate to Notification Preferences
        └─> NotificationPreferencesScreen
            ├─> View All Preferences
            ├─> Toggle Any Preference
            │   └─> Save to Database
            │       └─> Success
            └─> Navigate Back
```

### Trial Reminder Journey

```
App Launch
    │
    └─> User Authenticated
        └─> AuthContext Effect (2s delay)
            └─> checkAndSendTrialReminder()
                ├─> Check Trial Status
                │   └─> Active Trial?
                │       └─> Days Remaining ≤ 3?
                │           └─> Reminder Already Sent?
                │               └─> User Preferences Enabled?
                │                   └─> Send Reminder
                │                       └─> Log to Database
                │                           └─> Mark as Sent
                │
                └─> Exit (if any condition fails)
```

### New User Preference Setup

```
New User Sign Up
    │
    └─> User Profile Created
        │
        └─> User Accesses Preferences (First Time)
            └─> Load Preferences
                └─> No Preferences Found
                    └─> Create Default Preferences
                        └─> Insert into Database
                            └─> Display Default Preferences
                                └─> User Can Customize
```

---

## 🎯 User Goals

### Goal: Customize Notifications
- **Path:** Profile → Notification Preferences → Toggle preferences
- **Time:** < 30 seconds
- **Steps:** 3-4 taps

### Goal: Quick Toggle Push Notifications
- **Path:** Profile → Toggle switch
- **Time:** < 5 seconds
- **Steps:** 1 tap

### Goal: Receive Trial Reminder
- **Path:** Automatic (on app launch/sign-in)
- **Time:** Transparent to user
- **Steps:** Automatic

---

## 🔄 Integration Flows

### Authentication Integration

```
User Sign In
    │
    └─> AuthContext Updates
        └─> User ID Available
            └─> Trial Reminder Check (2s delay)
                └─> checkAndSendTrialReminder()
```

### Profile Integration

```
Profile Screen Load
    │
    └─> useUserProfile Hook
        └─> Load User Data
            └─> Load Notification Preferences
                └─> Sync to UI
                    └─> Display Toggle
```

### Subscription Integration

```
Trial Reminder Check
    │
    └─> Query user_subscriptions
        └─> Filter: status = 'trialing'
            └─> Get trial_end_date
                └─> Calculate days remaining
                    └─> Determine if reminder needed
```

---

## 📱 Screen Navigation Flow

```
Main App
    │
    ├─> Profile Screen
    │   ├─> Quick Notification Toggle
    │   └─> Navigate to Account Settings
    │       └─> Navigate to Notification Preferences
    │
    └─> Account Settings Screen
        ├─> Quick Push Notification Toggle
        └─> Navigate to Notification Preferences
            └─> NotificationPreferencesScreen
                └─> Manage All Preferences
```

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
