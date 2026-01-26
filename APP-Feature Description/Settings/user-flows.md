# Settings System - User Flows

## 🔄 Primary User Flows

### 1. Email Update Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Account Settings
   └─> Display AccountSettingsScreen
       └─> Show current email address
           └─> Show email update form

2. Enter New Email
   └─> Real-time email validation
       ├─> Invalid format → Show validation error
       └─> Valid format → Enable update button

3. Click "E-Mail aktualisieren"
   └─> Show confirmation dialog
       ├─> User cancels → Close dialog, stay on screen
       └─> User confirms → Continue
           └─> Show loading state
               └─> Call updateEmail API
                   ├─> Error → Show error toast
                   └─> Success → Continue
                       └─> Update current email display
                           └─> Clear new email field
                               └─> Show success toast
```

**Success Path:**
- Valid email entered
- Confirmation provided
- Email updated successfully
- UI updated with new email

**Error Paths:**
- Invalid email format → Validation error
- Network error → Error toast
- Authentication error → Redirect to login
- Email already in use → Error message

---

### 2. Password Change Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Account Settings
   └─> Display AccountSettingsScreen
       └─> Show password change form

2. Enter New Password
   └─> Real-time password validation
       ├─> Weak password (< 10 chars) → Show validation error
       └─> Valid password (≥ 10 chars) → Enable update button

3. Toggle Password Visibility (optional)
   └─> Toggle secureTextEntry
       └─> Update eye icon

4. Click "Passwort aktualisieren"
   └─> Validate password strength
       ├─> Invalid → Show validation error
       └─> Valid → Continue
           └─> Show loading state
               └─> Call updatePassword API
                   ├─> Error → Show error toast
                   └─> Success → Continue
                       └─> Clear password field
                           └─> Show success toast
```

**Success Path:**
- Valid password entered (≥ 10 characters)
- Password updated successfully
- Field cleared
- Success feedback shown

**Error Paths:**
- Weak password → Validation error
- Network error → Error toast
- Authentication error → Redirect to login
- Password update failure → Error message

---

### 3. Privacy Preferences Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Privacy Settings
   └─> Display PrivacySettingsScreen
       └─> Load preferences from AsyncStorage
           ├─> No preferences → Use defaults (all enabled)
           └─> Preferences exist → Load saved values
               └─> Display checkboxes with current state

2. Toggle Consent Checkboxes
   └─> Update local state
       └─> Visual feedback (checkbox checked/unchecked)

3. Click "Einstellungen speichern"
   └─> Validate all preferences
       └─> Create preferences object
           └─> Save to AsyncStorage
               ├─> Error → Show error alert
               └─> Success → Continue
                   └─> Update lastUpdated timestamp
                       └─> Show success alert
```

**Success Path:**
- Preferences toggled
- Save button clicked
- Preferences saved to AsyncStorage
- Success confirmation shown

**Error Paths:**
- Storage error → Error alert
- Invalid data → Validation error
- Network error (if sync needed) → Error message

---

### 4. Notification Preferences Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Notification Preferences
   └─> Display NotificationPreferencesScreen
       └─> Show loading state
           └─> Check user authentication
               ├─> Not authenticated → Show empty state
               └─> Authenticated → Continue
                   └─> Load preferences from backend
                       ├─> No preferences → Create defaults
                       └─> Preferences exist → Display toggles
                           └─> Update UI with current state

2. Toggle Notification Preference
   └─> Optimistic UI update (toggle immediately)
       └─> Call updateNotificationPreferences API
           ├─> Error → Rollback toggle, show error alert
           └─> Success → Keep toggle state
               └─> Backend synchronized
```

**Success Path:**
- Preference toggled
- Optimistic update applied
- Backend sync successful
- State persisted

**Error Paths:**
- Network error → Rollback, show error
- Authentication error → Redirect to login
- Backend sync failure → Rollback, show error

---

### 5. Biometric Login Toggle Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Account Settings
   └─> Display AccountSettingsScreen
       └─> Load biometric state from storage
           └─> Display toggle with current state

2. Toggle Biometric Login
   └─> Update local state
       └─> Check platform support
           ├─> Not supported → Show error
           └─> Supported → Continue
               ├─> Enabling → Show native biometric prompt
               │   ├─> User cancels → Revert toggle
               │   └─> User approves → Continue
               │       └─> Save to AsyncStorage
               │           └─> Show success toast
               └─> Disabling → Save to AsyncStorage
                   └─> Show success toast
```

**Success Path:**
- Toggle changed
- Native prompt approved (if enabling)
- State saved to storage
- Success feedback shown

**Error Paths:**
- Platform not supported → Error message
- User cancels prompt → Toggle reverted
- Storage error → Error message

---

### 6. Developer Settings Flow (DEV Mode Only)

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Navigate to Account Settings (DEV mode)
   └─> Display AccountSettingsScreen
       └─> Check __DEV__ flag
           ├─> Production → Hide developer section
           └─> DEV mode → Show developer section
               └─> Load paywall bypass state
                   └─> Display toggle

2. Toggle Paywall Bypass
   └─> Update local state
       └─> Save to AsyncStorage
           ├─> Error → Show error
           └─> Success → Continue
               └─> Paywall bypass enabled/disabled
                   └─> App behavior updated
```

**Success Path:**
- Toggle changed
- State saved
- Feature enabled/disabled
- App behavior updated

**Error Paths:**
- Storage error → Error message
- Not in DEV mode → Feature hidden

---

## 🔀 Alternative Flows

### Privacy Preferences Reset Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Clear Privacy Preferences
   └─> Remove from AsyncStorage
       └─> Reload screen
           └─> Display default preferences (all enabled)
```

**Use Cases:**
- User wants to reset privacy settings
- App reinstall scenario
- Data migration

---

### Notification Preferences Default Creation Flow

```
System Event                   System Response
─────────────────────────────────────────────────────────
1. User First Opens Notification Preferences
   └─> Check if preferences exist
       ├─> Exist → Load and display
       └─> Don't exist → Continue
           └─> Create default preferences
               └─> All preferences enabled (true)
                   └─> Save to backend
                       └─> Display with defaults
```

**Automatic Behavior:**
- Runs on first access
- No user interaction required
- All preferences default to enabled

---

### Concurrent Preference Update Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. User Toggles Preference
   └─> Optimistic update applied
       └─> Backend sync started

2. User Toggles Another Preference (before sync completes)
   └─> Optimistic update applied
       └─> Backend sync started
           └─> Previous sync cancelled/overwritten
               └─> Latest state synced
```

**Behavior:**
- Last write wins
- Optimistic updates prevent UI blocking
- Backend sync handles concurrent updates

---

## 🚨 Error Flows

### Network Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Preference Update
   └─> Network request fails
       └─> Detect network error
           └─> Show user-friendly error message
               └─> Offer retry option
                   └─> User can retry or cancel
```

**Error Messages:**
- "Keine Internetverbindung"
- "Einstellung konnte nicht gespeichert werden"
- Retry button available

---

### Authentication Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Attempt Settings Update
   └─> Session expired
       └─> Detect authentication error
           └─> Clear session
               └─> Navigate to Auth screen
                   └─> Show session expired message
```

**User Experience:**
- Seamless redirect to login
- Clear error message
- Preferences preserved (if possible)

---

### Validation Error Flow

```
User Action                    System Response
─────────────────────────────────────────────────────────
1. Enter Invalid Email
   └─> Real-time validation
       └─> Show validation error
           └─> Disable update button
               └─> User corrects email
                   └─> Validation passes
                       └─> Enable update button

2. Enter Weak Password
   └─> Real-time validation
       └─> Show validation error
           └─> Disable update button
               └─> User strengthens password
                   └─> Validation passes
                       └─> Enable update button
```

**User Actions:**
- Correct invalid input
- See real-time feedback
- Retry with valid input

---

## 🔄 State Transitions

### Email Update States

```
No Input → Entering Email → Valid Email → Confirming → Updating → Success
    │            │              │            │           │
    │            │              │            │           └─> Error
    │            │              │            │
    │            │              │            └─> Cancelled
    │            │              │
    │            │              └─> Invalid Email
    │            │
    │            └─> Invalid Format
    │
    └─> Empty
```

### Password Update States

```
No Input → Entering Password → Valid Password → Updating → Success
    │            │                  │              │
    │            │                  │              └─> Error
    │            │                  │
    │            │                  └─> Weak Password
    │            │
    │            └─> Weak Password
    │
    └─> Empty
```

### Privacy Preference States

```
Loading → Loaded → Toggling → Saving → Saved
    │        │          │         │
    │        │          │         └─> Error
    │        │          │
    │        │          └─> Cancelled
    │        │
    │        └─> Error Loading
    │
    └─> Error
```

### Notification Preference States

```
Loading → Loaded → Toggling → Syncing → Synced
    │        │          │          │
    │        │          │          └─> Error (Rollback)
    │        │          │
    │        │          └─> Optimistic Update
    │        │
    │        └─> Error Loading
    │
    └─> Error
```

---

## 📊 Flow Diagrams

### Complete Settings Navigation Flow

```
Profile Screen
    │
    ├─> ProfileAccountSection
    │   ├─> Navigate to Account Settings
    │   │   └─> AccountSettingsScreen
    │   │       ├─> Update Email
    │   │       ├─> Change Password
    │   │       ├─> Toggle Biometric
    │   │       └─> Toggle Push Notifications
    │   │
    │   ├─> Navigate to Privacy Settings
    │   │   └─> PrivacySettingsScreen
    │   │       ├─> Toggle Health Data Consent
    │   │       ├─> Toggle Analytics Consent
    │   │       ├─> Toggle Marketing Consent
    │   │       └─> Save Preferences
    │   │
    │   └─> Navigate to Legal
    │       └─> Legal Screen
    │
    └─> ProfileSettingsSection
        ├─> Toggle Notifications
        └─> Toggle HealthKit
            └─> Navigate to Notification Preferences
                └─> NotificationPreferencesScreen
                    ├─> Toggle Push Notifications
                    ├─> Toggle Email Notifications
                    ├─> Toggle Trial Reminders
                    ├─> Toggle Favorites Updates
                    ├─> Toggle New Content
                    └─> Toggle System Updates
```

---

### Email Update Complete Journey

```
Profile Screen
    │
    └─> Account Settings
        └─> Account Information Section
            └─> Enter New Email
                └─> Real-time Validation
                    ├─> Invalid → Show Error
                    └─> Valid → Enable Update Button
                        └─> Click Update
                            └─> Confirmation Dialog
                                ├─> Cancel → Stay on Screen
                                └─> Confirm → Update Email
                                    ├─> Error → Show Error Toast
                                    └─> Success → Update UI, Show Success Toast
```

---

### Privacy Preferences Complete Journey

```
Profile Screen
    │
    └─> Privacy Settings
        └─> Review Privacy Options
            ├─> Data Collection Section
            │   ├─> Toggle Health Data Consent
            │   └─> Toggle Analytics Consent
            │
            └─> Marketing Settings Section
                └─> Toggle Marketing Consent
                    └─> Click Save
                        ├─> Error → Show Error Alert
                        └─> Success → Show Success Alert
                            └─> Preferences Saved
```

---

### Notification Preferences Complete Journey

```
Profile Screen
    │
    └─> Notification Preferences
        └─> Loading State
            └─> Preferences Loaded
                ├─> General Settings
                │   ├─> Toggle Push Notifications
                │   │   └─> Auto-save → Backend Sync
                │   └─> Toggle Email Notifications
                │       └─> Auto-save → Backend Sync
                │
                └─> Content Notifications
                    ├─> Toggle Trial Reminders
                    │   └─> Auto-save → Backend Sync
                    ├─> Toggle Favorites Updates
                    │   └─> Auto-save → Backend Sync
                    ├─> Toggle New Content
                    │   └─> Auto-save → Backend Sync
                    └─> Toggle System Updates
                        └─> Auto-save → Backend Sync
```

---

## 🎯 User Goals

### Goal: Update Account Information
- **Path:** Profile → Account Settings → Update Email/Password
- **Time:** ~30 seconds
- **Steps:** Navigate → Enter → Validate → Confirm → Update

### Goal: Manage Privacy
- **Path:** Profile → Privacy Settings → Toggle Consents → Save
- **Time:** ~1 minute
- **Steps:** Navigate → Review → Toggle → Save

### Goal: Customize Notifications
- **Path:** Profile → Notification Preferences → Toggle Preferences
- **Time:** ~1 minute
- **Steps:** Navigate → Toggle → Auto-save

### Goal: Enable Biometric Login
- **Path:** Profile → Account Settings → Toggle Biometric
- **Time:** ~10 seconds
- **Steps:** Navigate → Toggle → Approve Prompt

---

*For component interactions, see `components.md`*  
*For service calls, see `services.md`*  
*For technical details, see `technical-spec.md`*
